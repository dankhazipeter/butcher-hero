import Foundation
import CoreGraphics
import ImageIO

public struct RewardIconMatch {
    public let kind:String
    public let error:Double
    public let margin:Double
}

/// Shape AND colour matching of the eight explicitly labelled game stat icons.
/// Shield geometry distinguishes damage from defense; ambiguous matches stay unknown.
public final class RewardIconClassifier {
    public static let kinds=["hp","regeneration","piercing_damage","cutting_damage","smash_damage","piercing_defense","cutting_defense","smash_defense"]
    private let templates:[(String,[UInt8])]
    public init(){
        templates=Self.kinds.flatMap {kind in [kind,kind+"_live"].compactMap {name -> (String,[UInt8])? in
            guard let url=Bundle.module.url(forResource:name,withExtension:"png",subdirectory:"RewardIcons"),
                  let source=CGImageSourceCreateWithURL(url as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil),let signature=Self.signature(image) else{return nil}
            return (kind,signature)
        }}
    }
    public func match(_ image:CGImage,rect:CGRect)->RewardIconMatch {
        let pixels=CGRect(x:rect.minX*Double(image.width),y:rect.minY*Double(image.height),width:rect.width*Double(image.width),height:rect.height*Double(image.height)).integral
        guard let crop=image.cropping(to:pixels),let signature=Self.signature(crop),templates.count>=8 else{return .init(kind:"unknown",error:1,margin:0)}
        let scores=Self.kinds.map {kind in (kind,templates.filter{$0.0==kind}.map{Self.error(signature,$0.1)}.min() ?? 1)}.sorted{$0.1<$1.1}
        let best=scores[0],margin=scores[1].1-best.1
        return .init(kind:best.1<0.48 && margin>0.035 ? best.0:"unknown",error:best.1,margin:margin)
    }
    private static func category(_ r:Int,_ g:Int,_ b:Int)->UInt8 {
        if r>175 && r>g*3/2 && r>b*5/4 {return 1} // health red
        if g>145 && g>r*5/4 && g>b*6/5 {return 2} // regen green
        if r>205 && g>145 && b<120 && r>g+12 {return 3} // gold axe / shield
        if r>160 && g>80 && g<170 && b<100 && r>g+35 {return 4} // wooden shaft / shield
        if g>145 && b>150 && g>r+12 {return 5} // cyan blade / shield
        if b>155 && b>r+18 && b>g+10 {return 6} // blue/purple hammer
        return 0
    }
    private static func signature(_ image:CGImage)->[UInt8]? {
        let w=image.width,h=image.height
        guard w>2,h>2 else{return nil}
        var rgba=[UInt8](repeating:0,count:w*h*4)
        let valid=rgba.withUnsafeMutableBytes {b->Bool in
            guard let c=CGContext(data:b.baseAddress,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue) else{return false}
            c.draw(image,in:CGRect(x:0,y:0,width:w,height:h));return true
        }
        guard valid else{return nil}
        var categories=[UInt8](repeating:0,count:w*h),minX=w,minY=h,maxX=0,maxY=0,count=0
        for y in 0..<h {for x in 0..<w {
            let i=(y*w+x)*4,c=category(Int(rgba[i]),Int(rgba[i+1]),Int(rgba[i+2]))
            categories[y*w+x]=c
            if c != 0 {minX=min(minX,x);minY=min(minY,y);maxX=max(maxX,x);maxY=max(maxY,y);count+=1}
        }}
        guard count>=12,maxX>minX,maxY>minY else{return nil}
        var normalized=[UInt8](repeating:0,count:32*32)
        for y in 0..<32 {for x in 0..<32 {
            let px=min(maxX,minX+Int((Double(x)+0.5)*Double(maxX-minX+1)/32))
            let py=min(maxY,minY+Int((Double(y)+0.5)*Double(maxY-minY+1)/32))
            normalized[y*32+x]=categories[py*w+px]
        }}
        return normalized
    }
    private static func error(_ candidate:[UInt8],_ reference:[UInt8])->Double {
        var error=0.0,total=0.0
        for i in 0..<1024 where candidate[i] != 0 || reference[i] != 0 {
            total+=1
            if candidate[i] != reference[i] {error += candidate[i]==0 || reference[i]==0 ? 0.85:1.0}
        }
        return total>0 ? error/total:1
    }
}
