import Foundation
import CoreGraphics
import ImageIO

struct DigitTemplate:Codable {let character:String;let aspect:Double;let bits:[UInt8]}
struct DigitShape {let rect:CGRect;let aspect:Double;let bits:[UInt8]}

/// Fixed HUD numeral glyphs: no OS OCR model, no inference from reward kind.
final class RewardNumberReader {
    private let templates:[DigitTemplate]
    init(){
        #if SWIFT_PACKAGE
        let url=Bundle.module.url(forResource:"digits",withExtension:"json",subdirectory:"RewardDigits")
        #else
        let url:URL?=URL(fileURLWithPath:"Sources/RewardAutomationCore/Resources/RewardDigits/digits.json")
        #endif
        templates=url.flatMap{try? Data(contentsOf:$0)}.flatMap{try? JSONDecoder().decode([DigitTemplate].self,from:$0)} ?? []
    }
    static func shapes(_ image:CGImage)throws->[DigitShape] {
        let roi=CGRect(x:0.035,y:0.636,width:0.115,height:0.039)
        let area=CGRect(x:roi.minX*Double(image.width),y:roi.minY*Double(image.height),width:roi.width*Double(image.width),height:roi.height*Double(image.height)).integral
        guard let crop=image.cropping(to:area) else{return []}
        let w=crop.width,h=crop.height
        var rgba=[UInt8](repeating:0,count:w*h*4)
        let valid=rgba.withUnsafeMutableBytes {buffer->Bool in
            guard let context=CGContext(data:buffer.baseAddress,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue) else{return false}
            context.draw(crop,in:CGRect(x:0,y:0,width:w,height:h));return true
        }
        guard valid else{return []}
        var white=[Bool](repeating:false,count:w*h)
        for i in white.indices {
            let r=Int(rgba[i*4]),g=Int(rgba[i*4+1]),b=Int(rgba[i*4+2])
            white[i]=min(r,min(g,b))>185 && max(r,max(g,b))-min(r,min(g,b))<45
        }
        func groups(_ mask:[Bool])->[[Int]] {
            var remaining=mask,result:[[Int]]=[]
            for start in remaining.indices where remaining[start] {
                var queue=[start],head=0;remaining[start]=false
                while head<queue.count {
                    let p=queue[head],x=p%w,y=p/w;head+=1
                    for dy in -1...1 {for dx in -1...1 {
                        let nx=x+dx,ny=y+dy
                        guard nx>=0,ny>=0,nx<w,ny<h else{continue}
                        let next=ny*w+nx
                        if remaining[next] {remaining[next]=false;queue.append(next)}
                    }}
                }
                result.append(queue)
            }
            return result
        }
        // Only boundary-connected white scenery needs separation. Preserve
        // intact glyphs verbatim: filtering every glyph can split the crossbar
        // of 4 and silently truncate 84 to 8. When scenery joins a final 0,
        // retain its white pixels enclosed by the font's dark horizontal outline.
        let outlineReach=max(3,Int(ceil(Double(image.height)*0.015)))
        func dark(_ x:Int,_ y:Int)->Bool {
            let i=(y*w+x)*4
            return max(rgba[i],max(rgba[i+1],rgba[i+2]))<80
        }
        for group in groups(white) where group.contains(where:{i in
            i%w==0 || i%w==w-1 || i/w==0 || i/w==h-1
        }) {
            for i in group {
                let x=i%w,y=i/w
                let left=(1...outlineReach).contains{d in x-d>=0 && dark(x-d,y)}
                let right=(1...outlineReach).contains{d in x+d<w && dark(x+d,y)}
                if !left || !right {white[i]=false}
            }
        }
        let components=groups(white).filter{$0.count>=2}.map{group in
            (group.map{$0%w}.min()!,group.map{$0/w}.min()!,
             group.map{$0%w}.max()!,group.map{$0/w}.max()!,group.count)
        }
        let maxHeight=components.map{$0.3-$0.1+1}.max() ?? 0
        let tops=components.filter{Double($0.3-$0.1+1)>=Double(maxHeight)*0.8}.map{$0.1}.sorted()
        let rowTop=tops.isEmpty ? 0:tops[tops.count/2]
        let bottoms=components.filter{Double($0.3-$0.1+1)>=Double(maxHeight)*0.8}.map{$0.3}.sorted()
        let rowBottom=bottoms.isEmpty ? 0:bottoms[bottoms.count/2]
        return components.filter {
            let height=$0.3-$0.1+1,width=$0.2-$0.0+1
            // Bright world scenery beyond the card can be as tall as a glyph
            // but is not on the numeral baseline (reviewed18.4K+snow case).
            return (Double(height)>=Double(maxHeight)*0.8 && abs($0.1-rowTop)<=max(2,maxHeight/4) &&
                abs($0.3-rowBottom)<=max(2,maxHeight/10)) ||
                (height<=max(3,Int(Double(maxHeight)*0.3)) && width<=max(4,Int(Double(maxHeight)*0.4)) && $0.1>=rowTop+maxHeight/2 && $0.3<=rowTop+maxHeight+2)
        }.sorted{$0.0<$1.0}.map {x0,y0,x1,y1,count in
            let width=x1-x0+1,height=y1-y0+1
            var bits=[UInt8](repeating:0,count:24*32)
            for y in 0..<32 {for x in 0..<24 {
                let px=min(x1,x0+Int((Double(x)+0.5)*Double(width)/24))
                let py=min(y1,y0+Int((Double(y)+0.5)*Double(height)/32))
                bits[y*24+x]=white[py*w+px] ? 1:0
            }}
            return DigitShape(rect:CGRect(x:(area.minX+Double(x0))/Double(image.width),y:(area.minY+Double(y0))/Double(image.height),width:Double(width)/Double(image.width),height:Double(height)/Double(image.height)),aspect:Double(width)/Double(height),bits:bits)
        }
    }
    func read(_ image:CGImage,diagnostics:(([String])->Void)?=nil)throws->RewardText? {
        let shapes=try Self.shapes(image)
        guard !shapes.isEmpty,!templates.isEmpty else{return nil}
        let maxHeight=shapes.map{$0.rect.height}.max() ?? 0
        let mainShapes=shapes.filter{$0.rect.height>=maxHeight*0.35}
        var text="",confidence=1.0
        for shape in shapes {
            if shape.rect.height<maxHeight*0.35 {
                if let first=mainShapes.first,let last=mainShapes.last,
                   shape.rect.minX>first.rect.minX,shape.rect.maxX<last.rect.maxX {text+="."}
                continue
            }
            let scores=Dictionary(grouping:templates,by:{$0.character}).map {character,samples in
                let error=samples.map {sample->Double in
                    let mismatch=zip(sample.bits,shape.bits).reduce(0){$0+($1.0==$1.1 ? 0:1)}
                    return Double(mismatch)/768+abs(sample.aspect-shape.aspect)*0.3
                }.min() ?? 1
                return (character,error)
            }.sorted{$0.1<$1.1}
            diagnostics?(scores.prefix(3).map{"\($0.0)=\($0.1)"})
            guard scores.count>=2,scores[0].1<0.30,scores[1].1-scores[0].1>0.035 else{return nil}
            text+=scores[0].0;confidence=min(confidence,1-scores[0].1)
        }
        guard RewardAmount.parse(text) != nil,let first=shapes.first else{return nil}
        let rect=shapes.dropFirst().reduce(first.rect){$0.union($1.rect)}
        return RewardText(text,confidence:Float(confidence),rect:rect)
    }
}
