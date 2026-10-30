import Foundation
import CoreGraphics
import CoreVideo
import ImageIO
import Vision

@main struct FlowProbe {
    static func main() throws {
        let args=Array(CommandLine.arguments.dropFirst())
        let path=args.first ?? "docs/runs/20260919-133246-444755cf-nudge"
        let urls=(try FileManager.default.contentsOfDirectory(at:URL(fileURLWithPath:path),includingPropertiesForKeys:nil)).filter{$0.pathExtension=="png"}.sorted{$0.path<$1.path}
        var previous:CGImage?
        for url in urls.prefix(args.contains("--synthetic") ? 2 : 8) {
            let raw=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(url as CFURL,nil)!,0,nil)!
            let ctx=CGContext(data:nil,width:318,height:441,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
            if args.contains("--synthetic"),let previous {
                ctx.draw(previous,in:CGRect(x:30,y:0,width:318,height:441))
            } else {ctx.draw(raw,in:CGRect(x:0,y:0,width:318,height:441))}
            let image=ctx.makeImage()!
            if let previous {
                let gray=CGContext(data:nil,width:318,height:441,bitsPerComponent:8,bytesPerRow:318,space:CGColorSpaceCreateDeviceGray(),bitmapInfo:0)!
                gray.draw(previous,in:CGRect(x:0,y:0,width:318,height:441))
                let intensities=gray.data!.assumingMemoryBound(to:UInt8.self)
                let start=Date(),r=VNGenerateOpticalFlowRequest(targetedCGImage:image,options:[:])
                r.computationAccuracy = .high
                if args.contains("--revision1") { r.revision=VNGenerateOpticalFlowRequestRevision1 }
                if args.contains("--very-high") {r.computationAccuracy = .veryHigh}
                try VNImageRequestHandler(cgImage:previous,options:[:]).perform([r])
                let b=r.results!.first!.pixelBuffer
                CVPixelBufferLockBaseAddress(b,.readOnly);defer{CVPixelBufferUnlockBaseAddress(b,.readOnly)}
                let data=CVPixelBufferGetBaseAddress(b)!,stride=CVPixelBufferGetBytesPerRow(b)
                let w=CVPixelBufferGetWidth(b),h=CVPixelBufferGetHeight(b)
                var xs:[Float]=[],ys:[Float]=[]
                for y in Swift.stride(from:Int(Double(h)*0.2),to:Int(Double(h)*0.8),by:6) {
                    let row=data.advanced(by:y*stride).assumingMemoryBound(to:Float.self)
                    for x in Swift.stride(from:Int(Double(w)*0.18),to:Int(Double(w)*0.78),by:6) {
                        if x>Int(Double(w)*0.37) && x<Int(Double(w)*0.62) && y>Int(Double(h)*0.4) && y<Int(Double(h)*0.59) {continue}
                        let gradient=abs(Int(intensities[y*w+x-2])-Int(intensities[y*w+x+2]))+abs(Int(intensities[(y-2)*w+x])-Int(intensities[(y+2)*w+x]))
                        if gradient < 35 {continue}
                        xs.append(row[x*2]);ys.append(row[x*2+1])
                    }
                }
                print(url.lastPathComponent,"size",w,h,"edges",xs.count,"flow",xs.sorted()[xs.count/2]*2,ys.sorted()[ys.count/2]*2,"seconds",Date().timeIntervalSince(start))
            }
            previous=image
        }
    }
}
