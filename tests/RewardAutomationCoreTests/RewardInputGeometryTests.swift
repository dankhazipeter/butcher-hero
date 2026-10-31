import XCTest
import ImageIO
@testable import RewardAutomationCore

final class RewardInputGeometryTests:XCTestCase {
    func testUserExternalScreenshotTargetFallsInsideTheVisibleFreeCard()throws {
        let project=URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let path=project.appendingPathComponent("docs/references/2026-10-31/external-pierce567-user.png")
        let source=try XCTUnwrap(CGImageSourceCreateWithURL(path as CFURL,nil))
        let image=try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
        let reward=try XCTUnwrap(RewardVision().observe(image).reward)
        XCTAssertEqual(reward.kind,"piercing_damage")
        let pixel=CGPoint(x:reward.tapX*Double(image.width),y:reward.tapY*Double(image.height))
        // Manually reviewed clickable card: FREE label, arrow567 and timer bar.
        XCTAssertTrue(CGRect(x:8,y:627,width:87,height:108).contains(pixel))
        let f=CGRect(x:-2400,y:-450,width:788,height:1083),display=CGRect(x:-2560,y:-553,width:2560,height:1440)
        let point=try XCTUnwrap(RewardInputGeometry.target(normalized:.init(x:reward.tapX,y:reward.tapY),
            imageSize:.init(width:image.width,height:image.height),capturedWindow:f,currentWindow:f,activeDisplays:[display]))
        XCTAssertEqual(point.x-f.minX,pixel.x,accuracy:0.01)
        XCTAssertEqual(point.y-f.minY,pixel.y,accuracy:0.01)
    }
    private func map(_ frame:CGRect,_ display:CGRect,scale:Double=1)->CGPoint? {
        RewardInputGeometry.target(normalized:.init(x:0.069,y:0.64),
            imageSize:.init(width:frame.width*scale,height:frame.height*scale),
            capturedWindow:frame,currentWindow:frame,activeDisplays:[display])
    }
    func testRetinaBackingPixelsNeverMultiplyGlobalClickCoordinates()throws {
        let frame=CGRect(x:874,y:33,width:637,height:882),screen=CGRect(x:0,y:0,width:1512,height:982)
        let one=try XCTUnwrap(map(frame,screen)),two=try XCTUnwrap(map(frame,screen,scale:2))
        XCTAssertEqual(one,two);XCTAssertEqual(one.x,917.953,accuracy:0.001);XCTAssertEqual(one.y,597.48,accuracy:0.001)
    }
    func testBothActualExternalMonitorOriginsIncludingNegativeY()throws {
        for x in [-5120.0,-2560.0] {
            let display=CGRect(x:x,y:-553,width:2560,height:1440),frame=CGRect(x:x+200,y:-400,width:788,height:1083)
            let point=try XCTUnwrap(map(frame,display))
            XCTAssertEqual(point.x,x+254.372,accuracy:0.001);XCTAssertEqual(point.y,293.12,accuracy:0.001)
            XCTAssertEqual(map(frame,display,scale:2),point)
        }
    }
    func testMonitorsAboveBelowRightAndWindowSpanningBoundary()throws {
        for screen in [CGRect(x:1512,y:0,width:2560,height:1440),CGRect(x:0,y:-1440,width:2560,height:1440),CGRect(x:0,y:982,width:2560,height:1440)] {
            let f=CGRect(x:screen.minX+80,y:screen.minY+50,width:788,height:1083)
            XCTAssertNotNil(map(f,screen))
        }
        let f=CGRect(x:-100,y:20,width:637,height:882)
        XCTAssertNotNil(map(f,.init(x:-2560,y:-553,width:2560,height:1440)))
    }
    func testMovedResizedStaleAndCroppedFramesFailClosed() {
        let f=CGRect(x:-2300,y:-400,width:788,height:1083),d=CGRect(x:-2560,y:-553,width:2560,height:1440)
        for current in [f.offsetBy(dx:5,dy:0),f.offsetBy(dx:0,dy:5),CGRect(x:f.minX,y:f.minY,width:790,height:1083)] {
            XCTAssertNil(RewardInputGeometry.target(normalized:.init(x:0.069,y:0.64),imageSize:f.size,capturedWindow:f,currentWindow:current,activeDisplays:[d]))
        }
        XCTAssertNil(RewardInputGeometry.target(normalized:.init(x:0.069,y:0.64),imageSize:.init(width:788,height:900),capturedWindow:f,currentWindow:f,activeDisplays:[d]))
        XCTAssertNil(map(f,.zero));XCTAssertNil(map(f,.init(x:0,y:0,width:1512,height:982)))
        XCTAssertNil(RewardInputGeometry.target(normalized:.init(x:0.069,y:0.64),imageSize:f.size,capturedWindow:f,currentWindow:f,activeDisplays:[]))
    }
    func testInvalidPointsAndWarpMismatchCannotSendMouseDown() {
        let f=CGRect(x:0,y:0,width:637,height:882)
        for p in [CGPoint(x:-0.1,y:0.64),CGPoint(x:0.1,y:1),CGPoint(x:Double.nan,y:0.64)] {
            XCTAssertNil(RewardInputGeometry.target(normalized:p,imageSize:f.size,capturedWindow:f,currentWindow:f,activeDisplays:[f]))
        }
        XCTAssertTrue(RewardInputGeometry.cursorMatches(expected:.init(x:-2200,y:-300),actual:.init(x:-2200,y:-300)))
        XCTAssertFalse(RewardInputGeometry.cursorMatches(expected:.init(x:-2200,y:-300),actual:.init(x:0,y:0)))
        XCTAssertFalse(RewardInputGeometry.cursorMatches(expected:.zero,actual:.init(x:Double.nan,y:0)))
    }
}
