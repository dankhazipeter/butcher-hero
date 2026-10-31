import Foundation
import CoreGraphics

/// All rectangles are Quartz global logical points (top-left origin), NOT
/// AppKit screen frames or backing pixels. Negative monitor origins are valid.
public enum RewardInputGeometry {
    public static func target(normalized:CGPoint,imageSize:CGSize,capturedWindow:CGRect,
                              currentWindow:CGRect,activeDisplays:[CGRect])->CGPoint? {
        func valid(_ r:CGRect)->Bool {
            [r.origin.x,r.origin.y,r.width,r.height].allSatisfy(\.isFinite) && r.width>0 && r.height>0
        }
        guard normalized.x.isFinite,normalized.y.isFinite,
              normalized.x>0,normalized.x<1,normalized.y>0,normalized.y<1,
              imageSize.width.isFinite,imageSize.height.isFinite,imageSize.width>0,imageSize.height>0,
              valid(capturedWindow),valid(currentWindow),
              abs(capturedWindow.minX-currentWindow.minX)<=1,
              abs(capturedWindow.minY-currentWindow.minY)<=1,
              abs(capturedWindow.width-currentWindow.width)<=1,
              abs(capturedWindow.height-currentWindow.height)<=1 else{return nil}
        // Capture must cover the same full-window aspect, at either 1x or 2x.
        // Do not stretch a cropped/letterboxed image into a different rectangle.
        let sx=imageSize.width/capturedWindow.width,sy=imageSize.height/capturedWindow.height
        guard abs(sx-sy)<=max(sx,sy)*0.01 else{return nil}
        let point=CGPoint(x:currentWindow.minX+normalized.x*currentWindow.width,
                          y:currentWindow.minY+normalized.y*currentWindow.height)
        guard currentWindow.contains(point),activeDisplays.contains(where:{valid($0) && $0.contains(point)}) else{return nil}
        return point
    }
    public static func cursorMatches(expected:CGPoint,actual:CGPoint)->Bool {
        [expected.x,expected.y,actual.x,actual.y].allSatisfy(\.isFinite) && hypot(expected.x-actual.x,expected.y-actual.y)<=2
    }
}
