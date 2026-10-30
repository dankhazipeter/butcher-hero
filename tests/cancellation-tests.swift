import Foundation
import Darwin
@main struct CancellationTests {
    static func main() {
        let flag=RunCancellation.shared
        precondition(!flag.requested)
        kill(getpid(), SIGINT)
        let deadline=Date().addingTimeInterval(1)
        while !flag.requested && Date()<deadline {usleep(1000)}
        precondition(flag.requested,"SIGINT must request cleanup, not terminate the process")
        let start=Date();flag.wait(10)
        precondition(Date().timeIntervalSince(start)<0.1)
        print("PASS: SIGINT requests graceful cleanup and cancels input wait")
    }
}
