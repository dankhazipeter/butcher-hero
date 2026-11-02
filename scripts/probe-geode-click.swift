// Manual, one-shot background click test. Run ONLY with the collector stopped
// and the normal game HUD visible. No OCR, collection loop, purchases or fallback.
import AppKit
import ApplicationServices
import Darwin

let usage="probe-geode-click cg|cg-move|appkit --hud-confirmed | --permissions"
let args=Array(CommandLine.arguments.dropFirst())
if args==["--permissions"] {print("accessibility=\(AXIsProcessTrusted());postEvent=\(CGPreflightPostEventAccess())");exit(0)}
guard args.count==2,["cg","cg-move","appkit"].contains(args[0]),args[1]=="--hud-confirmed" else {print(usage);exit(2)}
let lock=open("docs/runs/.live-capture.lock",O_CREAT|O_RDWR,mode_t(0o600))
guard lock>=0,flock(lock,LOCK_EX|LOCK_NB)==0 else{fputs("Collector active/unavailable lock; no input\n",stderr);exit(1)}
defer{flock(lock,LOCK_UN);close(lock)}
_ = NSApplication.shared;NSApplication.shared.setActivationPolicy(.prohibited)
let apps=NSWorkspace.shared.runningApplications.filter{$0.bundleIdentifier=="com.multicastgames.butcher" && !$0.isTerminated}
guard AXIsProcessTrusted(),CGPreflightPostEventAccess(),apps.count==1 else{fputs("Need existing Accessibility/post-event permission and exactly one game process\n",stderr);exit(1)}
let pid=apps[0].processIdentifier
let rows=(CGWindowListCopyWindowInfo(.optionOnScreenOnly,kCGNullWindowID) as? [[String:Any]] ?? []).filter {
    ($0[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value==pid && ($0[kCGWindowLayer as String] as? NSNumber)?.intValue==0
}.compactMap {row->(UInt32,CGRect)? in
    guard let id=row[kCGWindowNumber as String] as? NSNumber,let raw=row[kCGWindowBounds as String] as? [String:Any],
          let rect=CGRect(dictionaryRepresentation:raw as CFDictionary),rect.width>300,rect.height>500 else{return nil}
    return (id.uint32Value,rect)
}
guard rows.count==1,let foreground=NSWorkspace.shared.frontmostApplication?.processIdentifier,foreground != pid,
      let cursor=CGEvent(source:nil)?.location,!CGEventSource.buttonState(.combinedSessionState,button:.left),
      let source=CGEventSource(stateID:.privateState) else{fputs("Need normal HUD, one window, background game and released mouse\n",stderr);exit(1)}
let (window,frame)=rows[0],point=CGPoint(x:rows[0].1.minX+rows[0].1.width*0.945,y:rows[0].1.minY+rows[0].1.height*0.510)
func event(_ type:CGEventType)->CGEvent? {
    let result:CGEvent?
    if args[0]=="appkit" {
        result=NSEvent.mouseEvent(with:type == .leftMouseDown ? .leftMouseDown:.leftMouseUp,
            location:NSPoint(x:frame.width*0.945,y:frame.height*(1-0.510)),modifierFlags:[],
            timestamp:ProcessInfo.processInfo.systemUptime,windowNumber:Int(window),context:nil,eventNumber:0,clickCount:1,
            pressure:type == .leftMouseDown ? 1:0)?.cgEvent
    } else {result=CGEvent(mouseEventSource:source,mouseType:type,mouseCursorPosition:point,mouseButton:.left)}
    result?.setSource(source);result?.location=point;result?.flags=[]
    result?.setIntegerValueField(.mouseEventClickState,value:type == .mouseMoved ? 0:1)
    result?.setIntegerValueField(.mouseEventWindowUnderMousePointer,value:Int64(window))
    result?.setIntegerValueField(.mouseEventWindowUnderMousePointerThatCanHandleThisEvent,value:Int64(window))
    return result
}
guard let down=event(.leftMouseDown),let up=event(.leftMouseUp) else{fputs("Packet unavailable; no input\n",stderr);exit(1)}
if args[0]=="cg-move" {
    guard let move=event(.mouseMoved) else{exit(1)}
    move.postToPid(pid);usleep(25_000)
    guard NSWorkspace.shared.frontmostApplication?.processIdentifier==foreground,CGEvent(source:nil)?.location==cursor else{fputs("Move disturbed focus/cursor; no click\n",stderr);exit(1)}
}
guard NSWorkspace.shared.frontmostApplication?.processIdentifier==foreground,CGEvent(source:nil)?.location==cursor else{exit(1)}
// Keep the pair together on Ctrl+C/TERM; SIGKILL cannot be guarded against.
let oldINT=signal(SIGINT,SIG_IGN),oldTERM=signal(SIGTERM,SIG_IGN)
down.postToPid(pid);usleep(70_000);up.postToPid(pid)
signal(SIGINT,oldINT);signal(SIGTERM,oldTERM);usleep(300_000)
print("mode=\(args[0]);gamePID=\(pid);window=\(window);frame=\(frame);target=\(point);foregroundBefore=\(foreground);foregroundAfter=\(NSWorkspace.shared.frontmostApplication?.processIdentifier ?? 0);cursorBefore=\(cursor);cursorAfter=\(String(describing:CGEvent(source:nil)?.location));NO activate/warp/global tap")
