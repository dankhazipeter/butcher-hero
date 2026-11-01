import XCTest
@testable import RewardAutomationCore

final class RewardCaptureTests:XCTestCase {
    private func window(_ id:UInt32,_ bundle:String?,_ w:Double=637,_ h:Double=882,_ pid:Int32?=123)->GameCaptureWindow {
        .init(windowID:id,processID:pid,bundleIdentifier:bundle,width:w,height:h)
    }
    func testLargerSafariDashboardCanNeverReplaceGameWindow() {
        let game=window(419,GameCapturePolicy.bundleIdentifier)
        let safari=window(900,"com.apple.Safari",2560,1440)
        let chrome=window(901,"com.google.Chrome",3000,2000)
        for candidates in [[game,safari,chrome],[chrome,safari,game]] {
            XCTAssertEqual(GameCapturePolicy.selectWindow(candidates),419)
        }
    }
    func testNoGameMeansNoTitleFallbackOrForeignWindowCapture() {
        for bundle in ["com.apple.Safari","com.google.Chrome","com.openai.chat",nil,"com.multicastgames.butcher.fake"] {
            XCTAssertNil(GameCapturePolicy.selectWindow([window(900,bundle,2560,1440)]))
        }
    }
    func testOnlyUsableRealGameWindowsParticipateInSizeOrdering() {
        let bundle=GameCapturePolicy.bundleIdentifier
        XCTAssertEqual(GameCapturePolicy.selectWindow([
            window(1,bundle,300,900),window(2,bundle,637,100),window(3,bundle),
            window(4,bundle,788,1083),window(5,bundle,.infinity,9999),window(6,bundle,9999,.nan)
        ]),4)
        XCTAssertNil(GameCapturePolicy.selectWindow([]))
    }
    func testSourceRequiresExactBundleAndValidProcessAndWindowIdentity() {
        let bundle=GameCapturePolicy.bundleIdentifier
        XCTAssertTrue(GameCapturePolicy.trustedSource(bundleIdentifier:bundle,processID:123,windowID:419))
        for pid:Int32? in [nil,0,-1] {
            XCTAssertFalse(GameCapturePolicy.trustedSource(bundleIdentifier:bundle,processID:pid,windowID:419))
            XCTAssertNil(GameCapturePolicy.selectWindow([window(419,bundle,637,882,pid)]))
        }
        XCTAssertFalse(GameCapturePolicy.trustedSource(bundleIdentifier:bundle,processID:123,windowID:0))
        XCTAssertFalse(GameCapturePolicy.trustedSource(bundleIdentifier:"com.apple.Safari",processID:123,windowID:419))
    }
}
