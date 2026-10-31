import XCTest
import ImageIO
@testable import RewardAutomationCore

final class EventEndTests:XCTestCase {
    private var root:URL {URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()}
    private func load(_ path:String)throws->CGImage {
        let source=try XCTUnwrap(CGImageSourceCreateWithURL(root.appendingPathComponent(path) as CFURL,nil))
        return try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
    }
    private func fixture(_ name:String)throws->CGImage {try load("docs/references/2026-10-31/event-end/\(name).png")}
    private func o(_ screen:EventEndScreen)->EventEndObservation {.init(screen:screen)}
    func testRealUserScreensAndOverlayPriorityOverMisleadingHUDColours()throws {
        let vision=EventEndVision()
        for (name,expected) in [("offer-user",EventEndScreen.offer),("summary-user",.summary)] {
            let image=try fixture(name),free=try RewardVision().observe(image)
            let actual=try vision.observe(image,hudVisible:free.gameHUDVisible)
            XCTAssertEqual(actual.screen,expected,"\(name): \(actual.texts)")
            XCTAssertEqual(try vision.observe(image,hudVisible:true).screen,expected)
            XCTAssertNil(free.reward,"Event overlay is not a Free reward")
            let action:EventEndAction=expected == .offer ? .decline:.proceed
            XCTAssertTrue(action.permits(actual))
            XCTAssertTrue(CGRect(x:0.315,y:0.898,width:0.37,height:0.049).contains(action.point))
            XCTAssertGreaterThan(action.point.y,0.89,"Never click the green paid offer row")
        }
    }
    func testEveryExistingFreeAndCrystalScreenshotIsNotAnEventTarget()throws {
        struct Corpus:Decodable {struct Sample:Decodable {let image:String};let samples:[Sample]}
        let corpus=try JSONDecoder().decode(Corpus.self,from:Data(contentsOf:root.appendingPathComponent("tests/reward-reading-corpus.json")))
        let directory=root.appendingPathComponent("docs/references/2026-10-31/crystals")
        let crystals=try FileManager.default.contentsOfDirectory(atPath:directory.path).filter{$0.hasSuffix(".png")}
            .map{"docs/references/2026-10-31/crystals/"+$0}
        let vision=EventEndVision()
        for path in corpus.samples.map(\.image)+crystals {
            let image=try load(path),hud=try RewardVision().observe(image).gameHUDVisible
            let actual=try vision.observe(image,hudVisible:hud)
            XCTAssertFalse(EventEndAction.decline.permits(actual),"\(path): \(actual.texts)")
            XCTAssertFalse(EventEndAction.proceed.permits(actual),"\(path): \(actual.texts)")
        }
    }
    func testRealScreensReplayDeclineThenContinueAndTwoHUDFrames()throws {
        let vision=EventEndVision()
        var flow=EventEndFlow(),actions:[EventEndAction]=[]
        for (i,name) in ["offer-user","offer-user","summary-user"].enumerated() {
            let image=try fixture(name)
            let actual=try vision.observe(image,hudVisible:RewardVision().observe(image).gameHUDVisible)
            if let action=flow.observe(actual,now:Double(i*2),inputReady:true) {
                actions.append(action);flow.sent(action,now:Double(i*2))
            }
        }
        XCTAssertEqual(actions,[.decline,.proceed]);XCTAssertEqual(flow.completed,0)
        _=flow.observe(o(.hud),now:6,inputReady:true)
        XCTAssertTrue(flow.active);XCTAssertEqual(flow.completed,0)
        _=flow.observe(o(.hud),now:7,inputReady:true)
        XCTAssertFalse(flow.active);XCTAssertEqual(flow.completed,1)
        _=flow.observe(o(.hud),now:8,inputReady:true)
        XCTAssertEqual(flow.completed,1)
    }
    func testSummaryAloneCanResumeAfterHumanDeclinedOffer() {
        var flow=EventEndFlow()
        XCTAssertNil(flow.observe(o(.summary),now:0,inputReady:true))
        XCTAssertEqual(flow.observe(o(.summary),now:1,inputReady:true),.proceed)
        flow.sent(.proceed,now:1)
        _=flow.observe(o(.hud),now:3,inputReady:true)
        _=flow.observe(o(.hud),now:4,inputReady:true)
        XCTAssertEqual(flow.completed,1);XCTAssertFalse(flow.active)
    }
    func testHumanMouseWaitManualAdvanceAndManualReturnDoNotDeadlock() {
        var flow=EventEndFlow()
        _=flow.observe(o(.offer),now:0,inputReady:true)
        XCTAssertNil(flow.observe(o(.offer),now:1,inputReady:false))
        XCTAssertEqual(flow.observe(o(.offer),now:2,inputReady:true),.decline)
        // Offered action wasn't sent; human manually advanced to the summary.
        XCTAssertEqual(flow.observe(o(.summary),now:3,inputReady:true),.proceed)
        XCTAssertNil(flow.observe(o(.summary),now:4,inputReady:false))
        // A manual Continue must release collection, not invent an auto click.
        _=flow.observe(o(.hud),now:5,inputReady:true)
        _=flow.observe(o(.hud),now:6,inputReady:true)
        XCTAssertFalse(flow.active);XCTAssertEqual(flow.completed,0)
    }
    func testRetriesWaitOneSecondAndStopAtThreeSentAttempts() {
        var flow=EventEndFlow()
        _=flow.observe(o(.offer),now:0,inputReady:true)
        for t in [1.0,3.0,5.0] {
            XCTAssertEqual(flow.observe(o(.offer),now:t,inputReady:true),.decline)
            flow.sent(.decline,now:t)
            XCTAssertNil(flow.observe(o(.offer),now:t+0.5,inputReady:true))
        }
        XCTAssertNil(flow.observe(o(.offer),now:7,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked)
    }
    func testUnknownScreensAndTimeoutNeverAuthorizeBlindInput() {
        var flow=EventEndFlow()
        _=flow.observe(o(.summary),now:0,inputReady:true)
        _=flow.observe(o(.summary),now:1,inputReady:true)
        XCTAssertNil(flow.observe(o(.unknown),now:5,inputReady:true))
        XCTAssertNil(flow.observe(o(.unknown),now:62,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked)
        XCTAssertFalse(EventEndAction.decline.permits(o(.summary)))
        XCTAssertFalse(EventEndAction.proceed.permits(o(.offer)))
        for screen in [EventEndScreen.unknown,.hud] {
            XCTAssertFalse(EventEndAction.decline.permits(o(screen)))
            XCTAssertFalse(EventEndAction.proceed.permits(o(screen)))
        }
    }
    func testInterruptedFreeVerificationCannotBecomeAnEventReward() {
        // This is the same priority predicate used by the live integration to
        // discard pending Free verification, before its misleading HUD can count.
        for screen in [EventEndScreen.offer,.summary] {
            XCTAssertTrue(EventEndInputPolicy.reservesInput(screen:screen,active:false,wasActive:false))
        }
        XCTAssertTrue(EventEndInputPolicy.reservesInput(screen:.unknown,active:true,wasActive:false))
        XCTAssertTrue(EventEndInputPolicy.reservesInput(screen:.hud,active:false,wasActive:true))
        XCTAssertFalse(EventEndInputPolicy.reservesInput(screen:.hud,active:false,wasActive:false))
        var event=EventEndFlow()
        _=event.observe(o(.summary),now:0,inputReady:true)
        _=event.observe(o(.summary),now:1,inputReady:true);event.sent(.proceed,now:1)
        _=event.observe(o(.hud),now:3,inputReady:true)
        _=event.observe(o(.hud),now:4,inputReady:true)
        XCTAssertEqual(event.completed,1)
        XCTAssertFalse(EventEndInputPolicy.reservesInput(screen:.hud,active:event.active,wasActive:false))
    }
    func testPreclickRejectsCancellationChangedWindowAndStaleOrFutureFrames() {
        for action in [EventEndAction.decline,.proceed] {
            let current=o(action.expectedScreen)
            XCTAssertTrue(action.permits(current,sameWindow:true,cancelled:false,elapsed:0.7))
            XCTAssertFalse(action.permits(current,sameWindow:false))
            XCTAssertFalse(action.permits(current,cancelled:true))
            for elapsed in [-0.1,3.01] {XCTAssertFalse(action.permits(current,elapsed:elapsed))}
        }
    }
    func testSyntheticHeaderOcclusionCannotBecomeHUDOrAuthorizeButton()throws {
        for name in ["offer-user","summary-user"] {
            let image=try fixture(name)
            let context=try XCTUnwrap(CGContext(data:nil,width:image.width,height:image.height,
                bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),
                bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue))
            context.draw(image,in:CGRect(x:0,y:0,width:image.width,height:image.height))
            context.setFillColor(CGColor(gray:0,alpha:1))
            // Quartz drawing coordinates are bottom-up; mask the screenshot's
            // TOP 10–22%, leaving the bottom action button intact.
            context.fill(CGRect(x:0,y:Double(image.height)*(1-0.22),width:Double(image.width),height:Double(image.height)*0.12))
            let occluded=try XCTUnwrap(context.makeImage())
            let actual=try EventEndVision().observe(occluded,hudVisible:true)
            XCTAssertEqual(actual.screen,.unknown,"Synthetic header mask: \(name), \(actual.texts)")
            XCTAssertFalse(EventEndAction.decline.permits(actual))
            XCTAssertFalse(EventEndAction.proceed.permits(actual))
        }
    }
}
