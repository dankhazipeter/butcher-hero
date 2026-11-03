import AppKit
import CoreGraphics

/// Clicks into another app's window without moving the user's cursor or raising the window.
///
/// Verified recipe for the iOS-on-Mac game (2026-11-03):
/// - the mouse events are posted to the game process (`postToPid`), never to the HID tap;
/// - field 51 (what AppKit reads as `NSEvent.windowNumber`) names the window, and the
///   window-local location is set — without these AppKit drops the event (windowNumber 0);
/// - UIKit only turns mouse events into touches for the active app, so the game is made
///   frontmost for ~0.2 s *without* bringing its windows forward (SkyLight, as yabai does),
///   then the previously active app gets focus back.
/// Works with the game window covered by other windows.
@MainActor enum BackgroundInput {
    struct Failure:LocalizedError {let errorDescription:String?}

    static func click(pid:pid_t,windowID:CGWindowID,windowFrame:CGRect,at point:CGPoint)async throws {
        guard let api=SkyLight.shared else{throw Failure(errorDescription:"SkyLight nem érhető el; háttérkattintás nem lehetséges.")}
        let local=CGPoint(x:point.x-windowFrame.minX,y:point.y-windowFrame.minY)
        guard local.x>=0,local.y>=0,local.x<=windowFrame.width,local.y<=windowFrame.height
        else{throw Failure(errorDescription:"A célpont kívül esik a játékablakon.")}
        let previous=NSWorkspace.shared.frontmostApplication
        let previousWindow=previous.flatMap{frontWindow(of:$0.processIdentifier)}
        guard let target=api.psn(pid) else{throw Failure(errorDescription:"A játékfolyamat nem címezhető.")}
        let needsFocus=previous?.processIdentifier != pid
        if needsFocus {api.setFront(target,windowID)}
        api.makeKey(target,windowID)
        try? await Task.sleep(nanoseconds:50_000_000)
        post(.leftMouseDown,pid:pid,windowID:windowID,global:point,local:local)
        // The matching release always goes to the same process.
        try? await Task.sleep(nanoseconds:80_000_000)
        post(.leftMouseUp,pid:pid,windowID:windowID,global:point,local:local)
        try? await Task.sleep(nanoseconds:80_000_000)
        guard needsFocus,let previous,!previous.isTerminated else{return}
        // If the user switched to a third app meanwhile, leave their choice alone.
        let front=NSWorkspace.shared.frontmostApplication?.processIdentifier
        guard front==nil || front==pid || front==previous.processIdentifier,
              let back=api.psn(previous.processIdentifier) else{return}
        api.setFront(back,previousWindow ?? 0)
        if let previousWindow {api.makeKey(back,previousWindow)}
    }

    private static func post(_ type:CGEventType,pid:pid_t,windowID:CGWindowID,global:CGPoint,local:CGPoint) {
        guard let event=CGEvent(mouseEventSource:CGEventSource(stateID:.privateState),mouseType:type,
                                mouseCursorPosition:global,mouseButton:.left) else{return}
        event.flags=[]
        event.setIntegerValueField(.mouseEventClickState,value:1)
        event.setIntegerValueField(.mouseEventWindowUnderMousePointer,value:Int64(windowID))
        event.setIntegerValueField(.mouseEventWindowUnderMousePointerThatCanHandleThisEvent,value:Int64(windowID))
        event.setIntegerValueField(CGEventField(rawValue:51)!,value:Int64(windowID))
        SkyLight.shared?.setWindowLocation(event,local)
        event.postToPid(pid)
    }

    /// Frontmost normal-layer window of a process (window lists are front-to-back).
    private static func frontWindow(of pid:pid_t)->CGWindowID? {
        let rows=CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID) as? [[String:Any]] ?? []
        return rows.first{
            ($0[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value==pid && ($0[kCGWindowLayer as String] as? NSNumber)?.intValue==0
        }.flatMap{($0[kCGWindowNumber as String] as? NSNumber)?.uint32Value}
    }
}

/// Private window-server calls, loaded at runtime so a missing symbol degrades to an error.
private final class SkyLight {
    static let shared=SkyLight()
    private typealias SetFront=@convention(c)(UnsafeMutablePointer<ProcessSerialNumber>,UInt32,UInt32)->Int32
    private typealias PostRecord=@convention(c)(UnsafeMutablePointer<ProcessSerialNumber>,UnsafeMutablePointer<UInt8>)->Int32
    private typealias PSNForPID=@convention(c)(pid_t,UnsafeMutablePointer<ProcessSerialNumber>)->Int32
    private typealias SetWindowLocation=@convention(c)(CGEvent,CGPoint)->Void
    private let setFrontFn:SetFront,postRecordFn:PostRecord,psnFn:PSNForPID,windowLocationFn:SetWindowLocation
    private static let noWindows:UInt32=0x400 // kCPSNoWindows: activate without raising windows

    private init?() {
        let sky=dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight",RTLD_NOW)
        let services=dlopen("/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices",RTLD_NOW)
        guard let a=dlsym(sky,"_SLPSSetFrontProcessWithOptions"),let b=dlsym(sky,"SLPSPostEventRecordTo"),
              let c=dlsym(services,"GetProcessForPID"),let d=dlsym(dlopen(nil,RTLD_NOW),"CGEventSetWindowLocation") else{return nil}
        setFrontFn=unsafeBitCast(a,to:SetFront.self);postRecordFn=unsafeBitCast(b,to:PostRecord.self)
        psnFn=unsafeBitCast(c,to:PSNForPID.self);windowLocationFn=unsafeBitCast(d,to:SetWindowLocation.self)
    }
    func psn(_ pid:pid_t)->ProcessSerialNumber? {
        var psn=ProcessSerialNumber()
        return psnFn(pid,&psn)==0 ? psn:nil
    }
    func setFront(_ psn:ProcessSerialNumber,_ windowID:CGWindowID) {
        var psn=psn;_=setFrontFn(&psn,windowID,Self.noWindows)
    }
    /// The two event records yabai uses to make a window key without ordering it front.
    func makeKey(_ psn:ProcessSerialNumber,_ windowID:CGWindowID) {
        var psn=psn
        for kind:UInt8 in [0x01,0x02] {
            var bytes=[UInt8](repeating:0,count:0xf8)
            bytes[0x04]=0xf8;bytes[0x08]=kind;bytes[0x3a]=0x10
            withUnsafeBytes(of:windowID.littleEndian){for (i,b) in $0.enumerated(){bytes[0x3c+i]=b}}
            for i in 0x20..<0x30 {bytes[i]=0xff}
            _=postRecordFn(&psn,&bytes)
        }
    }
    func setWindowLocation(_ event:CGEvent,_ point:CGPoint) {windowLocationFn(event,point)}
}
