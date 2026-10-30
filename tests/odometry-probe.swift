import Foundation
import ImageIO

@main struct OdometryProbe {
    static func main() {
        let args=Array(CommandLine.arguments.dropFirst())
        let path=args.first ?? "docs/runs/20260919-133246-444755cf-nudge"
        let urls=(try! FileManager.default.contentsOfDirectory(at:URL(fileURLWithPath:path),includingPropertiesForKeys:nil))
            .filter{$0.pathExtension=="png"}.sorted{$0.path<$1.path}
        var previous:CGImage?
        let odometry=VisualOdometry()
        for url in urls {
            let image=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(url as CFURL,nil)!,0,nil)!
            if let previous {
                let start=Date(),motion=odometry.measure(previous:previous,current:image)
                if args.contains("--compact") {
                    print(url.lastPathComponent,"valid",motion.valid,"inliers",motion.consensus,"matches",motion.candidates.count,"dx",motion.dx,"dy",motion.dy,"residual",motion.residual,"time",Date().timeIntervalSince(start))
                } else {print(url.lastPathComponent,String(data:try! JSONEncoder().encode(motion),encoding:.utf8)!,Date().timeIntervalSince(start))}
            }
            previous=image
        }
    }
}
