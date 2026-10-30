import Foundation
@main struct QuarantineTests {
    static func main() {
        func p(_ x:Double,_ y:Double,_ anchor:String="dusty-gulch-venom-guard")->MinimapPose {
            .init(anchor:anchor,x:x,y:y,error:0,landmarkX:0,landmarkY:0)
        }
        let q=MinimapTargetQuarantine()
        let south=q.steer(pose:p(-50,-39),x:-0.75,y:-0.66)!
        precondition(south.y>0.9 && south.x>0)
        let east=q.steer(pose:p(-44.5,-14.5),x:-0.75,y:-0.66)!
        precondition(east.x==1 && east.y==0)
        precondition(q.steer(pose:p(-39,-15),x:-0.75,y:-0.66)!.x==1,"never pull back to an already reached frontier")
        precondition(MinimapTargetQuarantine().steer(pose:p(-39,-15),x:-0.75,y:-0.66)!.x==1,"infer passed frontier after restart")
        precondition(q.steer(pose:p(0,0),x:-0.75,y:-0.66)==nil)
        precondition(q.steer(pose:p(-50,-39),x:1,y:0)==nil)
        let equivalent=MinimapTargetQuarantine().steer(pose:p(-45.5,26.5,"dusty-gulch-orange-skull"),x:-0.75,y:-0.66)!
        precondition(abs(equivalent.y-south.y)<0.001)
        let house=MinimapTargetQuarantine().steer(pose:p(17,-62.5),x:-0.75,y:-0.66)!
        precondition(house.x>0.6 && house.y>0.6)
        print("PASS: spatial failed-goal quarantine, measured southern frontier, house exit and anchor equivalence")
    }
}
