import Foundation
@main struct Tests {
 static func main() {
  func run(speed:Double,narrowGate:Bool=false)->Int {
   let nav=NavigationV2(path:"/nonexistent-navigation-test-state",readOnly:true)
   var p=NavigationV2.Point(x:0,y:0)
   let goal=NavigationV2.Point(x:30,y:0)
   nav.observe(anchor:p,motion:nil,evidence:"start")
   for step in 0..<200 {
    if hypot(goal.x-p.x,goal.y-p.y)<5 {return step}
    guard let c=nav.decide(targetOffset:.init(x:goal.x-p.x,y:goal.y-p.y)) else{fatalError("lost goal")}
    nav.recordExecuted(c)
    let next=NavigationV2.Point(x:p.x+c.x*c.duration*speed,y:p.y+c.y*c.duration*speed)
    let blocked=(1...20).contains { i in
        let t=Double(i)/20,x=p.x+(next.x-p.x)*t,y=p.y+(next.y-p.y)*t
        return x>=10 && x<=18 && (narrowGate ? abs(y+10)>3 : abs(y)<30)
    }
    if !blocked {p=next}
    nav.observe(anchor:p,motion:nil,evidence:"sim/\(step)")
   }
   fatalError("failed wall escape at \(p); \(nav.snapshot())")
  }
  let normal=run(speed:5),boost=run(speed:10)
  let sidePath=FileManager.default.temporaryDirectory.appendingPathComponent("butcher-side-test-\(UUID().uuidString).json").path
  defer{try? FileManager.default.removeItem(atPath:sidePath)}
  let sided=NavigationV2(path:sidePath)
  sided.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"start",scene:[1,2,3])
  _ = sided.decide(targetOffset:.init(x:20,y:-30))
  for _ in 0..<2 {
    sided.recordExecuted(.init(x:0,y:-1,duration:0.5,reason:"north collision"))
    sided.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"wall north",scene:[1,2,3])
  }
  let east=sided.decide(targetOffset:.init(x:20,y:-30))!
  precondition(east.x>0.9 && abs(east.y)<0.1,"NE goal at north wall should contour east, not always west")
  let sideRestart=NavigationV2(path:sidePath,readOnly:true)
  sideRestart.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"restart",scene:[1,2,3])
  for _ in 0..<2 {
    let c=sideRestart.decide(targetOffset:.init(x:20,y:-30))!
    sideRestart.recordExecuted(c)
    sideRestart.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"east also blocked",scene:[1,2,3])
  }
  let clockwise=sideRestart.decide(targetOffset:.init(x:20,y:-30))!
  precondition(clockwise.x>0 && clockwise.y>0,"right contour must keep clockwise rotation after restart")
  _ = sided.decide(targetOffset:.init(x:10,y:20),preferCurrentTarget:true)
  precondition(!sided.snapshot().mode.contains("wall"),"visible target on this side clears stale obstacle commitment")
  let knownBlocked=NavigationV2(path:"/nonexistent-navigation-test-state",readOnly:true)
  knownBlocked.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"start")
  _ = knownBlocked.decide(targetOffset:.init(x:20,y:-30))
  for _ in 0..<2 {
    knownBlocked.recordExecuted(.init(x:1,y:0,duration:0.5,reason:"east collision"))
    knownBlocked.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"known east wall")
  }
  knownBlocked.handoffMovement()
  _ = knownBlocked.decide(targetOffset:.init(x:20,y:-30))
  for _ in 0..<2 {
    knownBlocked.recordExecuted(.init(x:0,y:-1,duration:0.5,reason:"north collision"))
    knownBlocked.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"north wall")
  }
  precondition(knownBlocked.decide(targetOffset:.init(x:20,y:-30))!.x < -0.9,
    "known blocked east side must outweigh the NE goal preference")
  let gate=run(speed:5,narrowGate:true)
  precondition(gate<65,"must find narrow gate, not blindly walk past")
  let nav=NavigationV2(path:"/nonexistent-navigation-test-state",readOnly:true)
  for _ in 0..<20 {nav.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"no input")}
  precondition(nav.snapshot().blockedEdges==0,"no input must not learn walls")
  let path=FileManager.default.temporaryDirectory.appendingPathComponent("butcher-nav-test-\(UUID().uuidString).json").path
  defer{try? FileManager.default.removeItem(atPath:path)}
  let saved=NavigationV2(path:path)
  saved.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"test",scene:[1,2,3])
  for _ in 0..<2 {
   let c=saved.decide(targetOffset:.init(x:30,y:0))!
   saved.recordExecuted(c)
   saved.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"collision",scene:[1,2,3])
  }
  let restored=NavigationV2(path:path,readOnly:true)
  restored.observe(anchor:.init(x:0,y:0),motion:nil,evidence:"restart",scene:[1,2,3])
  let continuation=restored.decide(targetOffset:.init(x:30,y:0))!
  precondition(continuation.reason.contains("wall-follow"),"dual-match restart must retain obstacle commitment")
  let beforeProbe=restored.snapshot()
  let probe=restored.observationProbe()
  precondition(probe.y < -0.9 && abs(probe.x)<0.1 && probe.duration<=0.5,
    "HP observation must follow committed wall side, not push east into known wall")
  restored.finishObservationProbe()
  restored.observe(anchor:.init(x:0,y:-2),motion:nil,evidence:"sensor clearing",scene:[1,2,3])
  precondition(restored.snapshot().goal==beforeProbe.goal &&
    restored.snapshot().blockedEdges==beforeProbe.blockedEdges,
    "sensor clearing must preserve goal and not learn obstacles")
  precondition(restored.decide(targetOffset:.init(x:30,y:2))!.reason.contains("wall-follow"),
    "sensor clearing must not erase the wall-follow commitment")
  let portal=NavigationV2(readOnly:true)
  portal.observe(anchor:.init(x:25,y:1),motion:nil,evidence:"known-house-side")
  let approach=portal.decide(targetOffset:.init(x:40,y:-5))!
  precondition(approach.reason.contains("bizonyított átjáró") && approach.y>0.5,"known boundary must route south to gate before east target")
  portal.handoffMovement()
  precondition(portal.snapshot().goal==nil && portal.snapshot().wallTravel==0,"combat movement must clear stale navigation commitment")
  let tower=NavigationV2(readOnly:true)
  tower.observe(anchor:nil,motion:nil,evidence:"verified tower east side",
    terrain:.init(chart:51,x:1025.73,y:820.46))
  let viaPath=tower.decide(targetOffset:.init(x:-24,y:-32))!
  precondition(viaPath.reason.contains("bizonyított átjáró") && viaPath.x>0.5 && viaPath.y<0,
    "northwest target must first approach eastern path, not hit western cliff")
  let otherChart=NavigationV2(readOnly:true)
  let tent=NavigationV2(readOnly:true)
  let dusty=NavigationV2(readOnly:true)
  dusty.observe(anchor:nil,motion:nil,evidence:"269 house pocket",terrain:.init(chart:62,x:-1122.551221,y:-90.253210))
  let south=dusty.decide(targetOffset:.init(x:-12.7,y:12.7))!
  precondition(south.reason.contains("bizonyított átjáró") && south.y>0.99,"cyan guard west of cliff must first take measured south bypass")
  let dustyBoss=NavigationV2(readOnly:true)
  dustyBoss.observe(anchor:nil,motion:nil,evidence:"same pocket, different boss goal",terrain:.init(chart:62,x:-1122.551221,y:-90.253210))
  precondition(!dustyBoss.decide(targetOffset:.init(x:-14.6,y:0))!.reason.contains("bizonyított átjáró"),"weapon corridor is not a fresh boss-trial instruction")
  tent.observe(anchor:nil,motion:nil,evidence:"measured tent pocket",terrain:.init(chart:63,x:-169.02623,y:-47.693488))
  let tentExit=tent.decide(targetOffset:.init(x:-18,y:2))!
  precondition(tentExit.reason.contains("bizonyított átjáró") && tentExit.x>0.9,
    "west golem beyond tent must first use verified east exit")
  precondition(!tent.decide(targetOffset:.init(x:18,y:0),preferCurrentTarget:true)!.reason.contains("bizonyított átjáró"),
    "new visible east target cancels the west-goal-only portal")
  let tentEast=NavigationV2(readOnly:true)
  tentEast.observe(anchor:nil,motion:nil,evidence:"tent pocket east goal",terrain:.init(chart:63,x:-169.02623,y:-47.693488))
  precondition(!tentEast.decide(targetOffset:.init(x:18,y:0))!.reason.contains("bizonyított átjáró"),
    "tent corridor cannot override an unrelated eastward goal")
  let tent47=NavigationV2(readOnly:true)
  tent47.observe(anchor:nil,motion:nil,evidence:"same surveyed place via endpoint bridge",terrain:.init(chart:47,x:-83.85541958,y:-1077.8080184))
  precondition(tent47.decide(targetOffset:.init(x:-18,y:2))!.x>0.9,"endpoint-calibrated chart uses same physical exit")
  otherChart.observe(anchor:nil,motion:nil,evidence:"same coordinates wrong chart",
    terrain:.init(chart:52,x:1025.73,y:820.46))
  precondition(!otherChart.decide(targetOffset:.init(x:-24,y:-32))!.reason.contains("bizonyított átjáró"),
    "corridor must never leak into another chart")
  for _ in 0..<2 {
    let c=tower.decide(targetOffset:.init(x:-24,y:-32))!
    tower.recordExecuted(c)
    tower.observe(anchor:nil,motion:.init(x:0,y:0),evidence:"live portal failure",
      terrain:.init(chart:51,x:1025.73,y:820.46))
  }
  precondition(!tower.decide(targetOffset:.init(x:-24,y:-32))!.reason.contains("bizonyított átjáró"),
    "two failed portal moves must suspend that evidence-backed route")
  let local=NavigationV2(path:"/nonexistent-navigation-test-state",readOnly:true)
  precondition(local.decide(targetOffset:nil)==nil,"no localization means no frontier input")
  local.observe(anchor:nil,motion:.init(x:0,y:0),evidence:"independent chart")
  precondition(local.snapshot().space.hasPrefix("local-"))
  precondition(local.decide(targetOffset:nil)?.reason.contains("frontier-astar")==true,
    "known local position with no red targets must explore a short frontier")
  let frontierGoal=local.snapshot().goal
  for _ in 0..<20 {_ = local.decide(targetOffset:nil)}
  precondition(local.snapshot().goal==frontierGoal,"frontier commitment must not expire like a vanished enemy")
  precondition(local.decide(targetOffset:.init(x:20,y:5)) != nil,"green island can use independent measured chart")
  precondition(local.snapshot().goal == .init(x:20,y:5),"fresh enemy replaces exploration immediately")
  local.observe(anchor:.init(x:40,y:10),motion:nil,evidence:"known anchor recovered")
  precondition(local.snapshot().space=="orange-skull" && local.snapshot().goal==nil,"never mix local and landmark coordinates")
  _ = local.decide(targetOffset:.init(x:-20,y:5))
  _ = local.decide(targetOffset:.init(x:7,y:3),preferCurrentTarget:true)
  precondition(local.snapshot().goal == .init(x:47,y:13),"visible safe target must replace stale minimap goal immediately")
  let atlasPath=FileManager.default.temporaryDirectory.appendingPathComponent("butcher-atlas-test-\(UUID().uuidString).json").path
  defer{try? FileManager.default.removeItem(atPath:atlasPath)}
  let atlas=NavigationV2(path:atlasPath)
  let pose=NavigationV2.TerrainPose(chart:51,x:1000,y:800)
  atlas.observe(anchor:.init(x:-40,y:12),motion:nil,evidence:"verified image pose plus ambiguous icon",scene:[1,2,3],terrain:pose)
  precondition(atlas.snapshot().space=="terrain-chart-51" && atlas.snapshot().position == .init(x:45,y:36))
  for _ in 0..<2 {
    let c=atlas.decide(targetOffset:.init(x:30,y:0))!
    atlas.recordExecuted(c)
    atlas.observe(anchor:nil,motion:.init(x:0,y:0),evidence:"measured collision",scene:[1,2,3],terrain:pose)
  }
  let atlasRestart=NavigationV2(path:atlasPath,readOnly:true)
  atlasRestart.observe(anchor:.init(x:80,y:-10),motion:nil,evidence:"dual-verified relocalization plus other identical icon",scene:[1,2,3],terrain:pose)
  precondition(atlasRestart.decide(targetOffset:.init(x:30,y:0))!.reason.contains("wall-follow"),
    "same verified terrain chart must restore wall commitment across processes")
  precondition(atlasRestart.snapshot().blockedEdges==atlas.snapshot().blockedEdges)
  let shiftedAtlasRestart=NavigationV2(path:atlasPath,readOnly:true)
  shiftedAtlasRestart.observe(anchor:.init(x:-90,y:80),motion:nil,evidence:"last swipe image-verified upstream",scene:[80,90,70],
    terrain:.init(chart:51,x:1080,y:800))
  precondition(shiftedAtlasRestart.decide(targetOffset:.init(x:30,y:0))!.reason.contains("wall-follow"),
    "verified same-chart displacement after the final swipe must preserve the obstacle side")
  atlasRestart.observe(anchor:.init(x:2,y:3),motion:nil,evidence:"intermittent skull returns",scene:[1,2,3],terrain:pose)
  precondition(atlasRestart.snapshot().space=="terrain-chart-51",
    "returning optional landmark must not churn an active verified atlas")
  atlasRestart.observe(anchor:.init(x:2,y:3),motion:nil,evidence:"new independent place with identical icon offset",scene:[1,2,3],
    terrain:.init(chart:52,x:1000,y:800))
  precondition(atlasRestart.snapshot().goal==nil && atlasRestart.snapshot().space=="terrain-chart-52",
    "different chart must never inherit route even at identical coordinates")
  let camp=NavigationV2(readOnly:true)
  camp.observe(anchor:nil,motion:nil,evidence:"212136/0",terrain:.init(chart:36,x:-7.062520911972081/0.045,y:-48.068553531959076/0.045))
  let campEntry=camp.decide(targetOffset:.init(x:17,y:-7))!
  precondition(campEntry.reason.contains("bizonyított átjáró") && campEntry.y < -0.95,
    "camp guard across west fence must first use measured north passage, not east wall")
  let unrelated=NavigationV2(readOnly:true)
  unrelated.observe(anchor:nil,motion:nil,evidence:"same start, western objective",terrain:.init(chart:36,x:-7.062520911972081/0.045,y:-48.068553531959076/0.045))
  precondition(!unrelated.decide(targetOffset:.init(x:-18,y:0))!.reason.contains("bizonyított átjáró"),
    "camp passage must not hijack an Island2 objective west of this fence")
  print("PASS: thick wall normal \(normal), boosted \(boost), narrow gate \(gate) inputs; no-input and restart invariants; chart36 camp passage")
 }
}
