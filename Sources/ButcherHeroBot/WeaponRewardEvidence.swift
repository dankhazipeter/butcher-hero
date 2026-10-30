import Foundation

enum WeaponRewardEvidence {
    static func endsGuardTrial(texts:[String],initialHP:Int?,lastDistance:Double?,
                               targetVisible:Bool,nearbyThreatCount:Int)->Bool {
        guard let initialHP,(1...5000).contains(initialHP),
              let lastDistance,lastDistance<=180,!targetVisible,nearbyThreatCount==0 else{return false}
        let level=texts.contains{$0.uppercased().contains("LEVEL UP")}
        let damage=texts.contains{$0.uppercased().contains("DAMAGE") && $0.filter(\.isNumber).count>=2}
        return level && damage
    }
}
