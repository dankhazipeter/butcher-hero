import Foundation
import ImageIO

/// Read-only route audit. Invalid optical-flow pairs stop the chain; no bridging
/// of unknown jumps and no writes to persistent navigation/game state.
@main struct MeasureRoute {
    static func main() throws {
        let paths=Array(CommandLine.arguments.dropFirst())
        guard paths.count>=2 else {
            throw NSError(domain:"route-audit",code:1,userInfo:[NSLocalizedDescriptionKey:"Provide ordered PNG paths"])
        }
        let odometry=VisualOdometry()
        var previous:CGImage?
        var x=0.0,y=0.0
        var output:[[String:Any]]=[]
        for path in paths {
            guard let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil),
                  let image=CGImageSourceCreateImageAtIndex(source,0,nil) else {
                throw NSError(domain:"route-audit",code:2,userInfo:[NSLocalizedDescriptionKey:"Cannot read \(path)"])
            }
            if let previous {
                let motion=odometry.measure(previous:previous,current:image)
                guard motion.valid,hypot(motion.dx,motion.dy)<200 else {
                    throw NSError(domain:"route-audit",code:3,userInfo:[NSLocalizedDescriptionKey:"Unverified image transition ending at \(path): valid=\(motion.valid), dx=\(motion.dx), dy=\(motion.dy), consensus=\(motion.consensus), residual=\(motion.residual)"])
                }
                x-=motion.dx;y-=motion.dy
                output.append(["image":path,"x":x,"y":y,"dx":-motion.dx,"dy":-motion.dy,
                    "consensus":motion.consensus,"residual":motion.residual])
            } else {output.append(["image":path,"x":0,"y":0])}
            previous=image
        }
        let data=try JSONSerialization.data(withJSONObject:output,options:[.prettyPrinted,.sortedKeys])
        print(String(decoding:data,as:UTF8.self))
    }
}
