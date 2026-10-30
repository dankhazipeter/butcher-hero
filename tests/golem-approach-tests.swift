import Foundation
@main struct Tests {
    static func main() {
        let east=GolemApproachPolicy.offset(x:21,y:3)!
        precondition(east.x>17 && east.y>0 && abs(hypot(east.x,east.y)-18)<0.001)
        let west=GolemApproachPolicy.offset(x:-65,y:5)!
        precondition(west.x < -17 && west.y>0)
        precondition(GolemApproachPolicy.offset(x:3,y:4)==nil)
        precondition(GolemApproachPolicy.offset(x:.nan,y:4)==nil)
        precondition(GolemApproachPolicy.offset(x:4,y:.infinity)==nil)
        print("PASS: orange-head relative approach east/west, bounded horizon, contact and invalid offset excluded")
    }
}
