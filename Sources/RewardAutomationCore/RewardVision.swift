import Foundation
import CoreGraphics

public struct RewardObservation: Codable {
    public let reward: FreeReward?
    public let texts: [RewardText]
    public let gameHUDVisible: Bool
    public let freeCardVisible: Bool
}

public final class RewardVision {
    private let icons=RewardIconClassifier()
    public init(){}
    public func observe(_ image:CGImage)throws->RewardObservation {
        // Only the left reward panel below the event. Never inspect shop buttons.
        let pixels=try Pixels(image)
        let hud=hudVisible(pixels)
        guard hud else{return .init(reward:nil,texts:[],gameHUDVisible:false,freeCardVisible:false)}
        // Independent, conservative presence check: OCR missing the word FREE
        // must not by itself turn a still-visible card into a successful claim.
        guard let badgeRegion=pixels.freeBadgeRect() else{return .init(reward:nil,texts:[],gameHUDVisible:true,freeCardVisible:false)}
        let cardVisible=true
        var texts=try recognize(image,roi:badgeRegion.insetBy(dx:-0.003,dy:-0.003),highContrast:true)
        guard hud,let badge=texts.first(where:{
            $0.text.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()=="FREE" &&
            $0.confidence>=0.45 && $0.x<0.12 && $0.y>=0.46 && $0.y<0.68 &&
            $0.height>=0.007 && $0.height<0.05
        }) else{return .init(reward:nil,texts:texts,gameHUDVisible:hud,freeCardVisible:cardVisible)}
        let green=pixels.count(in:badge.rect.insetBy(dx:-0.006,dy:-0.004)) {r,g,b in g>140 && g>r+25 && g>b+15}
        guard green>=12 else{return .init(reward:nil,texts:texts,gameHUDVisible:hud,freeCardVisible:cardVisible)}
        func amountCandidates()->[RewardText] { texts.filter {
            $0.confidence>=0.45 && $0.y>=badge.y+0.040 && $0.y<badge.y+0.073 &&
            $0.x>=0.035 && $0.x<0.15 && !$0.text.contains("m") && !$0.text.contains("h") && RewardAmount.parse($0.text) != nil
        }.sorted {
            // Preserve both the leading digit and magnitude. An OCR token such
            // as8.3 must not outrank the complete18.3K at a slightly smaller x.
            let suffixes="KMBTКМВТ"
            let a=$0.text.last.map{suffixes.contains($0)} ?? false
            let b=$1.text.last.map{suffixes.contains($0)} ?? false
            if a != b {return a}
            return $0.width>$1.width
        } }
        if let number=try RewardNumberReader().read(image) {texts.append(number)}
        let amount=amountCandidates().first
        let icon=CGRect(x:0.025,y:badge.y+badge.height+0.001,width:0.100,height:0.052)
        let match=icons.match(image,rect:icon),kind=match.kind
        let reward=FreeReward(kind:kind,amount:amount.flatMap{RewardAmount.parse($0.text)},
            rawAmount:amount?.text,classification:kind=="unknown" ? "unclassified icon; review evidence":"eight labelled stats icons; shape and colour; v2",
            texts:texts,tapX:0.069,tapY:min(0.74,badge.y+badge.height+0.041),
            badgeX:badge.x,badgeY:badge.y,iconFeatures:["templateErrorPermille":Int(match.error*1000),"templateMarginPermille":Int(match.margin*1000)])
        return .init(reward:reward,texts:texts,gameHUDVisible:hud,freeCardVisible:true)
    }
    private func hudVisible(_ pixels:Pixels)->Bool {
        // Active game's fixed bottom equipment strip, with repeated small red badges.
        // Upper/menu overlays suppress clicks by covering these slots.
        let red=pixels.count(in:.init(x:0.19,y:0.875,width:0.65,height:0.065)){r,g,b in r>170 && r>g*3/2 && r>b*5/4}
        let green=pixels.count(in:.init(x:0.34,y:0.40,width:0.30,height:0.16)){r,g,b in g>145 && g>r*3/2 && g>b*5/4}
        return red>=35 && green>=20
    }
    func recognize(_ image:CGImage,roi:CGRect,highContrast:Bool=false)throws->[RewardText] {
        let rect=CGRect(x:roi.minX*Double(image.width),y:roi.minY*Double(image.height),width:roi.width*Double(image.width),height:roi.height*Double(image.height)).integral
        guard let crop=image.cropping(to:rect),let c=CGContext(data:nil,width:crop.width*3,height:crop.height*3,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue) else{return []}
        c.interpolationQuality = .high
        c.draw(crop,in:CGRect(x:0,y:0,width:c.width,height:c.height))
        if highContrast,let bytes=c.data?.assumingMemoryBound(to:UInt8.self) {
            for y in 0..<c.height {for x in 0..<c.width {
                let i=y*c.bytesPerRow+x*4
                let r=Int(bytes[i]),g=Int(bytes[i+1]),b=Int(bytes[i+2])
                let white=min(r,min(g,b))>=175 && max(r,max(g,b))-min(r,min(g,b))<=65
                let value:UInt8=white ? 0:255
                bytes[i]=value;bytes[i+1]=value;bytes[i+2]=value;bytes[i+3]=255
            }}
        }
        guard let scaled=c.makeImage() else{return []}
        return try TesseractOCR.recognize(scaled).map {word in
            RewardText(word.text,confidence:word.confidence,rect:.init(
                x:(rect.minX+word.rect.minX/3)/Double(image.width),
                y:(rect.minY+word.rect.minY/3)/Double(image.height),
                width:word.rect.width/3/Double(image.width),height:word.rect.height/3/Double(image.height)))
        }
    }
}

struct Pixels {
    let w:Int,h:Int,data:[UInt8]
    init(_ image:CGImage)throws {
        w=image.width;h=image.height
        var bytes=[UInt8](repeating:0,count:w*h*4)
        let ok=bytes.withUnsafeMutableBytes {buffer->Bool in
            guard let c=CGContext(data:buffer.baseAddress,width:image.width,height:image.height,bitsPerComponent:8,bytesPerRow:image.width*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue) else{return false}
            c.draw(image,in:CGRect(x:0,y:0,width:image.width,height:image.height));return true
        }
        guard ok else{throw NSError(domain:"RewardVision",code:1)}
        data=bytes
    }
    func count(in r:CGRect,matching:(Int,Int,Int)->Bool)->Int {
        let x0=max(0,min(w,Int(r.minX*Double(w)))),x1=max(0,min(w,Int(r.maxX*Double(w))))
        let y0=max(0,min(h,Int(r.minY*Double(h)))),y1=max(0,min(h,Int(r.maxY*Double(h))))
        var count=0
        for y in y0..<max(y0,y1) {for x in x0..<max(x0,x1) {let i=(y*w+x)*4;if matching(Int(data[i]),Int(data[i+1]),Int(data[i+2])){count+=1}}}
        return count
    }
    func hasFreeBadge()->Bool {freeBadgeRect() != nil}
    func freeBadgeRect()->CGRect? {
        // A compact green component must contain white text and a dark outline.
        // Green terrain alone is never evidence of a remaining reward card.
        let x0=max(0,Int(Double(w)*0.002)),x1=min(w,Int(Double(w)*0.115))
        let y0=max(0,Int(Double(h)*0.56)),y1=min(h,Int(Double(h)*0.635))
        let rw=x1-x0,rh=y1-y0
        guard rw>0,rh>0 else{return nil}
        var mask=[Bool](repeating:false,count:rw*rh)
        for y in 0..<rh {for x in 0..<rw {
            let i=((y+y0)*w+x+x0)*4,r=Int(data[i]),g=Int(data[i+1]),b=Int(data[i+2])
            mask[y*rw+x]=g>145 && g>r+40 && g>b+30
        }}
        for start in mask.indices where mask[start] {
            var queue=[start],head=0,minX=rw,maxX=0,minY=rh,maxY=0
            mask[start]=false
            while head<queue.count {
                let index=queue[head],x=index%rw,y=index/rw;head+=1
                minX=min(minX,x);maxX=max(maxX,x);minY=min(minY,y);maxY=max(maxY,y)
                for (nx,ny) in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)] where nx>=0 && nx<rw && ny>=0 && ny<rh {
                    let next=ny*rw+nx
                    if mask[next] {mask[next]=false;queue.append(next)}
                }
            }
            let bw=maxX-minX+1,bh=maxY-minY+1,aspect=Double(bw)/Double(bh)
            guard Double(bw)>=Double(w)*0.028,Double(bw)<=Double(w)*0.095,
                  Double(bh)>=Double(h)*0.007,Double(bh)<=Double(h)*0.035,
                  aspect>=1.2,aspect<=6.5,Double(queue.count)>=Double(bw*bh)*0.25 else{continue}
            let rect=CGRect(x:Double(x0+minX-1)/Double(w),y:Double(y0+minY-1)/Double(h),
                width:Double(bw+2)/Double(w),height:Double(bh+2)/Double(h))
            let white=count(in:rect){r,g,b in min(r,min(g,b))>190 && max(r,max(g,b))-min(r,min(g,b))<65}
            let dark=count(in:rect){r,g,b in max(r,max(g,b))<90}
            if Double(white)>=Double(w*h)*0.000020 && Double(dark)>=Double(w*h)*0.000025 {return rect}
        }
        return nil
    }
}
