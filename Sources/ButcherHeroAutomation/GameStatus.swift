import AppKit
import CoreGraphics
import Foundation

/// Metadata only. No screen capture, Accessibility input, focus or app launch.
@MainActor enum NativeGameStatus {
    static let bundleID="com.multicastgames.butcher"
    struct Status:Codable {
        let known:Bool
        let installed:Bool
        let running:Bool
        let hidden:Bool
        let windowVisible:Bool?
    }
    static func read()->Status {
        let workspace=NSWorkspace.shared
        let apps=workspace.runningApplications.filter{$0.bundleIdentifier==bundleID && !$0.isTerminated}
        let installed=workspace.urlForApplication(withBundleIdentifier:bundleID)
            .map{FileManager.default.fileExists(atPath:$0.path)} ?? false
        guard !apps.isEmpty else{return .init(known:true,installed:installed,running:false,hidden:false,windowVisible:false)}
        let hidden=apps.allSatisfy(\.isHidden),pids=Set(apps.map(\.processIdentifier))
        let windows=CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID) as? [[String:Any]]
        let visible=windows.map {rows in rows.contains {row in
            guard let pid=row[kCGWindowOwnerPID as String] as? NSNumber,pids.contains(pid.int32Value),
                  (row[kCGWindowLayer as String] as? NSNumber)?.intValue==0,
                  let bounds=row[kCGWindowBounds as String] as? [String:Any],
                  let rect=CGRect(dictionaryRepresentation:bounds as CFDictionary) else{return false}
            return rect.width>=350 && rect.height>=550
        }}
        return .init(known:true,installed:installed,running:true,hidden:hidden,windowVisible:visible)
    }
}
