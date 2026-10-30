import Foundation
import ImageIO

@main struct ShopInspectorTests {
    static func main() {
        for (run,visible) in [("20260919-134549-e235be81-observe",true),("20260919-134643-0cdd64af-observe",true),("20260919-134512-4922877a-observe",false)] {
            let url=URL(fileURLWithPath:"docs/runs/\(run)/frame-00001.png")
            let image=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(url as CFURL,nil)!,0,nil)!
            let result=ShopInspector().inspect(image,visible:visible)
            print(run,"free:",result.freeButtons.count,"badge:",result.badgeVisible)
            if run.contains("134549") { assert(result.freeButtons.count == 1) }
            if run.contains("134643") { assert(result.freeButtons.isEmpty) }
            if !visible { assert(result.badgeVisible) }
        }
        let bottomURL=URL(fileURLWithPath:"docs/runs/20260919-135240-07d34394-play/frame-00016.png")
        let bottomImage=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(bottomURL as CFURL,nil)!,0,nil)!
        let bottom=ShopInspector().inspect(bottomImage,visible:true)
        assert(bottom.freeButtons.count == 1 && bottom.freeButtons[0].y > 0.875)
        assert(bottom.paidButtons.count >= 2)
        print("PASS: bottom regeneration Free retained, footer-clipped offer excluded, paid successors identified")
        for index in [1,10,120] {
            let path=String(format:"docs/runs/20260919-140618-28e8e880-play/frame-%05d.png",index)
            let image=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil)!,0,nil)!
            assert(!ShopInspector().inspect(image,visible:false).badgeVisible,"red rock is not a shop badge")
        }
        print("PASS: red terrain behind Shop does not trigger a new audit")
        let chestURL=URL(fileURLWithPath:"docs/runs/20260919-144628-b08da881-observe/frame-00000.png")
        let chestImage=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(chestURL as CFURL,nil)!,0,nil)!
        let chest=ShopInspector().inspect(chestImage,visible:true)
        precondition(chest.tab=="chests" && chest.freeButtons.isEmpty)
        print("PASS: chest tab is not a stat Free offer")
    }
}
