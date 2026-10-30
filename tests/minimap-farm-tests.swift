import Foundation
@main struct Tests {
 static func main() {
  let t=MinimapFarmTracker()
  let a=t.select([.init(x:20,y:10),.init(x:-30,y:0)])!
  precondition(a.x==20)
  let b=t.select([.init(x:16,y:9),.init(x:-10,y:0)])!
  precondition(b.x==16,"retain selected target instead of nearest-point oscillation")
  precondition(t.select([])==nil)
  precondition(t.select([.init(x:70,y:0),.init(x:2,y:0)])==nil)
  let gate=t.gatewayDirection(pose:.init(anchor:"dusty-gulch-orange-skull",x:26.5,y:36.5,error:0,landmarkX:0,landmarkY:0),toward:.init(x:1,y:0),orangeCoverage:0.75)!
  precondition(gate.y < -0.9,"cliff-separated eastern target needs northern gate")
  print("PASS: local red target continuity, loss and range bounds")
 }
}
