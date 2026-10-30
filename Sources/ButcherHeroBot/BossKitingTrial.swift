import Foundation

/// Single bounded tactical experiment, explicitly enabled by --kite-boss.
/// No HP-ratio prediction, no success inferred merely from disappearing bars.
final class BossKitingTrial {
    struct Enemy {let hp:Int;let x:Double;let y:Double;let distance:Double}
    struct Move {let x:Double;let y:Double;let duration:Double;let reason:String}
    enum Directive {case move(Move),wait(String)}
    private(set) var finished=false
    var initialHP:Int? {initial>0 ? initial:nil}
    private var began:Date?
    private var phase="approach"
    private var initial=0,lowest=Int.max
    private var awayX=0.0,awayY=1.0
    private var exitX=0.0,exitY=1.0
    private var contactSince:Date?
    private var lastEnemyAt:Date?
    private var recoverySince:Date?
    private var cycles=0
    private var freshHPFrames=0
    func cancel(){finished=true}

    func next(hp:Double?,fresh:Bool,enemies:[Enemy],dead:Bool,now:Date=Date())->Directive? {
        guard !finished else{return nil}
        func done(_ text:String)->Directive {finished=true;return .wait("Kitérős kísérlet vége: "+text)}
        if dead {return done("halál; nem ismétlem automatikusan")}
        if began==nil {
            if enemies.contains(where:{$0.hp>24_000 && $0.distance<300}) {
                return done("a látott cél nem a kijelölt18,8K-s ellenfél")
            }
            guard fresh,(hp ?? 0)>=0.95,
                  let enemy=enemies.filter({(17_500...20_000).contains($0.hp) && $0.distance<350}).min(by:{$0.distance<$1.distance}) else{return nil}
            began=now;initial=enemy.hp;lowest=enemy.hp;lastEnemyAt=now
            // Preserve the reverse of the observed approach. Chasing the
            // moving enemy's opposite bearing rotated the escape into a house.
            let d=max(0.001,hypot(enemy.x,enemy.y))
            exitX = -enemy.x/d;exitY = -enemy.y/d
        }
        guard let began else{return nil}
        if now.timeIntervalSince(began)>90 {return done("90s korlát; következő döntéshez képi értékelés kell")}
        let enemy=enemies.filter{$0.hp>=300 && $0.hp<=initial+400}.min{$0.distance<$1.distance}
        if let enemy {
            lastEnemyAt=now
            if enemy.hp<lowest {lowest=enemy.hp}
            let d=max(0.001,hypot(enemy.x,enemy.y));awayX = -enemy.x/d;awayY = -enemy.y/d
            if phase=="recover",Double(lowest)<Double(initial)*0.94,enemy.hp>=Int(Double(initial)*0.99) {
                return done("az ellenfélHP visszaállt a visszahúzódás alatt; így nem kumulálható a sebzés")
            }
        }
        if fresh {freshHPFrames=0}else{freshHPFrames+=1}
        // Missing numeric HP is not full health. A low pixel bar is enough to
        // retreat (but not to persist defeat), including the first obscured hit.
        if !fresh && ((hp ?? 1)<0.70 || freshHPFrames>=1) && phase=="approach" {
            phase="withdraw";recoverySince=now
        }
        if fresh,(hp ?? 1)<0.55 {phase="abort"}
        if phase=="abort" {
            if fresh,(hp ?? 0)>0.90{return done("kritikus sebzés után kijutottunk; az első roham túl veszteséges")}
            return .move(.init(x:exitX,y:exitY,duration:0.65,reason:"Kitérős próba: túl nagy saját sebzés; vissza a megközelítés irányán"))
        }
        if phase=="approach" {
            if fresh,(hp ?? 1)<0.82 {phase="withdraw";recoverySince=now}
            else if let enemy {
                if enemy.distance<155 {
                    if contactSince==nil {contactSince=now}
                    if now.timeIntervalSince(contactSince!)>1.4 {phase="withdraw";recoverySince=now}
                }
                if phase=="approach" {
                    return .move(.init(x:-awayX,y:-awayY,duration:enemy.distance>180 ? 0.35:0.18,
                        reason:"Kitérős próba: rövid támadókontaktus; boss\(initial)→\(lowest), ciklus\(cycles+1)"))
                }
            } else if now.timeIntervalSince(lastEnemyAt ?? began)>3 {phase="withdraw";recoverySince=now}
            else {return .wait("Kitérős próba: a közeli boss rövid takarását figyelem")}
        }
        if phase=="withdraw" {
            // A missing bar is not measured clearance: live203949/4 lost the
            // overlapping bar while the golem was still hitting the player.
            if let enemy,enemy.distance>260 && now.timeIntervalSince(recoverySince ?? now)>1 {
                phase="recover";recoverySince=now
            } else {
                return .move(.init(x:exitX,y:exitY,duration:0.52,reason:"Kitérős próba: távolodás a megközelítés visszirányán; megmarad-e a boss\(lowest)HP-ja?"))
            }
        }
        if phase=="recover" {
            if fresh,(hp ?? 0)>=0.96 {
                guard enemy != nil else {
                    if now.timeIntervalSince(recoverySince ?? now)>15{return done("felgyógyultunk, de a boss nincs képen; ez nem igazolt győzelem")}
                    return .wait("Kitérős próba: felgyógyultam; az ellenfélHP visszaellenőrzése kell")
                }
                cycles+=1
                if cycles>=3{return done("három sebzés–gyógyulás ciklus; legkisebb látottbossHP\(lowest)")}
                phase="approach";contactSince=nil;return .wait("Kitérős próba: újra teljesHP, következő rövid roham")
            }
            if let enemy,enemy.distance<200 {
                return .move(.init(x:exitX,y:exitY,duration:0.50,reason:"Kitérős próba: az ellenfél követ, a megközelítés visszirányán távolodom"))
            }
            return .wait("Kitérős próba: regeneráció, bosslegkisebbHP\(lowest); nem állítok győzelmet")
        }
        return .wait("Kitérős próba: állapotellenőrzés")
    }
}
