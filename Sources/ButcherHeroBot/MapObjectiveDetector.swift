import Foundation
import CoreGraphics
import ImageIO

/// Colour+glyph templates identify objective classes, not unique world origins.
/// Coordinates are in the normalized637x882 captured window.
final class MapObjectiveDetector {
    struct Icon:Codable {let kind:String;let x:Double;let y:Double;let error:Double}
    private struct Sample {let x:Int;let y:Int;let r:Int;let g:Int;let b:Int}
    private struct Template {let kind:String;let width:Int;let height:Int;let samples:[Sample]}
    private var templates:[Template]=[]
    init() {
        let path="docs/runs/20260919-205539-4953ef18-observe/frame-00000.png"
        guard let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil),
              let image=CGImageSourceCreateImageAtIndex(source,0,nil),let p=Self.rgba(image) else{return}
        for (kind,x,y,w,h) in [("weapon-cyan",385,254,14,14),("weapon-green",506,232,13,14),
                              ("golem-orange",403,220,15,16),("progression-red",385,174,16,17)] {
            var samples:[Sample]=[]
            for dy in 0..<h {for dx in 0..<w {
                let i=((y+dy)*637+x+dx)*4,r=Int(p[i]),g=Int(p[i+1]),b=Int(p[i+2])
                let dark=max(r,g,b)<95
                if dark || Self.coloured(kind,r,g,b) {samples.append(.init(x:dx,y:dy,r:r,g:g,b:b))}
            }}
            if samples.count>=35 {templates.append(.init(kind:kind,width:w,height:h,samples:samples))}
        }
    }
    private static func coloured(_ kind:String,_ r:Int,_ g:Int,_ b:Int)->Bool {
        switch kind {
        case "weapon-cyan":return g>160 && b>150 && r<130
        case "weapon-green":return g>170 && r>65 && r<220 && b<110 && g>r+20
        case "golem-orange":return r>185 && g>90 && g<195 && b<100
        default:return r>190 && g<95 && b>65 && b<170
        }
    }
    private static func rgba(_ image:CGImage)->[UInt8]? {
        guard let c=CGContext(data:nil,width:637,height:882,bitsPerComponent:8,bytesPerRow:637*4,
            space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else{return nil}
        c.draw(image,in:CGRect(x:0,y:0,width:637,height:882))
        return Array(UnsafeBufferPointer(start:c.data!.assumingMemoryBound(to:UInt8.self),count:637*882*4))
    }
    func detect(_ image:CGImage,expanded:Bool)->[Icon] {
        guard let p=Self.rgba(image) else{return []}
        let cx=expanded ? 447.0:552.0,cy=expanded ? 238.0:128.0,radius=expanded ? 177.0:75.0
        var found:[Icon]=[]
        for t in templates {
            var candidates:[Icon]=[]
            let loX=max(0,Int(cx-radius)),hiX=min(637-t.width,Int(cx+radius))
            let loY=max(32,Int(cy-radius)),hiY=min(882-t.height,Int(cy+radius))
            for y in loY..<hiY {for x in loX..<hiX {
                let px=Double(x)+Double(t.width)/2,py=Double(y)+Double(t.height)/2
                guard hypot(px-cx,py-cy)<radius-5 else{continue}
                // Require substantial saturated fill before the expensive glyph comparison.
                var colours=0
                for dy in stride(from:2,to:t.height-2,by:3) {for dx in stride(from:2,to:t.width-2,by:3) {
                    let i=((y+dy)*637+x+dx)*4
                    if Self.coloured(t.kind,Int(p[i]),Int(p[i+1]),Int(p[i+2])) {colours+=1}
                }}
                guard colours>=4 else{continue}
                var sum=0
                for s in t.samples {
                    let i=((y+s.y)*637+x+s.x)*4
                    sum+=abs(Int(p[i])-s.r)+abs(Int(p[i+1])-s.g)+abs(Int(p[i+2])-s.b)
                }
                let score=Double(sum)/Double(t.samples.count*3)
                if score<26 {candidates.append(.init(kind:t.kind,x:px,y:py,error:score))}
            }}
            for c in candidates.sorted(by:{$0.error<$1.error}) {
                if !found.contains(where:{$0.kind==c.kind && hypot($0.x-c.x,$0.y-c.y)<12}) {found.append(c)}
            }
        }
        return found.sorted{$0.x<$1.x}
    }
}
