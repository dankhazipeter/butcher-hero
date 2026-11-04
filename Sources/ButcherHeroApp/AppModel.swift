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
    /// No new capture for >10 s while collecting (re-checked by the slow health tick).
    @Published private(set) var captureStale=false
    /// Remembered across launches: if collecting was on, it resumes when the app starts.
    @AppStorage("collectorEnabled") var collectorEnabled=false
    private var timer:Timer?,bag:Set<AnyCancellable>=[]

    init() {
        engine.onEvent={[weak self] domain,e in
            if domain == .free {self?.stats.append(e)}
            self?.diagnostics.append(domain,e)
        }
        // Event-driven UI: the model re-publishes only changes a user can see. The engine
        // updates its status every tick, so it is reduced to its visible fields first.
        // Statistics and diagnostics are observed directly by their own views.
        engine.$status.map{s in "\(s.running)|\(s.captureStatus)|\(s.screenState)|\(s.crystalPhase)|\(s.eventEndPhase)|\(s.waitingForInput)|\(s.waitReason ?? "")|\(s.lastError ?? "")"}
            .removeDuplicates().dropFirst()
            .sink{[weak self] _ in self?.objectWillChange.send()}.store(in:&bag)
        game.objectWillChange.sink{[weak self] in self?.objectWillChange.send()}.store(in:&bag)
        // Slow health tick for things that have no notification (permissions, old CLI, stalls).
        timer=Timer.scheduledTimer(withTimeInterval:5,repeats:true){[weak self] _ in Task{@MainActor in self?.tick()}}
        if collectorEnabled {engine.start()}
        tick()
    }

    func tick() {
        // Assign only on change: every @Published write re-renders observers.
        func update<T:Equatable>(_ path:ReferenceWritableKeyPath<AppModel,T>,_ value:T) {if self[keyPath:path] != value {self[keyPath:path]=value}}
        update(\.accessibilityGranted,AXIsProcessTrusted())
        update(\.screenCaptureGranted,CGPreflightScreenCaptureAccess())
        update(\.legacyRunning,LegacyCollector.isRunning)
        update(\.captureStale,engine.isRunning && (engine.status.lastCheckedAt.map{Date().timeIntervalSince($0)>10} ?? false))
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
        if captureStale {return .stale(Int(Date().timeIntervalSince(checked)))}
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
