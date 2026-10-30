import Foundation
@main struct WeaponRewardTests {
    static func main() {
        func ends(_ texts:[String],hp:Int=3060,d:Double=130,visible:Bool=false,threats:Int=0)->Bool {
            WeaponRewardEvidence.endsGuardTrial(texts:texts,initialHP:hp,lastDistance:d,
                targetVisible:visible,nearbyThreatCount:threats)
        }
        let reward=["TLEVEL UP","Damage 595, 630"]
        precondition(ends(reward))
        precondition(!ends(["9h 58m"]))
        precondition(!ends(["LEVEL UP"]))
        precondition(!ends(["Damage 595,630"]))
        precondition(!ends(reward,hp:18800))
        precondition(!ends(reward,d:250))
        precondition(!ends(reward,visible:true))
        precondition(!ends(reward,threats:1))
        print("PASS: fresh weapon reward closes nearby small-guard trial; absence, timer, live threat or large boss do not")
    }
}
