import Foundation
@main struct KitingTests {
    static func main() {
        let t=Date(timeIntervalSince1970:1000)
        func e(_ hp:Int,_ distance:Double)->BossKitingTrial.Enemy {.init(hp:hp,x:0,y:-distance,distance:distance)}
        let bot=BossKitingTrial()
        precondition(bot.next(hp:1,fresh:false,enemies:[e(18800,200)],dead:false,now:t)==nil)
        guard case .move?=bot.next(hp:1,fresh:true,enemies:[e(18800,200)],dead:false,now:t) else{fatalError("start with fresh full HP")}
        guard case .move(let retreat)?=bot.next(hp:0.76,fresh:true,enemies:[e(17100,120)],dead:false,now:t.addingTimeInterval(1)) else{fatalError("retreat after hit")}
        precondition(retreat.y>0 && retreat.reason.contains("távolodás"))
        _=bot.next(hp:0.80,fresh:true,enemies:[e(17100,300)],dead:false,now:t.addingTimeInterval(3))
        guard case .wait(let reset)?=bot.next(hp:0.85,fresh:true,enemies:[e(18800,300)],dead:false,now:t.addingTimeInterval(4)) else{fatalError("reset must end experiment")}
        precondition(reset.contains("visszaállt") && bot.finished)
        precondition(bot.next(hp:1,fresh:true,enemies:[e(18800,100)],dead:false,now:t.addingTimeInterval(5))==nil)
        let wrong=BossKitingTrial()
        _=wrong.next(hp:1,fresh:true,enemies:[e(27700,200)],dead:false,now:t)
        precondition(wrong.finished)
        let death=BossKitingTrial()
        _=death.next(hp:1,fresh:true,enemies:[e(18800,100)],dead:false,now:t)
        _=death.next(hp:0,fresh:true,enemies:[],dead:true,now:t.addingTimeInterval(2))
        precondition(death.finished)
        let obscured=BossKitingTrial()
        _=obscured.next(hp:1,fresh:true,enemies:[e(18800,180)],dead:false,now:t)
        guard case .move(let uncertainRetreat)?=obscured.next(hp:0.39,fresh:false,enemies:[e(17400,100)],dead:false,now:t.addingTimeInterval(1)) else{fatalError("obscured HP must immediately retreat")}
        precondition(uncertainRetreat.y>0)
        guard case .move(let missing)?=obscured.next(hp:0.46,fresh:false,enemies:[],dead:false,now:t.addingTimeInterval(3)) else{fatalError("missing target is not safe recovery clearance")}
        precondition(missing.y>0 && missing.reason.contains("távolodás"))
        guard case .move(let chasing)?=obscured.next(hp:0.32,fresh:true,enemies:[.init(hp:16000,x:100,y:0,distance:100)],dead:false,now:t.addingTimeInterval(4)) else{fatalError("critical escape must move")}
        precondition(abs(chasing.x)<0.001 && chasing.y>0,"escape must retain observed approach reversal, not turn with pursuer")
        precondition(obscured.initialHP==18800)
        obscured.cancel()
        precondition(obscured.initialHP==18800,"death/cancel must retain initial identity for failure recording")
        precondition(obscured.next(hp:1,fresh:true,enemies:[e(18800,100)],dead:false,now:t.addingTimeInterval(2))==nil)
        print("PASS: fresh-HP start, early retreat, boss-reset abort, no repeat, wrong-boss rejection, death")
    }
}
