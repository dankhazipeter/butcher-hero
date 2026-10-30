import Foundation

enum CloseContactPolicy {
    /// A verified weak tree needs a small contact correction, not seven idle
    /// observations. Damage, threats and uncertain HP keep the conservative path.
    static func observationLimit(treeConfidence:Double,hp:Int?,nearbyThreats:Int,health:Double)->Int {
        guard treeConfidence>=0.25,let hp,(1...800).contains(hp),
              nearbyThreats==0,health>=0.90 else{return 7}
        return 2
    }
}
