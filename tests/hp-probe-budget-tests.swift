import Foundation
@main struct Tests {
    static func main() {
        let b=HPObservationProbeBudget()
        precondition(b.consume(now:0))
        for i in 1...10 {b.observe(freshHighHP:false);precondition(!b.consume(now:Double(i)))}
        b.observe(freshHighHP:true)
        precondition(!b.consume(now:11))
        b.observe(freshHighHP:true)
        precondition(b.consume(now:12))
        b.observe(freshHighHP:true);b.observe(freshHighHP:true)
        precondition(!b.consume(now:14))
        precondition(b.consume(now:20))
        print("PASS: no repeated blind probes; two fresh high HP frames rearm;8s minimum")
    }
}
