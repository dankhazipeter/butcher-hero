import Foundation
import ImageIO

@main struct MappingReplayProbe {
    static func main() throws {
        let directory=URL(fileURLWithPath:CommandLine.arguments[1])
        let events=try String(contentsOf:directory.appendingPathComponent("events.jsonl"),encoding:.utf8).split(separator:"\n")
        let map=LocalWorldMap(readOnly:true,load:false)
        var measured=0,rejected=0,overlays=0
        for line in events {
            let event=try JSONSerialization.jsonObject(with:Data(line.utf8)) as! [String:Any]
            let frame=event["frame"] as! Int,a=event["analysis"] as! [String:Any],d=event["decision"] as! [String:Any]
            let url=directory.appendingPathComponent(String(format:"frame-%05d.png",frame))
            guard let source=CGImageSourceCreateWithURL(url as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil) else{continue}
            let settings=(a["titanQuestOCRStrings"] as? [String] ?? []).contains{$0.uppercased().contains("SETTINGS") || $0.uppercased().contains("UNSTUCK")}
            let eligible=(a["hudConfidence"] as? Double ?? 0)>=0.8 && a["popupClose"]==nil && !settings &&
                a["expandedMapVisible"] as? Bool != true && (a["shop"] as? [String:Any])?["visible"] as? Bool != true &&
                !(d["reason"] as? String ?? "").contains("felhasználó aktív")
            let result=map.observe(image,eligible:eligible,evidence:directory.lastPathComponent+"/"+url.lastPathComponent,orangeCoverage:a["orangeRockCoverage"] as? Double)
            if let m=result.motion {if m.valid{measured+=1}else{rejected+=1}}
            if !eligible{overlays+=1}
            if result.status != "measured" && !result.status.contains("scene +") {print(frame,result.chart ?? -1,result.status)}
        }
        let result=map.snapshot()
        print("SUMMARY valid",measured,"rejected",rejected,"suspended",overlays,"last-chart",result.chart ?? -1,"nodes",result.nodes,"edges",result.edges)
    }
}
