import AppKit
import CoreGraphics

/// Clicks into another app's window without moving the user's cursor, raising the window
/// or changing which app has focus.
///
/// Verified recipe for the iOS-on-Mac game (2026-11-04):
/// - the mouse events are posted to the game process (`postToPid`), never to the HID tap;
/// - field 51 (what AppKit reads as `NSEvent.windowNumber`) names the window, and the
///   window-local location is set — without these AppKit drops the event (windowNumber 0);
/// - UIKit only turns mouse events into touches while the app believes it is active, so the
///   game is *told* it was activated (an AppKit `applicationActivated` event posted to it
///   alone) and told it was deactivated afterwards. The system's frontmost app never changes,
///   so typing, open menus and the user's window are untouched.
/// Works with the game window covered.
@MainActor enum BackgroundInput {
    struct Failure:LocalizedError {let errorDescription:String?}

    /// What happened around one click, for the journal.
    struct Receipt {
        var frontBefore:String?,frontAfter:String?,milliseconds=0,toldActive=false
        var summary:String {
            "front=\(frontBefore ?? "-")→\(frontAfter ?? "-");toldActive=\(toldActive);ms=\(milliseconds)"
        }
    }

    private static let settleNanos:UInt64=40_000_000,pressNanos:UInt64=60_000_000,releaseNanos:UInt64=40_000_000

    static func click(pid:pid_t,windowID:CGWindowID,windowFrame:CGRect,at point:CGPoint)async throws->Receipt {
        guard let setWindowLocation=windowLocationSetter else{
            throw Failure(errorDescription:L("CGEventSetWindowLocation nem érhető el; háttérkattintás nem lehetséges.","CGEventSetWindowLocation unavailable; background clicks impossible."))
        }
        let local=CGPoint(x:point.x-windowFrame.minX,y:point.y-windowFrame.minY)
        guard local.x>=0,local.y>=0,local.x<=windowFrame.width,local.y<=windowFrame.height
        else{throw Failure(errorDescription:L("A célpont kívül esik a játékablakon.","Target is outside the game window."))}
        let front=NSWorkspace.shared.frontmostApplication
        var receipt=Receipt(frontBefore:front?.localizedName)
        let started=DispatchTime.now().uptimeNanoseconds
        // If the user is in the game, it is really active; don't tell it otherwise afterwards.
        receipt.toldActive=front?.processIdentifier != pid
        if receipt.toldActive {appKitEvent(.applicationActivated)?.postToPid(pid)}
        try? await Task.sleep(nanoseconds:settleNanos)
        func post(_ type:CGEventType) {
            guard let event=CGEvent(mouseEventSource:CGEventSource(stateID:.privateState),mouseType:type,
                                    mouseCursorPosition:point,mouseButton:.left) else{return}
            event.flags=[]
            event.setIntegerValueField(.mouseEventClickState,value:1)
            event.setIntegerValueField(.mouseEventWindowUnderMousePointer,value:Int64(windowID))
            event.setIntegerValueField(.mouseEventWindowUnderMousePointerThatCanHandleThisEvent,value:Int64(windowID))
            event.setIntegerValueField(CGEventField(rawValue:51)!,value:Int64(windowID))
            setWindowLocation(event,local)
            event.postToPid(pid)
        }
        post(.leftMouseDown)
        // The matching release always goes to the same process.
        try? await Task.sleep(nanoseconds:pressNanos)
        post(.leftMouseUp)
        try? await Task.sleep(nanoseconds:releaseNanos)
        if receipt.toldActive {appKitEvent(.applicationDeactivated)?.postToPid(pid)}
        receipt.frontAfter=NSWorkspace.shared.frontmostApplication?.localizedName
        receipt.milliseconds=Int((DispatchTime.now().uptimeNanoseconds-started)/1_000_000)
        return receipt
    }

    private static func appKitEvent(_ subtype:NSEvent.EventSubtype)->CGEvent? {
        NSEvent.otherEvent(with:.appKitDefined,location:.zero,modifierFlags:[],timestamp:ProcessInfo.processInfo.systemUptime,
                           windowNumber:0,context:nil,subtype:subtype.rawValue,data1:0,data2:0)?.cgEvent
    }

    private typealias SetWindowLocation=@convention(c)(CGEvent,CGPoint)->Void
    /// Private CoreGraphics call, loaded at runtime so a missing symbol degrades to an error.
    private static let windowLocationSetter:SetWindowLocation? =
        dlsym(dlopen(nil,RTLD_NOW),"CGEventSetWindowLocation").map{unsafeBitCast($0,to:SetWindowLocation.self)}
}
