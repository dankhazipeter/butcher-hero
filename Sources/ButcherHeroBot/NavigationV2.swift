import Foundation

/// Single navigation owner. Coordinates are minimap pixels, not swipe counts.
/// Unknown space is a hypothesis; only measured movement creates free edges.
final class NavigationV2 {
    struct Point:Codable,Equatable {var x:Double;var y:Double}
    struct TerrainPose {let chart:Int;let x:Double;let y:Double}
    struct Cell:Codable,Hashable {let x:Int;let y:Int}
    struct Bounds:Decodable {let minX:Double;let maxX:Double;let minY:Double;let maxY:Double
        func contains(_ p:Point)->Bool {p.x>=minX && p.x<=maxX && p.y>=minY && p.y<=maxY}}
    struct Corridor:Decodable {
        let points:[Point];let evidence:String;let space:String?
        let activationBounds:Bounds?;let minimumBeyond:Double?;let goalBounds:Bounds?;let arrivalRadius:Double?
    }
    struct Checkpoint:Codable {
        let position:Point;let goal:Point?;let wall:Point?;let wallNormal:Point?
        let wallTravel:Double;let wallProbe:Bool;let probeTravel:Double;let scene:[Int]
        let space:String?
        let wallTurnSign:Double?
    }
    struct State:Codable {
        var version=3
        var blocked:[String:Int]=[:]
        var traversed:[String:Int]=[:]
        var visits:[String:Int]=[:]
        var evidence:[String:String]=[:]
        var corridorRetryAfter:[String:Double]?
        var checkpoint:Checkpoint?
    }
    struct Command {let x:Double;let y:Double;let duration:Double;let reason:String}
    struct Snapshot:Codable {
        let space:String
        let position:Point?;let goal:Point?;let mode:String
        let blockedEdges:Int;let traversedEdges:Int;let wallTravel:Double
    }
    private struct Pending {let start:Point;let dx:Double;let dy:Double;let duration:Double}
    private var state:State
    private let path:String
    private let readOnly:Bool
    private var position:Point?
    private var goal:Point?
    private var exploring=false
    private var pending:Pending?
    private var failureCount=0
    private var wall:Point?
    private var wallNormal:Point?
    private var wallTurnSign = -1.0
    private var probeTravel=0.0
    private var wallTravel=0.0
    private var wallProbe=false
    private var missingPose=0
    private var missingGoal=0
    private var mode="unlocalized"
    private var speed=5.0
    private var worldToMap=0.045
    private var lastAnchor:Point?
    private var lastAnchoredPosition:Point?
    private var restorationAttempted=false
    private var space="orange-skull"
    private var corridors:[Corridor]=[]
    private var portal:[Point]=[]
    private var portalEvidence=""
    private var portalArrivalRadius=2.0
    private var portalGoalBounds:Bounds?
    private let size=3.0
    init(path:String="docs/navigation-v2-map.json",readOnly:Bool=false) {
        self.path=path;self.readOnly=readOnly
        state=(try? Data(contentsOf:URL(fileURLWithPath:path)))
            .flatMap{try? JSONDecoder().decode(State.self,from:$0)} ?? State()
        if state.version<3 {state.checkpoint=nil;state.version=3}
        // Import only visually verified, directed traversals; no timed route macro.
        if path=="docs/navigation-v2-map.json",
           let data=try? Data(contentsOf:URL(fileURLWithPath:"docs/navigation-v2-corridors.json")),
           let corridors=try? JSONDecoder().decode([Corridor].self,from:data) {
            self.corridors=corridors
            for corridor in corridors {
                space=corridor.space ?? "orange-skull"
                for (a,b) in zip(corridor.points,corridor.points.dropFirst()) {
                    let n=max(1,Int(ceil(distance(a,b)/size)))
                    var last=cell(a)
                    for i in 1...n {
                        let t=Double(i)/Double(n),next=cell(.init(x:a.x+(b.x-a.x)*t,y:a.y+(b.y-a.y)*t))
                        if next != last {
                            let e=edge(last,next);state.traversed[e]=max(1,state.traversed[e,default:0])
                            state.evidence[e]=corridor.evidence;last=next
                        }
                    }
                }
            }
            space="orange-skull"
        }
    }
    private func length(_ p:Point)->Double{hypot(p.x,p.y)}
    private func distance(_ a:Point,_ b:Point)->Double{hypot(a.x-b.x,a.y-b.y)}
    private func unit(_ p:Point)->Point{let n=max(0.001,length(p));return .init(x:p.x/n,y:p.y/n)}
    private func cell(_ p:Point)->Cell{.init(x:Int((p.x/size).rounded()),y:Int((p.y/size).rounded()))}
    private func point(_ c:Cell)->Point{.init(x:Double(c.x)*size,y:Double(c.y)*size)}
    private func key(_ c:Cell)->String{(space=="orange-skull" ? "":"\(space):")+"\(c.x),\(c.y)"}
    private func edge(_ a:Cell,_ b:Cell)->String{"\(key(a))>\(key(b))"}
    private func persist(){guard !readOnly,let d=try? JSONEncoder().encode(state) else{return};try? d.write(to:URL(fileURLWithPath:path),options:.atomic)}
    func suspend(){pending=nil;mode="suspended"}
    /// One budgeted sensor-clearing step is not a new combat/navigation goal.
    /// Keep the chosen obstacle side, and never infer a wall from this step.
    func observationProbe()->Command {
        let direction=wall.map(unit) ?? Point(x:1,y:0)
        return .init(x:direction.x,y:direction.y,duration:0.50,
            reason:"HP-t takaró időzítő: egyszeri képtisztító lépés; a kerülőirány megmarad, nem gyógyulásigazolás")
    }
    func finishObservationProbe(){pending=nil;mode="observation-probe"}
    func handoffMovement() {
        pending=nil;goal=nil;exploring=false;wall=nil;wallNormal=nil;wallTravel=0
        wallProbe=false;probeTravel=0;portal=[];failureCount=0
        mode="combat/recovery handoff; old route cleared"
    }

    /// No command => no obstacle learning. UI/combat frames must call suspend.
    func observe(anchor:Point?,motion:Point?,evidence:String,scene:[Int]=[],terrain:TerrainPose?=nil) {
        // LocalWorldMap already verifies scene + minimap + optical flow. Reuse
        // its stable chart instead of discarding learned walls on every run.
        // Orange heads repeat across islands: an icon is NOT a unique world
        // origin. A verified terrain pose wins even on the first observation.
        let atlas=terrain
        let atlasSpace=atlas.map{"terrain-chart-\($0.chart)"}
        let atlasPosition=atlas.map{Point(x:$0.x*0.045,y:$0.y*0.045)}
        if let atlasSpace,space != atlasSpace {
            handoffMovement();position=nil;space=atlasSpace;missingPose=0
        }
        if !restorationAttempted {
            restorationAttempted=true
            let expectedSpace=atlasSpace ?? "orange-skull"
            if let saved=state.checkpoint,(saved.space ?? "orange-skull")==expectedSpace,
               let restoredPosition=atlasPosition ?? anchor,
               distance(saved.position,restoredPosition)<(atlas == nil ? 3:6),
               (atlas != nil || (!scene.isEmpty && scene.count==saved.scene.count &&
                Double(zip(scene,saved.scene).reduce(0){$0+abs($1.0-$1.1)})/Double(scene.count)<3)) {
                position=restoredPosition;goal=saved.goal;wall=saved.wall;wallNormal=saved.wallNormal
                wallTravel=saved.wallTravel;wallProbe=saved.wallProbe;probeTravel=saved.probeTravel
                wallTurnSign=saved.wallTurnSign ?? -1
            }
        }
        if atlas == nil,anchor != nil,space != "orange-skull" {
            handoffMovement();position=nil;space="orange-skull";missingPose=0
        }
        if atlas == nil,anchor == nil,motion != nil,(position == nil || (space=="orange-skull" && missingPose>=8)) {
            // Independent odometry chart, never mix uncertain global estimates
            // with the persistent landmark map or reuse its portal coordinates.
            handoffMovement();space="local-\(UUID().uuidString)";position = .init(x:0,y:0);missingPose=0
        }
        let old=position
        var current:Point?
        if let atlasPosition {
            if let old,distance(atlasPosition,old)>18 {
                pending=nil;goal=nil;wall=nil;wallNormal=nil;wallProbe=false
                wallTravel=0;probeTravel=0;failureCount=0;exploring=false
            }
            current=atlasPosition;missingPose=0;worldToMap=0.045
        } else if let anchor {
            if let old,distance(anchor,old)>18 {
                // A teleport or false landmark must not paint a wall.
                pending=nil;goal=nil;wall=nil;failureCount=0;mode="relocalized after jump"
            }
            current=anchor;missingPose=0
            if let old,let motion,length(motion)>10,distance(anchor,old)>0.5,distance(anchor,old)<12 {
                let sample=distance(anchor,old)/length(motion)
                if sample>0.01 && sample<0.15 {worldToMap=worldToMap*0.8+sample*0.2}
            }
            lastAnchor=anchor;lastAnchoredPosition=anchor
        } else if let old,let motion,(missingPose<8 || space != "orange-skull") {
            current = .init(x:old.x+motion.x*worldToMap,y:old.y+motion.y*worldToMap)
            if space != "orange-skull" {missingPose=0}
            else if length(motion)>3 {missingPose+=1}
        } else {missingPose+=1;pending=nil;mode="localization unavailable";return}
        guard let now=current else{return}
        position=now
        if let command=pending {
            let delta=Point(x:now.x-command.start.x,y:now.y-command.start.y)
            let forward=delta.x*command.dx+delta.y*command.dy
            let from=cell(command.start)
            let to=Cell(x:from.x+Int(command.dx.rounded()),y:from.y+Int(command.dy.rounded()))
            let e=edge(from,to)
            if forward<max(1.0,speed*command.duration*0.35) {
                failureCount+=1
                state.blocked[e,default:0]+=1;state.evidence[e]=evidence
                if failureCount>=2 {
                    if mode=="verified-portal" {
                        // Old evidence never authorizes repeating a failed live
                        // corridor indefinitely. Cool down this directed route.
                        if state.corridorRetryAfter==nil {state.corridorRetryAfter=[:]}
                        state.corridorRetryAfter?[portalEvidence]=Date().timeIntervalSinceReferenceDate+300
                        portal=[]
                    }
                    if wall == nil {
                        let left=Point(x:command.dy,y:-command.dx)
                        let right=Point(x:-left.x,y:-left.y)
                        let toward=goal.map{unit(.init(x:$0.x-now.x,y:$0.y-now.y))} ?? .init(x:0,y:0)
                        func score(_ tangent:Point)->Double {
                            let next=Cell(x:from.x+Int(tangent.x.rounded()),y:from.y+Int(tangent.y.rounded()))
                            return tangent.x*toward.x+tangent.y*toward.y
                                - Double(state.blocked[edge(from,next),default:0])*2
                        }
                        let chooseRight=score(right)>score(left)+0.05
                        wall=chooseRight ? right:left
                        wallTurnSign=chooseRight ? 1:-1
                        wallNormal = abs(command.dx)>=abs(command.dy)
                            ? .init(x:command.dx>=0 ? 1:-1,y:0)
                            : .init(x:0,y:command.dy>=0 ? 1:-1)
                    } else if mode=="wall-follow" {
                        let w=wall!
                        wall = .init(x:(w.x-wallTurnSign*w.y)*0.7071,
                                     y:(wallTurnSign*w.x+w.y)*0.7071)
                    }
                    wallTravel=0;wallProbe=false;probeTravel=0;failureCount=0
                }
            } else {
                failureCount=0
                if forward>2.5 {speed=speed*0.7+min(18,forward/max(0.1,command.duration))*0.3}
                let actual=cell(now)
                if actual != from {
                    let measured=edge(from,actual)
                    state.traversed[measured,default:0]+=1;state.evidence[measured]=evidence
                }
                if mode=="wall-follow" {wallTravel+=max(0,forward)}
                if wallProbe,let normal=wallNormal {
                    probeTravel+=max(0,delta.x*normal.x+delta.y*normal.y)
                    // One diagonal step can merely enter a gate alcove. Clear
                    // the entire obstacle thickness before turning to the goal.
                    if probeTravel>=9 {wall=nil;wallProbe=false;wallTravel=0;probeTravel=0}
                }
            }
            state.visits[key(cell(now)),default:0]+=1
        }
        pending=nil
        state.checkpoint = .init(position:now,goal:goal,wall:wall,wallNormal:wallNormal,
            wallTravel:wallTravel,wallProbe:wallProbe,probeTravel:probeTravel,scene:scene,space:space,wallTurnSign:wallTurnSign)
        persist()
    }

    /// A* on directed, collision-tested transitions. Unknown edges carry extra cost.
    private func route(from:Cell,to:Cell)->[Cell] {
        let margin=12
        let minX=min(from.x,to.x)-margin,maxX=max(from.x,to.x)+margin
        let minY=min(from.y,to.y)-margin,maxY=max(from.y,to.y)+margin
        var open=[from],cost:[Cell:Double]=[from:0],parent:[Cell:Cell]=[:],closed=Set<Cell>()
        func h(_ c:Cell)->Double{hypot(Double(c.x-to.x),Double(c.y-to.y))}
        var expansions=0
        while !open.isEmpty && expansions<2500 {
            let index=open.indices.min{cost[open[$0],default:1e9]+h(open[$0]) < cost[open[$1],default:1e9]+h(open[$1])}!
            let at=open.remove(at:index)
            if at==to {
                var result=[at],p=at
                while let before=parent[p] {result.append(before);p=before}
                return Array(result.reversed().dropFirst())
            }
            if !closed.insert(at).inserted {continue};expansions+=1
            for dy in -1...1 {for dx in -1...1 where dx != 0 || dy != 0 {
                let next=Cell(x:at.x+dx,y:at.y+dy)
                guard next.x>=minX,next.x<=maxX,next.y>=minY,next.y<=maxY,!closed.contains(next) else{continue}
                let e=edge(at,next)
                guard state.blocked[e,default:0]<2 else{continue}
                // A failed cardinal wall also blocks diagonal corner cutting.
                if dx != 0 && dy != 0 {
                    let horizontal=edge(at,.init(x:at.x+dx,y:at.y))
                    let vertical=edge(at,.init(x:at.x,y:at.y+dy))
                    if state.blocked[horizontal,default:0]>=2 || state.blocked[vertical,default:0]>=2 {continue}
                }
                let step=hypot(Double(dx),Double(dy))*(state.traversed[e] != nil ? 1:3)
                let nextCost=cost[at,default:1e9]+step+Double(state.visits[key(next),default:0])*0.08
                if nextCost<cost[next,default:1e9] {cost[next]=nextCost;parent[next]=at;open.append(next)}
            }}
        }
        return []
    }
    func screenOffset(x:Double,y:Double)->Point{.init(x:x*worldToMap,y:y*worldToMap)}
    /// A measured local chart can explore even when its last red dot was killed.
    /// Short frontier goals use the same collision-tested planner, not old macros.
    private func frontier(from here:Point)->Point? {
        let start=cell(here)
        var best:(Point,Double)?
        for dy in -1...1 {for dx in -1...1 where dx != 0 || dy != 0 {
            let end=Cell(x:start.x+dx*4,y:start.y+dy*4)
            let path=route(from:start,to:end)
            guard !path.isEmpty else{continue}
            let visited=path.reduce(0){$0+state.visits[key($1),default:0]}
            let score=Double(visited)*4+Double(path.count)*0.15
            if best == nil || score<best!.1 {best=(point(end),score)}
        }}
        return best?.0
    }
    func decide(targetOffset:Point?,preferCurrentTarget:Bool=false)->Command? {
        guard let here=position,missingPose<=8 else{return nil}
        if let targetOffset {
            let candidate=Point(x:here.x+targetOffset.x,y:here.y+targetOffset.y)
            if preferCurrentTarget,let normal=wallNormal,
               targetOffset.x*normal.x+targetOffset.y*normal.y < -3 {
                // A visible target behind us is not behind the old wall.
                wall=nil;wallNormal=nil;wallTravel=0;wallProbe=false;probeTravel=0
                portal=[];failureCount=0
            }
            if exploring || preferCurrentTarget || goal == nil || distance(goal!,here)<5 || missingGoal>12 {goal=candidate;missingGoal=0}
            else if distance(candidate,goal!)<10 {goal=candidate;missingGoal=0}
            else {missingGoal+=1}
            exploring=false
        } else {missingGoal+=1}
        if targetOffset == nil,(goal == nil || distance(goal!,here)<3 || (!exploring && missingGoal>18)) {
            goal=frontier(from:here);exploring=goal != nil;missingGoal=0
        }
        guard let goal else{return nil}
        if !portal.isEmpty,let bounds=portalGoalBounds,!bounds.contains(goal) {
            portal=[];portalGoalBounds=nil
        }
        if portal.isEmpty {
            // Topological planning: crossing a known boundary uses its observed
            // portal before geometric routing. No direct-line cliff crossing.
            let choices=corridors.filter { c in
                guard (c.space ?? "orange-skull")==space,
                      c.activationBounds?.contains(here) ?? true,
                      c.goalBounds?.contains(goal) ?? true,
                      (state.corridorRetryAfter?[c.evidence] ?? 0)<=Date().timeIntervalSinceReferenceDate else{return false}
                guard let a=c.points.first,let b=c.points.last else{return false}
                let axis=unit(.init(x:b.x-a.x,y:b.y-a.y))
                let before=(here.x-b.x)*axis.x+(here.y-b.y)*axis.y
                let beyond=(goal.x-b.x)*axis.x+(goal.y-b.y)*axis.y
                return before < -1 && beyond>(c.minimumBeyond ?? 6) && distance(here,a)<45
            }
            if let c=choices.min(by:{distance(here,$0.points.first!)<distance(here,$1.points.first!)}),
               let i=c.points.indices.min(by:{distance(here,c.points[$0])<distance(here,c.points[$1])}) {
                portal=Array(c.points[i...]);portalEvidence=c.evidence
                portalArrivalRadius=min(2,max(0.5,c.arrivalRadius ?? 2))
                portalGoalBounds=c.goalBounds
                wall=nil;wallProbe=false;wallTravel=0;probeTravel=0
            }
        }
        while let first=portal.first,distance(first,here)<portalArrivalRadius {portal.removeFirst()}
        if let waypoint=portal.first {
            let d=distance(waypoint,here),u=unit(.init(x:waypoint.x-here.x,y:waypoint.y-here.y))
            mode="verified-portal"
            return .init(x:u.x,y:u.y,duration:min(0.60,max(portalArrivalRadius<2 ? 0.12:0.25,d/max(2,speed))),
                reason:"Navigáció V2: bizonyított átjáró képi pontjai; hátralévő \(portal.count), távolság \(Int(d))px")
        }
        let toward=unit(.init(x:goal.x-here.x,y:goal.y-here.y))
        let direction:Point
        if let wall,wallTravel<6 {
            direction=unit(wall);mode="wall-follow"
        } else if wall != nil,let normal=wallNormal {
            wallProbe=true;direction=normal;mode="wall-probe"
        } else {
            let path=route(from:cell(here),to:cell(goal))
            if let next=path.first {
                let waypoint=point(next)
                direction=unit(.init(x:waypoint.x-here.x,y:waypoint.y-here.y))
            } else {direction=toward}
            mode=exploring ? "frontier-astar":"astar"
        }
        let duration=min(0.68,max(0.30,3.2/max(2,speed)))
        return .init(x:direction.x,y:direction.y,duration:duration,
            reason:"Navigáció V2: \(mode); egy cél, \(state.blocked.count) mért akadályél, \(Int(wallTravel))px falmenti haladás")
    }
    func recordExecuted(_ command:Command) {
        guard let position else{return}
        pending = .init(start:position,dx:command.x,dy:command.y,duration:command.duration)
    }
    func snapshot()->Snapshot{.init(space:space,position:position,goal:goal,mode:mode,blockedEdges:state.blocked.count,traversedEdges:state.traversed.count,wallTravel:wallTravel)}
}
