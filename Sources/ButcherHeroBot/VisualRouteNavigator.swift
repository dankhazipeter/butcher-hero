import Foundation

/// A route is evidence-backed data, not a biome-triggered movement macro.
final class VisualRouteNavigator {
    struct Node: Codable {
        let id: String
        let signatures: [[Int]]
        let evidence: String
    }
    struct Edge: Codable {
        let from: String
        let to: String
        let dx: Double
        let dy: Double
        let duration: Double
        let steps: Int
        let evidence: String
    }
    struct Graph: Codable {
        let goal: String
        var additionalGoals: [String]? = nil
        let entryTolerance: Int
        let arrivalTolerance: Int
        let nodes: [Node]
        let edges: [Edge]
    }
    struct Directive {
        let dx: Double
        let dy: Double
        let duration: Double
        let reason: String
    }

    private let graph: Graph?
    private var plan: [Edge] = []
    private var executed = 0
    private var staticSteps = 0
    private var previousSignature: [Int]?
    private var cooldown = 0

    init(path: String = "docs/route-graph.json") {
        graph = (try? Data(contentsOf: URL(fileURLWithPath: path)))
            .flatMap { try? JSONDecoder().decode(Graph.self, from: $0) }
    }
    init(graph: Graph) { self.graph = graph }

    var isActive: Bool { !plan.isEmpty }

    func cancel() {
        plan = []
        executed = 0
        staticSteps = 0
        previousSignature = nil
    }

    private func distance(_ a: [Int], _ b: [Int]) -> Int {
        guard !a.isEmpty, a.count == b.count else { return Int.max / 2 }
        return zip(a, b).reduce(0) { $0 + abs($1.0 - $1.1) }
    }

    private func nodeDistance(_ node: Node, _ signature: [Int]) -> Int {
        node.signatures.map { distance($0, signature) }.min() ?? Int.max / 2
    }

    private func path(from start: String, graph: Graph) -> [Edge]? {
        var queue: [(String, [Edge])] = [(start, [])]
        var visited: Set<String> = [start]
        while !queue.isEmpty {
            let (node, route) = queue.removeFirst()
            if node == graph.goal || (graph.additionalGoals ?? []).contains(node) { return route }
            for edge in graph.edges where edge.from == node && !visited.contains(edge.to) {
                guard edge.steps > 0, edge.steps <= 12,
                      edge.duration >= 0.1, edge.duration <= 0.7,
                      abs(edge.dx) + abs(edge.dy) > 0 else { continue }
                visited.insert(edge.to)
                queue.append((edge.to, route + [edge]))
            }
        }
        return nil
    }

    private func abort(_ reason: String) -> Directive {
        cancel()
        cooldown = 120
        return Directive(dx: 0, dy: 0, duration: 0,
                         reason: "Vizuális útvonalgráf: \(reason); az él nem igazolt, helyi újratervezés")
    }

    /// Called only for executable decisions; no timers advance on human activity.
    func next(signature: [Int]) -> Directive? {
        guard let graph else { return nil }
        if cooldown > 0 { cooldown -= 1; return nil }
        if plan.isEmpty {
            let candidates = graph.nodes.map { ($0, nodeDistance($0, signature)) }
                .sorted { $0.1 < $1.1 }
            guard let best = candidates.first, best.1 <= graph.entryTolerance,
                  candidates.count < 2 || candidates[1].1 - best.1 >= 6,
                  let route = path(from: best.0.id, graph: graph), !route.isEmpty else { return nil }
            plan = route
        }
        guard let edge = plan.first,
              let destination = graph.nodes.first(where: { $0.id == edge.to }) else {
            return abort("hiányzó végpont")
        }
        if executed > 0,
           nodeDistance(destination, signature) <= graph.arrivalTolerance {
            plan.removeFirst()
            executed = 0
            staticSteps = 0
            previousSignature = nil
            return Directive(dx: 0, dy: 0, duration: 0,
                             reason: "Vizuális útvonalgráf: képpel igazolt megérkezés — \(edge.to)")
        }
        if let previousSignature {
            staticSteps = distance(previousSignature, signature) <= 12 ? staticSteps + 1 : 0
        }
        if staticSteps >= 3 { return abort("három mozgás nélküli lépés") }
        if executed >= edge.steps { return abort("lépéskorlát végponti egyezés nélkül") }
        previousSignature = signature
        executed += 1
        return Directive(dx: edge.dx, dy: edge.dy, duration: edge.duration,
                         reason: "Vizuális útvonalgráf: \(edge.from) → \(edge.to), \(executed)/\(edge.steps)")
    }
}
