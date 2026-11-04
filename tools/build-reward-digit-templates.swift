import Foundation
import ImageIO

@main struct BuildDigits {
    static func main()throws {
        if CommandLine.arguments.contains("--inspect") {
            let names=CommandLine.arguments.dropFirst(2)
            for name in names.isEmpty ? ["corpus-piercedef616.png","free-hp-18k-occluded.png"]:Array(names) {
                let url=URL(fileURLWithPath:"docs/references/2026-10-30/"+name)
                let source=CGImageSourceCreateWithURL(url as CFURL,nil)!
                let image=CGImageSourceCreateImageAtIndex(source,0,nil)!
                print(name,try RewardNumberReader.shapes(image).map{$0.rect})
                print(try RewardNumberReader().read(image,diagnostics:{print($0)}) as Any)
            }
            return
        }
        let samples:[(String,String)]=[
            ("corpus-cut550.png","550"),("corpus-regen81.png","81"),
            ("corpus-pierce540.png","540"),("corpus-piercedef611.png","611"),
            ("free-578-moving-before.png","578"),("corpus-cutdef593.png","593"),
            ("free-health-18-3k-misread.png","18.3K"),("free-smash-680-before.png","680"),
            ("corpus-smashdef802.png","802"),("free-smash-defense-809-green.png","809"),
            ("corpus-piercedef616.png","616"),("free-hp-18k-occluded.png","18K"),
            ("corpus-regen83-current.png","83"),
            // Visually reviewed user screenshot; the575live frames remain held out.
            ("../2026-10-31/external-pierce567-user.png","567"),
            // Five visually reviewed calibrations at the observed font sizes;
            // separate grass/snow521 and large692 frames remain held out.
            ("../2026-10-31/reward-audit/pierce521-calibration.png","521"),
            ("../2026-10-31/reward-audit/smash692-small-calibration.png","692"),
            ("../2026-10-31/reward-audit/smash692-large-calibration.png","692"),
            ("../2026-10-31/reward-audit/health18100-font-calibration.png","18.1K"),
            ("../2026-10-31/reward-audit/health18600-font-calibration.png","18.6K"),
            // Visually verified card and +549 after-frame. Only its missing9
            // variant is added; the already accepted5/4 are left unchanged.
            ("../2026-11-01/pierce549-calibration.png","549"),
            // The game's "Low Quality" graphics: 3 lost its margin over 8 (0.126 vs 0.151).
            // Only this frame's 3 is added; low-quality 631 and 823 stay held out.
            ("../2026-11-04/low-quality-smash713.png","713"),
            // Purple dungeon floor, 2026-11-04 evening: 3 vs 9 (0.128/0.149) and 5 vs 9
            // (0.134/0.167) missed the margin. Card and +633/+591 after-frames reviewed.
            // Only the failing middle 3 and the 5 are added (the final 3 also made 598's 9
            // ambiguous); each claim's other frame is checked, not calibrated.
            ("../2026-11-04/piercedef633-calibration.png","633"),
            ("../2026-11-04/pierce591-calibration.png","591"),
            // The new 3 left 598's 9 (0.097, reviewed +598 after-frame) only 0.030 ahead of
            // it; this claim's 9 is added, two other 598 claims stay separate checks.
            ("../2026-11-04/cutdef598-nine-calibration.png","598")]
        var templates=[DigitTemplate]()
        for (name,label) in samples {
            let url=URL(fileURLWithPath:"docs/references/2026-10-30/"+name)
            guard let source=CGImageSourceCreateWithURL(url as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil) else{fatalError(name)}
            let shapes=try RewardNumberReader.shapes(image)
            print("\(name) expected=\(label) count=\(shapes.count) shapes=\(shapes.map{String(format:"%.4f/%.4f",$0.rect.width,$0.rect.height)})")
            guard shapes.count==label.count else{fatalError("Reviewed label and segmented glyph count disagree: \(name)")}
            for (index,(character,shape)) in zip(label,shapes).enumerated() where character != "." {
                if name=="../2026-11-01/pierce549-calibration.png",character != "9" {continue}
                if name=="../2026-11-04/low-quality-smash713.png",character != "3" {continue}
                if name=="../2026-11-04/piercedef633-calibration.png",index != 1 {continue}
                if name=="../2026-11-04/pierce591-calibration.png",character != "5" {continue}
                if name=="../2026-11-04/cutdef598-nine-calibration.png",character != "9" {continue}
                templates.append(.init(character:String(character),aspect:shape.aspect,bits:shape.bits))
            }
        }
        let chars=Set(templates.map{$0.character})
        guard Set("0123456789K".map(String.init)).isSubset(of:chars) else{fatalError("Missing digits: \(chars)")}
        let encoder=JSONEncoder();encoder.outputFormatting=[.sortedKeys]
        try encoder.encode(templates).write(to:URL(fileURLWithPath:"Sources/RewardAutomationCore/Resources/RewardDigits/digits.json"))
        print("Calibrated\(templates.count)glyphs from visually reviewed labels; no expected test values changed.")
    }
}
