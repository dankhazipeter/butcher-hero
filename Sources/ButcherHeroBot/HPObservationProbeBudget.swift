import Foundation
final class HPObservationProbeBudget {
    private var used=false
    private var clearFrames=0
    private var lastUse = -Double.infinity
    func observe(freshHighHP:Bool) {
        clearFrames=freshHighHP ? clearFrames+1:0
        if clearFrames>=2 {used=false}
    }
    func consume(now:Double)->Bool {
        guard !used,now-lastUse>=8 else{return false}
        used=true;clearFrames=0;lastUse=now
        return true
    }
}
