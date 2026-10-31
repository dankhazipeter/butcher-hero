import AppKit
import ApplicationServices
import Darwin
import Foundation
import ImageIO
import ScreenCaptureKit
import UniformTypeIdentifiers
import RewardAutomationCore

private struct AutomationError: LocalizedError {
    let errorDescription:String?
    init(_ message:String){errorDescription=message}
}

private final class Cancellation: @unchecked Sendable {
    private let lock=NSLock()
    private var stopped=false
    private var sources:[DispatchSourceSignal]=[]
    init(){for sig in [SIGINT,SIGTERM] {
        signal(sig,SIG_IGN)
        let source=DispatchSource.makeSignalSource(signal:sig,queue:.global())
        source.setEventHandler{[weak self] in self?.lock.lock();self?.stopped=true;self?.lock.unlock()}
        source.resume();sources.append(source)
    }}
    var requested:Bool {lock.lock();defer{lock.unlock()};return stopped}
}

private struct Frame {
    let image:CGImage,window:SCWindow
    let capturedAt:Date
}

private struct HumanInputBusy:LocalizedError {
    var errorDescription:String?{"Kézi egérgomb/húzás aktív; elengedés után újraellenőrzöm a Free kártyát."}
}

private enum HumanInput {
    static var buttonDown:Bool {
        (0..<5).contains {CGEventSource.buttonState(.combinedSessionState,button:CGMouseButton(rawValue:UInt32($0))!)}
    }
    static var ready:Bool {
        let events:[CGEventType]=[.leftMouseDown,.leftMouseUp,.leftMouseDragged,
            .rightMouseDown,.rightMouseUp,.rightMouseDragged,.otherMouseDown,.otherMouseUp,.otherMouseDragged]
        let quiet=events.map{CGEventSource.secondsSinceLastEventType(.combinedSessionState,eventType:$0)}.min() ?? 0
        return RewardInputPolicy.permitsClick(anyButtonDown:buttonDown,secondsSinceButtonActivity:quiet)
    }
}

@MainActor private final class Capture {
    func frame()async throws->Frame {
        let content=try await SCShareableContent.excludingDesktopWindows(false,onScreenWindowsOnly:true)
        let windows=content.windows.filter {
            $0.owningApplication?.bundleIdentifier=="com.multicastgames.butcher" ||
            ($0.title ?? "").lowercased().contains("butcher hero")
        }
        guard let window=windows.max(by:{$0.frame.width*$0.frame.height<$1.frame.width*$1.frame.height}),
              window.frame.width>=350,window.frame.height>=550 else{throw AutomationError("Játékablak nem található; várakozás.")}
        let config=SCStreamConfiguration()
        config.width=Int(window.frame.width.rounded());config.height=Int(window.frame.height.rounded())
        config.showsCursor=false;config.ignoreShadowsSingleWindow=true;config.captureResolution = .best
        let image=try await SCScreenshotManager.captureImage(contentFilter:SCContentFilter(desktopIndependentWindow:window),configuration:config)
        return Frame(image:image,window:window,capturedAt:Date())
    }
    func click(_ reward:FreeReward,frame:Frame,cancellation:Cancellation,
               rejected:(Frame,RewardObservation,String)throws->Void,
               validated:(Frame,FreeReward)throws->String)async throws->(sentAt:Date,reward:FreeReward,evidence:String) {
        guard HumanInput.ready else{throw HumanInputBusy()}
        guard AXIsProcessTrusted() else{throw AutomationError("A kattintáshoz Accessibility-engedély szükséges.")}
        guard let pid=frame.window.owningApplication?.processID,let app=NSRunningApplication(processIdentifier:pid) else{throw AutomationError("A játékfolyamat eltűnt.")}
        let previous=NSWorkspace.shared.frontmostApplication
        var cursor:CGPoint?,warped=false
        app.activate()
        defer {
            // If a human started a drag during validation, don't warp their
            // cursor or switch applications under the newly held button.
            if !HumanInput.buttonDown {
                if warped,let cursor {CGWarpMouseCursorPosition(cursor)}
                if let previous,previous.processIdentifier != pid {previous.activate()}
            }
        }
        try await Task.sleep(nanoseconds:180_000_000)
        guard HumanInput.ready else{throw HumanInputBusy()}
        // Revalidate after activation: no click from a stale screenshot or moved window.
        let validationStarted=ProcessInfo.processInfo.systemUptime
        var validation=RewardPreclickValidation(expectedFingerprint:reward.fingerprint)
        var accepted:(Frame,FreeReward)?
        while accepted==nil {
            guard HumanInput.ready else{throw HumanInputBusy()}
            let fresh=try await self.frame(),observation=try RewardVision().observe(fresh.image)
            let elapsed=ProcessInfo.processInfo.systemUptime-validationStarted
            let decision=validation.observe(fingerprint:observation.reward?.fingerprint,
                sameWindow:fresh.window.windowID==frame.window.windowID,cancelled:cancellation.requested,elapsed:elapsed)
            if decision == .accept,let current=observation.reward {accepted=(fresh,current);break}
            let reason=cancellation.requested ? "cancelled":fresh.window.windowID != frame.window.windowID ? "window_changed":
                elapsed>1.2 ? "validation_timeout":observation.reward == nil ? observation.diagnosticReason ?? "reward_unreadable":"fingerprint_changed"
            try rejected(fresh,observation,"\(reason);decision=\(decision)")
            guard decision == .retry else{throw AutomationError("Free preclick rejected: \(reason)")}
            try await Task.sleep(nanoseconds:150_000_000)
        }
        guard let (fresh,current)=accepted else{throw AutomationError("Free reward missing after validation")}
        let evidence=try validated(fresh,current)
        let point=CGPoint(x:fresh.window.frame.minX+current.tapX*fresh.window.frame.width,
                          y:fresh.window.frame.minY+current.tapY*fresh.window.frame.height)
        guard let source=CGEventSource(stateID:.hidSystemState),
              let down=CGEvent(mouseEventSource:source,mouseType:.leftMouseDown,mouseCursorPosition:point,mouseButton:.left),
              let up=CGEvent(mouseEventSource:source,mouseType:.leftMouseUp,mouseCursorPosition:point,mouseButton:.left) else{throw AutomationError("Kattintási esemény nem hozható létre.")}
        guard !cancellation.requested else{throw AutomationError("Leállítás kérve; nincs kattintás.")}
        guard HumanInput.ready else{throw HumanInputBusy()}
        cursor=CGEvent(source:nil)?.location
        CGWarpMouseCursorPosition(point);warped=true
        let sentAt=Date()
        down.post(tap:.cghidEventTap)
        // Always release the mouse, including on task cancellation.
        try? await Task.sleep(nanoseconds:70_000_000)
        up.post(tap:.cghidEventTap)
        return (sentAt,current,evidence)
    }
    func crystalClick(_ action:CrystalAction,frame:Frame,cancellation:Cancellation,
                      validated:(Frame,CrystalObservation)throws->Void)async throws {
        guard HumanInput.ready else{throw HumanInputBusy()}
        guard AXIsProcessTrusted(),let pid=frame.window.owningApplication?.processID,
              let app=NSRunningApplication(processIdentifier:pid) else{throw AutomationError("Crystal input unavailable")}
        let previous=NSWorkspace.shared.frontmostApplication
        var cursor:CGPoint?,warped=false
        app.activate()
        defer {
            if !HumanInput.buttonDown {
                if warped,let cursor {CGWarpMouseCursorPosition(cursor)}
                if let previous,previous.processIdentifier != pid {previous.activate()}
            }
        }
        try await Task.sleep(nanoseconds:180_000_000)
        guard !cancellation.requested,HumanInput.ready else{throw HumanInputBusy()}
        let fresh=try await self.frame()
        guard fresh.window.windowID==frame.window.windowID else{throw AutomationError("Crystal window changed")}
        let hud=try RewardVision().observe(fresh.image).gameHUDVisible
        let observation=try CrystalVision().observe(fresh.image,hudVisible:hud)
        guard action.permits(observation) else{throw AutomationError("Crystal preclick rejected: \(action.rawValue)/\(observation.screen.rawValue)")}
        try validated(fresh,observation)
        let point=CGPoint(x:fresh.window.frame.minX+action.point.x*fresh.window.frame.width,
                          y:fresh.window.frame.minY+action.point.y*fresh.window.frame.height)
        guard !cancellation.requested,HumanInput.ready,
              let source=CGEventSource(stateID:.hidSystemState),
              let down=CGEvent(mouseEventSource:source,mouseType:.leftMouseDown,mouseCursorPosition:point,mouseButton:.left),
              let up=CGEvent(mouseEventSource:source,mouseType:.leftMouseUp,mouseCursorPosition:point,mouseButton:.left)
        else{throw HumanInputBusy()}
        cursor=CGEvent(source:nil)?.location;CGWarpMouseCursorPosition(point);warped=true
        down.post(tap:.cghidEventTap)
        try? await Task.sleep(nanoseconds:70_000_000)
        up.post(tap:.cghidEventTap)
    }
    func eventEndClick(_ action:EventEndAction,frame:Frame,cancellation:Cancellation,
                       validated:(Frame,EventEndObservation)throws->Void)async throws {
        guard HumanInput.ready else{throw HumanInputBusy()}
        guard AXIsProcessTrusted(),let pid=frame.window.owningApplication?.processID,
              let app=NSRunningApplication(processIdentifier:pid) else{throw AutomationError("Event input unavailable")}
        let previous=NSWorkspace.shared.frontmostApplication
        var cursor:CGPoint?,warped=false
        app.activate()
        defer {
            if !HumanInput.buttonDown {
                if warped,let cursor {CGWarpMouseCursorPosition(cursor)}
                if let previous,previous.processIdentifier != pid {previous.activate()}
            }
        }
        try await Task.sleep(nanoseconds:180_000_000)
        guard !cancellation.requested,HumanInput.ready else{throw HumanInputBusy()}
        let fresh=try await self.frame()
        guard fresh.window.windowID==frame.window.windowID else{throw AutomationError("Event window changed")}
        let hud=try RewardVision().observe(fresh.image).gameHUDVisible
        let observation=try EventEndVision().observe(fresh.image,hudVisible:hud)
        let age=Date().timeIntervalSince(fresh.capturedAt)
        guard action.permits(observation,sameWindow:fresh.window.windowID==frame.window.windowID,
                             cancelled:cancellation.requested,elapsed:age)
        else{throw AutomationError("Event preclick rejected: \(action.rawValue)/\(observation.screen.rawValue); age=\(age);cancelled=\(cancellation.requested)")}
        try validated(fresh,observation)
        let point=CGPoint(x:fresh.window.frame.minX+action.point.x*fresh.window.frame.width,
                          y:fresh.window.frame.minY+action.point.y*fresh.window.frame.height)
        guard !cancellation.requested,HumanInput.ready,
              let source=CGEventSource(stateID:.hidSystemState),
              let down=CGEvent(mouseEventSource:source,mouseType:.leftMouseDown,mouseCursorPosition:point,mouseButton:.left),
              let up=CGEvent(mouseEventSource:source,mouseType:.leftMouseUp,mouseCursorPosition:point,mouseButton:.left)
        else{throw HumanInputBusy()}
        cursor=CGEvent(source:nil)?.location;CGWarpMouseCursorPosition(point);warped=true
        down.post(tap:.cghidEventTap)
        try? await Task.sleep(nanoseconds:70_000_000)
        up.post(tap:.cghidEventTap)
    }
}

private struct JournalEvent:Codable {
    let schemaVersion:Int
    let event:String, timestamp:String, runID:String
    let claimID:String?
    let reward:FreeReward?
    let evidence:String?
    let message:String?
}

private struct WatchState:Codable {
    var blockedFingerprint:String?
    var pid:Int32
    var running:Bool
    var intervalSeconds:Double
    var lastCheckedAt:String?
    var waitingForMouseRelease:Bool? = nil
    var pendingClaimID:String? = nil
    var verificationMode:String? = nil
    var ocrBackend:String? = nil
    var crystalPhase:String? = nil
    var eventEndPhase:String? = nil
}

private final class Journal {
    let root:URL,runID=UUID().uuidString
    let encoder=JSONEncoder()
    let handle:FileHandle
    init(root:URL)throws {
        self.root=root
        try FileManager.default.createDirectory(at:root.appendingPathComponent("evidence"),withIntermediateDirectories:true)
        let path=root.appendingPathComponent("events.jsonl")
        let fd=open(path.path,O_CREAT|O_WRONLY|O_APPEND,mode_t(0o600))
        guard fd>=0 else{throw AutomationError("Jutalomnapló nem nyitható meg.")}
        handle=FileHandle(fileDescriptor:fd,closeOnDealloc:true)
        encoder.outputFormatting=[.sortedKeys,.withoutEscapingSlashes]
    }
    deinit{try? handle.close()}
    static func stamp(_ date:Date=Date())->String {
        let f=ISO8601DateFormatter();f.formatOptions=[.withInternetDateTime,.withFractionalSeconds];return f.string(from:date)
    }
    func append(_ event:String,claimID:String?=nil,reward:FreeReward?=nil,evidence:String?=nil,message:String?=nil,at:Date=Date())throws {
        let e=JournalEvent(schemaVersion:1,event:event,timestamp:Self.stamp(at),runID:runID,claimID:claimID,reward:reward,evidence:evidence,message:message)
        var data=try encoder.encode(e);data.append(10)
        guard flock(handle.fileDescriptor,LOCK_EX)==0 else{throw AutomationError("Jutalomnapló nem zárolható.")}
        defer{flock(handle.fileDescriptor,LOCK_UN)}
        try handle.write(contentsOf:data);try handle.synchronize()
    }
    func image(_ image:CGImage,id:String,suffix:String)throws->String {
        let relative="evidence/\(id)-\(suffix).png",url=root.appendingPathComponent(relative)
        guard let destination=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil) else{throw AutomationError("Bizonyítékkép nem menthető.")}
        CGImageDestinationAddImage(destination,image,nil)
        guard CGImageDestinationFinalize(destination) else{throw AutomationError("Bizonyítékkép mentése sikertelen.")}
        return relative
    }
    func state(_ state:WatchState)throws {try encoder.encode(state).write(to:root.appendingPathComponent("state.json"),options:.atomic)}
}

@main struct Automation {
    @MainActor static func main()async {
        _ = NSApplication.shared
        NSApplication.shared.setActivationPolicy(.prohibited)
        do {try await run(Array(CommandLine.arguments.dropFirst()))}
        catch {fputs("HIBA: \(error.localizedDescription)\n",stderr);exit(1)}
    }
    @MainActor static func run(_ args:[String])async throws {
        guard let command=args.first else{print(usage);return}
        if command=="badge-signature" {
            guard args.count==2,let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:args[1]) as CFURL,nil),
                  let image=CGImageSourceCreateImageAtIndex(source,0,nil),let signature=try FreeBadgeMatcher.calibrationSignature(image)
            else{throw AutomationError("badge-signature <visually-reviewed-FREE.png>")}
            print(String(decoding:try JSONEncoder().encode(signature),as:UTF8.self));return
        }
        if command=="inspect" {
            guard args.count==2,let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:args[1]) as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil) else{throw AutomationError("inspect <frame.png>")}
            let encoder=JSONEncoder();encoder.outputFormatting=[.prettyPrinted,.sortedKeys]
            print(String(decoding:try encoder.encode(RewardVision().observe(image)),as:UTF8.self));return
        }
        if command=="inspect-crystal" || command=="inspect-event" {
            guard args.count==2,let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:args[1]) as CFURL,nil),
                  let image=CGImageSourceCreateImageAtIndex(source,0,nil) else{throw AutomationError("inspect-crystal <frame.png>")}
            let hud=try RewardVision().observe(image).gameHUDVisible
            if command=="inspect-event" {
                print(String(decoding:try JSONEncoder().encode(EventEndVision().observe(image,hudVisible:hud)),as:UTF8.self))
            } else {
                print(String(decoding:try JSONEncoder().encode(CrystalVision().observe(image,hudVisible:hud)),as:UTF8.self))
            };return
        }
        if command=="snapshot" {
            guard args.count==2 else{throw AutomationError("snapshot <output.png>")}
            let frame=try await Capture().frame()
            guard let destination=CGImageDestinationCreateWithURL(URL(fileURLWithPath:args[1]) as CFURL,UTType.png.identifier as CFString,1,nil)
            else{throw AutomationError("Snapshot destination unavailable")}
            CGImageDestinationAddImage(destination,frame.image,nil)
            guard CGImageDestinationFinalize(destination) else{throw AutomationError("Snapshot failed")};return
        }
        let root=URL(fileURLWithPath:FileManager.default.currentDirectoryPath).appendingPathComponent("data/free-rewards")
        if command=="stats" {try stats(root:root,args:Array(args.dropFirst()));return}
        if command=="reconcile" {try reconcile(root:root,args:Array(args.dropFirst()));return}
        guard command=="watch-free" else{throw AutomationError(usage)}
        var interval=1.0,seconds=Double.infinity,dryRun=false,resumeRun=false,recoverCrystal=false
        var i=1
        while i<args.count {
            switch args[i] {
            case "--dry-run":dryRun=true
            case "--resume-run":resumeRun=true
            case "--recover-crystal":recoverCrystal=true
            case "--interval","--seconds":
                guard i+1<args.count,let n=Double(args[i+1]),n.isFinite,n>0 else{throw AutomationError("Hiányzó/hibás időérték.")}
                if args[i]=="--interval" {guard n>=1 else{throw AutomationError("Legalább1másodperces mintavétel kell.")};interval=n}else{seconds=n};i+=1
            default:throw AutomationError("Ismeretlen kapcsoló: \(args[i])")
            };i+=1
        }
        try await watch(root:root,interval:interval,seconds:seconds,dryRun:dryRun,resumeRun:resumeRun,recoverCrystal:recoverCrystal)
    }
    @MainActor static func watch(root:URL,interval:Double,seconds:Double,dryRun:Bool,resumeRun:Bool=false,recoverCrystal:Bool=false)async throws {
        try FileManager.default.createDirectory(atPath:"docs/runs",withIntermediateDirectories:true)
        let lockFD=open("docs/runs/.live-capture.lock",O_CREAT|O_RDWR,mode_t(0o600))
        guard lockFD>=0 else{throw AutomationError("Képrögzítési zár nem hozható létre.")}
        guard flock(lockFD,LOCK_EX|LOCK_NB)==0 else{close(lockFD);throw AutomationError("Már fut élő játékfigyelő; másodikat nem indítok.")}
        defer{flock(lockFD,LOCK_UN);close(lockFD)}
        if !dryRun && !AXIsProcessTrusted(){throw AutomationError("Accessibility-engedély hiányzik.")}
        let journal=try Journal(root:root),capture=Capture(),vision=RewardVision(),cancel=Cancellation()
        let crystalJournal=try Journal(root:root.deletingLastPathComponent().appendingPathComponent("crystal-rewards"))
        let crystalVision=CrystalVision()
        var crystal=CrystalFlow(),crystalID:String?,crystalScreen:CrystalScreen?,crystalFailure:String?
        let eventJournal=try Journal(root:root.deletingLastPathComponent().appendingPathComponent("event-dismissals"))
        let eventVision=EventEndVision()
        var eventFlow=EventEndFlow(),eventID:String?,eventScreen:EventEndScreen?,eventFailure:String?
        if recoverCrystal {
            let path=crystalJournal.root.appendingPathComponent("events.jsonl")
            let events=(try String(contentsOf:path,encoding:.utf8)).split(separator:"\n").compactMap{try? JSONDecoder().decode(JournalEvent.self,from:Data($0.utf8))}
            guard let start=events.last(where:{$0.event=="crystal_started"}),let id=start.claimID,
                  let at=ISO8601DateFormatter().date(from:start.timestamp.replacingOccurrences(of:#"\.\d{3}Z$"#,with:"Z",options:.regularExpression)),
                  Date().timeIntervalSince(at)>=0,Date().timeIntervalSince(at)<600,
                  !events.contains(where:{$0.claimID==id && ["crystal_completed_ui","crystal_finished_no_reward"].contains($0.event)})
            else{throw AutomationError("No recent unfinished owned crystal transaction to recover")}
            let actions=events.filter{$0.claimID==id && $0.event=="crystal_click_sent"}.compactMap{$0.message.flatMap(CrystalAction.init(rawValue:))}
            guard !actions.isEmpty else{throw AutomationError("No owned crystal input to recover")}
            crystal=CrystalFlow(recovering:actions,now:ProcessInfo.processInfo.systemUptime);crystalID=id
            try crystalJournal.append("crystal_operator_recovered",claimID:id,message:"Explicit --recover-crystal; sent attempt counts retained; every click requires fresh known UI")
        }
        // Old permanent reservations must not deadlock a visible Free card on
        // restart. Every new attempt still needs stable, freshly validated UI.
        var dryGate=RewardGate()
        var state=WatchState(blockedFingerprint:nil,pid:getpid(),running:true,intervalSeconds:interval)
        state.verificationMode="vision3: pixel-first FREE; fresh same-offer validation; two HUD frames without card; 1s retry"
        state.ocrBackend="pixel-free+pixel-digits-v2; tesseract fallback"
        let oldLines=(try? String(contentsOf:root.appendingPathComponent("events.jsonl"),encoding:.utf8)) ?? ""
        let hasPriorRun=oldLines.split(separator:"\n").contains {line in
            (try? JSONDecoder().decode(JournalEvent.self,from:Data(line.utf8)))?.event=="watcher_started"
        }
        try journal.state(state)
        try journal.append(resumeRun && hasPriorRun ? "watcher_resumed":"watcher_started",
            message:dryRun ? "dry run; no clicks":"left event Free + user-authorized crystal opening; vision3 verification")
        defer {state.running=false;try? journal.state(state);try? journal.append("watcher_stopped")}
        print("Free-figyelő: \(interval)s; napló: \(root.appendingPathComponent("events.jsonl").path); PID \(getpid())\(dryRun ? " (csak megfigyelés)":"")")
        fflush(stdout)
        let started=ProcessInfo.processInfo.systemUptime
        var stableKey:String?,candidateID:String?,stableCount=0,lastError:String?
        var pending:(id:String,reward:FreeReward,verification:RewardClaimVerification,blockedProofSaved:Bool)?
        var mouseDeferred=false
        var diagnosticSaves=0
        var lastReadableAt=started,lastIdleDiagnosticAt=started
        var lastCandidateReadableAt:TimeInterval?,lastLostFingerprint:String?
        func diagnostic(_ frame:Frame,_ observation:RewardObservation,_ event:String,_ id:String?,_ message:String)throws {
            guard diagnosticSaves<40 else{return};diagnosticSaves+=1
            let proof=try journal.image(frame.image,id:id ?? journal.runID,suffix:"diagnostic-\(diagnosticSaves)")
            let detail="\(message); reason=\(observation.diagnosticReason ?? "readable");HUD=\(observation.gameHUDVisible);card=\(observation.freeCardVisible);fingerprint=\(observation.reward?.fingerprint ?? "nil");texts=\(observation.texts.map(\.text))"
            try journal.append(event,claimID:id,reward:observation.reward,evidence:proof,message:detail)
        }
        while !cancel.requested && ProcessInfo.processInfo.systemUptime-started<seconds {
            let tick=ProcessInfo.processInfo.systemUptime
            do {
                let frame=try await capture.frame(),observation=try vision.observe(frame.image)
                if diagnosticSaves==0 {try diagnostic(frame,observation,"observation_diagnostic",nil,"startup")}
                if observation.reward != nil {lastReadableAt=tick}
                else if tick-lastReadableAt>=35 && tick-lastIdleDiagnosticAt>=30 {
                    try diagnostic(frame,observation,"idle_observation",nil,"no readable reward for \(Int(tick-lastReadableAt))s")
                    lastIdleDiagnosticAt=tick
                }
                if observation.reward != nil {lastLostFingerprint=nil}
                if observation.reward==nil && stableKey != nil && pending==nil && lastLostFingerprint != stableKey {
                    try diagnostic(frame,observation,"candidate_lost",candidateID,"previous=\(stableKey ?? "nil")")
                    lastLostFingerprint=stableKey
                }
                state.lastCheckedAt=Journal.stamp(frame.capturedAt)
                if lastError != nil {try journal.append("capture_recovered");lastError=nil}
                // Recognised event overlays have priority over Free and crystals.
                // Their disappearance must never count as a Free reward claim.
                let eo=try eventVision.observe(frame.image,hudVisible:observation.gameHUDVisible)
                let eventWasActive=eventFlow.active,eventCompleted=eventFlow.completed
                let eventAction=eventFlow.observe(eo,now:tick,inputReady:HumanInput.ready)
                state.eventEndPhase=eventFlow.phase.rawValue
                if !eventWasActive && eventFlow.active {
                    eventID=UUID().uuidString;eventScreen=nil;eventFailure=nil
                    try eventJournal.append("event_started",claimID:eventID)
                }
                // Reserve even the first recognised frame while stability builds.
                if EventEndInputPolicy.reservesInput(screen:eo.screen,active:eventFlow.active,wasActive:eventWasActive) {
                    if let p=pending {
                        try journal.append("claim_unconfirmed",claimID:p.id,reward:p.reward,message:"Event overlay interrupted Free verification; no reward inferred from its disappearance")
                        pending=nil
                    }
                    stableKey=nil;stableCount=0;candidateID=nil;lastCandidateReadableAt=nil
                    state.waitingForMouseRelease = !HumanInput.ready
                    if eventFlow.active || eventWasActive {
                        if eo.screen != eventScreen {
                            eventScreen=eo.screen
                            let proof=try eventJournal.image(frame.image,id:eventID ?? eventJournal.runID,suffix:"\(eo.screen.rawValue)-\(UUID().uuidString)")
                            try eventJournal.append("event_screen",claimID:eventID,evidence:proof,message:"\(eo.screen.rawValue); \(eo.texts)")
                        }
                        if eventFlow.failure != eventFailure,let failure=eventFlow.failure {
                            eventFailure=failure;try eventJournal.append("event_blocked",claimID:eventID,message:failure)
                        }
                        if let action=eventAction,!dryRun {
                            do {
                                try await capture.eventEndClick(action,frame:frame,cancellation:cancel) {fresh,current in
                                    let proof=try eventJournal.image(fresh.image,id:eventID ?? eventJournal.runID,suffix:"before-\(action.rawValue)-\(UUID().uuidString)")
                                    try eventJournal.append("event_click_validated",claimID:eventID,evidence:proof,message:"\(action.rawValue); \(current.texts)")
                                }
                                eventFlow.sent(action,now:ProcessInfo.processInfo.systemUptime)
                                try eventJournal.append("event_click_sent",claimID:eventID,message:action.rawValue)
                            } catch is HumanInputBusy {state.waitingForMouseRelease=true}
                            catch {try eventJournal.append("event_click_rejected",claimID:eventID,message:error.localizedDescription)}
                        }
                        if eventFlow.completed>eventCompleted {
                            try eventJournal.append("event_dismissed_ui",claimID:eventID,message:"Event Continue sent and two subsequent game-HUD frames observed; no purchase or reward booked")
                        } else if eventWasActive && !eventFlow.active {
                            try eventJournal.append("event_returned_to_hud",claimID:eventID,message:"HUD returned without a fully observed automated Continue; not counted as an automated dismissal or reward")
                        }
                    }
                    state.pendingClaimID=pending?.id
                    try journal.state(state)
                    let delay=max(0,interval-(ProcessInfo.processInfo.systemUptime-tick))
                    if delay>0 {try? await Task.sleep(nanoseconds:UInt64(delay*1_000_000_000))}
                    continue
                }
                // Single input owner: crystal transaction has priority. Free
                // candidates cannot survive across its overlays. A pending Free
                // claim must finish verification before a new transaction starts.
                let co=try crystalVision.observe(frame.image,hudVisible:observation.gameHUDVisible)
                let wasActive=crystal.active,completed=crystal.completed
                let action=crystal.observe(co,now:tick,inputReady:HumanInput.ready,mayStart:pending==nil)
                state.crystalPhase=crystal.phase.rawValue
                if !wasActive && crystal.active {
                    crystalID=UUID().uuidString;crystalScreen=nil;crystalFailure=nil
                    try crystalJournal.append("crystal_started",claimID:crystalID)
                }
                if crystal.active || wasActive {
                    state.waitingForMouseRelease = !HumanInput.ready
                    stableKey=nil;stableCount=0;candidateID=nil;lastCandidateReadableAt=nil
                    if co.screen != crystalScreen {
                        crystalScreen=co.screen
                        let proof=try crystalJournal.image(frame.image,id:crystalID ?? crystalJournal.runID,suffix:"\(co.screen.rawValue)-\(UUID().uuidString)")
                        try crystalJournal.append("crystal_screen",claimID:crystalID,evidence:proof,message:"\(co.screen.rawValue); \(co.texts)")
                    }
                    if crystal.failure != crystalFailure,let failure=crystal.failure {
                        crystalFailure=failure
                        try crystalJournal.append("crystal_blocked",claimID:crystalID,message:failure)
                    }
                    if let action,!dryRun {
                        do {
                            try await capture.crystalClick(action,frame:frame,cancellation:cancel) {fresh,current in
                                let proof=try crystalJournal.image(fresh.image,id:crystalID ?? crystalJournal.runID,suffix:"before-\(action.rawValue)-\(UUID().uuidString)")
                                try crystalJournal.append("crystal_click_validated",claimID:crystalID,evidence:proof,message:"\(action.rawValue); \(current.texts)")
                            }
                            crystal.sent(action,now:ProcessInfo.processInfo.systemUptime)
                            try crystalJournal.append("crystal_click_sent",claimID:crystalID,message:action.rawValue)
                        } catch is HumanInputBusy {
                            state.waitingForMouseRelease=true
                        } catch {
                            try crystalJournal.append("crystal_click_rejected",claimID:crystalID,message:error.localizedDescription)
                        }
                    }
                    if crystal.completed>completed {
                        try crystalJournal.append("crystal_completed_ui",claimID:crystalID,message:"Result, Continue, inventory and return to HUD observed; not a Free stat gain")
                    } else if wasActive && !crystal.active {
                        try crystalJournal.append("crystal_finished_no_reward",claimID:crystalID,message:"HUD returned without a fully observed result flow; not counted")
                    }
                    try journal.state(state)
                    let delay=max(0,interval-(ProcessInfo.processInfo.systemUptime-tick))
                    if delay>0 {try? await Task.sleep(nanoseconds:UInt64(delay*1_000_000_000))}
                    continue
                }
                dryGate.observe(observation.reward)
                if var p=pending {
                    if let changed=observation.reward,changed.fingerprint != p.reward.fingerprint {
                        try journal.append("claim_unconfirmed",claimID:p.id,reward:p.reward,message:"Offer changed without observed disappearance; not counted")
                        pending=nil;candidateID=nil;stableKey=nil;stableCount=0
                    } else {
                    let decision=p.verification.observe(gameHUDVisible:observation.gameHUDVisible,
                        cardVisible:observation.freeCardVisible,
                        matchingOfferVisible:observation.reward?.fingerprint==p.reward.fingerprint,
                        now:ProcessInfo.processInfo.systemUptime)
                    if decision == .confirm {
                        let proof=try journal.image(frame.image,id:p.id,suffix:"after")
                        try journal.append("claim_confirmed_ui",claimID:p.id,reward:p.reward,evidence:proof,message:"Free card absent on two subsequent game-HUD frames; numeric stat gain not independently measured")
                        print("\(Journal.stamp()) Free átvétel: \(p.reward.kind) +\(p.reward.amount ?? "?")");fflush(stdout)
                        pending=nil;candidateID=nil;stableKey=nil;stableCount=0
                    } else if decision == .retry {
                        try journal.append("click_not_confirmed",claimID:p.id,reward:p.reward,message:"Same Free card still visible after 1s; retry when human mouse is released")
                        // Keep one logical claimID through all attempts. Only its
                        // eventual disappearance may contribute to reward totals.
                        pending=nil;candidateID=p.id
                        stableKey=p.reward.fingerprint;stableCount=max(1,stableCount)
                    } else {
                        if !p.blockedProofSaved && ProcessInfo.processInfo.systemUptime-p.verification.sentAt>8 {
                            let proof=try journal.image(frame.image,id:p.id,suffix:"verification-blocked")
                            try journal.append("verification_blocked",claimID:p.id,reward:p.reward,evidence:proof,
                                message:"HUD=\(observation.gameHUDVisible);card=\(observation.freeCardVisible);readable=\(observation.reward != nil). Not counted; retaining visual evidence.")
                            p.blockedProofSaved=true
                        }
                        pending=p
                    }
                    }
                }
                if let reward=observation.reward {
                    lastCandidateReadableAt=tick
                    if stableKey==reward.fingerprint {stableCount+=1}else{
                        stableKey=reward.fingerprint;stableCount=1;candidateID=UUID().uuidString
                        try journal.append("reward_detected",claimID:candidateID,reward:reward,at:frame.capturedAt)
                    }
                    if stableCount>=2 && pending==nil {
                        if dryRun {
                            if dryGate.permits(reward) {
                            print("Free észlelve: \(reward.kind), \(reward.rawAmount ?? "?"); \(reward.iconFeatures)");fflush(stdout)
                            dryGate.reserve(reward)
                            }
                        } else if !HumanInput.ready {
                            if !mouseDeferred {
                                try journal.append("input_deferred",claimID:candidateID,reward:reward,message:HumanInputBusy().localizedDescription)
                                mouseDeferred=true
                            }
                        } else {
                            mouseDeferred=false
                            let id=candidateID ?? UUID().uuidString
                            // Each attempt has its own evidence, but shares the
                            // logical claimID so retries cannot multiply totals.
                            let attempt="before-\(UUID().uuidString)"
                            let before=try journal.image(frame.image,id:id,suffix:attempt)
                            try journal.append("click_intent",claimID:id,reward:reward,evidence:before)
                            if cancel.requested {break}
                            var receipt:(sentAt:Date,reward:FreeReward,evidence:String)?
                            do {
                                receipt=try await capture.click(reward,frame:frame,cancellation:cancel,rejected:{fresh,observation,reason in
                                    try diagnostic(fresh,observation,"preclick_rejected",id,"reason=\(reason);expected=\(reward.fingerprint)")
                                },validated:{fresh,current in
                                    let proof=try journal.image(fresh.image,id:id,suffix:"validated-\(UUID().uuidString)")
                                    try journal.append("click_validated",claimID:id,reward:current,evidence:proof)
                                    return proof
                                })
                            } catch is HumanInputBusy {
                                try journal.append("input_deferred",claimID:id,reward:reward,evidence:before,message:HumanInputBusy().localizedDescription)
                                mouseDeferred=true
                            } catch {
                                try journal.append("click_failed",claimID:id,reward:reward,evidence:before,message:error.localizedDescription)
                                stableCount=0
                            }
                            if let receipt {
                                try journal.append("click_sent",claimID:id,reward:receipt.reward,evidence:receipt.evidence,at:receipt.sentAt)
                                pending=(id,receipt.reward,RewardClaimVerification(sentAt:ProcessInfo.processInfo.systemUptime),false)
                            }
                        }
                    }
                } else if !RewardStabilityPolicy.bridgeUnreadable(gameHUDVisible:observation.gameHUDVisible,
                    cardVisible:observation.freeCardVisible,lastReadableAt:lastCandidateReadableAt,now:tick) {
                    stableKey=nil;stableCount=0;if pending==nil {candidateID=nil;mouseDeferred=false}
                }
                state.waitingForMouseRelease=mouseDeferred
                state.pendingClaimID=pending?.id
                try journal.state(state)
            } catch {
                let message=error.localizedDescription
                if lastError != message {try journal.append("observation_error",message:message);fputs("\(message)\n",stderr);lastError=message}
                // Journal writes failing must stop the watcher rather than allow unlogged input.
                if (error as NSError).domain==NSCocoaErrorDomain {throw error}
            }
            let now=ProcessInfo.processInfo.systemUptime
            let remaining=max(0,max(interval-(now-tick),pending.map{max(0,$0.verification.sentAt+1-now)} ?? 0))
            if remaining>0 {try? await Task.sleep(nanoseconds:UInt64(remaining*1_000_000_000))}
        }
    }
    static func stats(root:URL,args:[String])throws {
        var from=Date.distantPast,to=Date.distantFuture,i=0
        var path=root.appendingPathComponent("events.jsonl")
        func date(_ s:String)->Date? {let f=ISO8601DateFormatter();f.formatOptions=[.withInternetDateTime,.withFractionalSeconds];return f.date(from:s) ?? ISO8601DateFormatter().date(from:s)}
        while i<args.count {
            if args[i]=="--log" {
                guard i+1<args.count else{throw AutomationError("--log fájl hiányzik")}
                path=URL(fileURLWithPath:args[i+1]);i+=2;continue
            }
            guard i+1<args.count,let value=date(args[i+1]) else{throw AutomationError("stats --from/--to ISO8601 dátum időzónával")}
            if args[i]=="--from" {from=value}else if args[i]=="--to" {to=value}else{throw AutomationError("Ismeretlen statisztikakapcsoló")};i+=2
        }
        guard from<=to else{throw AutomationError("A kezdőidő későbbi a végidőnél.")}
        guard FileManager.default.fileExists(atPath:path.path) else{print("Még nincs jutalomnapló.");return}
        var allClicks:[String:JournalEvent]=[:],corrected:[String:FreeReward]=[:],confirmed=Set<String>(),malformed=0,attempts=0
        for line in try String(contentsOf:path,encoding:.utf8).split(separator:"\n") {
            guard let e=try? JSONDecoder().decode(JournalEvent.self,from:Data(line.utf8)) else{malformed+=1;continue}
            guard let id=e.claimID else{continue}
            if e.event=="click_sent" {
                allClicks[id]=e
                if let d=date(e.timestamp),d>=from,d<to {attempts+=1}
            }
            if e.event=="claim_confirmed_ui"{confirmed.insert(id)}
            if e.event=="reward_corrected",let reward=e.reward{corrected[id]=reward}
        }
        // Attribute a retried claim to its final sent attempt. A failed earlier
        // attempt in a different interval must not also acquire the later gain.
        let clicks=allClicks.filter {_,event in
            guard let d=date(event.timestamp) else{return false};return d>=from && d<to
        }
        var totals=Dictionary(uniqueKeysWithValues:RewardIconClassifier.kinds.map{($0,Decimal.zero)}),unknown=0
        for (id,event) in clicks where confirmed.contains(id) {
            guard let reward=corrected[id] ?? event.reward,RewardIconClassifier.kinds.contains(reward.kind),let text=reward.amount,let n=Decimal(string:text,locale:Locale(identifier:"en_US_POSIX")) else{unknown+=1;continue}
            totals[reward.kind,default:0]+=n
        }
        let result:[String:Any]=["clicks":clicks.count,"click_attempts":attempts,"confirmed_ui_claims":clicks.keys.filter{confirmed.contains($0)}.count,
            "unconfirmed_or_pending":clicks.keys.filter{!confirmed.contains($0)}.count,
            "unknown_confirmed_rewards":unknown,"malformed_lines":malformed,
            "totals":totals.mapValues{NSDecimalNumber(decimal:$0).stringValue},
            "note":"One reward per UI-confirmed claim, attributed to its final click attempt; attempts are counted separately. No independent account-stat verification."]
        print(String(decoding:try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys]),as:UTF8.self))
    }
    static func reconcile(root:URL,args:[String]=[])throws {
        guard args.isEmpty || args==["--current-run"] else{throw AutomationError("reconcile [--current-run]")}
        let path=root.appendingPathComponent("events.jsonl")
        let events=try String(contentsOf:path,encoding:.utf8).split(separator:"\n").compactMap{try? JSONDecoder().decode(JournalEvent.self,from:Data($0.utf8))}
        let already=Set(events.filter{$0.event=="reward_corrected"}.compactMap(\.claimID))
        let formatter=ISO8601DateFormatter();formatter.formatOptions=[.withInternetDateTime,.withFractionalSeconds]
        func date(_ text:String)->Date? {formatter.date(from:text) ?? ISO8601DateFormatter().date(from:text)}
        var since:Date?
        if args==["--current-run"] {
            guard let start=events.last(where:{$0.event=="watcher_started"}),let parsed=date(start.timestamp) else{throw AutomationError("Nincs azonosítható aktuális gyűjtési futás.")}
            since=parsed
        }
        var latest:[String:JournalEvent]=[:]
        for event in events where event.event=="click_sent" {
            if let id=event.claimID {latest[id]=event}
        }
        let journal=try Journal(root:root),vision=RewardVision()
        var count=0
        for event in latest.values.sorted(by:{$0.timestamp<$1.timestamp}) {
            if let since {guard let at=date(event.timestamp),at>=since else{continue}}
            guard let id=event.claimID,!already.contains(id),let old=event.reward,
                  old.kind=="unknown" || old.amount==nil,let evidence=event.evidence,
                  let source=CGImageSourceCreateWithURL(root.appendingPathComponent(evidence) as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil),
                  let reward=try vision.observe(image).reward,reward.kind != "unknown",reward.amount != nil else{continue}
            try journal.append("reward_corrected",claimID:id,reward:reward,evidence:evidence,message:"Offline reinspection of original pre-click image with labelled icon references; original event and confirmation status preserved")
            print("\(id): \(old.kind)→\(reward.kind), \(reward.amount ?? "?")")
            count+=1
        }
        print("Bizonyítékkép alapján pontosítva: \(count). Eredeti kattintási sorok megőrizve.")
    }
    static let usage="""
    ButcherHeroAutomation watch-free [--interval 1] [--seconds 60] [--dry-run] [--resume-run] [--recover-crystal]
    ButcherHeroAutomation inspect <frame.png>
    ButcherHeroAutomation inspect-crystal <frame.png>
    ButcherHeroAutomation inspect-event <frame.png>
    ButcherHeroAutomation snapshot <output.png>  # passive single window capture
    ButcherHeroAutomation stats [--from 2026-10-29T22:00:00+02:00] [--to 2026-10-30T08:00:00+02:00]
    ButcherHeroAutomation reconcile [--current-run]  # offline re-read of uncertain saved rewards
    Local append-only journal: data/free-rewards/events.jsonl. Ctrl+C stops.
    """
}
