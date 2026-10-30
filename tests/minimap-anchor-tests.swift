import Foundation
import ImageIO

@main struct AnchorTests {
    static func main() {
        let detector=MinimapAnchorDetector()
        let paths=["20260919-140122-71600bcd-play/frame-00021.png","20260919-142112-1f558f77-play/frame-00013.png","20260919-143043-e66f36f1-play/frame-00068.png","20260919-142548-c23344e4-play/frame-00034.png"]
        for path in paths {
            let image=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(URL(fileURLWithPath:"docs/runs/"+path) as CFURL,nil)!,0,nil)!
            let pose=detector.detect(image,playerX:554,playerY:129)
            print(path,pose.map{String(data:try! JSONEncoder().encode($0),encoding:.utf8)!} ?? "none")
            let weapon=detector.detectVenom(image,playerX:554,playerY:129)
            print("weapon",weapon.map{String(data:try! JSONEncoder().encode($0),encoding:.utf8)!} ?? "none")
            if path.contains("140122") {precondition(weapon != nil && abs(weapon!.landmarkX-544.5)<2 && abs(weapon!.landmarkY-139)<2)}
            if path.contains("140122") {precondition(pose != nil && abs(pose!.landmarkX-540)<2 && abs(pose!.landmarkY-73.5)<2)}
            if path.contains("00034") {precondition(pose==nil,"dark modal cannot locate world")}
        }
    }
}
