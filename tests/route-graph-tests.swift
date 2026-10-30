import Foundation

@main
struct RouteGraphTests {
    static func main() {
        let nodes = [
            VisualRouteNavigator.Node(id: "a", signatures: [[0,0,0]], evidence: "test"),
            VisualRouteNavigator.Node(id: "b", signatures: [[100,100,100]], evidence: "test")
        ]
        let edge = VisualRouteNavigator.Edge(from: "a", to: "b", dx: 0, dy: 1,
                                             duration: 0.5, steps: 4, evidence: "test")
        let graph = VisualRouteNavigator.Graph(goal: "b", entryTolerance: 8,
                                              arrivalTolerance: 22, nodes: nodes, edges: [edge])
        let navigator = VisualRouteNavigator(graph: graph)
        assert(navigator.next(signature: [40,40,40]) == nil, "Unknown scene must not start")
        assert(navigator.next(signature: [0,0,0])?.duration == 0.5)
        assert(navigator.next(signature: [20,20,20])?.duration == 0.5)
        assert(navigator.next(signature: [100,100,100])?.reason.contains("megérkezés") == true)
        assert(navigator.next(signature: [100,100,100]) == nil)

        let stuck = VisualRouteNavigator(graph: graph)
        for _ in 0..<3 { assert(stuck.next(signature: [0,0,0])?.duration == 0.5) }
        assert(stuck.next(signature: [0,0,0])?.reason.contains("mozgás nélküli") == true)
        assert(stuck.next(signature: [0,0,0]) == nil, "Failed edge must cool down")

        let budget = VisualRouteNavigator(graph: graph)
        for value in [0,20,40,60] { assert(budget.next(signature: [value,value,value])?.duration == 0.5) }
        assert(budget.next(signature: [80,80,80])?.reason.contains("lépéskorlát") == true)

        let ambiguous = VisualRouteNavigator(graph: .init(goal: "b", entryTolerance: 8,
            arrivalTolerance: 22, nodes: nodes + [.init(id: "duplicate", signatures: [[0,0,0]], evidence: "test")], edges: [edge]))
        assert(ambiguous.next(signature: [0,0,0]) == nil)
        let real = VisualRouteNavigator()
        let data = try! Data(contentsOf: URL(fileURLWithPath: "tests/fixtures/route-signatures.json"))
        let signatures = try! JSONDecoder().decode([[Int]].self, from: data)
        let directives = signatures.compactMap { real.next(signature: $0) }
        assert(directives.filter { $0.reason.contains("megérkezés") }.count == 3,
               "Each measured edge must reach its visual destination")
        assert(!directives.contains { $0.reason.contains("nem igazolt") })
        assert(!real.isActive)
        let fence = VisualRouteNavigator()
        let fenceData = try! Data(contentsOf: URL(fileURLWithPath: "tests/fixtures/fence-route-signatures.json"))
        let fenceSignatures = try! JSONDecoder().decode([[Int]].self, from: fenceData)
        let fenceDirectives = fenceSignatures.compactMap { fence.next(signature: $0) }
        assert(fenceDirectives.filter { $0.reason.contains("megérkezés") }.count == 3)
        assert(!fenceDirectives.contains { $0.reason.contains("nem igazolt") })
        assert(!fence.isActive)
        print("PASS: independent fence exit with three visually verified edges")
        print("PASS: visual graph unknown/ambiguous entry, verified arrival, blocked edge, step budget")
        print("PASS: all three real measured edges have verified visual arrival")
    }
}
