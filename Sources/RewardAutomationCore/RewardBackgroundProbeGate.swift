import Foundation
import CoreGraphics

/// Experimental one-shot gate, NOT the normal foreground input policy.
public enum RewardBackgroundProbeGate {
    public static func permits(baselinePID:Int32,currentPID:Int32,gamePID:Int32,
                               baselineCursor:CGPoint,currentCursor:CGPoint,
                               buttonDown:Bool,cancelled:Bool,frameAge:Double)->Bool {
        baselinePID>0 && gamePID>0 && baselinePID != gamePID && currentPID==baselinePID &&
        !buttonDown && !cancelled && frameAge.isFinite && frameAge>=0 && frameAge<=1 &&
        [baselineCursor.x,baselineCursor.y,currentCursor.x,currentCursor.y].allSatisfy(\.isFinite) &&
        hypot(baselineCursor.x-currentCursor.x,baselineCursor.y-currentCursor.y)<=0.5
    }
}
