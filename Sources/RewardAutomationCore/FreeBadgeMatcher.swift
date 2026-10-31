import Foundation
import CoreGraphics

/// Pixel templates of the actual fixed FREE graphic, independent of OCR text.
public final class FreeBadgeMatcher {
    private struct Template:Decodable {let name:String,source:String,signature:[UInt8]}
    private struct Model:Decodable {let templates:[Template]}
    private let templates:[[UInt8]]
    public static let threshold=0.82
    public init() {
        if let url=Bundle.module.url(forResource:"templates",withExtension:"json",subdirectory:"FreeBadges"),
           let data=try? Data(contentsOf:url),let model=try? JSONDecoder().decode(Model.self,from:data) {
            templates=model.templates.map(\.signature).filter{$0.count==48*24}
        } else {templates=[]}
    }
    /// Offline calibration only; caller must visually label the source as FREE.
    public static func calibrationSignature(_ image:CGImage)throws->[UInt8]? {
        let pixels=try Pixels(image)
        guard let rect=pixels.freeBadgeRect() else{return nil}
        return signature(pixels,rect:rect)
    }
    public func similarity(_ image:CGImage,rect:CGRect)throws->Double {
        let pixels=try Pixels(image)
        var best=0.0
        for dy in [-1,0,1] {for dx in [-1,0,1] {
            let candidate=Self.signature(pixels,rect:rect.offsetBy(dx:Double(dx)/Double(pixels.w),dy:Double(dy)/Double(pixels.h)))
            for reference in templates {
                func dice(_ category:UInt8)->Double {
                    var intersection=0,a=0,b=0
                    for i in candidate.indices {
                        if candidate[i]==category {a+=1}
                        if reference[i]==category {b+=1}
                        if candidate[i]==category && reference[i]==category {intersection+=1}
                    }
                    if category==2 && (a<40 || b<40) {return 0}
                    return a+b>0 ? Double(2*intersection)/Double(a+b):0
                }
                let white=dice(2),green=dice(1)
                // White letter geometry dominates; green background alone cannot match.
                if white>=Self.threshold {best=max(best,white*0.85+green*0.15)}
            }
        }}
        return best
    }
    private static func signature(_ pixels:Pixels,rect:CGRect)->[UInt8] {
        var result=[UInt8](repeating:0,count:48*24)
        for y in 0..<24 {for x in 0..<48 {
            let px=max(0,min(pixels.w-1,Int((rect.minX+(Double(x)+0.5)*rect.width/48)*Double(pixels.w))))
            let py=max(0,min(pixels.h-1,Int((rect.minY+(Double(y)+0.5)*rect.height/24)*Double(pixels.h))))
            let i=(py*pixels.w+px)*4,r=Int(pixels.data[i]),g=Int(pixels.data[i+1]),b=Int(pixels.data[i+2])
            if min(r,min(g,b))>=175 && max(r,max(g,b))-min(r,min(g,b))<=65 {result[y*48+x]=2}
            else if g>145 && g>r+40 && g>b+30 {result[y*48+x]=1}
        }}
        return result
    }
}
