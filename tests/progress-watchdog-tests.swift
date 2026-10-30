import Foundation
@main struct WatchdogTests {
    static func main() {
        let stalled=ProgressWatchdog()
        _=stalled.observe(chart:1,x:0,y:0,eligible:true)
        for i in 1...12 {
            stalled.recordMovement()
            let result=stalled.observe(chart:1,x:Double(i)*4,y:0,eligible:true)
            precondition((result != nil)==(i==12))
        }
        let moving=ProgressWatchdog()
        _=moving.observe(chart:1,x:0,y:0,eligible:true)
        for i in 1...24 {
            moving.recordMovement()
            precondition(moving.observe(chart:1,x:Double(i)*60,y:0,eligible:true)==nil)
        }
        let idle=ProgressWatchdog()
        for _ in 1...25 {precondition(idle.observe(chart:1,x:0,y:0,eligible:true)==nil)}
        _=stalled.observe(chart:1,x:0,y:0,eligible:false)
        stalled.recordMovement()
        precondition(stalled.observe(chart:2,x:0,y:0,eligible:true)==nil)
        print("PASS: unproductive movement escalates; real progress, skipped input and UI/chart changes do not")
        let relocalizing=ProgressWatchdog()
        _=relocalizing.observe(chart:1,x:0,y:0,eligible:true,landmark:(0,0))
        for i in 1...12 {
            relocalizing.recordMovement()
            let stopped=relocalizing.observe(chart:i,x:Double(i)*90,y:0,eligible:true,landmark:(Double(i%3),0))
            precondition((stopped != nil)==(i==12),"relocalization must not erase a minimap-confirmed loop")
        }
        print("PASS: minimap loop survives local chart changes")
    }
}
