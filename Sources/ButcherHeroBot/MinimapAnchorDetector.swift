import Foundation
import CoreGraphics
import ImageIO

struct MinimapPose:Codable {
    let anchor:String
    let x:Double
    let y:Double
    let error:Double
    let landmarkX:Double
    let landmarkY:Double
}

/// One persistent landmark, never the normalized bearing alone. Units are
/// minimap pixels at 637px window width, not movement time or world pixels.
final class MinimapAnchorDetector {
    private struct Sample {let x:Int;let y:Int;let r:Int;let g:Int;let b:Int}
    private var samples:[Sample]=[]
    private var weaponSamples:[Sample]=[]
    init() {
        let url=URL(fileURLWithPath:"docs/runs/20260919-140122-71600bcd-play/frame-00021.png")
        guard let source=CGImageSourceCreateWithURL(url as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil),
              let rgba=Self.rgba(image) else{return}
        for y in 0..<15 {for x in 0..<14 {
            let i=((66+y)*637+533+x)*4,r=Int(rgba[i]),g=Int(rgba[i+1]),b=Int(rgba[i+2])
            if (r>170 && g>90 && b<95) || (r<100 && g<90 && b<80) {
                samples.append(.init(x:x,y:y,r:r,g:g,b:b))
            }
        }}
        for y in 0..<18 {for x in 0..<17 {
            let i=((130+y)*637+536+x)*4,r=Int(rgba[i]),g=Int(rgba[i+1]),b=Int(rgba[i+2])
            if (g>175 && b<125 && g>r+15) || (r<90 && g<110 && b<90) {
                weaponSamples.append(.init(x:x,y:y,r:r,g:g,b:b))
            }
        }}
    }
    private static func rgba(_ image:CGImage)->[UInt8]? {
        guard let c=CGContext(data:nil,width:637,height:882,bitsPerComponent:8,bytesPerRow:637*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else{return nil}
        c.draw(image,in:CGRect(x:0,y:0,width:637,height:882))
        return Array(UnsafeBufferPointer(start:c.data!.assumingMemoryBound(to:UInt8.self),count:637*882*4))
    }
    func detect(_ image:CGImage,playerX:Double,playerY:Double)->MinimapPose? {
        guard samples.count>50,let p=Self.rgba(image) else{return nil}
        var best=Double.infinity,second=Double.infinity,bx=0,by=0
        var scores:[(Int,Int,Double)]=[]
        for y in 51..<186 {for x in 478..<619 {
            // Fast yellow center gate before testing the eyes/outline template.
            let i=((y+7)*637+x+7)*4
            guard p[i]>150,p[i+1]>80,p[i+2]<110 else{continue}
            var error=0
            for s in samples {
                let j=((y+s.y)*637+x+s.x)*4
                error += abs(Int(p[j])-s.r)+abs(Int(p[j+1])-s.g)+abs(Int(p[j+2])-s.b)
            }
            let score=Double(error)/Double(samples.count*3)
            scores.append((x,y,score));if score<best{best=score;bx=x;by=y}
        }}
        for (x,y,score) in scores where hypot(Double(x-bx),Double(y-by))>8 {second=min(second,score)}
        guard best<27,second>best+8 else{return nil}
        let lx=Double(bx)+7,ly=Double(by)+7.5
        return .init(anchor:"dusty-gulch-orange-skull",x:playerX*637/Double(image.width)-lx,
                     y:playerY*882/Double(image.height)-ly,error:best,landmarkX:lx,landmarkY:ly)
    }
    func detectVenom(_ image:CGImage,playerX:Double,playerY:Double)->MinimapPose? {
        guard weaponSamples.count>70,let p=Self.rgba(image) else{return nil}
        var best=Double.infinity,second=Double.infinity,bx=0,by=0
        var scores:[(Int,Int,Double)]=[]
        for y in 51..<183 {for x in 478..<617 {
            let i=((y+4)*637+x+4)*4
            guard p[i+1]>150,p[i+2]<140 else{continue}
            var error=0
            for s in weaponSamples {
                let j=((y+s.y)*637+x+s.x)*4
                error+=abs(Int(p[j])-s.r)+abs(Int(p[j+1])-s.g)+abs(Int(p[j+2])-s.b)
            }
            let score=Double(error)/Double(weaponSamples.count*3)
            scores.append((x,y,score));if score<best{best=score;bx=x;by=y}
        }}
        for (x,y,score) in scores where hypot(Double(x-bx),Double(y-by))>9 {second=min(second,score)}
        guard best<27,second>best+8 else{return nil}
        let lx=Double(bx)+8.5,ly=Double(by)+9
        return .init(anchor:"dusty-gulch-venom-guard",x:playerX*637/Double(image.width)-lx,
                     y:playerY*882/Double(image.height)-ly,error:best,landmarkX:lx,landmarkY:ly)
    }
}
