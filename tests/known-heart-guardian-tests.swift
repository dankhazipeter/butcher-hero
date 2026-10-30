import Foundation
@main struct Tests {
    static func main() {
        precondition(KnownHeartGuardianPolicy.matches(hp:4310,heart:0.11,rewardNumbers:[501],structure:0))
        precondition(KnownHeartGuardianPolicy.matches(hp:4310,heart:0.11,rewardNumbers:[500],structure:0))
        for hp in [3060,4401,7150,18800,27700] {
            precondition(!KnownHeartGuardianPolicy.matches(hp:hp,heart:0.11,rewardNumbers:[500],structure:0))
        }
        precondition(!KnownHeartGuardianPolicy.matches(hp:4310,heart:0.01,rewardNumbers:[500],structure:0))
        precondition(!KnownHeartGuardianPolicy.matches(hp:4310,heart:0.11,rewardNumbers:[],structure:0))
        precondition(!KnownHeartGuardianPolicy.matches(hp:4310,heart:0.11,rewardNumbers:[500],structure:0.1))
        print("PASS: known4310/500heart signature only; DOC/snow/skulls/structure excluded")
    }
}
