import AppKit
import ApplicationServices
import Combine
import ScreenCaptureKit
import SwiftUI

/// Ties the collector, the game monitor and the statistics together for the UI.
@MainActor final class AppModel:ObservableObject {
    let engine=CollectorEngine(),game=GameMonitor(),stats=StatsStore(),diagnostics=DiagnosticsStore()
    @Published private(set) var accessibilityGranted=AXIsProcessTrusted()
    @Published private(set) var screenCaptureGranted=CGPreflightScreenCaptureAccess()
    @Published private(set) var legacyRunning=LegacyCollector.isRunning
    @Published private(set) var now=Date()
    /// Remembered across launches: if collecting was on, it resumes when the app starts.
    @AppStorage("collectorEnabled") var collectorEnabled=false
    private var timer:Timer?,bag:Set<AnyCancellable>=[]

    init() {
        engine.onEvent={[weak self] domain,e in
            if domain == .free {self?.stats.append(e)}
            self?.diagnostics.append(domain,e)
        }
        // Re-publish child changes so views observing the model refresh.
        // The engine updates its status every second; only re-render for changes a user can see.
        // (The capture time shown in the UI refreshes with the 2 s tick.)
        engine.$status.map{s in "\(s.running)|\(s.captureStatus)|\(s.screenState)|\(s.crystalPhase)|\(s.eventEndPhase)|\(s.waitingForInput)|\(s.waitReason ?? "")|\(s.lastError ?? "")"}
            .removeDuplicates().dropFirst()
            .sink{[weak self] _ in self?.objectWillChange.send()}.store(in:&bag)
        game.objectWillChange.sink{[weak self] in self?.objectWillChange.send()}.store(in:&bag)
        stats.objectWillChange.sink{[weak self] in self?.objectWillChange.send()}.store(in:&bag)
        diagnostics.objectWillChange.sink{[weak self] in self?.objectWillChange.send()}.store(in:&bag)
        timer=Timer.scheduledTimer(withTimeInterval:2,repeats:true){[weak self] _ in Task{@MainActor in self?.tick()}}
        if collectorEnabled {engine.start()}
        tick()
    }

    func tick() {
        now=Date()
        accessibilityGranted=AXIsProcessTrusted()
        screenCaptureGranted=CGPreflightScreenCaptureAccess()
        legacyRunning=LegacyCollector.isRunning
        if stats.range != .custom {stats.recompute(now:now)}
        // Resume after a permission was granted or the old collector stopped.
        if collectorEnabled && !engine.isRunning && CollectorEngine.blocker()==nil {engine.start()}
        updateDockBadge()
    }

    func setCollecting(_ on:Bool) {
        collectorEnabled=on
        if on {engine.start()} else {engine.stop()}
    }

    func requestPermissions() {
        if !accessibilityGranted {
            _=AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String:true] as CFDictionary)
        }
        if !screenCaptureGranted {
            _=CGRequestScreenCaptureAccess()
            // The app only appears in the Screen Recording list after a real ScreenCaptureKit request.
            Task{_=try? await SCShareableContent.excludingDesktopWindows(false,onScreenWindowsOnly:true)}
        }
    }
    func openPrivacySettings(_ pane:String) {
        if let url=URL(string:"x-apple.systempreferences:com.apple.preference.security?\(pane)") {NSWorkspace.shared.open(url)}
    }

    enum CollectorState {
        case stopped,blocked(String),waitingGame,waitingWindow,starting,stale(Int),captureError(String),
             crystalBlocked,manualPanel,unrecognized,waitingInput,processing(String),running
    }
    var collectorState:CollectorState {
        let s=engine.status
        if !engine.isRunning {
            if collectorEnabled,let reason=CollectorEngine.blocker() {return .blocked(reason)}
            if let error=s.lastError,collectorEnabled {return .blocked(error)}
            return .stopped
        }
        switch game.state {
        case .notInstalled,.notRunning,.launching:return .waitingGame
        case .windowUnavailable:return .waitingWindow
        case .running:break
        }
        guard let checked=s.lastCheckedAt else{return .starting}
        let age=Int(now.timeIntervalSince(checked))
        if age>10 {return .stale(age)}
        if s.captureStatus=="error" {return .captureError(s.lastError ?? "")}
        if s.crystalPhase=="blocked" || s.eventEndPhase=="blocked" {return .crystalBlocked}
        if s.screenState=="manual_crystal" {return .manualPanel}
        if !["hud","crystal","event"].contains(s.screenState) {return .unrecognized}
        if s.waitingForInput {return .waitingInput}
        if s.screenState=="crystal" {return .processing(L("Kristály/geode nyitása folyamatban.","Opening crystals/geodes."))}
        if s.screenState=="event" {return .processing(L("Esemény végi ablak kezelése.","Handling an event-end screen."))}
        return .running
    }

    private func updateDockBadge() {
        let problem=collectorEnabled && (game.state != .running || !engine.isRunning)
        NSApp.dockTile.badgeLabel=problem ? "!":nil
    }
}
