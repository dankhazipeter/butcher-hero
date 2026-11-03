import Foundation

/// Recent journal events of all three collectors, with human-readable labels, so it is
/// visible *why* something did or didn't happen (deferrals, rejections, errors, focus data).
@MainActor final class DiagnosticsStore:ObservableObject {
    struct Entry:Identifiable {
        let id=UUID()
        let at:Date,domain:JournalDomain,event:String,claimID:String?,detail:String
        var label:String {DiagnosticsStore.label(event)}
        var severity:Severity {DiagnosticsStore.severity(event)}
    }
    enum Severity:Int,Comparable {
        case info,wait,problem
        static func <(a:Severity,b:Severity)->Bool {a.rawValue<b.rawValue}
    }
    @Published private(set) var entries:[Entry]=[]
    private let limit=500

    init() {
        var all:[Entry]=[]
        for domain in JournalDomain.allCases {
            let events=Journal.read(domain.root.appendingPathComponent("events.jsonl")).events.suffix(limit)
            all+=events.compactMap{Self.entry(domain,$0)}
        }
        entries=Array(all.sorted{$0.at>$1.at}.prefix(limit))
    }

    func append(_ domain:JournalDomain,_ event:JournalEvent) {
        guard let entry=Self.entry(domain,event) else{return}
        entries.insert(entry,at:0)
        if entries.count>limit {entries.removeLast(entries.count-limit)}
    }

    private static func entry(_ domain:JournalDomain,_ e:JournalEvent)->Entry? {
        guard let at=Stamp.date(e.timestamp) else{return nil}
        var detail=e.message ?? ""
        if let reward=e.reward {
            let what="\(StatsStore.Kind.label(reward.kind)) \(reward.rawAmount ?? reward.amount ?? "?")"
            detail=detail.isEmpty ? what:"\(what) · \(detail)"
        }
        return Entry(at:at,domain:domain,event:e.event,claimID:e.claimID,detail:detail)
    }

    nonisolated static func severity(_ event:String)->Severity {
        switch event {
        case "click_failed","observation_error","claim_unconfirmed","verification_blocked","preclick_rejected",
             "crystal_blocked","crystal_click_rejected","crystal_opening_abandoned","event_blocked","event_click_rejected",
             "click_not_confirmed","candidate_lost":.problem
        case "input_deferred":.wait
        default:.info
        }
    }

    nonisolated static func label(_ event:String)->String {
        switch event {
        case "watcher_started":L("Gyűjtő elindult","Collector started")
        case "watcher_resumed":L("Gyűjtő folytatta","Collector resumed")
        case "watcher_stopped":L("Gyűjtő leállt","Collector stopped")
        case "reward_detected":L("Free jutalom észlelve","Free reward detected")
        case "click_intent":L("Kattintás előkészítése","Preparing click")
        case "click_validated":L("Friss képen ellenőrizve","Validated on fresh frame")
        case "input_geometry":L("Kattintás részletei","Click details")
        case "click_sent":L("Kattintás elküldve","Click sent")
        case "claim_confirmed_ui":L("Átvétel igazolva","Claim confirmed")
        case "click_not_confirmed":L("Kártya maradt, újrapróba","Card stayed, retrying")
        case "claim_unconfirmed":L("Átvétel nem igazolt","Claim not confirmed")
        case "input_deferred":L("Várakozás rád","Waiting for you")
        case "click_failed":L("Kattintás elmaradt","Click not sent")
        case "preclick_rejected":L("Ellenőrzés elutasította","Pre-click check rejected")
        case "candidate_lost":L("Jutalom eltűnt kattintás előtt","Reward vanished before click")
        case "verification_blocked":L("Igazolás elakadt","Verification stuck")
        case "observation_error":L("Képrögzítési hiba","Capture error")
        case "capture_recovered":L("Képrögzítés helyreállt","Capture recovered")
        case "observation_diagnostic","idle_observation":L("Diagnosztikai kép","Diagnostic frame")
        case "crystal_started":L("Kristálynyitás indul","Crystal opening started")
        case "crystal_screen","event_screen":L("Képernyő felismerve","Screen recognised")
        case "crystal_click_validated","event_click_validated":L("Kattintás ellenőrizve","Click validated")
        case "crystal_click_sent","event_click_sent":L("Kattintás elküldve","Click sent")
        case "crystal_click_rejected","event_click_rejected":L("Kattintás elutasítva","Click rejected")
        case "crystal_blocked","event_blocked":L("Folyamat elakadt","Flow stuck")
        case "crystal_completed_ui":L("Kristálykör kész","Crystal round done")
        case "crystal_finished_no_reward":L("Kristálykör megszakadt","Crystal round interrupted")
        case "crystal_opening_abandoned":L("Kristálynyitás feladva","Crystal opening abandoned")
        case "event_started":L("Esemény végi ablak","Event-end overlay")
        case "event_dismissed_ui":L("Esemény ablak bezárva","Event overlay dismissed")
        case "event_returned_to_hud":L("Visszatért a játékhoz","Returned to game")
        default:event
        }
    }
}
