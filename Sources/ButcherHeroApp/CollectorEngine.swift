import AppKit
import ApplicationServices
import Darwin
import RewardAutomationCore

/// The collector loop that used to be `ButcherHeroAutomation watch-free`, hosted in the app.
/// Detection, stability, verification and the crystal/event state machines are the same
/// RewardAutomationCore code; only input changed: every click is a background click.
@MainActor final class CollectorEngine:ObservableObject {
    struct Status {
        var running=false
        var captureStatus="starting"     // starting | ok | error
        var screenState="unrecognized"   // hud | crystal | event | manual_crystal | unrecognized
        var crystalPhase="idle",eventEndPhase="idle"
        var waitingForInput=false
        var waitReason:String?
        var pendingClaimID:String?
        var lastCheckedAt:Date?
        var lastError:String?
        var startedAt:Date?
    }
    @Published private(set) var status=Status()
    /// Called on every journal append (stats and diagnostics update live).
    var onEvent:((JournalDomain,JournalEvent)->Void)?

    private var task:Task<Void,Never>?
    private var stopRequested=false
    private var lockFD:Int32 = -1
    let interval:TimeInterval=1,idleInterval:TimeInterval=2

    var isRunning:Bool {task != nil}

    func start() {
        guard task==nil else{return}
        if let reason=Self.blocker() {status.lastError=reason;return}
        stopRequested=false
        status=Status(running:true,startedAt:Date())
        task=Task{[weak self] in
            guard let self else{return}
            do {try await self.watch()}
            catch {self.status.lastError=error.localizedDescription}
            self.status.running=false
            self.releaseLock()
            self.task=nil
        }
    }

    func stop() {stopRequested=true}

    /// Why the collector can't start right now, if anything.
    static func blocker()->String? {
        if !AXIsProcessTrusted() {return L("Hiányzik a Kisegítő lehetőségek engedély (Rendszerbeállítások › Adatvédelem és biztonság › Kisegítő lehetőségek).","Accessibility permission missing (System Settings › Privacy & Security › Accessibility).")}
        if !CGPreflightScreenCaptureAccess() {return L("Hiányzik a képernyőfelvételi engedély (Rendszerbeállítások › Adatvédelem és biztonság › Képernyő- és rendszerhang-felvétel).","Screen Recording permission missing (System Settings › Privacy & Security › Screen & System Audio Recording).")}
        if LegacyCollector.isRunning {return L("A régi gyűjtő (ButcherHeroAutomation) még fut; előbb azt kell leállítani.","The old collector (ButcherHeroAutomation) is still running; stop it first.")}
        return nil
    }

    private func acquireLock()throws {
        try FileManager.default.createDirectory(at:AppPaths.root,withIntermediateDirectories:true)
        let fd=open(AppPaths.root.appendingPathComponent(".collector.lock").path,O_CREAT|O_RDWR,mode_t(0o600))
        guard fd>=0 else{throw AppError("A gyűjtőzár nem hozható létre.")}
        guard flock(fd,LOCK_EX|LOCK_NB)==0 else{close(fd);throw AppError("Már fut egy gyűjtő; másodikat nem indítok.")}
        lockFD=fd
    }
    private func releaseLock() {
        guard lockFD>=0 else{return}
        flock(lockFD,LOCK_UN);close(lockFD);lockFD = -1
    }

    private func sleep(_ seconds:TimeInterval)async {
        guard seconds>0 else{return}
        try? await Task.sleep(nanoseconds:UInt64(seconds*1_000_000_000))
    }

    private func watch()async throws {
        try acquireLock()
        let journal=try Journal(root:AppPaths.free),vision=RewardVision()
        journal.onAppend={[weak self] e in self?.onEvent?(.free,e)}
        let crystalJournal=try Journal(root:AppPaths.crystal),crystalVision=CrystalVision()
        crystalJournal.onAppend={[weak self] e in self?.onEvent?(.crystal,e)}
        var crystal=CrystalFlow(),crystalID:String?,crystalScreen:CrystalScreen?,crystalFailure:String?
        let eventJournal=try Journal(root:AppPaths.event),eventVision=EventEndVision()
        eventJournal.onAppend={[weak self] e in self?.onEvent?(.event,e)}
        var eventFlow=EventEndFlow(),eventID:String?,eventScreen:EventEndScreen?,eventFailure:String?
        Journal.pruneEvidence(in:[AppPaths.free,AppPaths.crystal,AppPaths.event])
        var lastPrune=ProcessInfo.processInfo.systemUptime

        let hasPriorRun=Journal.read(journal.eventsURL).events.contains{$0.event=="watcher_started"}
        try journal.append(hasPriorRun ? "watcher_resumed":"watcher_started",
            message:"native app; background input; left event Free + crystal opening; vision3 verification")
        defer {try? journal.append("watcher_stopped")}

        let started=ProcessInfo.processInfo.systemUptime
        var stableKey:String?,candidateID:String?,stableCount=0,lastError:String?
        var pending:(id:String,reward:FreeReward,verification:RewardClaimVerification,blockedProofSaved:Bool)?
        var inputDeferred=false,diagnosticSaves=0
        var lastReadableAt=started,lastIdleDiagnosticAt=started
        var lastCandidateReadableAt:TimeInterval?,lastLostFingerprint:String?
        var lastActivityAt=started
        var manualPanelSince:TimeInterval?

        func diagnostic(_ frame:Frame,_ observation:RewardObservation,_ event:String,_ id:String?,_ message:String)throws {
            guard diagnosticSaves<40 else{return};diagnosticSaves+=1
            let proof=try journal.image(frame.image,id:id ?? journal.runID,suffix:"diagnostic-\(diagnosticSaves)")
            let detail="\(message); reason=\(observation.diagnosticReason ?? "readable");HUD=\(observation.gameHUDVisible);card=\(observation.freeCardVisible);fingerprint=\(observation.reward?.fingerprint ?? "nil");texts=\(observation.texts.map(\.text))"
            try journal.append(event,claimID:id,reward:observation.reward,evidence:proof,message:detail)
        }
        func resetCandidate() {stableKey=nil;stableCount=0;candidateID=nil;lastCandidateReadableAt=nil}

        while !stopRequested && !Task.isCancelled {
            let tick=ProcessInfo.processInfo.systemUptime
            if tick-lastPrune>3600 {Journal.pruneEvidence(in:[AppPaths.free,AppPaths.crystal,AppPaths.event]);lastPrune=tick}
            do {
                let frame=try await GameIO.frame(),observation=try vision.observe(frame.image)
                status.captureStatus="ok"
                status.screenState=observation.gameHUDVisible ? "hud":"unrecognized"
                status.lastCheckedAt=frame.capturedAt
                if diagnosticSaves==0 {try diagnostic(frame,observation,"observation_diagnostic",nil,"startup")}
                if observation.reward != nil {lastReadableAt=tick;lastLostFingerprint=nil}
                else if tick-lastReadableAt>=35 && tick-lastIdleDiagnosticAt>=30 {
                    try diagnostic(frame,observation,"idle_observation",nil,"no readable reward for \(Int(tick-lastReadableAt))s")
                    lastIdleDiagnosticAt=tick
                }
                if observation.reward==nil && stableKey != nil && pending==nil && lastLostFingerprint != stableKey {
                    try diagnostic(frame,observation,"candidate_lost",candidateID,"previous=\(stableKey ?? "nil")")
                    lastLostFingerprint=stableKey
                }
                if lastError != nil {try journal.append("capture_recovered");lastError=nil;status.lastError=nil}

                // 1. Recognised event overlays have priority; their disappearance never counts as a Free claim.
                let eo=try eventVision.observe(frame.image,hudVisible:observation.gameHUDVisible)
                if eo.screen != .hud && eo.screen != .unknown {status.screenState="event"}
                let eventWasActive=eventFlow.active,eventCompleted=eventFlow.completed
                let eventAction=eventFlow.observe(eo,now:tick,inputReady:HumanInput.ready)
                status.eventEndPhase=eventFlow.phase.rawValue
                if !eventWasActive && eventFlow.active {
                    eventID=UUID().uuidString;eventScreen=nil;eventFailure=nil
                    try eventJournal.append("event_started",claimID:eventID)
                }
                if EventEndInputPolicy.reservesInput(screen:eo.screen,active:eventFlow.active,wasActive:eventWasActive) {
                    if let p=pending {
                        try journal.append("claim_unconfirmed",claimID:p.id,reward:p.reward,message:"Event overlay interrupted Free verification; no reward inferred from its disappearance")
                        pending=nil
                    }
                    resetCandidate()
                    status.waitingForInput = !HumanInput.ready
                    if eventFlow.active || eventWasActive {
                        if eo.screen != eventScreen {
                            eventScreen=eo.screen
                            let proof=try eventJournal.image(frame.image,id:eventID ?? eventJournal.runID,suffix:"\(eo.screen.rawValue)-\(UUID().uuidString)")
                            try eventJournal.append("event_screen",claimID:eventID,evidence:proof,message:"\(eo.screen.rawValue); \(eo.texts)")
                        }
                        if eventFlow.failure != eventFailure,let failure=eventFlow.failure {
                            eventFailure=failure;try eventJournal.append("event_blocked",claimID:eventID,message:failure)
                        }
                        if let action=eventAction {
                            do {
                                let fresh=try await GameIO.frame()
                                guard fresh.window.windowID==frame.window.windowID else{throw AppError("Event window changed")}
                                let current=try eventVision.observe(fresh.image,hudVisible:try vision.observe(fresh.image).gameHUDVisible)
                                let age=Date().timeIntervalSince(fresh.capturedAt)
                                guard action.permits(current,sameWindow:true,cancelled:stopRequested,elapsed:age)
                                else{throw AppError("Event preclick rejected: \(action.rawValue)/\(current.screen.rawValue); age=\(age)")}
                                let proof=try eventJournal.image(fresh.image,id:eventID ?? eventJournal.runID,suffix:"before-\(action.rawValue)-\(UUID().uuidString)")
                                try eventJournal.append("event_click_validated",claimID:eventID,evidence:proof,message:"\(action.rawValue); \(current.texts)")
                                let geometry=try await GameIO.click(normalized:action.point,in:fresh)
                                try eventJournal.append("input_geometry",claimID:eventID,message:geometry)
                                eventFlow.sent(action,now:ProcessInfo.processInfo.systemUptime)
                                try eventJournal.append("event_click_sent",claimID:eventID,message:action.rawValue)
                            } catch is HumanInputBusy {status.waitingForInput=true}
                            catch {try eventJournal.append("event_click_rejected",claimID:eventID,message:error.localizedDescription)}
                        }
                        if eventFlow.completed>eventCompleted {
                            try eventJournal.append("event_dismissed_ui",claimID:eventID,message:"Event Continue sent and two subsequent game-HUD frames observed; no purchase or reward booked")
                        } else if eventWasActive && !eventFlow.active {
                            try eventJournal.append("event_returned_to_hud",claimID:eventID,message:"HUD returned without a fully observed automated Continue; not counted")
                        }
                    }
                    status.pendingClaimID=pending?.id
                    await sleep(interval-(ProcessInfo.processInfo.systemUptime-tick))
                    continue
                }

                // 2. Single input owner: a crystal transaction has priority over Free.
                let co=try crystalVision.observe(frame.image,hudVisible:observation.gameHUDVisible)
                if co.screen != .hud && co.screen != .unknown {status.screenState="crystal"}
                // A manually opened panel is not ours to close, and suppresses Free input.
                if CrystalInputPolicy.isManualPanel(screen:co.screen,active:crystal.active) {
                    // A panel left open (e.g. our own flow interrupted by an app restart) is
                    // adopted after 2 quiet minutes while the user is not playing the game.
                    if manualPanelSince==nil {manualPanelSince=tick}
                    let userPlaying=NSWorkspace.shared.frontmostApplication?.bundleIdentifier==GameIO.bundleID
                    if let since=manualPanelSince,tick-since>=120,!userPlaying,pending==nil,let resume=Self.adoption(for:co.screen) {
                        crystal=CrystalFlow(recovering:resume,now:tick)
                        crystalID=UUID().uuidString;crystalScreen=nil;crystalFailure=nil;manualPanelSince=nil
                        try crystalJournal.append("crystal_adopted",claimID:crystalID,
                            message:"Panel \(co.screen.rawValue) open for \(Int(tick-since))s without the user playing; finishing it as \(resume.map(\.rawValue))")
                        await sleep(interval-(ProcessInfo.processInfo.systemUptime-tick))
                        continue
                    }
                    status.screenState="manual_crystal"
                    if let p=pending {
                        try journal.append("claim_unconfirmed",claimID:p.id,reward:p.reward,message:"Manual crystal panel interrupted verification; not counted")
                        pending=nil
                    }
                    resetCandidate()
                    status.crystalPhase=crystal.phase.rawValue;status.pendingClaimID=nil
                    status.waitingForInput = !HumanInput.ready
                    await sleep(interval-(ProcessInfo.processInfo.systemUptime-tick))
                    continue
                }
                manualPanelSince=nil
                let wasActive=crystal.active,completed=crystal.completed
                let action=crystal.observe(co,now:tick,inputReady:HumanInput.ready,mayStart:pending==nil)
                status.crystalPhase=crystal.phase.rawValue
                if !wasActive && crystal.active {
                    crystalID=UUID().uuidString;crystalScreen=nil;crystalFailure=nil
                    try crystalJournal.append("crystal_started",claimID:crystalID)
                }
                if crystal.active || wasActive {
                    status.waitingForInput = !HumanInput.ready
                    resetCandidate()
                    if co.screen != crystalScreen {
                        crystalScreen=co.screen
                        let proof=try crystalJournal.image(frame.image,id:crystalID ?? crystalJournal.runID,suffix:"\(co.screen.rawValue)-\(UUID().uuidString)")
                        try crystalJournal.append("crystal_screen",claimID:crystalID,evidence:proof,message:"\(co.screen.rawValue); \(co.texts)")
                    }
                    if crystal.failure != crystalFailure,let failure=crystal.failure {
                        crystalFailure=failure
                        try crystalJournal.append("crystal_blocked",claimID:crystalID,message:failure)
                    }
                    if let action {
                        do {
                            let fresh=try await GameIO.frame()
                            guard fresh.window.windowID==frame.window.windowID else{throw AppError("Crystal window changed")}
                            let current=try crystalVision.observe(fresh.image,hudVisible:try vision.observe(fresh.image).gameHUDVisible)
                            guard action.permits(current) else{throw AppError("Crystal preclick rejected: \(action.rawValue)/\(current.screen.rawValue)")}
                            // One image per geode is enough; saving one per strike slowed striking down.
                            let proof=action == .strike && crystal.strikes>0 ? nil:
                                try crystalJournal.image(fresh.image,id:crystalID ?? crystalJournal.runID,suffix:"before-\(action.rawValue)-\(UUID().uuidString)")
                            try crystalJournal.append("crystal_click_validated",claimID:crystalID,evidence:proof,message:"\(action.rawValue); \(current.texts)")
                            let geometry=try await GameIO.click(normalized:action.point(in:current),in:fresh)
                            try crystalJournal.append("input_geometry",claimID:crystalID,message:geometry)
                            crystal.sent(action,now:ProcessInfo.processInfo.systemUptime)
                            try crystalJournal.append("crystal_click_sent",claimID:crystalID,message:action.rawValue)
                        } catch is HumanInputBusy {
                            status.waitingForInput=true
                        } catch {
                            try crystalJournal.append("crystal_click_rejected",claimID:crystalID,message:error.localizedDescription)
                            if crystal.abandonUnsentOpening(now:ProcessInfo.processInfo.systemUptime) {
                                status.crystalPhase=crystal.phase.rawValue
                                try crystalJournal.append("crystal_opening_abandoned",claimID:crystalID,
                                    message:"Initial click rejected before any input; returning priority to collection with 60s crystal cooldown")
                            }
                        }
                    }
                    if crystal.completed>completed {
                        try crystalJournal.append("crystal_completed_ui",claimID:crystalID,message:"Result, Continue, inventory and return to HUD observed; not a Free stat gain")
                    } else if wasActive && !crystal.active {
                        try crystalJournal.append("crystal_finished_no_reward",claimID:crystalID,message:"HUD returned without a fully observed result flow; not counted")
                    }
                    // Look again quickly while striking a geode.
                    let period=crystal.phase == .breaking ? CrystalFlow.strikeSpacing:interval
                    await sleep(period-(ProcessInfo.processInfo.systemUptime-tick))
                    continue
                }

                // 3. Free rewards: verify a pending claim, then click a stable new card.
                if var p=pending {
                    if let changed=observation.reward,changed.fingerprint != p.reward.fingerprint {
                        try journal.append("claim_unconfirmed",claimID:p.id,reward:p.reward,message:"Offer changed without observed disappearance; not counted")
                        pending=nil;resetCandidate()
                    } else {
                        let decision=p.verification.observe(gameHUDVisible:observation.gameHUDVisible,
                            cardVisible:observation.freeCardVisible,
                            matchingOfferVisible:observation.reward?.fingerprint==p.reward.fingerprint,
                            now:ProcessInfo.processInfo.systemUptime)
                        if decision == .confirm {
                            let proof=try journal.image(frame.image,id:p.id,suffix:"after")
                            try journal.append("claim_confirmed_ui",claimID:p.id,reward:p.reward,evidence:proof,message:"Free card absent on two subsequent game-HUD frames; numeric stat gain not independently measured")
                            pending=nil;resetCandidate()
                        } else if decision == .retry {
                            try journal.append("click_not_confirmed",claimID:p.id,reward:p.reward,message:"Same Free card still visible after 1s; retry")
                            // One logical claimID through all attempts; only its disappearance counts.
                            pending=nil;candidateID=p.id
                            stableKey=p.reward.fingerprint;stableCount=max(1,stableCount)
                        } else {
                            if !p.blockedProofSaved && ProcessInfo.processInfo.systemUptime-p.verification.sentAt>8 {
                                let proof=try journal.image(frame.image,id:p.id,suffix:"verification-blocked")
                                try journal.append("verification_blocked",claimID:p.id,reward:p.reward,evidence:proof,
                                    message:"HUD=\(observation.gameHUDVisible);card=\(observation.freeCardVisible);readable=\(observation.reward != nil). Not counted.")
                                p.blockedProofSaved=true
                            }
                            pending=p
                        }
                    }
                }
                if let reward=observation.reward {
                    lastCandidateReadableAt=tick
                    if stableKey==reward.fingerprint {stableCount+=1} else {
                        stableKey=reward.fingerprint;stableCount=1;candidateID=UUID().uuidString
                        try journal.append("reward_detected",claimID:candidateID,reward:reward,at:frame.capturedAt)
                    }
                    if stableCount>=2 && pending==nil {
                        if let busy=HumanInput.busy {
                            status.waitReason=busy.description
                            if !inputDeferred {
                                try journal.append("input_deferred",claimID:candidateID,reward:reward,message:busy.description)
                                inputDeferred=true
                            }
                        } else {
                            inputDeferred=false
                            let id=candidateID ?? UUID().uuidString
                            let before=try journal.image(frame.image,id:id,suffix:"before-\(UUID().uuidString)")
                            try journal.append("click_intent",claimID:id,reward:reward,evidence:before)
                            do {
                                let (fresh,current)=try await validateFree(reward,original:frame,vision:vision) {fresh,observation,reason in
                                    try diagnostic(fresh,observation,"preclick_rejected",id,"reason=\(reason);expected=\(reward.fingerprint)")
                                }
                                let proof=try journal.image(fresh.image,id:id,suffix:"validated-\(UUID().uuidString)")
                                try journal.append("click_validated",claimID:id,reward:current,evidence:proof)
                                let sentAt=Date()
                                let geometry=try await GameIO.click(normalized:.init(x:current.tapX,y:current.tapY),in:fresh)
                                try journal.append("input_geometry",claimID:id,message:geometry)
                                try journal.append("click_sent",claimID:id,reward:current,evidence:proof,at:sentAt)
                                pending=(id,current,RewardClaimVerification(sentAt:ProcessInfo.processInfo.systemUptime),false)
                            } catch let busy as HumanInputBusy {
                                status.waitReason=busy.reason.description
                                try journal.append("input_deferred",claimID:id,reward:reward,evidence:before,message:busy.reason.description)
                                inputDeferred=true
                            } catch {
                                try journal.append("click_failed",claimID:id,reward:reward,evidence:before,message:error.localizedDescription)
                                stableCount=0
                            }
                        }
                    }
                } else if !RewardStabilityPolicy.bridgeUnreadable(gameHUDVisible:observation.gameHUDVisible,
                    cardVisible:observation.freeCardVisible,lastReadableAt:lastCandidateReadableAt,now:tick) {
                    stableKey=nil;stableCount=0;if pending==nil {candidateID=nil;inputDeferred=false}
                }
                status.waitingForInput=inputDeferred
                if !inputDeferred {status.waitReason=nil}
                status.pendingClaimID=pending?.id
            } catch {
                status.captureStatus="error";status.screenState="unrecognized"
                let message=error.localizedDescription
                status.lastError=message
                if lastError != message {try journal.append("observation_error",message:message);lastError=message}
                // A failing journal write must stop the collector rather than allow unlogged input.
                if (error as NSError).domain==NSCocoaErrorDomain {throw error}
            }
            let now=ProcessInfo.processInfo.systemUptime
            // Adaptive sampling: every second while anything is on screen or pending,
            // every 2 s after 10 quiet seconds (a new Free card waits at most 1 s longer).
            if pending != nil || stableKey != nil || crystal.active || eventFlow.active {lastActivityAt=now}
            let period=now-lastActivityAt>10 ? idleInterval:interval
            await sleep(max(period-(now-tick),pending.map{max(0,$0.verification.sentAt+1-now)} ?? 0))
        }
    }

    /// Which already-sent actions an adopted panel corresponds to, so the flow continues from there.
    private static func adoption(for screen:CrystalScreen)->[CrystalAction]? {
        switch screen {
        case .inventoryReady,.inventoryEmpty,.inventoryUnavailable:[.openInventory]
        case .geode:[.openInventory,.openOne]
        case .result:[.openInventory,.openOne,.strike]
        default:nil
        }
    }

    /// Fresh frames until the same offer is seen again in the same window (≤1.2 s).
    private func validateFree(_ reward:FreeReward,original:Frame,vision:RewardVision,
                              rejected:(Frame,RewardObservation,String)throws->Void)async throws->(Frame,FreeReward) {
        let startedAt=ProcessInfo.processInfo.systemUptime
        var validation=RewardPreclickValidation(expectedFingerprint:reward.fingerprint)
        while true {
            if let busy=HumanInput.busy {throw HumanInputBusy(reason:busy)}
            let fresh=try await GameIO.frame(),observation=try vision.observe(fresh.image)
            let elapsed=ProcessInfo.processInfo.systemUptime-startedAt
            let sameWindow=fresh.window.windowID==original.window.windowID
            let decision=validation.observe(fingerprint:observation.reward?.fingerprint,sameWindow:sameWindow,cancelled:stopRequested,elapsed:elapsed)
            if decision == .accept,let current=observation.reward {return (fresh,current)}
            let reason=stopRequested ? "cancelled":!sameWindow ? "window_changed":
                elapsed>1.2 ? "validation_timeout":observation.reward==nil ? observation.diagnosticReason ?? "reward_unreadable":"fingerprint_changed"
            try rejected(fresh,observation,"\(reason);decision=\(decision)")
            guard decision == .retry else{throw AppError("Free preclick rejected: \(reason)")}
            try await Task.sleep(nanoseconds:150_000_000)
        }
    }
}

/// Detects the old command-line collector so the two never click at the same time.
enum LegacyCollector {
    static var isRunning:Bool {
        let count=proc_listallpids(nil,0)
        guard count>0 else{return false}
        var pids=[pid_t](repeating:0,count:Int(count)*2)
        let filled=proc_listallpids(&pids,Int32(pids.count*MemoryLayout<pid_t>.size))
        var name=[CChar](repeating:0,count:256)
        for pid in pids.prefix(Int(max(0,filled))) where pid>0 {
            if proc_name(pid,&name,UInt32(name.count))>0,String(cString:name)=="ButcherHeroAutoma" || String(cString:name).hasPrefix("ButcherHeroAuto") {return true}
        }
        return false
    }
}
