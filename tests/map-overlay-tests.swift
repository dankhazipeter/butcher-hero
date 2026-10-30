import Foundation
import ImageIO

@main
struct MapOverlayTests {
    static func main() {
        let detector = ExpandedMapDetector()
        let cases: [(String, Bool)] = [
            ("20260919-192415-29b0f273-observe", true),
            ("20260919-192516-7c1c3ffa-observe", false),
            ("20260919-192821-b495cbbf-observe", false),
            ("20260919-192746-a40e803b-observe", false),
            ("20260919-133816-62ee5a19-observe", true),
            ("20260919-134014-e1eb1568-observe", true),
            ("20260919-133747-aacac89c-observe", false),
            ("20260919-133643-d1d0b8a0-observe", false),
            ("20260919-133558-80011c16-observe", false),
            ("20260919-133301-cb25e1cb-observe", false),
            ("20260919-115359-observe", false)
        ]
        for (run, expected) in cases {
            let url = URL(fileURLWithPath: "docs/runs/\(run)/frame-00000.png")
            let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)!
            print("\(run): difference \(detector.difference(image)!), expected \(expected)")
            assert(detector.matches(image) == expected)
        }
        print("PASS: expanded map separated from normal gameplay and equipment")
    }
}
