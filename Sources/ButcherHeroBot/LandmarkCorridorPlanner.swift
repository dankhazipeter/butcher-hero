import Foundation

/// Measured corridor in minimap coordinates; no fixed swipe counts.
final class LandmarkCorridorPlanner {
    struct Area:Decodable {let minX:Double;let maxX:Double;let minY:Double;let maxY:Double}
    struct Point:Decodable {let x:Double;let y:Double;let evidence:String}
    struct Plan:Decodable {let id:String;let anchor:String;let entry:Area;let waypoints:[Point]}
    struct Direction {let x:Double;let y:Double;let reason:String}
    private let plan:Plan?
    private var step:Int?
    private var started:Date?
    private var cooldownUntil=Date.distantPast
    init(path:String="docs/landmark-corridors.json") {
        plan=(try? Data(contentsOf:URL(fileURLWithPath:path))).flatMap{try? JSONDecoder().decode(Plan.self,from:$0)}
    }
    func direction(_ pose:MinimapPose,now:Date=Date())->Direction? {
        guard let plan,plan.anchor=="dusty-gulch-venom-guard",!plan.waypoints.isEmpty else{return nil}
        let x:Double,y:Double
        switch pose.anchor {
        case "dusty-gulch-venom-guard":x=pose.x;y=pose.y
        case "dusty-gulch-orange-skull":x=pose.x-4.5;y=pose.y-65.5
        default:return nil
        }
        if let started,now.timeIntervalSince(started)>180 {
            step=nil;self.started=nil;cooldownUntil=now.addingTimeInterval(180);return nil
        }
        if step==nil {
            let a=plan.entry
            guard now>=cooldownUntil,x>=a.minX,x<=a.maxX,y>=a.minY,y<=a.maxY else{return nil}
            step=0;started=now
        }
        while let current=step,current<plan.waypoints.count {
            let point=plan.waypoints[current],dx=point.x-x,dy=point.y-y,d=hypot(dx,dy)
            guard d<80 else {step=nil;started=nil;return nil}
            if d<3.5 {step=current+1;continue}
            return .init(x:dx/d,y:dy/d,reason:"Térképi farmcél: \(plan.id) mért köztes pontja \(current+1)/\(plan.waypoints.count); friss minimaphelyzet")
        }
        step=nil;started=nil;cooldownUntil=now.addingTimeInterval(180)
        return nil
    }
}
