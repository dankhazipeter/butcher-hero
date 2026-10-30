import Foundation
import Darwin

/// SIGINT must finish the synthetic mouse-up/focus restoration, not kill a drag.
final class RunCancellation: @unchecked Sendable {
    static let shared = RunCancellation()
    private let lock = NSLock()
    private var stopped = false
    private var sources: [DispatchSourceSignal] = []
    var requested: Bool {
        lock.lock(); defer { lock.unlock() }; return stopped
    }
    private init() {
        for number in [SIGINT, SIGTERM] {
            signal(number, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: number, queue: .global())
            source.setEventHandler { [weak self] in self?.request() }
            source.resume(); sources.append(source)
        }
    }
    func request() { lock.lock(); stopped = true; lock.unlock() }
    func wait(_ duration: Double) {
        let end = Date().addingTimeInterval(duration)
        while !requested && Date() < end {
            Thread.sleep(forTimeInterval: min(0.02, max(0, end.timeIntervalSinceNow)))
        }
    }
}
