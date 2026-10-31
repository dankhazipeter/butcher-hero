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
    func testUserAndHeldOutLiveScreensAndBothNotificationStates()throws {
        let vision=CrystalVision(),free=RewardVision()
        let samples:[(String,CrystalScreen,Bool)]=[
            ("inventory-ready-user",.inventoryReady,false),("geode-user",.geode,false),
            ("result-user",.result,false),("inventory-empty-user",.inventoryEmpty,false),
            ("hud-notification-user",.hud,true),("hud-notification-live",.hud,true),
            ("geode-cracked-live",.geode,false),("hud-without-notification-live",.hud,false),
            ("inventory-ready-live",.inventoryReady,false),("inventory-empty-live",.inventoryEmpty,false),
            ("geode-first-live",.geode,false),("result-blue-live",.result,false)]
        for (name,screen,dot) in samples {
            let png=try image(name),reward=try free.observe(png)
            let actual=try vision.observe(png,hudVisible:reward.gameHUDVisible)
            XCTAssertEqual(actual.screen,screen,"\(name): \(actual.texts)")
            XCTAssertEqual(actual.notification,dot,"\(name): \(actual.texts)")
            if screen != .hud {XCTAssertNil(reward.reward,"Crystal overlay must suppress Free clicks")}
        }
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
