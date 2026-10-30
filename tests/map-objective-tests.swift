import Foundation
import ImageIO
@main struct Tests {
    static func main() {
        let detector=MapObjectiveDetector()
        func icons(_ path:String,_ expanded:Bool)->[MapObjectiveDetector.Icon] {
            let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil)!
            return detector.detect(CGImageSourceCreateImageAtIndex(source,0,nil)!,expanded:expanded)
        }
        let large=icons("docs/runs/20260919-205539-4953ef18-observe/frame-00000.png",true)
        precondition(Set(large.map(\.kind))==Set(["weapon-cyan","weapon-green","golem-orange","progression-red"]))
        precondition(large.count==4,"grey eastern head and grey weapons are not active objectives")
        let small=icons("docs/runs/20260919-205503-68f978e1-observe/frame-00000.png",false)
        precondition(small.filter{$0.kind.hasPrefix("weapon-")}.count==2)
        let red=icons("docs/runs/20260919-203913-ce0e5246-observe/frame-00000.png",false)
        precondition(red.contains{$0.kind=="progression-red"} && red.contains{$0.kind=="golem-orange"})
        let p=MapObjectivePlanner(path:"/nonexistent-map-objective-tests",readOnly:true)
        let seen:[MapObjectivePlanner.Seen]=[.init(kind:"progression-red",dx:10,dy:0),
            .init(kind:"golem-orange",dx:12,dy:0),.init(kind:"weapon-cyan",dx:20,dy:0),
            .init(kind:"weapon-green",dx:30,dy:0)]
        p.observe(seen,space:"terrain-chart-1",x:0,y:0,now:100)
        let first=p.choose(now:100)!
        precondition(first.kind=="weapon-cyan","weapon guard first, not nearest boss head")
        for _ in 0..<20 {p.observe(seen,space:"terrain-chart-1",x:0,y:0,now:101);_ = p.choose(now:101)}
        precondition(p.choose(now:101)!.id==first.id,"no input cannot learn blocked target")
        for _ in 0..<12 {p.recordExecuted();p.observe(seen,space:"terrain-chart-1",x:0,y:0,now:102);_ = p.choose(now:102)}
        precondition(p.choose(now:102)!.kind=="weapon-green","failed route must yield to another weapon")
        let heads=MapObjectivePlanner(path:"/nonexistent-head-only-tests",readOnly:true)
        heads.observe(Array(seen.prefix(2)),space:"terrain-chart-1",x:0,y:0,now:100)
        precondition(heads.choose(now:100)==nil,"no automatic large-boss fallback")
        let detour=MapObjectivePlanner(path:"/nonexistent-detour-tests",readOnly:true)
        for i in 0..<20 {
            detour.observe([.init(kind:"weapon-cyan",dx:20,dy:Double(i))],space:"terrain-chart-2",x:0,y:-Double(i),now:100)
            precondition(detour.choose(now:100) != nil,"moving away on a real detour must not quarantine")
            detour.recordExecuted()
        }
        print("PASS: active weapon/head classes, grey exclusion, weapon priority, no-input safety, blocked-target rotation, legitimate detour")
    }
}
