import Foundation
enum KnownHeartGuardianPolicy {
    static func matches(hp:Int?,heart:Double,rewardNumbers:[Int],structure:Double)->Bool {
        guard let hp,(4200...4400).contains(hp),heart>=0.06,structure<0.06 else{return false}
        return rewardNumbers.contains(500) || rewardNumbers.contains(501)
    }
}
