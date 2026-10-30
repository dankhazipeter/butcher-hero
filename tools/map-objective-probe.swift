import Foundation
import ImageIO
@main struct Probe {
    static func main() throws {
        let detector=MapObjectiveDetector()
        let expanded=CommandLine.arguments.contains("--expanded")
        for path in CommandLine.arguments.dropFirst() where path != "--expanded" {
            guard let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil),
                  let image=CGImageSourceCreateImageAtIndex(source,0,nil) else{continue}
            print(path)
            print(String(decoding:try JSONEncoder().encode(detector.detect(image,expanded:expanded)),as:UTF8.self))
        }
    }
}
