import XCTest
import ImageIO
@testable import RewardAutomationCore

final class CrystalTests:XCTestCase {
    private let hud=CrystalObservation(screen:.hud,notification:true)
    private func observation(_ screen:CrystalScreen)->CrystalObservation {.init(screen:screen)}
    private var root:URL {URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()}
    private func image(_ name:String)throws->CGImage {
        let source=try XCTUnwrap(CGImageSourceCreateWithURL(root.appendingPathComponent("docs/references/2026-10-31/crystals/\(name).png") as CFURL,nil))
        return try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
    }
    func testReviewedSmallNotificationAndSeparateHeldOutClaims()throws {
        for name in ["hud-notification-small-development","hud-notification-small-pulse-development",
                     "hud-notification-small-phase-development-a","hud-notification-small-phase-development-b",
                     "hud-notification-small-heldout-b","hud-notification-small-heldout-e","hud-notification-small-heldout-f"] {
            let png=try image(name),hudVisible=try RewardVision().observe(png).gameHUDVisible
            XCTAssertTrue(hudVisible,name)
            let actual=try CrystalVision().observe(png,hudVisible:hudVisible)
            XCTAssertTrue(actual.notification,"\(name): \(actual.texts)")
            XCTAssertTrue(CrystalAction.openInventory.permits(actual),name)
            var flow=CrystalFlow()
            XCTAssertNil(flow.observe(actual,now:0,inputReady:true),"One frame is insufficient")
            XCTAssertNil(flow.observe(actual,now:1,inputReady:false),"Held mouse still blocks")
            XCTAssertNil(flow.observe(actual,now:2,inputReady:true,mayStart:false),"Pending Free still blocks")
            XCTAssertEqual(flow.observe(actual,now:3,inputReady:true),.openInventory)
        }
    }
    func testSmallAntialiasedRingStillRequiresBrightAnchorsDarkOutlineAndDenseRedCore()throws {
        let png=try image("hud-notification-small-development"),p=try Pixels(png)
        for mode in ["no-bright-anchors","one-sided-bright-anchors","broken-neutral-ring","no-dark-outline","hollow-red-core"] {
            var data=p.data
            for y in 417...439 {for x in 613...635 {
                let i=(y*p.w+x)*4,r=Int(p.data[i]),g=Int(p.data[i+1]),b=Int(p.data[i+2])
                let distance=hypot(Double(x)-624,Double(y)-428)
                var replacement:[UInt8]?
                if (mode=="no-bright-anchors" || (mode=="one-sided-bright-anchors" && (x>=624 || y>=428))),distance>=4,distance<=9,
                   min(r,min(g,b))>205,max(r,max(g,b))-min(r,min(g,b))<45 {replacement=[180,180,180]}
                if mode=="broken-neutral-ring",distance>=4,distance<=9,
                   min(r,min(g,b))>150,min(r,min(g,b))<=205,max(r,max(g,b))-min(r,min(g,b))<45 {replacement=[50,150,70]}
                if mode=="no-dark-outline",distance>=7,distance<=11,max(r,max(g,b))<105 {replacement=[50,150,70]}
                if mode=="hollow-red-core",abs(x-624)<=1,abs(y-428)<=1 {replacement=[60,60,60]}
                if let replacement {for n in 0..<3 {data[i+n]=replacement[n]}}
            }}
            let provider=try XCTUnwrap(CGDataProvider(data:Data(data) as CFData))
            let altered=try XCTUnwrap(CGImage(width:p.w,height:p.h,bitsPerComponent:8,bitsPerPixel:32,
                bytesPerRow:p.w*4,space:CGColorSpaceCreateDeviceRGB(),
                bitmapInfo:.init(rawValue:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue),
                provider:provider,decode:nil,shouldInterpolate:false,intent:.defaultIntent))
            XCTAssertNil(CrystalNotificationMatcher.match(try Pixels(altered)),mode)
        }
    }
    func testSmallRingChangeKeepsAllReviewedNoNotificationScreensNegative()throws {
        for name in ["hud-no-dot-confetti-user","hud-no-dot-external-after","hud-without-notification-live"] {
            let png=try image(name)
            XCTAssertNil(CrystalNotificationMatcher.match(try Pixels(png)),name)
            let actual=try CrystalVision().observe(png,hudVisible:true)
            XCTAssertFalse(actual.notification,name)
        }
        let confetti=try image("hud-no-dot-confetti-user")
        for width in [637,788] {
            let height=Int((Double(confetti.height)*Double(width)/Double(confetti.width)).rounded())
            for quality in [CGInterpolationQuality.none,.high] {
                let context=try XCTUnwrap(CGContext(data:nil,width:width,height:height,bitsPerComponent:8,bytesPerRow:0,
                    space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue))
                context.interpolationQuality=quality
                context.draw(confetti,in:.init(x:0,y:0,width:width,height:height))
                let scaled=try XCTUnwrap(context.makeImage())
                XCTAssertNil(CrystalNotificationMatcher.match(try Pixels(scaled)),"Scaled confetti width=\(width), interpolation=\(quality)")
            }
        }
    }
    func testSmallInventoryHeaderRequiresExactTextWithBoundedVerticalAlignment()throws {
        let png=try image("inventory-ready-small-live"),vision=CrystalVision()
        let actual=try vision.observe(png,hudVisible:false)
        XCTAssertEqual(actual.screen,.inventoryReady,actual.texts.joined(separator:";"))
        XCTAssertTrue(actual.texts.contains("CRYSTALS"))
        let point=CrystalAction.openOne.point(in:actual)
        XCTAssertTrue(CGRect(x:249,y:498,width:129,height:41).contains(.init(x:point.x*637,y:point.y*882)))
        let p=try Pixels(png);var data=p.data
        for y in 539..<568 {for x in 230..<411 {let i=(y*p.w+x)*4
            data[i]=100;data[i+1]=80;data[i+2]=70
        }}
        let provider=try XCTUnwrap(CGDataProvider(data:Data(data) as CFData))
        let missing=try XCTUnwrap(CGImage(width:p.w,height:p.h,bitsPerComponent:8,bitsPerPixel:32,
            bytesPerRow:p.w*4,space:CGColorSpaceCreateDeviceRGB(),
            bitmapInfo:.init(rawValue:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue),
            provider:provider,decode:nil,shouldInterpolate:false,intent:.defaultIntent))
        let rejected=try vision.observe(missing,hudVisible:false)
        XCTAssertEqual(rejected.screen,.unknown,"Do not replace CRYSTALS with fuzzy OCR or a gold-button-only rule")
        XCTAssertFalse(CrystalAction.openOne.permits(rejected))
        XCTAssertFalse(CrystalAction.closeInventory.permits(rejected))
    }
    func test623PixelInventoryUsesItsVisibleX1AndOwnCloseButton()throws {
        let png=try image("inventory-ready-623-live")
        let actual=try CrystalVision().observe(png,hudVisible:false)
        XCTAssertEqual(actual.screen,.inventoryReady,actual.texts.joined(separator:";"))
        XCTAssertTrue(actual.texts.contains{$0.filter{$0.isLetter || $0.isNumber}=="CRYSTALSTATS"})
        XCTAssertTrue(actual.texts.contains("CRYSTALS"))
        XCTAssertTrue(CrystalAction.openOne.permits(actual))
        let open=CrystalAction.openOne.point(in:actual)
        XCTAssertTrue(CGRect(x:246,y:489,width:122,height:37).contains(.init(x:open.x*623,y:open.y*863)))
        let close=try XCTUnwrap(actual.closePoint)
        XCTAssertTrue(CGRect(x:418,y:112,width:66,height:30).contains(.init(x:close.x*623,y:close.y*863)))
    }
    func testStrikesFollowQuicklyButOtherStepsStillWaitASecond()throws {
        var flow=CrystalFlow(recovering:[.openInventory,.openOne],now:0)
        XCTAssertEqual(flow.observe(observation(.geode),now:1,inputReady:true),.strike)
        flow.sent(.strike,now:1)
        XCTAssertNil(flow.observe(observation(.geode),now:1.2,inputReady:true),"Too soon even for a strike")
        XCTAssertEqual(flow.observe(observation(.geode),now:1.35,inputReady:true),.strike)
        flow.sent(.strike,now:1.35)
        XCTAssertNil(flow.observe(observation(.result),now:1.7,inputReady:true),"Continue still waits a full second")
        XCTAssertEqual(flow.observe(observation(.result),now:2.4,inputReady:true),.proceed)
    }
    func testLowQualityGraphicsInventoryFindsCrystalsAndX1()throws {
        // "Low Quality" draws the pink close X ~2px wider, so the inferred scale is
        // over-estimated; the grid title and gold button must still be found exactly.
        let url=root.appendingPathComponent("docs/references/2026-11-04/low-quality-crystal-inventory-ready.png")
        let source=try XCTUnwrap(CGImageSourceCreateWithURL(url as CFURL,nil))
        let png=try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
        let actual=try CrystalVision().observe(png,hudVisible:false)
        XCTAssertEqual(actual.screen,.inventoryReady,actual.texts.joined(separator:";"))
        XCTAssertTrue(actual.texts.contains("CRYSTALS"))
        XCTAssertTrue(actual.texts.contains("X1"))
        let open=CrystalAction.openOne.point(in:actual)
        XCTAssertTrue(CGRect(x:250,y:500,width:125,height:37).contains(.init(x:open.x*637,y:open.y*882)))
    }
    private func masked623Inventory(_ rect:CGRect)throws->CGImage {
        let png=try image("inventory-ready-623-live"),p=try Pixels(png)
        var data=p.data
        for y in Int(rect.minY)..<Int(rect.maxY) {for x in Int(rect.minX)..<Int(rect.maxX) {
            let i=(y*p.w+x)*4;for n in 0..<3 {data[i+n]=160}
        }}
        let provider=try XCTUnwrap(CGDataProvider(data:Data(data) as CFData))
        return try XCTUnwrap(CGImage(width:p.w,height:p.h,bitsPerComponent:8,bitsPerPixel:32,
            bytesPerRow:p.w*4,space:CGColorSpaceCreateDeviceRGB(),
            bitmapInfo:.init(rawValue:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue),
            provider:provider,decode:nil,shouldInterpolate:false,intent:.defaultIntent))
    }
    func test623InventoryStillRequiresBothExactHeaders()throws {
        for rect in [CGRect(x:236,y:298,width:150,height:38),CGRect(x:232,y:530,width:164,height:26)] {
            let actual=try CrystalVision().observe(masked623Inventory(rect),hudVisible:false)
            XCTAssertEqual(actual.screen,.unknown,actual.texts.joined(separator:";"))
            XCTAssertFalse(CrystalAction.openOne.permits(actual))
            XCTAssertFalse(CrystalAction.closeInventory.permits(actual))
        }
    }
    func test623InventoryMissingX1ClosesOwnedPanelAndRecoveryRetainsAttempts()throws {
        let actual=try CrystalVision().observe(masked623Inventory(.init(x:242,y:485,width:131,height:45)),hudVisible:false)
        XCTAssertEqual(actual.screen,.inventoryUnavailable,actual.texts.joined(separator:";"))
        XCTAssertFalse(CrystalAction.openOne.permits(actual))
        var owned=begin()
        XCTAssertNil(owned.observe(actual,now:3,inputReady:true))
        XCTAssertNil(owned.observe(actual,now:4,inputReady:false))
        XCTAssertEqual(owned.observe(actual,now:5,inputReady:true),.closeInventory)
        owned.sent(.closeInventory,now:5)
        _=owned.observe(observation(.hud),now:7,inputReady:true)
        _=owned.observe(observation(.hud),now:8,inputReady:true)
        XCTAssertFalse(owned.active);XCTAssertEqual(owned.completed,0)
        let ready=try CrystalVision().observe(image("inventory-ready-623-live"),hudVisible:false)
        var recovered=CrystalFlow(recovering:[.openInventory,.openOne,.openOne],now:100)
        XCTAssertNil(recovered.observe(ready,now:101,inputReady:false))
        XCTAssertEqual(recovered.observe(ready,now:102,inputReady:true),.openOne)
        recovered.sent(.openOne,now:102)
        XCTAssertNil(recovered.observe(ready,now:103,inputReady:true))
        XCTAssertEqual(recovered.failure,"attempt_limit_openOne")
    }
    func test623LiveValidationResultAndNoOpenPanelRequireTheirOwnActions()throws {
        let vision=CrystalVision()
        for (name,expected,action) in [
            ("inventory-ready-623-validation",CrystalScreen.inventoryReady,CrystalAction.openOne),
            ("result-623-live",.result,.proceed),
            ("inventory-no-open-623-live",.inventoryUnavailable,.closeInventory)] {
            let actual=try vision.observe(image(name),hudVisible:false)
            XCTAssertEqual(actual.screen,expected,"\(name):\(actual.texts)")
            XCTAssertTrue(action.permits(actual),name)
            if expected != .inventoryReady {XCTAssertFalse(CrystalAction.openOne.permits(actual),name)}
            XCTAssertFalse(CrystalAction.openInventory.permits(actual),name)
        }
    }
    func testSmallResultRequiresExactTitleAndContinueWithoutDecorativeBorderOCR()throws {
        let png=try image("result-small-live"),vision=CrystalVision()
        let animation=try vision.observe(image("result-small-animation-live"),hudVisible:false)
        XCTAssertEqual(animation.screen,.unknown,"Reward animation without the visible Continue is not a result action")
        XCTAssertFalse(CrystalAction.proceed.permits(animation))
        let actual=try vision.observe(png,hudVisible:false)
        XCTAssertEqual(actual.screen,.result,actual.texts.joined(separator:";"))
        let point=CrystalAction.proceed.point
        XCTAssertTrue(CGRect(x:212,y:784,width:215,height:50).contains(.init(x:point.x*637,y:point.y*882)))
        let p=try Pixels(png)
        for mode in ["no-title","no-continue"] {
            var data=p.data
            let xs=mode=="no-title" ? 220..<415:270..<370
            let ys=mode=="no-title" ? 498..<530:790..<822
            let color:[UInt8]=mode=="no-title" ? [140,90,60]:[255,190,0]
            for y in ys {for x in xs {let i=(y*p.w+x)*4;for n in 0..<3 {data[i+n]=color[n]}}}
            let provider=try XCTUnwrap(CGDataProvider(data:Data(data) as CFData))
            let missing=try XCTUnwrap(CGImage(width:p.w,height:p.h,bitsPerComponent:8,bitsPerPixel:32,
                bytesPerRow:p.w*4,space:CGColorSpaceCreateDeviceRGB(),
                bitmapInfo:.init(rawValue:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue),
                provider:provider,decode:nil,shouldInterpolate:false,intent:.defaultIntent))
            let rejected=try vision.observe(missing,hudVisible:false)
            XCTAssertEqual(rejected.screen,.unknown,mode)
            XCTAssertFalse(CrystalAction.proceed.permits(rejected),mode)
        }
    }
    func testUserAndHeldOutLiveScreensAndBothNotificationStates()throws {
        let vision=CrystalVision(),free=RewardVision()
        let samples:[(String,CrystalScreen,Bool)]=[
            ("inventory-ready-user",.inventoryReady,false),("geode-user",.geode,false),
            ("result-user",.result,false),("inventory-empty-user",.inventoryEmpty,false),
            ("hud-notification-user",.hud,true),("hud-notification-live",.hud,true),
            ("hud-notification-external-live",.hud,true),
            ("geode-cracked-live",.geode,false),("hud-without-notification-live",.hud,false),
            ("inventory-ready-live",.inventoryReady,false),("inventory-empty-live",.inventoryEmpty,false),
            ("geode-first-live",.geode,false),("result-blue-live",.result,false),
            ("inventory-unavailable-external-live",.inventoryUnavailable,false),("hud-no-dot-external-after",.hud,false)]
        for (name,screen,dot) in samples {
            let png=try image(name),reward=try free.observe(png)
            let actual=try vision.observe(png,hudVisible:reward.gameHUDVisible)
            XCTAssertEqual(actual.screen,screen,"\(name): \(actual.texts)")
            XCTAssertEqual(actual.notification,dot,"\(name): \(actual.texts)")
            if screen != .hud {XCTAssertNil(reward.reward,"Crystal overlay must suppress Free clicks")}
        }
    }
    func testUserConfettiCannotBeAWhiteRingedNotification()throws {
        let png=try image("hud-no-dot-confetti-user")
        let reward=try RewardVision().observe(png)
        XCTAssertTrue(reward.gameHUDVisible)
        let actual=try CrystalVision().observe(png,hudVisible:reward.gameHUDVisible)
        XCTAssertEqual(actual.screen,.hud)
        XCTAssertFalse(actual.notification,"Separate red and white confetti are not a notification")
        XCTAssertFalse(CrystalAction.openInventory.permits(actual))
        var flow=CrystalFlow()
        for n in 0..<10 {XCTAssertNil(flow.observe(actual,now:Double(n),inputReady:true))}
        XCTAssertFalse(flow.active)
    }
    func testManualPanelsReserveInputEvenIfHUDColoursLeakButNeverTakeOwnership() {
        for screen in [CrystalScreen.inventoryReady,.inventoryEmpty,.inventoryUnavailable,.geode,.result] {
            XCTAssertTrue(CrystalInputPolicy.isManualPanel(screen:screen,active:false))
            XCTAssertFalse(CrystalInputPolicy.isManualPanel(screen:screen,active:true))
            var flow=CrystalFlow()
            for t in 0..<4 {XCTAssertNil(flow.observe(observation(screen),now:Double(t),inputReady:true))}
            XCTAssertFalse(flow.active)
        }
        XCTAssertFalse(CrystalInputPolicy.isManualPanel(screen:.hud,active:false))
        XCTAssertFalse(CrystalInputPolicy.isManualPanel(screen:.unknown,active:false))
    }
    func testRealExternalInventoryWithX1AndX2TargetsOnlyTheX1Button()throws {
        let png=try image("inventory-ready-external-live")
        let actual=try CrystalVision().observe(png,hudVisible:false)
        XCTAssertEqual(actual.screen,.inventoryReady,actual.texts.joined(separator:";"))
        let point=CrystalAction.openOne.point(in:actual)
        XCTAssertTrue(CGRect(x:308,y:609,width:91,height:49).contains(.init(x:point.x*788,y:point.y*1083)))
        let close=try XCTUnwrap(actual.closePoint)
        XCTAssertTrue(CGRect(x:523,y:128,width:95,height:50).contains(.init(x:close.x*788,y:close.y*1083)))
    }
    func testContinueMayLeadToNextGeodeWithoutAnotherOpenOrResettingBudgets()throws {
        var flow=begin()
        _=flow.observe(observation(.inventoryReady),now:3,inputReady:true);flow.sent(.openOne,now:3)
        _=flow.observe(observation(.geode),now:5,inputReady:true);flow.sent(.strike,now:5)
        _=flow.observe(observation(.result),now:7,inputReady:true);flow.sent(.proceed,now:7)
        let next=try CrystalVision().observe(image("geode-auto-next-external-live"),hudVisible:false)
        XCTAssertEqual(next.screen,.geode)
        XCTAssertNil(flow.observe(next,now:9,inputReady:true))
        XCTAssertEqual(flow.observe(next,now:10,inputReady:true),.strike)
        flow.sent(.strike,now:10);XCTAssertEqual(flow.strikes,2)
        let result=try CrystalVision().observe(image("result-external-blue-live"),hudVisible:false)
        XCTAssertEqual(result.screen,.result)
        XCTAssertEqual(flow.observe(result,now:12,inputReady:true),.proceed)
        XCTAssertNil(flow.observe(observation(.inventoryEmpty),now:12.1,inputReady:true),"Previous result's Continue cannot approve this result")
        XCTAssertNil(flow.observe(next,now:12.2,inputReady:true))
        XCTAssertNil(flow.observe(next,now:12.3,inputReady:true))
        XCTAssertEqual(flow.observe(result,now:13,inputReady:true),.proceed)
        flow.sent(.proceed,now:13)
        let final=try CrystalVision().observe(image("inventory-unavailable-external-live"),hudVisible:false)
        XCTAssertEqual(final.screen,.inventoryUnavailable)
        XCTAssertEqual(flow.observe(final,now:14,inputReady:true),.closeInventory)
        flow.sent(.closeInventory,now:14)
        _=flow.observe(observation(.hud),now:16,inputReady:true);_=flow.observe(observation(.hud),now:17,inputReady:true)
        XCTAssertEqual(flow.completed,1);XCTAssertFalse(flow.active)
        var unownedContinue=begin()
        _=unownedContinue.observe(observation(.inventoryReady),now:3,inputReady:true);unownedContinue.sent(.openOne,now:3)
        _=unownedContinue.observe(observation(.geode),now:5,inputReady:true);unownedContinue.sent(.strike,now:5)
        _=unownedContinue.observe(result,now:7,inputReady:true)
        XCTAssertNil(unownedContinue.observe(next,now:9,inputReady:true))
        XCTAssertNil(unownedContinue.observe(next,now:10,inputReady:true))
        var interrupted=CrystalFlow(recovering:[.openInventory,.openOne,.strike,.proceed,.strike],now:100)
        _=interrupted.observe(observation(.unknown),now:191,inputReady:true)
        _=interrupted.observe(observation(.inventoryEmpty),now:192,inputReady:true)
        XCTAssertEqual(interrupted.observe(observation(.inventoryEmpty),now:193,inputReady:true),.closeInventory)
        interrupted.sent(.closeInventory,now:193)
        _=interrupted.observe(observation(.hud),now:195,inputReady:true)
        _=interrupted.observe(observation(.hud),now:196,inputReady:true)
        XCTAssertEqual(interrupted.completed,0,"An earlier geode's result cannot complete the interrupted next stone")
    }
    func testVanishedNotificationStopsOpeningAndReleasesInputWithoutInventingSuccess() {
        for sent in [false,true] {
            var flow=CrystalFlow()
            _=flow.observe(hud,now:0,inputReady:true)
            _=flow.observe(hud,now:1,inputReady:true)
            if sent {flow.sent(.openInventory,now:1)}
            XCTAssertNil(flow.observe(observation(.hud),now:2,inputReady:true))
            XCTAssertNil(flow.observe(observation(.hud),now:3,inputReady:true))
            XCTAssertFalse(flow.active);XCTAssertEqual(flow.completed,0)
            for t in 4..<20 {XCTAssertNil(flow.observe(hud,now:Double(t),inputReady:true))}
        }
    }
    func testKnownInventoryWithoutOpenClosesOnlyOurOwnTransaction() {
        var idle=CrystalFlow()
        for t in 0..<5 {XCTAssertNil(idle.observe(observation(.inventoryUnavailable),now:Double(t),inputReady:true))}
        XCTAssertFalse(idle.active)
        var flow=begin()
        XCTAssertNil(flow.observe(observation(.inventoryUnavailable),now:3,inputReady:true))
        XCTAssertNil(flow.observe(observation(.inventoryUnavailable),now:4,inputReady:false))
        XCTAssertEqual(flow.observe(observation(.inventoryUnavailable),now:5,inputReady:true),.closeInventory)
        flow.sent(.closeInventory,now:5)
        _=flow.observe(observation(.hud),now:7,inputReady:true)
        _=flow.observe(observation(.hud),now:8,inputReady:true)
        XCTAssertFalse(flow.active);XCTAssertEqual(flow.completed,0)
        var ready=begin()
        _=ready.observe(observation(.inventoryReady),now:3,inputReady:true)
        XCTAssertEqual(ready.observe(observation(.inventoryEmpty),now:4,inputReady:true),.closeInventory)
    }
    func testTimeoutCanOnlyCleanUpOwnedKnownInventoryOnceWithinOriginalClickBudget() {
        var flow=begin()
        XCTAssertNil(flow.observe(observation(.unknown),now:92,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked)
        XCTAssertNil(flow.observe(observation(.inventoryEmpty),now:93,inputReady:true))
        for t in [94.0,96.0,98.0] {
            XCTAssertEqual(flow.observe(observation(.inventoryEmpty),now:t,inputReady:true),.closeInventory)
            flow.sent(.closeInventory,now:t)
        }
        XCTAssertNil(flow.observe(observation(.inventoryEmpty),now:100,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked)
        for t in 101..<115 {XCTAssertNil(flow.observe(observation(.inventoryEmpty),now:Double(t),inputReady:true))}
        XCTAssertEqual(flow.completed,0)
        var neverSent=CrystalFlow()
        _=neverSent.observe(hud,now:0,inputReady:true);_=neverSent.observe(hud,now:1,inputReady:true)
        _=neverSent.observe(observation(.unknown),now:92,inputReady:true)
        for t in 93..<98 {XCTAssertNil(neverSent.observe(observation(.inventoryEmpty),now:Double(t),inputReady:true))}
    }
    func testCleanupCannotCountAResultWithoutOurContinueAndHasATimeLimit() {
        var flow=begin()
        _=flow.observe(observation(.inventoryReady),now:3,inputReady:true);flow.sent(.openOne,now:3)
        _=flow.observe(observation(.geode),now:5,inputReady:true);flow.sent(.strike,now:5)
        XCTAssertEqual(flow.observe(observation(.result),now:7,inputReady:true),.proceed)
        // Continue was not sent; a human may subsequently close the result.
        _=flow.observe(observation(.unknown),now:92,inputReady:true)
        _=flow.observe(observation(.inventoryEmpty),now:93,inputReady:true)
        XCTAssertEqual(flow.observe(observation(.inventoryEmpty),now:94,inputReady:true),.closeInventory)
        flow.sent(.closeInventory,now:94)
        _=flow.observe(observation(.hud),now:96,inputReady:true);_=flow.observe(observation(.hud),now:97,inputReady:true)
        XCTAssertEqual(flow.completed,0);XCTAssertFalse(flow.active)
        var stuck=begin()
        _=stuck.observe(observation(.unknown),now:92,inputReady:true)
        _=stuck.observe(observation(.inventoryUnavailable),now:93,inputReady:true)
        XCTAssertEqual(stuck.observe(observation(.inventoryUnavailable),now:94,inputReady:true),.closeInventory)
        XCTAssertNil(stuck.observe(observation(.inventoryUnavailable),now:105,inputReady:true))
        XCTAssertEqual(stuck.failure,"empty_cleanup_timeout")
        XCTAssertNil(stuck.observe(observation(.inventoryUnavailable),now:106,inputReady:true))
    }
    func testAspectShiftedInventoryUsesItsActualXAndMissingOpenStillCloses()throws {
        let source=try image("inventory-empty-live")
        func derived(height:Int,maskButton:Bool)throws->CGImage {
            let c=try XCTUnwrap(CGContext(data:nil,width:642,height:height,bitsPerComponent:8,bytesPerRow:0,
                space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue))
            c.setFillColor(CGColor(gray:0.03,alpha:1));c.fill(.init(x:0,y:0,width:642,height:height))
            // Synthetic aspect test only: preserve width, bottom anchor inventory.
            c.draw(source,in:.init(x:0,y:0,width:642,height:951))
            if maskButton {
                c.setFillColor(CGColor(gray:0.65,alpha:1))
                c.fill(.init(x:254,y:951-566,width:119,height:28))
            }
            return try XCTUnwrap(c.makeImage())
        }
        let vision=CrystalVision()
        for height in [882,951,1010] {
            let actual=try vision.observe(derived(height:height,maskButton:false),hudVisible:false)
            XCTAssertEqual(actual.screen,.inventoryEmpty,"height=\(height):\(actual.texts)")
            let point=try XCTUnwrap(actual.closePoint)
            XCTAssertEqual(point.y*Double(height),137-Double(951-height),accuracy:3)
            XCTAssertEqual(CrystalAction.closeInventory.point(in:actual),point)
        }
        let missing=try vision.observe(derived(height:882,maskButton:true),hudVisible:false)
        XCTAssertEqual(missing.screen,.inventoryUnavailable,missing.texts.joined(separator:";"))
        XCTAssertFalse(CrystalAction.openOne.permits(missing));XCTAssertTrue(CrystalAction.closeInventory.permits(missing))
        XCTAssertNotNil(missing.closePoint)
        let actual=try vision.observe(source,hudVisible:true)
        XCTAssertEqual(actual.screen,.inventoryEmpty,"Known inventory outranks a false-positive HUD")
    }
    func testScreenshotReplayProducesOnlyTheAuthorizedSequence()throws {
        var flow=CrystalFlow(),actions:[CrystalAction]=[]
        let vision=CrystalVision(),free=RewardVision()
        let names=["hud-notification-user","hud-notification-user","inventory-ready-user","geode-user","geode-cracked-live","geode-cracked-live","result-user","inventory-empty-user","hud-without-notification-live","hud-without-notification-live"]
        for (i,name) in names.enumerated() {
            let png=try image(name)
            let o=try vision.observe(png,hudVisible:free.observe(png).gameHUDVisible)
            if let a=flow.observe(o,now:Double(i*2),inputReady:true) {
                XCTAssertTrue(a.permits(o));actions.append(a);flow.sent(a,now:Double(i*2))
            }
        }
        XCTAssertEqual(actions,[.openInventory,.openOne,.strike,.strike,.strike,.proceed,.closeInventory])
        XCTAssertEqual(flow.completed,1);XCTAssertFalse(flow.active)
    }
    func testNoStartWithoutDotTwoFramesMouseReleaseAndNoPendingFree() {
        for (o,ready,mayStart) in [(observation(.hud),true,true),(hud,false,true),(hud,true,false)] {
            var flow=CrystalFlow()
            for t in 0..<4 {XCTAssertNil(flow.observe(o,now:Double(t),inputReady:ready,mayStart:mayStart))}
            XCTAssertFalse(flow.active)
        }
        var flow=CrystalFlow()
        XCTAssertNil(flow.observe(hud,now:0,inputReady:true))
        XCTAssertEqual(flow.observe(hud,now:1,inputReady:true),.openInventory)
        var appeared=CrystalFlow()
        _=appeared.observe(observation(.hud),now:0,inputReady:true)
        _=appeared.observe(observation(.hud),now:1,inputReady:true)
        XCTAssertNil(appeared.observe(hud,now:2,inputReady:true))
        XCTAssertEqual(appeared.observe(hud,now:3,inputReady:true),.openInventory)
    }
    func testEveryClickRequiresItsFreshScreenAndNotification() {
        for a in [CrystalAction.openInventory,.openOne,.strike,.proceed,.closeInventory] {
            XCTAssertFalse(a.permits(observation(.unknown)))
            XCTAssertTrue(a.permits(a == .openInventory ? hud:observation(a.expectedScreen)))
            for s in [CrystalScreen.hud,.geode,.result] where s != a.expectedScreen {
                XCTAssertFalse(a.permits(observation(s)))
            }
        }
        XCTAssertFalse(CrystalAction.openInventory.permits(observation(.hud)))
    }
    private func begin()->CrystalFlow {
        var flow=CrystalFlow()
        _=flow.observe(hud,now:0,inputReady:true)
        _=flow.observe(hud,now:1,inputReady:true);flow.sent(.openInventory,now:1)
        return flow
    }
    func testMouseWaitDoesNotConsumeAttemptOrProgress() {
        var flow=begin()
        XCTAssertNil(flow.observe(observation(.inventoryReady),now:3,inputReady:false))
        XCTAssertEqual(flow.observe(observation(.inventoryReady),now:4,inputReady:true),.openOne)
        XCTAssertEqual(flow.strikes,0)
    }
    func testUnknownAndOutOfOrderScreensNeverClickOrConfirm() {
        var flow=begin()
        for s in [CrystalScreen.unknown,.result,.geode] {
            XCTAssertNil(flow.observe(observation(s),now:3,inputReady:true))
        }
        XCTAssertEqual(flow.completed,0)
        XCTAssertNil(flow.observe(observation(.unknown),now:92,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked)
    }
    func testFailedOpenRetriesAreBoundedAndSpaced() {
        var flow=begin()
        XCTAssertNil(flow.observe(hud,now:1.5,inputReady:true))
        for t in [3.0,5.0] {
            XCTAssertEqual(flow.observe(hud,now:t,inputReady:true),.openInventory)
            flow.sent(.openInventory,now:t)
        }
        XCTAssertNil(flow.observe(hud,now:7,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked)
    }
    func testStrikesStopAtResultAndAreBounded() {
        var flow=begin()
        XCTAssertEqual(flow.observe(observation(.inventoryReady),now:3,inputReady:true),.openOne)
        flow.sent(.openOne,now:3)
        for i in 0..<16 {
            let t=Double(5+i*2)
            XCTAssertEqual(flow.observe(observation(.geode),now:t,inputReady:true),.strike)
            flow.sent(.strike,now:t)
        }
        XCTAssertNil(flow.observe(observation(.geode),now:39,inputReady:true))
        XCTAssertEqual(flow.phase,.blocked);XCTAssertEqual(flow.strikes,16)
    }
    func testEmptyInventoryClosesWithoutInventingAReward() {
        var flow=begin()
        XCTAssertEqual(flow.observe(observation(.inventoryEmpty),now:3,inputReady:true),.closeInventory)
        flow.sent(.closeInventory,now:3)
        _=flow.observe(observation(.hud),now:5,inputReady:true)
        _=flow.observe(observation(.hud),now:6,inputReady:true)
        XCTAssertFalse(flow.active);XCTAssertEqual(flow.completed,0)
        XCTAssertNil(flow.observe(hud,now:7,inputReady:true))
    }
    func testResultCannotBeCountedBeforeContinueAndObservedReturn() {
        var flow=begin()
        _=flow.observe(observation(.inventoryReady),now:3,inputReady:true);flow.sent(.openOne,now:3)
        _=flow.observe(observation(.geode),now:5,inputReady:true);flow.sent(.strike,now:5)
        XCTAssertEqual(flow.observe(observation(.result),now:7,inputReady:true),.proceed)
        XCTAssertEqual(flow.completed,0)
        XCTAssertNil(flow.observe(observation(.inventoryEmpty),now:9,inputReady:true))
        flow.sent(.proceed,now:10)
        XCTAssertEqual(flow.observe(observation(.inventoryReady),now:12,inputReady:true),.closeInventory)
        flow.sent(.closeInventory,now:12)
        XCTAssertNil(flow.observe(observation(.hud),now:14,inputReady:true))
        XCTAssertEqual(flow.completed,0)
        _=flow.observe(observation(.hud),now:15,inputReady:true)
        XCTAssertEqual(flow.completed,1)
        _=flow.observe(observation(.hud),now:16,inputReady:true)
        XCTAssertEqual(flow.completed,1)
    }
    func testManualModalDoesNotStartATransaction() {
        for s in [CrystalScreen.inventoryReady,.inventoryEmpty,.geode,.result,.unknown] {
            var flow=CrystalFlow()
            for t in 0..<4 {XCTAssertNil(flow.observe(observation(s),now:Double(t),inputReady:true))}
            XCTAssertFalse(flow.active)
        }
    }
    func testUnsentOpeningRejectionReleasesCollectionButNeverAbandonsSentInput() {
        var unsent=CrystalFlow()
        _=unsent.observe(hud,now:0,inputReady:true)
        XCTAssertEqual(unsent.observe(hud,now:1,inputReady:true),.openInventory)
        XCTAssertTrue(unsent.abandonUnsentOpening(now:2))
        XCTAssertFalse(unsent.active);XCTAssertEqual(unsent.completed,0)
        XCTAssertNil(unsent.observe(hud,now:3,inputReady:true))
        XCTAssertEqual(unsent.observe(hud,now:63,inputReady:true),.openInventory)
        var sent=begin()
        XCTAssertFalse(sent.abandonUnsentOpening(now:2))
        XCTAssertTrue(sent.active)
        XCTAssertEqual(sent.observe(observation(.inventoryReady),now:3,inputReady:true),.openOne)
        sent.sent(.openOne,now:3)
        XCTAssertFalse(sent.abandonUnsentOpening(now:4))
    }
    func testExplicitOwnedRecoveryRetainsStrikeLimitAndDoesNotAssumeCompletion()throws {
        let encoded=[CrystalAction.openInventory,.openOne,.strike]
        var flow=CrystalFlow(recovering:encoded,now:100)
        XCTAssertEqual(flow.phase,.breaking);XCTAssertEqual(flow.strikes,1);XCTAssertEqual(flow.completed,0)
        XCTAssertNil(flow.observe(observation(.unknown),now:102,inputReady:true))
        let png=try image("geode-cracked-live")
        let actual=try CrystalVision().observe(png,hudVisible:false)
        XCTAssertEqual(flow.observe(actual,now:103,inputReady:true),.strike)
        let exhausted=[CrystalAction.openInventory,.openOne]+Array(repeating:CrystalAction.strike,count:16)
        var blocked=CrystalFlow(recovering:exhausted,now:100)
        XCTAssertNil(blocked.observe(actual,now:102,inputReady:true))
        XCTAssertEqual(blocked.phase,.blocked)
    }
    func testUnrelatedFreeCorpusModalsNeverBecomeCrystalActions()throws {
        struct Corpus:Decodable {struct Sample:Decodable {let image:String;let hud:Bool};let samples:[Sample]}
        let corpus=try JSONDecoder().decode(Corpus.self,from:Data(contentsOf:root.appendingPathComponent("tests/reward-reading-corpus.json")))
        let vision=CrystalVision()
        for sample in corpus.samples where !sample.hud {
            let source=try XCTUnwrap(CGImageSourceCreateWithURL(root.appendingPathComponent(sample.image) as CFURL,nil))
            let png=try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
            let actual=try vision.observe(png,hudVisible:false)
            XCTAssertEqual(actual.screen,.unknown,sample.image)
            for action in [CrystalAction.openInventory,.openOne,.strike,.proceed,.closeInventory] {
                XCTAssertFalse(action.permits(actual),sample.image)
            }
        }
    }
}
