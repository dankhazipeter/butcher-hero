import Foundation
import CoreGraphics
import ImageIO

@main struct LocalMapTests {
    static func main() {
        let path="docs/runs/20260919-133246-444755cf-nudge/frame-00000.png"
        let base=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil)!,0,nil)!
        let odometry=VisualOdometry()
        let tinyResize=CGContext(data:nil,width:base.width+3,height:base.height+4,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        tinyResize.draw(base,in:CGRect(x:0,y:0,width:base.width+3,height:base.height+4))
        let rasterMotion=odometry.measure(previous:base,current:tinyResize.makeImage()!)
        precondition(rasterMotion.valid && hypot(rasterMotion.dx,rasterMotion.dy)<3,
            "tiny proportional capture-size jitter is not a camera jump")
        let badResize=CGContext(data:nil,width:base.width+40,height:base.height,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        badResize.draw(base,in:CGRect(x:0,y:0,width:base.width+40,height:base.height))
        precondition(!odometry.measure(previous:base,current:badResize.makeImage()!).valid,"large/aspect resize remains unverified")
        for (dx,dy) in [(60,0),(-40,0),(0,60),(0,-60),(30,40),(0,0)] {
            let c=CGContext(data:nil,width:base.width,height:base.height,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
            c.draw(base,in:CGRect(x:dx,y:-dy,width:base.width,height:base.height))
            let motion=odometry.measure(previous:base,current:c.makeImage()!)
            print("known",dx,dy,"measured",motion.dx,motion.dy,"valid",motion.valid)
            precondition(motion.valid && abs(motion.dx-Double(dx))<5 && abs(motion.dy-Double(dy))<5,"synthetic translation must calibrate")
        }
        let map=LocalWorldMap(path:"/tmp/butcher-map-test-must-not-exist.json",readOnly:true,load:false)
        let start=map.observe(base,eligible:true,evidence:path)
        precondition(start.nodes==1 && start.edges==0)
        map.recordExecuted(x:1,y:0,duration:0.5,learnObstacle:true)
        _=map.observe(base,eligible:true,evidence:path)
        map.recordExecuted(x:1,y:0,duration:0.5,learnObstacle:true)
        _=map.observe(base,eligible:true,evidence:path)
        precondition(map.steer(x:1,y:0,duration:0.5) != nil,"two executed blocked inputs must trigger measured detour")
        _=map.observe(base,eligible:false,evidence:"UI")
        precondition(map.steer(x:1,y:0,duration:0.5)==nil,"UI must suspend control")
        let resumed=map.observe(base,eligible:true,evidence:path)
        precondition(resumed.chart==start.chart && resumed.status.contains("relocalized"),"scene and minimap relocalize")
        precondition(!FileManager.default.fileExists(atPath:"/tmp/butcher-map-test-must-not-exist.json"),"read-only must not write")
        print("PASS: calibrated motion, two-input obstacle, UI suspension, dual-image relocalization, read-only")
        let checkpointPath=FileManager.default.temporaryDirectory.appendingPathComponent("butcher-checkpoint-\(UUID().uuidString).json").path
        defer {try? FileManager.default.removeItem(atPath:checkpointPath)}
        let checkpointMap=LocalWorldMap(path:checkpointPath,load:false)
        let saved=checkpointMap.observe(base,eligible:true,evidence:path)
        let c=CGContext(data:nil,width:base.width,height:base.height,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        c.draw(base,in:CGRect(x:10,y:-10,width:base.width,height:base.height))
        let restarted=LocalWorldMap(path:checkpointPath,readOnly:true)
        let continued=restarted.observe(c.makeImage()!,eligible:true,evidence:"translated-test-only")
        precondition(continued.chart==saved.chart && abs(continued.position.x+10)<5 && abs(continued.position.y+10)<5,
            "last pre-input checkpoint must restore shifted camera into the same chart")
        precondition(continued.status.contains("checkpoint"),"checkpoint is checked before old thumbnail candidates")
        let blank=CGContext(data:nil,width:base.width,height:base.height,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        let unrelated=LocalWorldMap(path:checkpointPath,readOnly:true)
        precondition(unrelated.observe(blank.makeImage()!,eligible:true,evidence:"unrelated").chart != saved.chart,
            "checkpoint cannot join an unrelated screen")
        print("PASS: image-verified checkpoint continuity and unrelated-screen rejection")
        let lastFramePath="docs/runs/20260919-195734-17926fcb-play/frame-00006.png"
        let nextFramePath="docs/runs/20260919-195800-71979fb3-play/frame-00000.png"
        let lastFrame=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(URL(fileURLWithPath:lastFramePath) as CFURL,nil)!,0,nil)!
        let nextFrame=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(URL(fileURLWithPath:nextFramePath) as CFURL,nil)!,0,nil)!
        let realMap=LocalWorldMap(path:checkpointPath,load:false)
        let realStart=realMap.observe(lastFrame,eligible:true,evidence:lastFramePath)
        let realRestart=LocalWorldMap(path:checkpointPath,readOnly:true)
        let realEnd=realRestart.observe(nextFrame,eligible:true,evidence:nextFramePath)
        precondition(realEnd.chart==realStart.chart && realEnd.status.contains("checkpoint") && abs(realEnd.position.x+59.13)<3,
            "real59px last-swipe displacement must restore via aligned image, not reset its chart")
        print("PASS: real59px restart with motion-aligned scene validation")
        let sliding=LocalWorldMap(path:"/tmp/butcher-map-slide-test.json",readOnly:true,load:false)
        _=sliding.observe(base,eligible:true,evidence:path)
        for offset in [5,10] {
            let c=CGContext(data:nil,width:base.width,height:base.height,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
            c.draw(base,in:CGRect(x:offset,y:-offset,width:base.width,height:base.height))
            sliding.recordExecuted(x:-1,y:1,duration:0.6,learnObstacle:true)
            _=sliding.observe(c.makeImage()!,eligible:true,evidence:path)
        }
        precondition(sliding.steer(x:-1,y:1,duration:0.6) != nil,"sideways drift cannot masquerade as requested forward progress")
        print("PASS: two sideways slides trigger a new direction despite nonzero camera movement")
        let nodes=(0..<4).map {i in LocalWorldMap.Node(id:i,chart:0,position:.init(x:Double(i)*60,y:0),scene:[],minimap:[],visits:0,blocked:[:],evidence:"test")}
        var graph=LocalWorldMap.State()
        graph.nodes=nodes
        graph.edges=[.init(from:0,to:1,traversals:1,evidence:"test"),.init(from:1,to:2,traversals:1,evidence:"test")]
        precondition(LocalWorldMap.shortestRoute(graph,from:0,to:2)==[1,2])
        precondition(LocalWorldMap.shortestRoute(graph,from:2,to:0)==nil,"reverse ledge is not assumed")
        precondition(LocalWorldMap.shortestRoute(graph,from:0,to:3)==nil,"spatial proximity is not an edge")
        graph.nodes[0].orangeCoverage=0.1
        graph.nodes[2].orangeCoverage=0.9
        graph.nodes[3].orangeCoverage=0.9
        precondition(LocalWorldMap.routeToIsland2(graph,from:0)==[1,2],"return only on recorded route, not unconnected orange terrain")
        precondition(LocalWorldMap.routeToIsland2(graph,from:2)==nil,"already in Island2")
        graph.nodes[1].blocked[0]=2
        precondition(LocalWorldMap.shortestRoute(graph,from:0,to:2)==nil,"confirmed blocked edge is excluded")
        precondition(LocalWorldMap.routeToIsland2(graph,from:0)==nil,"no fallback across blocked return edge")
        print("PASS: shortest measured directed route; unknown reverse, unconnected and blocked edges excluded")
    }
}
