import AppKit
import ApplicationServices
import CoreGraphics
import ScreenCaptureKit
import RewardAutomationCore

struct AppError:LocalizedError {
    let errorDescription:String?
    init(_ message:String){errorDescription=message}
}

/// The user is playing the game by hand right now; input waits.
struct HumanInputBusy:LocalizedError {
    let reason:HumanInput.Busy
    var errorDescription:String?{reason.description}
}

/// Background clicks never touch the user's focus, cursor or keyboard, so whatever they do
/// in other apps is irrelevant. Only when the game itself is the active app (the user plays)
/// does a held or just-released mouse button defer input, so the two never collide.
enum HumanInput {
    enum Busy:Equatable,CustomStringConvertible {
        case buttonHeld,recentClick(Double)
        var description:String {
            switch self {
            case .buttonHeld:L("A játékban épp lenyomva tartod az egérgombot; elengedés után kattintok.","You are holding a mouse button in the game; clicking after release.")
            case .recentClick(let s):L("Épp kattintottál a játékban (\(String(format:"%.2f",s)) mp); rövid szünet után kattintok.","You just clicked in the game (\(String(format:"%.2f",s)) s ago); clicking after a short pause.")
            }
        }
    }
    static var buttonDown:Bool {
        (0..<5).contains{CGEventSource.buttonState(.combinedSessionState,button:CGMouseButton(rawValue:UInt32($0))!)}
    }
    @MainActor static var busy:Busy? {
        guard NSWorkspace.shared.frontmostApplication?.bundleIdentifier==GameIO.bundleID else{return nil}
        if buttonDown {return .buttonHeld}
        let buttons:[CGEventType]=[.leftMouseDown,.leftMouseUp,.leftMouseDragged,
            .rightMouseDown,.rightMouseUp,.rightMouseDragged,.otherMouseDown,.otherMouseUp,.otherMouseDragged]
        let mouseQuiet=buttons.map{CGEventSource.secondsSinceLastEventType(.combinedSessionState,eventType:$0)}.min() ?? 0
        if !RewardInputPolicy.permitsClick(anyButtonDown:false,secondsSinceButtonActivity:mouseQuiet) {return .recentClick(mouseQuiet)}
        return nil
    }
    @MainActor static var ready:Bool {busy==nil}
}

struct Frame {
    let image:CGImage,window:SCWindow
    let capturedAt:Date
    var pid:pid_t? {window.owningApplication?.processID}
}

@MainActor enum GameIO {
    static let bundleID="com.multicastgames.butcher"

    static func frame()async throws->Frame {
        guard !displays().isEmpty else{throw AppError("Nincs aktív kijelző; a képernyők ébredésére várok.")}
        let content=try await SCShareableContent.excludingDesktopWindows(false,onScreenWindowsOnly:true)
        let selected=GameCapturePolicy.selectWindow(content.windows.map {
            .init(windowID:$0.windowID,processID:$0.owningApplication?.processID,
                  bundleIdentifier:$0.owningApplication?.bundleIdentifier,width:$0.frame.width,height:$0.frame.height)
        })
        guard let window=content.windows.first(where:{$0.windowID==selected})
        else{throw AppError("A játék ablaka nem található; várakozás.")}
        let config=SCStreamConfiguration()
        config.width=Int(window.frame.width.rounded());config.height=Int(window.frame.height.rounded())
        config.showsCursor=false;config.ignoreShadowsSingleWindow=true;config.captureResolution = .best
        let image=try await SCScreenshotManager.captureImage(contentFilter:SCContentFilter(desktopIndependentWindow:window),configuration:config)
        return Frame(image:image,window:window,capturedAt:Date())
    }

    /// Clicks a normalized point of a freshly captured frame in the background.
    /// The window must still be where the frame saw it; nothing is raised or warped.
    static func click(normalized:CGPoint,in frame:Frame)async throws->String {
        guard AXIsProcessTrusted() else{throw AppError("A kattintáshoz Accessibility-engedély szükséges.")}
        guard let pid=frame.pid,NSRunningApplication(processIdentifier:pid)?.bundleIdentifier==bundleID
        else{throw AppError("A játékfolyamat eltűnt.")}
        let windowID=frame.window.windowID
        guard let current=bounds(windowID:windowID,pid:pid),
              let point=RewardInputGeometry.target(normalized:normalized,
                imageSize:.init(width:frame.image.width,height:frame.image.height),
                capturedWindow:frame.window.frame,currentWindow:current,activeDisplays:displays())
        else{throw AppError("Kattintási geometria elutasítva; window=\(windowID);frame=\(frame.window.frame)")}
        if let busy=HumanInput.busy {throw HumanInputBusy(reason:busy)}
        let receipt=try await BackgroundInput.click(pid:pid,windowID:windowID,windowFrame:current,at:point)
        return "background;window=\(windowID);frame=\(current);image=\(frame.image.width)x\(frame.image.height);target=\(point);\(receipt.summary)"
    }

    static func bounds(windowID:CGWindowID,pid:pid_t)->CGRect? {
        guard let rows=CGWindowListCopyWindowInfo([.optionIncludingWindow],windowID) as? [[String:Any]],
              let row=rows.first(where:{($0[kCGWindowNumber as String] as? NSNumber)?.uint32Value==windowID}),
              (row[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value==pid,
              (row[kCGWindowIsOnscreen as String] as? NSNumber)?.boolValue==true,
              let raw=row[kCGWindowBounds as String] as? [String:Any] else{return nil}
        return CGRect(dictionaryRepresentation:raw as CFDictionary)
    }
    static func displays()->[CGRect] {
        var ids=[CGDirectDisplayID](repeating:0,count:32),count:UInt32=0
        guard CGGetActiveDisplayList(32,&ids,&count) == .success else{return []}
        return ids.prefix(Int(count)).map{CGDisplayBounds($0)}
    }
}
