import Foundation

final class ShopAuditor {
    enum Directive {
        case wait(String), open, selectStats, tap(ShopFreeButton), scroll(up: Bool), close(String)
    }
    struct State: Codable {
        var nextAuditAt: Date = .distantPast
        var lastBadgeVisible = false
        var confirmedClaims = 0
        var lastResult = "Még nem auditált"
        var pendingClaim: ShopFreeButton?
        var pendingClaimAt: Date?
    }
    private let url = URL(fileURLWithPath: "docs/shop-state.json")
    private let readOnly: Bool
    private var state: State
    private var active = false
    private var openingFrames = 0
    private var resettingTop = true
    private var scrolls = 0
    private var totalScrolls = 0
    private var previousContent = ""
    private var stableContent = 0
    private var pending: ShopFreeButton?
    private var pendingFrames = 0
    private var attempts = 0
    private var claimWait = 0
    private var closing = false

    init(readOnly: Bool, loadState: Bool = true) {
        self.readOnly = readOnly
        state = loadState ? ((try? Data(contentsOf:url)).flatMap { try? JSONDecoder().decode(State.self,from:$0) } ?? State()) : State()
    }
    private func persist() {
        guard !readOnly, let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to:url,options:.atomic)
    }
    private func finish(_ result: String) -> Directive {
        state.nextAuditAt = Date().addingTimeInterval(300)
        state.lastResult = result
        persist()
        closing = true
        return .close(result)
    }
    func next(_ o: ShopObservation, safeToOpen: Bool) -> Directive? {
        if !o.visible {
            if closing { active = false; closing = false }
            if active {
                openingFrames += 1
                if openingFrames <= 5 { return .wait("Bolt megnyílását várom") }
                active = false
                state.nextAuditAt = Date().addingTimeInterval(60)
                state.lastResult = "Panelnyitás nem igazolt"
                persist()
                return nil
            }
            let newBadge = o.badgeVisible && !state.lastBadgeVisible
            if state.lastBadgeVisible != o.badgeVisible { state.lastBadgeVisible=o.badgeVisible;persist() }
            guard o.badgeVisible, safeToOpen,
                  Date() >= state.nextAuditAt || newBadge else { return nil }
            begin()
            return .open
        }
        if !active { begin() }
        if o.tab == "chests" {return .selectStats}
        if closing { return .wait("Boltbezárás utáni képi átmenetet várom; nem ismétlek vak tapot") }
        openingFrames = 0
        if claimWait > 0 { claimWait -= 1; return .wait("Free átvétel utáni képi állapotot ellenőrzöm") }
        if let pending {
            if o.freeButtons.contains(where: { abs($0.x-pending.x)<0.03 && abs($0.y-pending.y)<0.025 }) {
                pendingFrames += 1
                if pendingFrames < 3 { return .wait("A Free gomb változását várom") }
                if attempts < 2 { attempts += 1; pendingFrames=0;claimWait=2;return .tap(pending) }
                self.pending=nil
                state.pendingClaim=nil;state.pendingClaimAt=nil
                return finish("A Free gomb két próbára sem változott; felügyeleti ellenőrzés kell")
            }
            guard o.paidButtons.contains(where: {abs($0.x-pending.x)<0.05 && abs($0.y-pending.y)<0.025}) else {
                pendingFrames += 1
                if pendingFrames < 5 { return .wait("A Free helyén az új ajánlatot még nem azonosítottam; nem állítok átvételt") }
                self.pending=nil
                state.pendingClaim=nil;state.pendingClaimAt=nil
                return finish("A Free eltűnt, de a következő ajánlat nem igazolt; képi ellenőrzés kell")
            }
            state.confirmedClaims += 1
            state.lastResult = "Free helyén fizetős következő ajánlat igazolt: \(pending.label)"
            state.pendingClaim=nil;state.pendingClaimAt=nil
            persist()
            self.pending = nil
            return .wait("Free átvétel képpel igazolt: \(pending.label); fizetős következő ajánlatot nem nyomok meg")
        }
        if let button = o.freeButtons.first {
            pending = button;pendingFrames=0;attempts=1;claimWait=2
            state.pendingClaim=button;state.pendingClaimAt=Date();persist()
            return .tap(button)
        }
        if totalScrolls >= 20 { return finish("Görgetési korlát elérve; részleges audit, később újraellenőrzöm") }
        if !previousContent.isEmpty && previousContent == o.contentKey { stableContent += 1 } else { stableContent = 0 }
        previousContent = o.contentKey
        if resettingTop && (stableContent >= 1 || scrolls >= 6) {
            resettingTop=false;scrolls=0;stableContent=0;previousContent=""
            return .wait("Boltlista teteje/előkészítése kész; teljes lefelé audit indul")
        }
        if !resettingTop && stableContent >= 2 { return finish("A statlista alja kétszer változatlan; látható Free ajánlatok ellenőrizve") }
        scrolls += 1;totalScrolls += 1
        return .scroll(up: !resettingTop)
    }
    private func begin() {
        active=true;closing=false;openingFrames=0;resettingTop=true;scrolls=0;totalScrolls=0
        previousContent="";stableContent=0;pending=nil;claimWait=0
        if let date=state.pendingClaimAt,Date().timeIntervalSince(date)<300 {
            pending=state.pendingClaim;pendingFrames=0;attempts=1
        } else { state.pendingClaim=nil;state.pendingClaimAt=nil }
    }
}
