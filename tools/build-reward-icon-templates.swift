import Foundation
import ImageIO
import UniformTypeIdentifiers
import Darwin

// Targeted current-HUD calibration. Coordinates are the recorded FREE badge
// bottom plus0.001, exactly as used by RewardVision. Other templates stay intact.
if CommandLine.arguments.contains("--current-smash-only") {
    let current:[(String,String,Double)]=[
        ("smash_damage","docs/references/2026-10-30/free-smash-688-green-a.png",0.6005699232803566),
        ("smash_defense","docs/references/2026-10-30/free-smash-defense-809-green.png",0.6008839419575099)
    ]
    for (kind,path,y) in current {
        let target="Sources/RewardAutomationCore/Resources/RewardIcons/\(kind)_current.png"
        guard let source=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil),
              let image=CGImageSourceCreateImageAtIndex(source,0,nil),
              let crop=image.cropping(to:CGRect(x:Double(image.width)*0.025,y:Double(image.height)*y,width:Double(image.width)*0.100,height:Double(image.height)*0.052).integral),
              let out=CGImageDestinationCreateWithURL(URL(fileURLWithPath:target) as CFURL,UTType.png.identifier as CFString,1,nil) else{fatalError(kind)}
        CGImageDestinationAddImage(out,crop,nil)
        guard CGImageDestinationFinalize(out) else{fatalError(kind)}
    }
    print("Two current-HUD smash references calibrated from visually verified real cards.")
    exit(0)
}

// Calibrated from the two user-supplied 1246x1726 stats screenshots.
let sources=["docs/references/2026-10-30/reward-stats-top.png","docs/references/2026-10-30/reward-stats-bottom.png"]
let icons:[(String,Int,CGRect)]=[
    ("hp",0,CGRect(x:309,y:608,width:53,height:56)),
    ("regeneration",0,CGRect(x:309,y:690,width:53,height:57)),
    ("piercing_damage",0,CGRect(x:309,y:775,width:53,height:56)),
    ("cutting_damage",0,CGRect(x:309,y:945,width:53,height:56)),
    ("smash_damage",0,CGRect(x:309,y:1113,width:53,height:57)),
    ("piercing_defense",1,CGRect(x:309,y:582,width:53,height:56)),
    ("cutting_defense",1,CGRect(x:309,y:753,width:53,height:57)),
    ("smash_defense",1,CGRect(x:309,y:922,width:53,height:57))
]
let directory=URL(fileURLWithPath:"Sources/RewardAutomationCore/Resources/RewardIcons")
try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
for (kind,index,rect) in icons {
    guard let s=CGImageSourceCreateWithURL(URL(fileURLWithPath:sources[index]) as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(s,0,nil),let crop=image.cropping(to:rect),
          let out=CGImageDestinationCreateWithURL(directory.appendingPathComponent(kind+".png") as CFURL,UTType.png.identifier as CFString,1,nil) else{fatalError(kind)}
    CGImageDestinationAddImage(out,crop,nil);guard CGImageDestinationFinalize(out) else{fatalError(kind)}
}
print("Eight labelled icon references extracted; percentage variants excluded.")

// Independently inspected real Free cards: full shield/handle geometry and HUD background.
let live:[(String,String)]=[
    ("cutting_defense","data/free-rewards/evidence/89E6513B-89F9-4D01-96D3-92F42040F8C3-before.png"),
    ("piercing_defense","data/free-rewards/evidence/1B8ED547-4EC8-4CCD-B405-B77E3925EC3E-before.png"),
    ("smash_defense","data/free-rewards/evidence/8D4443D2-BE1D-49B8-BB28-6116B0B433D5-before.png"),
    ("piercing_damage","data/free-rewards/evidence/43FBCC0B-5B0A-4ACD-BC10-F89FE3BEAE73-before.png"),
    ("smash_damage","data/free-rewards/evidence/81FBCA4B-E142-4BBC-ACFA-E3477D63E416-before.png"),
    ("hp","data/free-rewards/evidence/B3644615-053D-4135-9A56-91D737199ACC-before.png")]
for (kind,path) in live {
    guard let s=CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(s,0,nil),
          let crop=image.cropping(to:CGRect(x:Double(image.width)*0.025,y:Double(image.height)*0.602,width:Double(image.width)*0.100,height:Double(image.height)*0.052).integral),
          let out=CGImageDestinationCreateWithURL(directory.appendingPathComponent(kind+"_live.png") as CFURL,UTType.png.identifier as CFString,1,nil) else{continue}
    CGImageDestinationAddImage(out,crop,nil);guard CGImageDestinationFinalize(out) else{fatalError(kind)}
}
