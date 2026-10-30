import Foundation
import CoreGraphics
import Vision

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
        let roi=CGRect(x:0,y:0.43,width:0.17,height:0.30)
        let pixels=try Pixels(image)
        let hud=hudVisible(pixels)
        guard hud else{return .init(reward:nil,texts:[],gameHUDVisible:false,freeCardVisible:false)}
        // Independent, conservative presence check: OCR missing the word FREE
        // must not by itself turn a still-visible card into a successful claim.
        let badgePixels=pixels.count(in:.init(x:0.008,y:0.575,width:0.066,height:0.040)) {r,g,b in
            g>145 && g>r+40 && g>b+30
        }
        let cardVisible=badgePixels>=12
        var texts=try recognize(image,roi:roi)
        guard hud,let badge=texts.first(where:{
            $0.text.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()=="FREE" &&
            $0.confidence>=0.45 && $0.x<0.12 && $0.y>=0.46 && $0.y<0.68 &&
            $0.height>=0.007 && $0.height<0.05
        }) else{return .init(reward:nil,texts:texts,gameHUDVisible:hud,freeCardVisible:cardVisible)}
        let green=pixels.count(in:badge.rect.insetBy(dx:-0.006,dy:-0.004)) {r,g,b in g>140 && g>r+25 && g>b+15}
        guard green>=12 else{return .init(reward:nil,texts:texts,gameHUDVisible:hud,freeCardVisible:cardVisible)}
        func amountCandidates()->[RewardText] { texts.filter {
            $0.confidence>=0.45 && $0.y>=badge.y+0.040 && $0.y<badge.y+0.073 &&
            $0.x>=0.055 && $0.x<0.15 && !$0.text.contains("m") && !$0.text.contains("h") && RewardAmount.parse($0.text) != nil
        }.sorted{$0.height>$1.height} }
        if amountCandidates().isEmpty {
            texts += try recognize(image,roi:.init(x:0.065,y:badge.y+0.046,width:0.085,height:0.039))
        }
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
    private func recognize(_ image:CGImage,roi:CGRect)throws->[RewardText] {
        let rect=CGRect(x:roi.minX*Double(image.width),y:roi.minY*Double(image.height),width:roi.width*Double(image.width),height:roi.height*Double(image.height)).integral
        guard let crop=image.cropping(to:rect),let c=CGContext(data:nil,width:crop.width*3,height:crop.height*3,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else{return []}
        c.interpolationQuality = .high
        c.draw(crop,in:CGRect(x:0,y:0,width:c.width,height:c.height))
        guard let scaled=c.makeImage() else{return []}
        let request=VNRecognizeTextRequest()
        request.recognitionLevel = .accurate; request.usesLanguageCorrection=false
        request.recognitionLanguages=["en-US"]; request.minimumTextHeight=0.018
        try VNImageRequestHandler(cgImage:scaled).perform([request])
        let numbers=try NSRegularExpression(pattern:#"(?<![A-Za-z0-9.,])\d+(?:[.,]\d+)?[KMBT]?(?![A-Za-z0-9%])"#)
        func token(_ text:String,_ confidence:Float,_ b:CGRect)->RewardText {
            RewardText(text,confidence:confidence,rect:.init(
                x:(rect.minX+b.minX*rect.width)/Double(image.width),
                y:(rect.minY+(1-b.maxY)*rect.height)/Double(image.height),
                width:b.width*rect.width/Double(image.width),height:b.height*rect.height/Double(image.height)))
        }
        return (request.results ?? []).flatMap { observation -> [RewardText] in
            guard let t=observation.topCandidates(1).first else{return []}
            var result=[token(t.string,t.confidence,observation.boundingBox)]
            // Obtain the number's own geometric box when a world timer touches the label.
            for match in numbers.matches(in:t.string,range:NSRange(t.string.startIndex...,in:t.string)) {
                guard let range=Range(match.range,in:t.string),String(t.string[range]) != t.string,
                      let box=try? t.boundingBox(for:range) else{continue}
                result.append(token(String(t.string[range]),t.confidence,box.boundingBox))
            }
            return result
        }
    }
}

private struct Pixels {
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
}
