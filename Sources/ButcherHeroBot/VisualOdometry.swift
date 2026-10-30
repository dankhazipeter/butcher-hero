import Foundation
import CoreGraphics
import CoreVideo
import Vision

struct CameraMotion: Codable {
    let dx: Double
    let dy: Double
    let consensus: Int
    let residual: Double
    let candidates: [[Double]]
    let valid: Bool
}

/// Revision 1 calibrated against known translations; patches verify flow matches.
final class VisualOdometry {
    private let w=318, h=440
    private func resized(_ image:CGImage)->CGImage? {
        guard let c=CGContext(data:nil,width:w,height:h,bitsPerComponent:8,bytesPerRow:w,
              space:CGColorSpaceCreateDeviceGray(),bitmapInfo:0) else{return nil}
        c.draw(image,in:CGRect(x:0,y:0,width:w,height:h));return c.makeImage()
    }
    func measure(previous:CGImage,current:CGImage)->CameraMotion {
        let invalid=CameraMotion(dx:0,dy:0,consensus:0,residual:999,candidates:[],valid:false)
        // Capture occasionally alternates634x878 and637x882. Both are already
        // normalized below; accept only tiny uniform raster-size jitter, not
        // arbitrary window resize or changed aspect ratio.
        let scaleX=Double(current.width)/Double(previous.width)
        let scaleY=Double(current.height)/Double(previous.height)
        guard abs(scaleX-1)<0.012,abs(scaleY-1)<0.012,abs(scaleX-scaleY)<0.002,
              let old=resized(previous),let new=resized(current),
              let a=old.dataProvider?.data,let b=new.dataProvider?.data,
              let p=CFDataGetBytePtr(a),let q=CFDataGetBytePtr(b) else{return invalid}
        let r=VNGenerateOpticalFlowRequest(targetedCGImage:new,options:[:])
        r.revision=VNGenerateOpticalFlowRequestRevision1;r.computationAccuracy = .high
        do{try VNImageRequestHandler(cgImage:old,options:[:]).perform([r])}catch{return invalid}
        guard let buffer=r.results?.first?.pixelBuffer,
              CVPixelBufferGetWidth(buffer)==w,CVPixelBufferGetHeight(buffer)==h else{return invalid}
        CVPixelBufferLockBaseAddress(buffer,.readOnly)
        defer{CVPixelBufferUnlockBaseAddress(buffer,.readOnly)}
        guard let data=CVPixelBufferGetBaseAddress(buffer) else{return invalid}
        let stride=CVPixelBufferGetBytesPerRow(buffer)
        var matches:[[Double]]=[]
        for y in Swift.stride(from:90,to:350,by:8) {
            let flow=data.advanced(by:y*stride).assumingMemoryBound(to:Float.self)
            for x in Swift.stride(from:54,to:258,by:8) {
                if x>112 && x<204 && y>174 && y<274 {continue}
                let gradient=abs(Int(p[y*w+x-2])-Int(p[y*w+x+2]))+abs(Int(p[(y-2)*w+x])-Int(p[(y+2)*w+x]))
                guard gradient>35 else{continue}
                let fx=Double(flow[x*2]),fy=Double(flow[x*2+1])
                guard fx.isFinite,fy.isFinite,abs(fx)<105,abs(fy)<105 else{continue}
                var best=Double.infinity,second=Double.infinity,bx=0,by=0
                var scores:[(Int,Int,Double)]=[]
                for dy in (Int(fy.rounded())-5)...(Int(fy.rounded())+5) {
                    for dx in (Int(fx.rounded())-5)...(Int(fx.rounded())+5) {
                        guard x+dx>5,x+dx<w-6,y+dy>5,y+dy<h-6 else{continue}
                        var error=0
                        for py in -3...3 {for px in -3...3 {
                            error += abs(Int(p[(y+py)*w+x+px])-Int(q[(y+dy+py)*w+x+dx+px]))
                        }}
                        let score=Double(error)/49;scores.append((dx,dy,score))
                        if score<best {best=score;bx=dx;by=dy}
                    }
                }
                for (dx,dy,score) in scores where abs(dx-bx)+abs(dy-by)>3 {second=min(second,score)}
                guard best<14,second>best+2 else{continue}
                matches.append([Double(bx),Double(by),Double(x),Double(y)])
            }
        }
        // Perspective changes displacement across the screen. A robust affine
        // plane models that; a single translation wrongly rejects normal motion.
        func plane(_ a:[Double],_ b:[Double],_ c:[Double],_ index:Int)->[Double]? {
            let x=b[2]-a[2],y=b[3]-a[3],u=c[2]-a[2],v=c[3]-a[3],det=x*v-u*y
            guard abs(det)>400 else{return nil}
            let z=b[index]-a[index],t=c[index]-a[index]
            let k=(z*v-t*y)/det,l=(x*t-u*z)/det
            guard abs(k)<0.3,abs(l)<0.3 else{return nil}
            return [k,l,a[index]-k*a[2]-l*a[3]]
        }
        func value(_ p:[Double],_ x:Double,_ y:Double)->Double {p[0]*x+p[1]*y+p[2]}
        var cluster:[[Double]]=[],bestX:[Double]=[],bestY:[Double]=[]
        var seed:UInt64=17
        if matches.count>=8 {
            for _ in 0..<150 {
                func pick()->[Double]{seed=seed &* 6364136223846793005 &+ 1;return matches[Int((seed>>32)%UInt64(matches.count))]}
                let a=pick(),b=pick(),c=pick()
                guard let px=plane(a,b,c,0),let py=plane(a,b,c,1) else{continue}
                let inliers=matches.filter{hypot($0[0]-value(px,$0[2],$0[3]),$0[1]-value(py,$0[2],$0[3]))<3}
                if inliers.count>cluster.count {cluster=inliers;bestX=px;bestY=py}
            }
        }
        guard cluster.count>=8,Double(cluster.count)>=Double(matches.count)*0.45 else{
            return .init(dx:0,dy:0,consensus:cluster.count,residual:999,candidates:matches.map{[$0[0]*2,$0[1]*2]},valid:false)
        }
        let spreadX=(cluster.map{$0[2]}.max() ?? 0)-(cluster.map{$0[2]}.min() ?? 0)
        let spreadY=(cluster.map{$0[3]}.max() ?? 0)-(cluster.map{$0[3]}.min() ?? 0)
        guard spreadX>65 || spreadY>90 else{return invalid}
        let dx=value(bestX,159,255),dy=value(bestY,159,255)
        let sx=Double(current.width)/Double(w),sy=Double(current.height)/Double(h)
        let residual=cluster.map{hypot($0[0]-value(bestX,$0[2],$0[3]),$0[1]-value(bestY,$0[2],$0[3]))}.reduce(0,+)/Double(cluster.count)*sx
        return .init(dx:dx*sx,dy:dy*sy,consensus:cluster.count,residual:residual,
                     candidates:matches.map{[$0[0]*sx,$0[1]*sy]},valid:true)
    }
}
