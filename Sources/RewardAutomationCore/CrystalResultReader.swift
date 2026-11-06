import Foundation
import CoreGraphics

/// What an opened geode gave, read offline from the saved CRYSTAL STATS result frame.
/// Every field is optional: an unreadable part stays nil, it is never guessed.
public struct CrystalResult:Codable,Equatable {
    /// Colour of the tile behind the crystal (the game's rarity): grey, green, blue, purple, orange, red.
    public var rarity:String?
    /// Colour of the crystal itself: blue, green or red.
    public var gem:String?
    public var level:Int?
    /// Game stat name as printed, e.g. "Cut Defense".
    public var stat:String?
    /// Normalised amount ("148000") and as printed ("148K").
    public var amount:String?
    public var rawAmount:String?
    public var statLine:String?
    public init(rarity:String?=nil,gem:String?=nil,level:Int?=nil,stat:String?=nil,amount:String?=nil,rawAmount:String?=nil,statLine:String?=nil) {
        self.rarity=rarity;self.gem=gem;self.level=level;self.stat=stat;self.amount=amount;self.rawAmount=rawAmount;self.statLine=statLine
    }
}

/// Reads the result frame of the bounded crystal flow: centred square tile with the crystal
/// and its level, and the first CRYSTAL STATS line below it. (The sell cost is not read: two
/// OCR renderings agreed on 2.97K for a reviewed 2.37K, too risky for a small number.)
/// Pure image analysis plus the local Tesseract process; never sends input.
public enum CrystalResultReader {
    public static let version="crystal-result-v3"
    public static let stats=["Health Regen","Health","Lifesteal","Pierce Damage","Cut Damage","Smash Damage",
                             "Pierce Defense","Cut Defense","Smash Defense"]

    struct Pixels {
        let width:Int,height:Int,bytes:[UInt8]
        init?(_ image:CGImage) {
            let width=image.width,height=image.height
            self.width=width;self.height=height
            var data=[UInt8](repeating:0,count:width*height*4)
            let ok=data.withUnsafeMutableBytes {buffer->Bool in
                guard let context=CGContext(data:buffer.baseAddress,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,
                                            space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGBitmapInfo.byteOrder32Big.rawValue|CGImageAlphaInfo.premultipliedLast.rawValue)
                else{return false}
                context.draw(image,in:CGRect(x:0,y:0,width:width,height:height));return true
            }
            guard ok else{return nil}
            bytes=data
        }
        func rgb(_ x:Int,_ y:Int)->(Int,Int,Int) {
            let i=(min(max(y,0),height-1)*width+min(max(x,0),width-1))*4
            return (Int(bytes[i]),Int(bytes[i+1]),Int(bytes[i+2]))
        }
    }

    /// Tile outline: dark and not the purple/magenta of the glow and the sell-cost pill.
    static func outline(_ c:(Int,Int,Int))->Bool {max(c.0,max(c.1,c.2))<75 && c.1>=c.0}

    /// The tile's square in pixels. The result panel scales with the window height: measured on
    /// 623×863, 637×882, 642×951 and 788×1083 frames the tile's top is at 0.352 H (±0.003) and its
    /// side is 0.1135 H, centred horizontally. Sampling regions keep margins for the title bar.
    static func tile(_ p:Pixels)->CGRect? {
        let h=Double(p.height),side=h*0.1135
        guard p.width>200,p.height>300 else{return nil}
        return CGRect(x:Double(p.width)/2-side/2,y:h*0.352,width:side,height:side)
    }

    static func hue(_ c:(Int,Int,Int))->(hue:Double,saturation:Double,value:Double) {
        let r=Double(c.0)/255,g=Double(c.1)/255,b=Double(c.2)/255
        let mx=max(r,max(g,b)),mn=min(r,min(g,b)),d=mx-mn
        guard d>0 else{return (0,0,mx)}
        var h:Double
        if mx==r {h=(g-b)/d} else if mx==g {h=(b-r)/d+2} else {h=(r-g)/d+4}
        h*=60;if h<0 {h+=360}
        return (h,d/mx,mx)
    }

    static func median(_ values:[(Int,Int,Int)])->(Int,Int,Int)? {
        guard !values.isEmpty else{return nil}
        func m(_ k:KeyPath<(Int,Int,Int),Int>)->Int {values.map{$0[keyPath:k]}.sorted()[values.count/2]}
        return (m(\.0),m(\.1),m(\.2))
    }

    /// Tile fill above the crystal → the rarity colour name.
    static func rarity(_ p:Pixels,_ t:CGRect)->(name:String,fill:(Int,Int,Int))? {
        var samples:[(Int,Int,Int)]=[]
        let y=Int(t.minY+t.height*0.13)
        for dy in -2...2 {for x in stride(from:Int(t.minX+t.width*0.2),to:Int(t.maxX-t.width*0.2),by:2) {
            let c=p.rgb(x,y+dy);if !outline(c) {samples.append(c)}
        }}
        guard samples.count>10,let fill=median(samples) else{return nil}
        let (h,s,v)=hue(fill)
        let name:String
        if s<0.42 {name="grey"}
        else if h<15 || h>=340 {name="red"}
        else if h<50 {name="orange"}
        else if h<170 {name="green"}
        else if h<250 {name="blue"}
        else {name="purple"}
        _=v
        return (name,fill)
    }

    /// The crystal's own colour: saturated pixels in the tile's centre that differ from the fill.
    static func gem(_ p:Pixels,_ t:CGRect,fill:(Int,Int,Int))->String? {
        var votes=["red":0,"green":0,"blue":0]
        for y in stride(from:Int(t.minY+t.height*0.3),to:Int(t.minY+t.height*0.72),by:1) {
            for x in stride(from:Int(t.minX+t.width*0.3),to:Int(t.maxX-t.width*0.3),by:1) {
                let c=p.rgb(x,y)
                let distance=abs(c.0-fill.0)+abs(c.1-fill.1)+abs(c.2-fill.2)
                let (h,s,v)=hue(c)
                guard distance>70,s>0.35,v>0.45 else{continue}
                if h>=300 || h<20 {votes["red"]!+=1}
                else if h>=60 && h<165 {votes["green"]!+=1}
                else if h>=180 && h<250 {votes["blue"]!+=1}
            }
        }
        let sorted=votes.sorted{$0.value>$1.value}
        let area=Int(t.width*0.4*t.height*0.42)
        guard sorted[0].value>=max(20,area/12),sorted[0].value>=sorted[1].value*3 else{return nil}
        return sorted[0].key
    }

    /// Smooth dark-on-light copy: bright text maps to black with a soft ramp, then a
    /// high-quality upscale. Tesseract reads the game's rounded font better without hard edges.
    static func smoothTextImage(_ p:Pixels,_ r:CGRect,low:Int,high:Int,scale:Double=3)->CGImage? {
        let x0=max(0,Int(r.minX)),y0=max(0,Int(r.minY)),x1=min(p.width,Int(r.maxX)),y1=min(p.height,Int(r.maxY))
        let w=x1-x0,h=y1-y0
        guard w>4,h>4,high>low else{return nil}
        var grey=[UInt8](repeating:255,count:w*h)
        for y in 0..<h {for x in 0..<w {
            let c=p.rgb(x0+x,y0+y),v=min(c.0,min(c.1,c.2))
            let t=max(0,min(255,(v-low)*255/(high-low)))
            grey[y*w+x]=UInt8(255-t)
        }}
        guard let provider=CGDataProvider(data:Data(grey) as CFData),
              let small=CGImage(width:w,height:h,bitsPerComponent:8,bitsPerPixel:8,bytesPerRow:w,space:CGColorSpaceCreateDeviceGray(),
                                bitmapInfo:CGBitmapInfo(rawValue:CGImageAlphaInfo.none.rawValue),provider:provider,decode:nil,shouldInterpolate:true,intent:.defaultIntent)
        else{return nil}
        let pad=16,ow=Int(Double(w)*scale)+pad*2,oh=Int(Double(h)*scale)+pad*2
        guard let context=CGContext(data:nil,width:ow,height:oh,bitsPerComponent:8,bytesPerRow:ow,space:CGColorSpaceCreateDeviceGray(),
                                    bitmapInfo:CGImageAlphaInfo.none.rawValue) else{return nil}
        context.setFillColor(gray:1,alpha:1);context.fill(CGRect(x:0,y:0,width:ow,height:oh))
        context.interpolationQuality = .high
        context.draw(small,in:CGRect(x:pad,y:pad,width:ow-pad*2,height:oh-pad*2))
        return context.makeImage()
    }

    static func ocrSmooth(_ p:Pixels,_ r:CGRect,low:Int,high:Int,scale:Double=3)->String? {
        guard let image=smoothTextImage(p,r,low:low,high:high,scale:scale),let words=try? TesseractOCR.recognize(image),!words.isEmpty else{return nil}
        return words.map(\.text).joined(separator:" ")
    }

    static func distance(_ a:[Character],_ b:[Character])->Int {
        var row=Array(0...b.count)
        for (i,x) in a.enumerated() {
            var previous=row[0];row[0]=i+1
            for (j,y) in b.enumerated() {
                let current=row[j+1]
                row[j+1]=min(row[j+1]+1,row[j]+1,previous+(x==y ? 0:1))
                previous=current
            }
        }
        return row[b.count]
    }

    /// Known stat name for the letters before the amount (its sign or first digit): at most
    /// 2 OCR letter errors, unique best.
    public static func statName(_ text:String)->String? {
        let head=String(text.prefix{!$0.isNumber && !"+#«*".contains($0)})
        let letters=Array(head.lowercased().filter(\.isLetter))
        guard letters.count>=4 else{return nil}
        let scored=stats.map{($0,distance(letters,Array($0.lowercased().filter(\.isLetter))))}.sorted{$0.1<$1.1}
        guard scored[0].1<=2,scored[0].1<scored[1].1 else{return nil}
        return scored[0].0
    }

    /// "Cut Defense +148K" → ("Cut Defense","148K"). OCR often turns the "+" into "#", "«" or
    /// "*", or drops it, so the sign is not required. The unit is: every crystal stat is shown
    /// with K/M/B/T, and "Health +1.574" is a misread 1.57M, not 1.574. No letter or digit may
    /// touch the number ("2S1K", "G26K" are not amounts).
    ///
    /// `unit` is the unit read from the glyph's shape (see `unitShape`). In this font the M
    /// looks like an H, and Tesseract reads it as h, 4, 8 or a quote. With a shape unit, an
    /// explicit OCR unit must agree with it; a decimal number with one character too many
    /// ("1.51h", "1.514", "1.518": the game shows at most three digits) loses that last
    /// character, which was the misread unit. Without a decimal point nothing is dropped.
    public static func parseStatLine(_ text:String,unit:String?=nil)->(stat:String,raw:String)? {
        guard let stat=statName(text) else{return nil}
        if let range=text.range(of:#"(?<![A-Za-z0-9.,])\d+(?:[.,]\d+)?\s*[KMBT](?![A-Za-z0-9.,])"#,options:.regularExpression) {
            let raw=text[range].replacingOccurrences(of:" ",with:"")
            guard unit==nil || raw.hasSuffix(unit!),RewardAmount.parse(raw) != nil else{return nil}
            return (stat,raw)
        }
        guard let unit,["K","M","B","T"].contains(unit),
              let range=text.range(of:#"(?<![A-Za-z0-9.,])\d+[.,]\d+"#,options:.regularExpression) else{return nil}
        var number=String(text[range])
        let rest=text[range.upperBound...]
        // Digits after the dot beyond what the game prints (X.YZ, XY.Z): one is the unit.
        let digits=number.filter(\.isNumber).count
        if digits==4 {number.removeLast()} else if digits>4 {return nil}
        else if let next=rest.first,next.isLetter || next.isNumber {
            // A single character in the unit's place ("3.78h") is the misread unit itself;
            // anything longer is not an amount.
            guard rest.dropFirst().first.map({$0.isWhitespace}) ?? true else{return nil}
        }
        guard number.last?.isNumber == true else{return nil}
        let raw=number.replacingOccurrences(of:",",with:".")+unit
        guard RewardAmount.parse(raw) != nil else{return nil}
        return (stat,raw)
    }

    /// K or M from the last glyph of the stat line: in this font an M has a full-height right
    /// stem (the right quarter covers every middle row), a K only its two arms (none). Measured
    /// on 77 reviewed frames: K 0.00, M 1.00 at the 200 brightness threshold.
    static func unitShape(_ p:Pixels,_ r:CGRect)->String? {
        let x0=max(0,Int(r.minX)),y0=max(0,Int(r.minY)),w=min(p.width,Int(r.maxX))-x0,h=min(p.height,Int(r.maxY))-y0
        guard w>8,h>8 else{return nil}
        var mask=[Bool](repeating:false,count:w*h)
        for y in 0..<h {for x in 0..<w {let c=p.rgb(x0+x,y0+y);mask[y*w+x]=min(c.0,min(c.1,c.2))>=200}}
        var seen=[Bool](repeating:false,count:w*h)
        var glyphs:[(minX:Int,minY:Int,maxX:Int,maxY:Int)]=[]
        for start in 0..<(w*h) where mask[start] && !seen[start] {
            var queue=[start],head=0;seen[start]=true
            var box=(minX:w,minY:h,maxX:0,maxY:0)
            while head<queue.count {
                let i=queue[head],x=i%w,y=i/w;head+=1
                box=(min(box.minX,x),min(box.minY,y),max(box.maxX,x),max(box.maxY,y))
                for dy in -1...1 {for dx in -1...1 {
                    let nx=x+dx,ny=y+dy
                    guard nx>=0,ny>=0,nx<w,ny<h else{continue}
                    let n=ny*w+nx
                    if mask[n] && !seen[n] {seen[n]=true;queue.append(n)}
                }}
            }
            if queue.count>=4 {glyphs.append(box)}
        }
        let tallest=glyphs.map{$0.maxY-$0.minY+1}.max() ?? 0
        guard tallest>=6,let last=glyphs.filter({Double($0.maxY-$0.minY+1)>=Double(tallest)*0.6}).max(by:{$0.maxX<$1.maxX}) else{return nil}
        let width=last.maxX-last.minX+1,height=last.maxY-last.minY+1
        guard height>=6,width>=3 else{return nil}
        var hit=0,rows=0
        for y in (last.minY+height/3)...(last.maxY-height/3) {
            rows+=1
            if ((last.maxX-max(1,width/4)+1)...last.maxX).contains(where:{mask[y*w+$0]}) {hit+=1}
        }
        let coverage=Double(hit)/Double(max(1,rows))
        return coverage>=0.8 ? "M":coverage<=0.2 ? "K":nil
    }

    /// Which gem colour each stat group shows (all 76 reviewed result frames agree).
    public static func gemColour(forStat stat:String)->String {
        stat.hasSuffix("Defense") ? "blue":stat.hasSuffix("Damage") ? "red":"green"
    }

    /// Three renderings of the same text; a value counts only if at least two agree.
    static let variants:[(low:Int,high:Int,scale:Double)]=[(110,200,3),(140,230,3),(110,200,2)]
    static func agreed<T:Hashable>(_ values:[T?])->T? {
        let counts=Dictionary(grouping:values.compactMap{$0},by:{$0}).mapValues(\.count)
        guard let best=counts.max(by:{$0.value<$1.value}),best.value>=2,
              counts.values.filter({$0==best.value}).count==1 else{return nil}
        return best.key
    }

    public static func read(_ image:CGImage)->CrystalResult {
        var result=CrystalResult()
        guard let p=Pixels(image),let t=tile(p) else{return result}
        if let (name,fill)=rarity(p,t) {
            result.rarity=name
            result.gem=gem(p,t,fill:fill)
        }
        func texts(_ r:CGRect)->[String?] {variants.map{ocrSmooth(p,r,low:$0.low,high:$0.high,scale:$0.scale)}}
        // Level: white numerals in the tile's lower right corner.
        let levels=texts(CGRect(x:t.midX+t.width*0.02,y:t.minY+t.height*0.6,width:t.width*0.45,height:t.height*0.36))
        result.level=agreed(levels.map{text in text.flatMap{Int($0.filter(\.isNumber))}.flatMap{(1...999).contains($0) ? $0:nil}})
        // First CRYSTAL STATS line below the tile, right of its small icon.
        let lineRect=CGRect(x:t.midX-t.width*1.22,y:t.maxY+t.height*1.2,width:t.width*3.1,height:t.height*0.38)
        let lines=texts(lineRect)
        result.statLine=lines.compactMap{$0}.first
        let unit=unitShape(p,lineRect)
        let parsed=lines.map{$0.flatMap{parseStatLine($0,unit:unit)}}
        if let stat=agreed(lines.map{$0.flatMap(statName)}),result.gem.map({$0==gemColour(forStat:stat)}) ?? true {
            result.stat=stat
            if let raw=agreed(parsed.map{$0.flatMap{$0.stat==stat ? $0.raw:nil}}) {
                result.rawAmount=raw;result.amount=RewardAmount.parse(raw)
            }
        }
        return result
    }
}
