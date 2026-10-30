import Foundation

/// Chart-scoped objective memory. Icon classes repeat: never merge charts by
/// matching a weapon glyph, and never infer combat strength from icon colour.
final class MapObjectivePlanner {
    struct Seen {let kind:String;let dx:Double;let dy:Double}
    struct Entry:Codable {
        let id:String;let kind:String;let space:String
        var x:Double;var y:Double;var lastSeen:Double
        var blockedUntil:Double=0;var result="observed; strength unknown"
    }
    struct State:Codable {var entries:[Entry]=[];var selected:String?}
    struct Choice {let dx:Double;let dy:Double;let id:String;let kind:String}
    private var state:State
    private let path:String;private let readOnly:Bool
    private var current:[String:Seen]=[:]
    private var pending=false,stagnant=0
    private var previousDistance:Double?
    private var previousPosition:(Double,Double)?
    init(path:String="docs/map-objectives.json",readOnly:Bool=false) {
        self.path=path;self.readOnly=readOnly
        state=(try? Data(contentsOf:URL(fileURLWithPath:path)))
            .flatMap{try? JSONDecoder().decode(State.self,from:$0)} ?? State()
    }
    private func save() {
        guard !readOnly,let data=try? JSONEncoder().encode(state) else{return}
        try? data.write(to:URL(fileURLWithPath:path),options:.atomic)
    }
    func observe(_ seen:[Seen],space:String,x:Double,y:Double,now:Double=Date().timeIntervalSince1970) {
        current=[:]
        for s in seen {
            let wx=x+s.dx,wy=y+s.dy
            let matching=state.entries.indices.filter {
                state.entries[$0].kind==s.kind && state.entries[$0].space==space &&
                hypot(state.entries[$0].x-wx,state.entries[$0].y-wy)<8
            }.min{hypot(state.entries[$0].x-wx,state.entries[$0].y-wy)<hypot(state.entries[$1].x-wx,state.entries[$1].y-wy)}
            let i:Int
            if let matching {i=matching}
            else {i=state.entries.count;state.entries.append(.init(id:UUID().uuidString,kind:s.kind,space:space,x:wx,y:wy,lastSeen:now))}
            state.entries[i].x=wx;state.entries[i].y=wy;state.entries[i].lastSeen=now
            current[state.entries[i].id]=s
        }
        if let id=state.selected,let s=current[id] {
            let d=hypot(s.dx,s.dy)
            if pending,let old=previousPosition {
                // A legitimate obstacle detour may increase target distance.
                // Quarantine only actual stationary executed attempts.
                stagnant = hypot(x-old.0,y-old.1)<0.75 ? stagnant+1:0
                if stagnant>=12,let i=state.entries.firstIndex(where:{$0.id==id}) {
                    state.entries[i].blockedUntil=now+180
                    state.entries[i].result="12 executed approaches without measured movement; route review required"
                    state.selected=nil;previousDistance=nil;stagnant=0
                }
            }
            if state.selected != nil {previousDistance=d}
        } else {state.selected=nil;previousDistance=nil;stagnant=0}
        previousPosition=(x,y);pending=false;save()
    }
    func choose(now:Double=Date().timeIntervalSince1970)->Choice? {
        // Red heads are unlock bosses. Orange heads require their individual
        // combat record. Neither is an automatic fallback over active weapons.
        let available=state.entries.filter {
            $0.kind.hasPrefix("weapon-") && $0.blockedUntil<=now && current[$0.id] != nil &&
            hypot(current[$0.id]!.dx,current[$0.id]!.dy)>5
        }
        let entry=available.first(where:{$0.id==state.selected}) ?? available.min {
            hypot(current[$0.id]!.dx,current[$0.id]!.dy)<hypot(current[$1.id]!.dx,current[$1.id]!.dy)
        }
        guard let entry,let s=current[entry.id] else{return nil}
        if state.selected != entry.id {previousDistance=hypot(s.dx,s.dy);stagnant=0}
        state.selected=entry.id;save()
        let d=hypot(s.dx,s.dy),horizon=min(d,18)
        return .init(dx:s.dx/d*horizon,dy:s.dy/d*horizon,id:entry.id,kind:entry.kind)
    }
    func recordExecuted(){pending=true}
    func snapshot()->State {state}
}
