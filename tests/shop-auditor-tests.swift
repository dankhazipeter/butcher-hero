import Foundation

@main struct ShopAuditorTests {
    static func main() {
        let auditor=ShopAuditor(readOnly:true,loadState:false)
        let hud=ShopObservation(visible:false,badgeVisible:true,freeButtons:[],contentKey:"",texts:[])
        assert(auditor.next(hud,safeToOpen:false) == nil)
        guard case .open? = auditor.next(hud,safeToOpen:true) else {fatalError("safe badge must open")}
        let free=ShopFreeButton(x:0.30,y:0.70,label:"Free +1")
        let offer=ShopObservation(visible:true,badgeVisible:false,freeButtons:[free],contentKey:"Free+1",texts:[])
        guard case .tap?=auditor.next(offer,safeToOpen:false) else {fatalError("Free must claim")}
        var paid=ShopObservation(visible:true,badgeVisible:false,freeButtons:[],contentKey:"50",texts:[])
        paid.paidButtons=[.init(x:0.31,y:0.70,label:"50")]
        for _ in 0..<2 { guard case .wait?=auditor.next(paid,safeToOpen:false) else {fatalError("must settle")} }
        guard case .wait(let message)?=auditor.next(paid,safeToOpen:false),message.contains("képpel igazolt") else {fatalError("paid successor confirms, is never purchased")}
        guard case .scroll(up:false)?=auditor.next(paid,safeToOpen:false) else {fatalError("must first find top")}
        guard case .wait?=auditor.next(paid,safeToOpen:false) else {fatalError("top verified")}
        guard case .scroll(up:true)?=auditor.next(paid,safeToOpen:false) else {fatalError("must scan downward")}
        guard case .scroll(up:true)?=auditor.next(paid,safeToOpen:false) else {fatalError("bottom needs second confirmation")}
        guard case .close?=auditor.next(paid,safeToOpen:false) else {fatalError("close after full sweep")}
        print("PASS: safe badge, Free-only tap, paid successor verification, top-to-bottom sweep")

        let uncertain=ShopAuditor(readOnly:true,loadState:false)
        _=uncertain.next(offer,safeToOpen:false)
        let missing=ShopObservation(visible:true,badgeVisible:false,freeButtons:[],contentKey:"OCR missing",texts:[])
        for _ in 0..<6 {
            if case .wait(let reason)?=uncertain.next(missing,safeToOpen:false) { assert(!reason.contains("képpel igazolt")) }
        }
        guard case .close?=uncertain.next(missing,safeToOpen:false) else {fatalError("unproven disappearance must fail closed")}
        print("PASS: missing OCR is not a successful claim")
        let chestAudit=ShopAuditor(readOnly:true,loadState:false)
        let chest=ShopObservation(visible:true,badgeVisible:false,freeButtons:[],contentKey:"Weapon",texts:[],tab:"chests")
        guard case .selectStats?=chestAudit.next(chest,safeToOpen:false) else{fatalError("stat audit must switch from chests")}
        print("PASS: chest panel explicitly redirects to Stats without claiming a chest")
    }
}
