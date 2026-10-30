import Foundation

enum PassiveTreePolicy {
    static func verified(hp:Int?,rawHP:Int?,foliage:Double,axe:Double,heart:Double,
                         outline:Double,independentBoss:Bool)->Bool {
        guard let hp,let rawHP,!independentBoss else{return false}
        return (1...1600).contains(hp) && (1...1600).contains(rawHP) &&
            foliage>=0.45 && max(axe,heart)>=0.03 && outline>=0.12
    }
}
