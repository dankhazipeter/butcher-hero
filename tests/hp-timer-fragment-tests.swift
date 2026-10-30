import Foundation
@main struct Tests {
    static func main() {
        for s in ["3m 52s","7h 6m","52s16:52K=","152s16.52K"] {
            precondition(HPTimerOcclusionPolicy.matches([s]),"missed timer \(s)")
        }
        for s in ["6.52K","16:52K","52s","Damage 52","6.52sK","Stats"] {
            precondition(!HPTimerOcclusionPolicy.matches([s]),"invented timer \(s)")
        }
        print("PASS: clipped timer+K HP permits observation only; clean HP and unrelated text rejected")
    }
}
