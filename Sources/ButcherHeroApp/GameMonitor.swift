import AppKit
import CoreGraphics

/// Watches whether the game is installed, running and has a usable window.
@MainActor final class GameMonitor:ObservableObject {
    enum State:Equatable {case notInstalled,notRunning,launching,windowUnavailable,running}
    @Published private(set) var state:State = .notRunning
    @Published private(set) var hidden=false
    @Published private(set) var pid:pid_t?
    @Published private(set) var checkedAt=Date()
    private var timer:Timer?,launchRequestedAt:Date?,observers:[NSObjectProtocol]=[]

    init() {
        refresh()
        timer=Timer.scheduledTimer(withTimeInterval:2,repeats:true){[weak self] _ in Task{@MainActor in self?.refresh()}}
        let center=NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.didLaunchApplicationNotification,NSWorkspace.didTerminateApplicationNotification,
                     NSWorkspace.didHideApplicationNotification,NSWorkspace.didUnhideApplicationNotification] {
            observers.append(center.addObserver(forName:name,object:nil,queue:.main){[weak self] _ in
                Task{@MainActor in self?.refresh()}
            })
        }
    }

    var installedURL:URL? {NSWorkspace.shared.urlForApplication(withBundleIdentifier:GameIO.bundleID)}

    func refresh() {
        checkedAt=Date()
        let apps=NSWorkspace.shared.runningApplications.filter{$0.bundleIdentifier==GameIO.bundleID && !$0.isTerminated}
        guard let app=apps.first else {
            pid=nil;hidden=false
            if let at=launchRequestedAt,Date().timeIntervalSince(at)<20 {state = .launching}
            else {state=installedURL==nil ? .notInstalled:.notRunning}
            return
        }
        launchRequestedAt=nil
        pid=app.processIdentifier;hidden=apps.allSatisfy(\.isHidden)
        state=hasGameWindow(pids:Set(apps.map(\.processIdentifier))) ? .running:.windowUnavailable
    }

    /// Opens the game in the background; it never steals focus from the user.
    func launch() {
        guard state != .running,let url=installedURL else{return}
        launchRequestedAt=Date();state = .launching
        let config=NSWorkspace.OpenConfiguration();config.activates=false
        NSWorkspace.shared.openApplication(at:url,configuration:config){_,_ in Task{@MainActor in self.refresh()}}
    }

    private func hasGameWindow(pids:Set<pid_t>)->Bool {
        let rows=CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID) as? [[String:Any]] ?? []
        return rows.contains {row in
            guard let pid=row[kCGWindowOwnerPID as String] as? NSNumber,pids.contains(pid.int32Value),
                  (row[kCGWindowLayer as String] as? NSNumber)?.intValue==0,
                  let raw=row[kCGWindowBounds as String] as? [String:Any],
                  let rect=CGRect(dictionaryRepresentation:raw as CFDictionary) else{return false}
            return rect.width>=350 && rect.height>=550
        }
    }
}
