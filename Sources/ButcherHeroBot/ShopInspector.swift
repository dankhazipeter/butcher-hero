import Foundation
import CoreGraphics
import Vision

struct ShopFreeButton: Codable {
    let x: Double
    let y: Double
    let label: String
}

struct ShopObservation: Codable {
    let visible: Bool
    let badgeVisible: Bool
    let freeButtons: [ShopFreeButton]
    var paidButtons: [ShopFreeButton] = []
    let contentKey: String
    let texts: [String]
    var tab: String? = nil
}

final class ShopInspector {
    func inspect(_ image: CGImage, visible: Bool) -> ShopObservation {
        let w = image.width, h = image.height
        guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
            bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return .init(visible: visible, badgeVisible: false, freeButtons: [], contentKey: "", texts: [])
        }
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        let pixels = ctx.data!.assumingMemoryBound(to: UInt8.self)
        func fraction(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double,
                      test: (Int, Int, Int) -> Bool) -> Double {
            var hits = 0, n = 0
            for yy in max(0, Int((y-ry)*Double(h)))..<min(h, Int((y+ry)*Double(h))) {
                for xx in max(0, Int((x-rx)*Double(w)))..<min(w, Int((x+rx)*Double(w))) {
                    let i = (yy*w+xx)*4
                    if test(Int(pixels[i]), Int(pixels[i+1]), Int(pixels[i+2])) { hits += 1 }
                    n += 1
                }
            }
            return Double(hits) / Double(max(1,n))
        }
        let red: (Int,Int,Int)->Bool = { r,g,b in r > 190 && g < 110 && b < 110 && r > g+90 }
        let green: (Int,Int,Int)->Bool = { r,g,b in g > 150 && r < 155 && b < 145 && g > r+55 }
        let badge = fraction(0.98,0.486,0.015,0.012,test:red) > 0.12 &&
            fraction(0.98,0.486,0.015,0.012,test:{r,g,b in r>220 && g>220 && b>220}) > 0.025 &&
            fraction(0.947,0.506,0.03,0.014,test:{ r,g,b in g > 70 && r < 110 && b < 110 && g > r+20 }) > 0.12
        guard visible else { return .init(visible:false,badgeVisible:badge,freeButtons:[],contentKey:"",texts:[]) }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.005
        try? VNImageRequestHandler(cgImage:image,options:[:]).perform([request])
        let boxes = (request.results ?? []).compactMap { observation -> (String,CGRect)? in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            let b = observation.boundingBox
            return (candidate.string,CGRect(x:b.minX,y:1-b.maxY,width:b.width,height:b.height))
        }
        var buttons: [ShopFreeButton] = []
        for (text,box) in boxes where text.trimmingCharacters(in:.whitespacesAndNewlines).lowercased() == "free" {
            let x = box.midX, y = box.midY
            // Fully visible first-column stat button. Blue FREE art, FREE IN,
            // OPEN QUESTS, ads, gem prices and footer-clipped buttons cannot pass.
            guard x > 0.22, x < 0.40, y > 0.16, y < 0.895,
                  fraction(x,y,0.060,0.021,test:green) > 0.30,
                  fraction(x+0.075,y-0.022,0.018,0.015,test:red) > 0.05 else { continue }
            let stat = boxes.filter { $0.1.midX < 0.4 && $0.1.midY < y && $0.1.midY > y-0.19 && $0.0.contains("+") }
                .max { $0.1.midY < $1.1.midY }?.0 ?? "stat"
            buttons.append(.init(x:x,y:y,label:"Free \(stat)"))
        }
        let content = boxes.filter { $0.1.midX > 0.21 && $0.1.midX < 0.79 && $0.1.midY > 0.18 && $0.1.midY < 0.91 }
            .map { $0.0 }.filter { !$0.contains("h ") && !$0.contains("m ") && !$0.uppercased().contains("K") }.sorted().joined(separator:"|")
        var result = ShopObservation(visible:true,badgeVisible:badge,freeButtons:buttons.sorted{$0.y < $1.y},
                                     contentKey:content,texts:boxes.map{$0.0})
        let dark:(Int,Int,Int)->Bool={r,g,b in r<170 && g<140 && b<120}
        if fraction(0.28,0.945,0.025,0.004,test:dark)>0.55 {result.tab="stats"}
        else if fraction(0.428,0.945,0.025,0.004,test:dark)>0.55 {result.tab="chests"}
        // Chest Free offers may start an ad. The stat collector never claims them.
        if result.tab != "stats" {
            return ShopObservation(visible:true,badgeVisible:badge,freeButtons:[],contentKey:content,texts:boxes.map{$0.0},tab:result.tab)
        }
        result.paidButtons = boxes.compactMap { text,box in
            let digits=text.filter(\.isNumber)
            guard box.midX > 0.22,box.midX < 0.40,box.midY > 0.16,box.midY < 0.895,
                  !digits.isEmpty,text.count <= digits.count+2,
                  fraction(box.midX,box.midY,0.06,0.021,test:{r,g,b in r>190 && g>130 && b<100}) > 0.25 else {return nil}
            return ShopFreeButton(x:box.midX,y:box.midY,label:digits)
        }
        return result
    }
}
