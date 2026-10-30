import Foundation
import Vision
import ImageIO

// Read-only diagnostic: compare tight HP-row crops, never game input/state.
@main struct BarOCRProbe {
    static func main() throws {
        let a=CommandLine.arguments
        guard a.count==6,let x=Double(a[2]),let y=Double(a[3]),
              let w=Double(a[4]),let h=Double(a[5]),
              let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:a[1]) as CFURL,nil),
              let image=CGImageSourceCreateImageAtIndex(source,0,nil) else {
            fatalError("image x y width height")
        }
        for padding in [4.0,6.0,10.0,14.0] {
            for scale in [2,3,4,6] {
                let roi=CGRect(x:x-12,y:y-padding,width:w+24,height:h+padding*2)
                    .intersection(CGRect(x:0,y:0,width:image.width,height:image.height)).integral
                guard let crop=image.cropping(to:roi),let ctx=CGContext(data:nil,
                    width:crop.width*scale,height:crop.height*scale,bitsPerComponent:8,
                    bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else {continue}
                ctx.interpolationQuality = .high
                ctx.draw(crop,in:CGRect(x:0,y:0,width:crop.width*scale,height:crop.height*scale))
                let request=VNRecognizeTextRequest();request.recognitionLevel = .accurate
                request.usesLanguageCorrection=false;request.minimumTextHeight=0.004
                try VNImageRequestHandler(cgImage:ctx.makeImage()!,options:[:]).perform([request])
                let texts=(request.results ?? []).map { $0.topCandidates(3).map(\.string) }
                print("padding=\(padding),scale=\(scale): \(texts)")
            }
        }
    }
}
