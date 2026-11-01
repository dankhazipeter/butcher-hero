import Foundation

/// Window titles are deliberately not an input: the dashboard has the game's
/// name too. Only WindowServer's owning application identity can select it.
public struct GameCaptureWindow {
    public let windowID:UInt32,processID:Int32?
    public let bundleIdentifier:String?
    public let width:Double,height:Double
    public init(windowID:UInt32,processID:Int32?,bundleIdentifier:String?,width:Double,height:Double) {
        self.windowID=windowID;self.processID=processID;self.bundleIdentifier=bundleIdentifier
        self.width=width;self.height=height
    }
}

public enum GameCapturePolicy {
    public static let bundleIdentifier="com.multicastgames.butcher"
    public static func trustedSource(bundleIdentifier:String?,processID:Int32?,windowID:UInt32)->Bool {
        bundleIdentifier==self.bundleIdentifier && (processID ?? 0)>0 && windowID>0
    }
    public static func selectWindow(_ windows:[GameCaptureWindow])->UInt32? {
        windows.filter {
            trustedSource(bundleIdentifier:$0.bundleIdentifier,processID:$0.processID,windowID:$0.windowID) &&
            $0.width.isFinite && $0.height.isFinite && $0.width>=350 && $0.height>=550
        }.max { $0.width*$0.height < $1.width*$1.height }?.windowID
    }
}
