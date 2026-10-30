import Foundation
@main struct Tests {
    static func main() {
        func allowed(_ hp:Int?,_ raw:Int?,_ foliage:Double=0.65,_ axe:Double=0.06,_ independent:Bool=false)->Bool {
            PassiveTreePolicy.verified(hp:hp,rawHP:raw,foliage:foliage,axe:axe,heart:0,outline:0.5,independentBoss:independent)
        }
        precondition(allowed(923,923))
        precondition(!allowed(923,923,0.2))
        precondition(!allowed(923,923,0.65,0))
        precondition(!allowed(923,7150))
        precondition(!allowed(11400,11400))
        precondition(!allowed(923,923,0.65,0.06,true))
        precondition(!allowed(nil,923))
        print("PASS: verified923tree; humanoid, missing icon/HP, larger/raw boss excluded")
    }
}
