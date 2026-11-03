import AppKit
import CoreGraphics

/// Holds back keystrokes for the ~0.2 s the game is the active app during a background
/// click, then replays them in order once the user's app has focus again. Without this,
/// anything typed in that moment would land in the game, so clicks had to wait for typing
/// pauses. Keystrokes are only buffered in memory and never logged.
@MainActor final class KeyboardShield {
    static let shared=KeyboardShield()
    /// Marks our own replayed events so the tap lets them through.
    private static let replayMarker:Int64=0x4248_4B53
    private var tap:CFMachPort?,source:CFRunLoopSource?
    private var held:[CGEvent]=[]
    private var shielding=false

    /// Whether keys can be held back (needs the Accessibility permission for an active event tap).
    var available:Bool {
        if tap==nil {install()}
        return tap != nil
    }

    /// Starts holding keys. Returns false if the tap can't be created (then callers fall back to waiting).
    func begin()->Bool {
        held.removeAll()
        guard available,let tap else{return false}
        shielding=true
        CGEvent.tapEnable(tap:tap,enable:true)
        return true
    }

    /// Replays held keys to whichever app is now focused, then stops intercepting.
    /// Returns how many key events were held (the count only, never the keys).
    @discardableResult func end()->Int {
        shielding=false
        let count=held.count
        for event in held {
            event.setIntegerValueField(.eventSourceUserData,value:Self.replayMarker)
            event.post(tap:.cgSessionEventTap)
        }
        held.removeAll()
        if let tap {CGEvent.tapEnable(tap:tap,enable:false)}
        return count
    }

    private func install() {
        let mask=[CGEventType.keyDown,.keyUp,.flagsChanged].reduce(CGEventMask(0)){$0|(1<<$1.rawValue)}
        let callback:CGEventTapCallBack={_,type,event,info in
            guard let info else{return Unmanaged.passUnretained(event)}
            let shield=Unmanaged<KeyboardShield>.fromOpaque(info).takeUnretainedValue()
            return MainActor.assumeIsolated{shield.handle(type,event)}
        }
        guard let tap=CGEvent.tapCreate(tap:.cgSessionEventTap,place:.headInsertEventTap,options:.defaultTap,
                                        eventsOfInterest:mask,callback:callback,
                                        userInfo:Unmanaged.passUnretained(self).toOpaque()) else{return}
        self.tap=tap
        source=CFMachPortCreateRunLoopSource(nil,tap,0)
        CFRunLoopAddSource(CFRunLoopGetMain(),source,.commonModes)
        CGEvent.tapEnable(tap:tap,enable:false)
    }

    private func handle(_ type:CGEventType,_ event:CGEvent)->Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if shielding,let tap {CGEvent.tapEnable(tap:tap,enable:true)}
            return Unmanaged.passUnretained(event)
        }
        guard shielding,event.getIntegerValueField(.eventSourceUserData) != Self.replayMarker,
              let copy=event.copy() else{return Unmanaged.passUnretained(event)}
        held.append(copy)
        return nil
    }
}
