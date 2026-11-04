import AppKit
import SwiftUI

enum Format {
    private static var hu:Locale {AppLanguage.current.locale}
    static func percent(_ fraction:Double)->String {
        fraction.formatted(.percent.precision(.fractionLength(1)).locale(hu))
    }

    /// 19000 → "19K", 1712345 → "1,7M": truncated, one decimal only for short heads.
    static func compact(_ value:Decimal)->String {
        let n=NSDecimalNumber(decimal:value).doubleValue
        let units:[(Double,String)]=[(1e12,"T"),(1e9,"B"),(1e6,"M"),(1e3,"K")]
        for (size,suffix) in units where abs(n)>=size {
            let head=n/size
            if abs(head)<100 {
                let truncated=(head*10).rounded(.towardZero)/10
                let text=truncated==truncated.rounded(.towardZero) ? String(Int(truncated)):String(format:"%.1f",truncated).replacingOccurrences(of:".",with:AppLanguage.current == .hu ? ",":".")
                return text+suffix
            }
            return String(Int(head.rounded(.towardZero)))+suffix
        }
        return exact(value)
    }
    static func exact(_ value:Decimal)->String {
        let f=NumberFormatter();f.locale=hu;f.numberStyle = .decimal;f.maximumFractionDigits=2
        if AppLanguage.current == .hu {f.groupingSeparator="\u{202F}"}
        return f.string(from:NSDecimalNumber(decimal:value)) ?? "\(value)"
    }
    static func rate(_ total:Decimal,from:Date,to:Date)->String {
        let ms=max(1,to.timeIntervalSince(from)*1000)
        let perMinute=(NSDecimalNumber(decimal:total).doubleValue*60000/ms*100).rounded(.towardZero)/100
        return compact(Decimal(perMinute))
    }
    static func time(_ date:Date)->String {date.formatted(.dateTime.hour(.twoDigits(amPM:.omitted)).minute(.twoDigits).second(.twoDigits))}
    static func dateTime(_ date:Date)->String {
        date.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).hour(.twoDigits(amPM:.omitted)).minute(.twoDigits).second(.twoDigits).locale(hu))
    }
    static func shortDateTime(_ date:Date)->String {
        date.formatted(.dateTime.month(.twoDigits).day(.twoDigits).hour(.twoDigits(amPM:.omitted)).minute(.twoDigits).second(.twoDigits).locale(hu))
    }
    static func duration(_ seconds:TimeInterval)->String {
        var rest=Int(max(0,seconds))
        let d=rest/86400;rest%=86400
        let h=rest/3600;rest%=3600
        let m=rest/60,s=rest%60
        var parts:[String]=[]
        if d>0 {parts.append(L("\(d) nap","\(d) d"))}
        if h>0 {parts.append(L("\(h) óra","\(h) h"))}
        if m>0 {parts.append(L("\(m) perc","\(m) min"))}
        parts.append(L("\(s) mp","\(s) s"))
        return parts.joined(separator:" ")
    }
}

extension Color {
    init(light:String,dark:String) {
        self.init(nsColor:NSColor(name:nil){appearance in
            let hex=appearance.bestMatch(from:[.darkAqua,.aqua]) == .darkAqua ? dark:light
            var value:UInt64=0;Scanner(string:hex.replacingOccurrences(of:"#",with:"")).scanHexInt64(&value)
            return NSColor(srgbRed:CGFloat((value>>16)&0xff)/255,green:CGFloat((value>>8)&0xff)/255,blue:CGFloat(value&0xff)/255,alpha:1)
        })
    }
}

enum KindStyle {
    static func color(_ kind:String)->Color {
        switch kind {
        case "hp":Color(light:"#d74c62",dark:"#f08a99")
        case "regeneration":Color(light:"#2b8a65",dark:"#75d0a2")
        case "piercing_damage":Color(light:"#0b80aa",dark:"#75c7e3")
        case "cutting_damage":Color(light:"#aa7611",dark:"#efc879")
        case "smash_damage":Color(light:"#7961bd",dark:"#bba2ee")
        case "piercing_defense":Color(light:"#326cb6",dark:"#8db7ff")
        case "cutting_defense":Color(light:"#bb693c",dark:"#f6ac81")
        case "smash_defense":Color(light:"#a44889",dark:"#ed98d3")
        default:.secondary
        }
    }
    static func dash(_ kind:String)->[CGFloat] {
        switch kind {
        case "regeneration":[7,3];case "cutting_damage":[2,3];case "piercing_defense":[8,3,2,3]
        case "cutting_defense":[5,3];case "smash_defense":[1,4];default:[]
        }
    }
    @MainActor private static var icons:[String:NSImage]=[:]
    /// Loaded once per kind; views ask for icons on every render.
    @MainActor static func icon(_ kind:String)->NSImage? {
        if let cached=icons[kind] {return cached}
        let image=Bundle.module.url(forResource:kind,withExtension:"png",subdirectory:"Icons").flatMap(NSImage.init(contentsOf:))
        icons[kind]=image
        return image
    }
}
