import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

@main struct CropProbe {
    static func main(){
        let path=CommandLine.arguments[1]
        let image=CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithURL(URL(fileURLWithPath:path) as CFURL,nil)!,0,nil)!
        let crop=image.cropping(to:CGRect(x:480,y:45,width:150,height:165))!
        let c=CGContext(data:nil,width:600,height:660,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        c.interpolationQuality = .none;c.draw(crop,in:CGRect(x:0,y:0,width:600,height:660))
        let url=URL(fileURLWithPath:".build/minimap-crop.png")
        let d=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)!
        CGImageDestinationAddImage(d,c.makeImage()!,nil);CGImageDestinationFinalize(d)
    }
}
