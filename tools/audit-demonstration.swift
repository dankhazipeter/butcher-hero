import Foundation
import ImageIO

// Offline only: dense image-measured tracks, broken on unverified transitions.
// Output is evidence, NOT an automatically approved navigable corridor.
@main struct AuditDemonstration {
    static func main() throws {
        let a=Array(CommandLine.arguments.dropFirst())
        guard a.count==4,let start=Int(a[1]),let end=Int(a[2]),start<end else {
            fatalError("record-directory first-frame last-frame output.json")
        }
        let odometry=VisualOdometry()
        var previous:CGImage?,x=0.0,y=0.0,segment=0
        var points:[[String:Any]]=[]
        for frame in start...end {
            let name=String(format:"frame-%05d.png",frame)
            let url=URL(fileURLWithPath:a[0]).appendingPathComponent(name)
            guard let src=CGImageSourceCreateWithURL(url as CFURL,nil),
                  let image=CGImageSourceCreateImageAtIndex(src,0,nil) else{fatalError("missing \(name)")}
            var item:[String:Any]=["frame":frame,"image":url.path]
            if let previous {
                let m=odometry.measure(previous:previous,current:image)
                let accepted=m.valid && hypot(m.dx,m.dy)<200
                item["valid"]=accepted;item["consensus"]=m.consensus;item["residual"]=m.residual
                item["measuredDx"] = -m.dx;item["measuredDy"] = -m.dy
                if accepted {x-=m.dx;y-=m.dy}
                else {segment+=1;x=0;y=0;item["breakReason"]="unverified image transition; no bridging"}
            }
            item["segment"]=segment;item["x"]=x;item["y"]=y;points.append(item)
            previous=image
        }
        let result:[String:Any]=["source":a[0],"first":start,"last":end,
            "status":"offline measured evidence; not approved for blind replay",
            "segments":segment+1,"points":points]
        try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys])
            .write(to:URL(fileURLWithPath:a[3]),options:.atomic)
        print("Measured \(points.count) frames, \(segment+1) independent segments: \(a[3])")
    }
}
