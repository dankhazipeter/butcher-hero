import Foundation
@main struct CorridorTests {
    static func main() {
        func pose(_ x:Double,_ y:Double)->MinimapPose {.init(anchor:"dusty-gulch-venom-guard",x:x,y:y,error:0,landmarkX:0,landmarkY:0)}
        let planner=LandmarkCorridorPlanner(),now=Date()
        precondition(planner.direction(pose(-50,0),now:now)==nil,"outside entry region must not start a macro")
        precondition(planner.direction(pose(-25,-30),now:now)!.y<0,"go north out of DOC, not south through wall")
        let west=planner.direction(pose(-25,-44.5),now:now)!
        precondition(west.x < -0.9)
        let south=planner.direction(pose(-44,-45),now:now)!
        precondition(south.y>0.9)
        precondition(planner.direction(pose(-44.5,-14.5),now:now)==nil,"measured exit permits direct farm bearing again")
        precondition(planner.direction(pose(-25,-30),now:now)==nil,"no immediate repeated corridor")
        let samePlace=LandmarkCorridorPlanner()
        let otherAnchor=MinimapPose(anchor:"dusty-gulch-orange-skull",x:-20.5,y:35.5,error:0,landmarkX:0,landmarkY:0)
        precondition(samePlace.direction(otherAnchor,now:now)!.y<0)
        precondition(samePlace.direction(otherAnchor,now:now.addingTimeInterval(181))==nil,"bounded attempt")
        print("PASS: measured DOC corridor, equivalent anchors, no blind steps, timeout and no immediate repeat")
        let western=LandmarkCorridorPlanner(path:"docs/west-courtyard-exit.json")
        precondition(western.direction(pose(-64,-64),now:now)!.y>0.9)
        let southeast=western.direction(pose(-64.5,-50.5),now:now)!
        precondition(southeast.x>0 && southeast.y>0)
        precondition(western.direction(pose(-50,-39),now:now)==nil)
        print("PASS: western dead-end exits south then southeast to the measured open courtyard")
    }
}
