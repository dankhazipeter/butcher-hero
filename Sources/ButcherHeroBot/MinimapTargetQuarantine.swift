import Foundation

/// Spatially scoped supervisor evidence, not a global ban on a compass direction.
final class MinimapTargetQuarantine {
    struct Rule:Decodable {
        let id:String
        let minX:Double;let maxX:Double;let minY:Double;let maxY:Double
        let blockedX:Double;let blockedY:Double
        let frontierX:Double;let frontierY:Double
        let evidence:String
    }
    struct Direction {let x:Double;let y:Double;let reason:String}
    private let rules:[Rule]
    private var reachedFrontiers=Set<String>()
    init(path:String="docs/minimap-target-quarantine.json") {
        rules=(try? Data(contentsOf:URL(fileURLWithPath:path)))
            .flatMap{try? JSONDecoder().decode([Rule].self,from:$0)} ?? []
    }
    func steer(pose:MinimapPose,x:Double,y:Double)->Direction? {
        let px:Double,py:Double
        switch pose.anchor {
        case "dusty-gulch-venom-guard":px=pose.x;py=pose.y
        case "dusty-gulch-orange-skull":px=pose.x-4.5;py=pose.y-65.5
        default:return nil
        }
        for rule in rules {
            guard px>=rule.minX,px<=rule.maxX,py>=rule.minY,py<=rule.maxY else{continue}
            let norm=hypot(x,y)*hypot(rule.blockedX,rule.blockedY)
            guard norm>0,(x*rule.blockedX+y*rule.blockedY)/norm>0.65 else{continue}
            let dx=rule.frontierX-px,dy=rule.frontierY-py,d=hypot(dx,dy)
            if d<=4 || (px>=rule.frontierX && py>=rule.frontierY-4) {
                reachedFrontiers.insert(rule.id)
            }
            let explore=reachedFrontiers.contains(rule.id)
            // At the measured open frontier, explore east instead of re-entering NW.
            return .init(x:explore ? 1:dx/d,y:explore ? 0:dy/d,
                reason:"Térképi farmcél: helyhez kötött célkarantén (\(rule.id)); nyílt déli pont, majd keleti felderítés")
        }
        return nil
    }
}
