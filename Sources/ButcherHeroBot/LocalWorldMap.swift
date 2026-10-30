import Foundation
import CoreGraphics
import ImageIO

/// Evidence-backed local charts, not an assumed global game coordinate system.
/// Unknown camera jumps split charts; only strong scene AND minimap matches join.
final class LocalWorldMap {
    struct Point:Codable {var x:Double;var y:Double}
    struct Enemy:Codable {
        var position:Point;var maximumObservedHP:Int;var lastSeen:Date
        var observations:Int;var evidence:String
        var reconsiderAfter:Date?
    }
    struct Node:Codable {
        var id:Int;var chart:Int;var position:Point;var scene:[UInt8];var minimap:[UInt8]
        var visits:Int;var blocked:[Int:Int];var evidence:String
        var orangeCoverage:Double?
        var anchorPose:MinimapPose?
    }
    struct Edge:Codable {var from:Int;var to:Int;var traversals:Int;var evidence:String}
    struct Chart:Codable {var id:Int;var enemies:[Enemy]}
    struct Checkpoint:Codable {
        var chart:Int;var position:Point;var scene:[UInt8];var minimap:[UInt8];var evidence:String
    }
    struct State:Codable {
        var version=1;var nodes:[Node]=[];var edges:[Edge]=[];var charts:[Chart]=[]
        var checkpoint:Checkpoint?
    }
    struct Snapshot:Codable {
        let chart:Int?;let position:Point;let node:Int?;let motion:CameraMotion?
        let status:String;let speed:Double?;let nodes:Int;let edges:Int
    }
    struct Steering {let x:Double;let y:Double;let duration:Double;let reason:String}
    private struct Executed {let x:Double;let y:Double;let duration:Double;let learnObstacle:Bool}
    private var state:State
    private let url:URL
    private let readOnly:Bool
    private let odometry=VisualOdometry()
    private var previous:CGImage?
    private var executed:Executed?
    private var chart:Int?
    private var position=Point(x:0,y:0)
    private var node:Int?
    private var validPose=false
    private var speed:Double?
    private var stuck=0
    private var escape:Point?
    private var escapeDistance=0.0
    private var lastStatus="unlocalized"
    private var lastMotion:CameraMotion?
    private var observations=0
    private var route:[Int]=[]
    private var routeChart:Int?
    private var routePurpose="a korábban látott Island2-ellenfélhez"

    init(path:String="docs/local-world-map.json",readOnly:Bool=false,load:Bool=true) {
        url=URL(fileURLWithPath:path);self.readOnly=readOnly
        state=load ? ((try? Data(contentsOf:url)).flatMap{try? JSONDecoder().decode(State.self,from:$0)} ?? State()) : State()
    }
    private func persist(){guard !readOnly,let data=try? JSONEncoder().encode(state) else{return};try? data.write(to:url,options:.atomic)}
    private func distance(_ a:Point,_ b:Point)->Double{hypot(a.x-b.x,a.y-b.y)}
    private func descriptor(_ image:CGImage,_ rect:CGRect,_ w:Int,_ h:Int)->[UInt8] {
        let r=CGRect(x:rect.minX*Double(image.width),y:rect.minY*Double(image.height),width:rect.width*Double(image.width),height:rect.height*Double(image.height)).integral
        guard let crop=image.cropping(to:r),let c=CGContext(data:nil,width:w,height:h,bitsPerComponent:8,bytesPerRow:w,space:CGColorSpaceCreateDeviceGray(),bitmapInfo:0) else{return []}
        c.draw(crop,in:CGRect(x:0,y:0,width:w,height:h))
        let p=c.data!.assumingMemoryBound(to:UInt8.self)
        return Array(UnsafeBufferPointer(start:p,count:w*h))
    }
    private func difference(_ a:[UInt8],_ b:[UInt8])->Double {
        guard !a.isEmpty,a.count==b.count else{return 999}
        return zip(a,b).reduce(0){$0+abs(Double($1.0)-Double($1.1))}/Double(a.count)
    }
    private func sector(_ x:Double,_ y:Double)->Int{(Int((atan2(y,x)/(Double.pi/4)).rounded())+8)%8}
    private func evidenceImage(_ evidence:String)->CGImage? {
        let path=(evidence.hasPrefix("/") || evidence.hasPrefix("docs/runs/")) ? evidence:"docs/runs/"+evidence
        guard let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil) else{return nil}
        return CGImageSourceCreateImageAtIndex(source,0,nil)
    }
    private func alignedSceneDifference(_ source:CGImage,scene:[UInt8],motion:CameraMotion)->Double {
        guard let c=CGContext(data:nil,width:source.width,height:source.height,bitsPerComponent:8,bytesPerRow:0,
            space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else{return 999}
        c.draw(source,in:CGRect(x:motion.dx,y:-motion.dy,width:Double(source.width),height:Double(source.height)))
        guard let aligned=c.makeImage() else{return 999}
        return difference(scene,descriptor(aligned,.init(x:0.18,y:0.20,width:0.58,height:0.57),24,28))
    }

    func observe(_ image:CGImage,eligible:Bool,evidence:String,orangeCoverage:Double?=nil,anchorPose:MinimapPose?=nil)->Snapshot {
        defer {previous=eligible ? image:nil;executed=nil;persist()}
        lastMotion=nil
        observations+=1
        guard eligible else {
            previous=nil;validPose=false;escape=nil;stuck=0;route=[]
            lastStatus="UI/user/combat transition: mapping suspended"
            return snapshot()
        }
        let scene=descriptor(image,.init(x:0.18,y:0.20,width:0.58,height:0.57),24,28)
        let minimap=descriptor(image,.init(x:0.78,y:0.065,width:0.19,height:0.15),20,20)
        var moved=0.0
        // Prefer the last observed image/pose over two loosely ranked old
        // keyframes. The final executed swipe may not have a post-input frame.
        // Verify its displacement; never restore coordinates from age alone.
        if !validPose, let saved=state.checkpoint,
           state.charts.contains(where:{$0.id==saved.chart}),
           difference(scene,saved.scene)<40,difference(minimap,saved.minimap)<18,
           let keyframe=evidenceImage(saved.evidence) {
            let motion=odometry.measure(previous:keyframe,current:image)
            if motion.valid,motion.consensus>=15,motion.residual<3.5,
               hypot(motion.dx,motion.dy)<160,
               alignedSceneDifference(keyframe,scene:scene,motion:motion)<12 {
                chart=saved.chart
                position = .init(x:saved.position.x-motion.dx,y:saved.position.y-motion.dy)
                validPose=true;lastMotion=motion
                lastStatus="checkpoint + scene + minimap + verified motion relocalized"
            }
        }
        if let previous,validPose {
            let motion=odometry.measure(previous:previous,current:image);lastMotion=motion
            if motion.valid && hypot(motion.dx,motion.dy)<200 {
                position.x-=motion.dx;position.y-=motion.dy;moved=hypot(motion.dx,motion.dy)
                lastStatus="measured"
                var forwardProgress=0.0
                if let executed,executed.learnObstacle {
                    let norm=max(0.001,hypot(executed.x,executed.y))
                    forwardProgress=(-motion.dx*executed.x-motion.dy*executed.y)/norm
                    let minimumProgress=min(12,max(4,(speed ?? 100)*executed.duration*0.12))
                    if forwardProgress<minimumProgress && executed.duration>=0.30 {stuck+=1}
                    else if forwardProgress>=minimumProgress {stuck=0}
                    if stuck>=2,let node,let i=state.nodes.firstIndex(where:{$0.id==node}) {
                        let s=sector(executed.x,executed.y)
                        state.nodes[i].blocked[s,default:0]+=1
                        escape=nil;escapeDistance=0
                    }
                    if forwardProgress>12 {
                        let sample=forwardProgress/executed.duration
                        speed=speed.map{$0*0.7+sample*0.3} ?? sample
                    }
                }
                if escape != nil {escapeDistance+=max(0,forwardProgress);if escapeDistance>150 {escape=nil;escapeDistance=0}}
            } else {validPose=false;lastStatus="motion rejected; new chart unless relocalized";escape=nil;stuck=0;route=[]}
        }
        // Strict dual-image loop closure. Similar orange ground alone is not a place.
        let matches=state.nodes.compactMap { n -> (Node,Double)? in
            let d=difference(scene,n.scene),m=difference(minimap,n.minimap)
            guard d<5,m<7 else{return nil};return(n,d+m)
        }.sorted{$0.1<$1.1}
        if let match=matches.first,(matches.count==1 || matches[1].1-match.1>3),
           !validPose || (match.0.chart==chart && distance(position,match.0.position)<120) {
            chart=match.0.chart;position=match.0.position;node=match.0.id;validPose=true
            lastStatus="scene + minimap relocalized"
        }
        // A near keyframe need not be pixel-identical: verify displacement from
        // its saved image, rather than snapping to a vaguely similar thumbnail.
        if !validPose || observations%15==0 {
            let candidates=state.nodes.filter{n in
                (!validPose || n.chart==chart) && n.evidence.contains("/frame-") &&
                difference(scene,n.scene)<20 && difference(minimap,n.minimap)<18
            }.sorted{difference(scene,$0.scene)<difference(scene,$1.scene)}.prefix(2)
            for candidate in candidates {
                guard let keyframe=evidenceImage(candidate.evidence) else{continue}
                let motion=odometry.measure(previous:keyframe,current:image)
                guard motion.valid,motion.consensus>=15,motion.residual<3.5,
                      hypot(motion.dx,motion.dy)<100 else{continue}
                let corrected=Point(x:candidate.position.x-motion.dx,y:candidate.position.y-motion.dy)
                if validPose && distance(position,corrected)>120 {continue}
                chart=candidate.chart;position=corrected;node=candidate.id;validPose=true
                lastStatus="keyframe + minimap + verified motion relocalized";break
            }
        }
        if !validPose {
            chart=(state.charts.map{$0.id}.max() ?? -1)+1;state.charts.append(.init(id:chart!,enemies:[]))
            position = .init(x:0,y:0);node=nil;validPose=true;lastStatus="new independent chart"
        }
        let nearest=state.nodes.filter{$0.chart==chart}.min{distance($0.position,position)<distance($1.position,position)}
        let oldNode=node
        if let nearest,distance(nearest.position,position)<45 {node=nearest.id}
        else {
            let id=(state.nodes.map{$0.id}.max() ?? -1)+1
            state.nodes.append(.init(id:id,chart:chart!,position:position,scene:scene,minimap:minimap,visits:0,blocked:[:],evidence:evidence));node=id
        }
        if let node,let i=state.nodes.firstIndex(where:{$0.id==node}) {
            state.nodes[i].visits+=1
            if let orangeCoverage {state.nodes[i].orangeCoverage=orangeCoverage}
            if let anchorPose {state.nodes[i].anchorPose=anchorPose}
        }
        if let oldNode,let node,oldNode != node,lastMotion?.valid==true,moved>8,
           state.nodes.first(where:{$0.id==oldNode})?.chart==chart {
            if let i=state.edges.firstIndex(where:{$0.from==oldNode && $0.to==node}) {state.edges[i].traversals+=1}
            else{state.edges.append(.init(from:oldNode,to:node,traversals:1,evidence:evidence))}
        }
        state.checkpoint = .init(chart:chart!,position:position,scene:scene,minimap:minimap,evidence:evidence)
        return snapshot()
    }
    func recordEnemy(screenX:Double,screenY:Double,width:Double,height:Double,hp:Int,evidence:String) {
        guard validPose,let chart,let i=state.charts.firstIndex(where:{$0.id==chart}),hp>=100 else{return}
        let p=Point(x:position.x+screenX-width*0.5,y:position.y+screenY-height*0.53)
        if let j=state.charts[i].enemies.firstIndex(where:{distance($0.position,p)<90 && abs($0.maximumObservedHP-hp)<max(150,hp/5)}) {
            state.charts[i].enemies[j].lastSeen=Date();state.charts[i].enemies[j].observations+=1
            state.charts[i].enemies[j].maximumObservedHP=max(hp,state.charts[i].enemies[j].maximumObservedHP)
        } else {state.charts[i].enemies.append(.init(position:p,maximumObservedHP:hp,lastSeen:Date(),observations:1,evidence:evidence))}
    }
    func recordExecuted(x:Double,y:Double,duration:Double,learnObstacle:Bool) {
        executed = .init(x:x,y:y,duration:duration,learnObstacle:learnObstacle)
    }
    /// Directed edges only: drops/ledges are not assumed reversible.
    static func shortestRoute(_ state:State,from:Int,to:Int)->[Int]? {
        shortestRoute(state,from:from,goals:[to])
    }
    private static func shortestRoute(_ state:State,from:Int,goals:Set<Int>)->[Int]? {
        var queue:[(Int,[Int],Double)]=[(from,[],0)],best:[Int:Double]=[from:0]
        let lookup=Dictionary(uniqueKeysWithValues:state.nodes.map{($0.id,$0)})
        while !queue.isEmpty {
            queue.sort{$0.2<$1.2};let (at,path,cost)=queue.removeFirst()
            if goals.contains(at) {return path}
            guard let origin=lookup[at] else{continue}
            for edge in state.edges where edge.from==at {
                guard let next=lookup[edge.to],next.chart==origin.chart else{continue}
                let dx=next.position.x-origin.position.x,dy=next.position.y-origin.position.y
                let sector=(Int((atan2(dy,dx)/(Double.pi/4)).rounded())+8)%8
                guard origin.blocked[sector,default:0]<2 else{continue}
                let newCost=cost+hypot(dx,dy)+Double(next.visits)*0.2
                if newCost<best[next.id,default:.infinity] {
                    best[next.id]=newCost;queue.append((next.id,path+[next.id],newCost))
                }
            }
        }
        return nil
    }
    private func mappedEnemyRoute(from node:Int)->[Int]? {
        guard let chart,let index=state.charts.firstIndex(where:{$0.id==chart}) else{return nil}
        let now=Date()
        let candidates=state.charts[index].enemies.enumerated().filter {
            $0.element.maximumObservedHP<=5_000 && $0.element.observations>=2 &&
            ($0.element.reconsiderAfter ?? .distantPast)<now &&
            now.timeIntervalSince($0.element.lastSeen)<1800
        }.sorted{distance($0.element.position,position)<distance($1.element.position,position)}
        for (enemyIndex,enemy) in candidates {
            // Arrival without a visible target is not a kill. Defer re-checking
            // instead of endlessly circling an empty, cooling spawn location.
            if distance(enemy.position,position)<160 {
                state.charts[index].enemies[enemyIndex].reconsiderAfter=now.addingTimeInterval(120);continue
            }
            guard let goal=state.nodes.filter({$0.chart==chart && ($0.orangeCoverage ?? 0)>=0.55})
                .min(by:{distance($0.position,enemy.position)<distance($1.position,enemy.position)}),
                distance(goal.position,enemy.position)<140,
                let path=Self.shortestRoute(state,from:node,to:goal.id),!path.isEmpty else{continue}
            state.charts[index].enemies[enemyIndex].reconsiderAfter=now.addingTimeInterval(120)
            return path
        }
        return nil
    }
    /// Reuse a recorded return, never infer an edge from nearby orange pixels.
    static func routeToIsland2(_ state:State,from:Int)->[Int]? {
        guard let here=state.nodes.first(where:{$0.id==from}),
              let coverage=here.orangeCoverage,coverage<0.50 else{return nil}
        let goals=Set(state.nodes.filter{$0.chart==here.chart && ($0.orangeCoverage ?? 0)>0.72}.map{$0.id})
        guard !goals.isEmpty else{return nil}
        return shortestRoute(state,from:from,goals:goals)
    }
    /// Only general exploration enters here, never combat, recovery, UI or escape.
    func steer(x:Double,y:Double,duration:Double,allowGoalReplacement:Bool=true)->Steering? {
        guard validPose,lastMotion?.valid==true,let node,
              let here=state.nodes.first(where:{$0.id==node}) else{return nil}
        if let escape {return .init(x:escape.x,y:escape.y,duration:0.60,reason:"Saját helyi térkép: mért távolságú falmenti kerülő")}
        let desired=sector(x,y)
        // Aktív helyi farmcél mellett ez csak akadálykerülő, nem második célválasztó.
        if !allowGoalReplacement {route=[]}
        if stuck<2 && here.blocked[desired,default:0]<2 {
            if !allowGoalReplacement {return nil}
            if routeChart != chart {route=[];routeChart=chart}
            if route.isEmpty {
                if let returnPath=Self.routeToIsland2(state,from:node) {
                    route=returnPath;routePurpose="Island2-be vissza, már bejárt úton"
                } else {
                    route=mappedEnemyRoute(from:node) ?? []
                    routePurpose="a korábban látott Island2-ellenfélhez"
                }
            }
            while let first=route.first,let goal=state.nodes.first(where:{$0.id==first}),distance(goal.position,position)<45 {route.removeFirst()}
            if let first=route.first,let goal=state.nodes.first(where:{$0.id==first}) {
                let dx=goal.position.x-position.x,dy=goal.position.y-position.y,d=hypot(dx,dy)
                guard d<190 else{route=[];return nil}
                let hold=min(0.68,max(0.25,d/max(90,speed ?? 160)))
                return .init(x:dx/d,y:dy/d,duration:hold,reason:"Saját helyi térkép: igazolt éleken \(routePurpose)")
            }
            return nil
        }
        route=[]
        let norm=max(0.001,hypot(x,y)),ux=x/norm,uy=y/norm
        let directions=[1,-1,2,-2,3,-3,4].map {step -> Point in
            let angle=Double(step)*Double.pi/4
            return Point(x:ux*cos(angle)-uy*sin(angle),y:ux*sin(angle)+uy*cos(angle))
        }
        let best=directions.min {a,b in
            func score(_ p:Point)->Double {
                let target=Point(x:position.x+p.x*100,y:position.y+p.y*100)
                let visited=state.nodes.filter{$0.chart==chart && distance($0.position,target)<65}.map{$0.visits}.reduce(0,+)
                return Double(here.blocked[sector(p.x,p.y),default:0]*100+visited)
            }
            return score(a)<score(b)
        }!
        escape=best;escapeDistance=0;stuck=0
        return .init(x:best.x,y:best.y,duration:0.60,reason:"Saját helyi térkép: két igazolt mozdulatlan input; kevésbé bejárt oldalkerülő")
    }
    func snapshot()->Snapshot {.init(chart:chart,position:position,node:node,motion:lastMotion,status:lastStatus,speed:speed,nodes:state.nodes.count,edges:state.edges.count)}
}
