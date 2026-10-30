import Foundation

/// A fresh icon gives a relative exploratory direction, never world identity,
/// combat strength or a timed route. Stop short-range icon chasing at contact.
enum GolemApproachPolicy {
    struct Offset {let x:Double;let y:Double}
    static func offset(x:Double,y:Double)->Offset? {
        let distance=hypot(x,y)
        guard x.isFinite,y.isFinite,distance>8 else{return nil}
        let horizon=min(distance,18)
        return .init(x:x/distance*horizon,y:y/distance*horizon)
    }
}
