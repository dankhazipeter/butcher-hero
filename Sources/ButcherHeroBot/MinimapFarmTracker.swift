import Foundation

/// Short-range visual identity continuity; no unverified global world coordinates.
final class MinimapFarmTracker {
    struct Point {let x:Double;let y:Double}
    private var previous:Point?
    func gatewayDirection(pose:MinimapPose?,toward:Point,orangeCoverage:Double)->Point? {
        guard let pose,pose.anchor=="dusty-gulch-orange-skull",orangeCoverage>0.40,
              toward.x>0.50 else{return nil}
        let x=pose.x-4.5,y=pose.y-65.5
        guard x>=5,x<=32,y>=(-80),y<=(-15) else{return nil}
        // Verified north-gate waypoint; east dots across the cliff need this portal.
        let dx=24-x,dy = -55-y,d=hypot(dx,dy)
        if d<=4 || (x>=24 && abs(y+55)<=5) {return .init(x:1,y:0)}
        return .init(x:dx/d,y:dy/d)
    }
    func select(_ points:[Point])->Point? {
        let candidates=points.filter{hypot($0.x,$0.y)>=8 && hypot($0.x,$0.y)<=65}
        guard !candidates.isEmpty else {previous=nil;return nil}
        if let old=previous,
           let same=candidates.min(by:{hypot($0.x-old.x,$0.y-old.y)<hypot($1.x-old.x,$1.y-old.y)}),
           hypot(same.x-old.x,same.y-old.y)<=12 {
            previous=same;return same
        }
        let nearest=candidates.min{hypot($0.x,$0.y)<hypot($1.x,$1.y)}!
        previous=nearest;return nearest
    }
}
