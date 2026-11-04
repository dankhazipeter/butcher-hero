import AppKit
import CoreImage

// Renders the 1024×1024 app icon used to build AppIcon.icns.
// Based on the installed game's own icon (never committed to the repo) with an
// "automatic" badge; falls back to a plain symbol icon when the game isn't installed.
// Usage: swift scripts/make-app-icon.swift <output.png>
let size=CGFloat(1024)
let gameBundleID="com.multicastgames.butcher"
// macOS icon grid: 824 pt rounded square centred on the 1024 canvas.
let tile=NSRect(x:100,y:100,width:824,height:824)
let tilePath=NSBezierPath(roundedRect:tile,xRadius:185,yRadius:185)

/// Largest AppIcon PNG inside the game bundle, upscaled with Lanczos and lightly sharpened.
func gameArtwork()->CGImage? {
    guard let app=NSWorkspace.shared.urlForApplication(withBundleIdentifier:gameBundleID),
          let files=FileManager.default.enumerator(at:app,includingPropertiesForKeys:nil) else{return nil}
    var best:(CGImage,Int)?
    for case let url as URL in files where url.lastPathComponent.hasPrefix("AppIcon") && url.pathExtension=="png" {
        if let source=CGImageSourceCreateWithURL(url as CFURL,nil),let image=CGImageSourceCreateImageAtIndex(source,0,nil),
           image.width>(best?.1 ?? 0) {best=(image,image.width)}
    }
    guard let (image,width)=best else{return nil}
    let scale=tile.width/CGFloat(width)
    var ci=CIImage(cgImage:image).applyingFilter("CILanczosScaleTransform",parameters:[kCIInputScaleKey:scale,kCIInputAspectRatioKey:1])
    ci=ci.applyingFilter("CIUnsharpMask",parameters:[kCIInputRadiusKey:2.5,kCIInputIntensityKey:0.6])
    return CIContext().createCGImage(ci,from:CGRect(x:0,y:0,width:tile.width,height:tile.height))
}

let image=NSImage(size:NSSize(width:size,height:size))
image.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high

// Soft drop shadow like system icons.
let shadow=NSShadow();shadow.shadowBlurRadius=24;shadow.shadowOffset=NSSize(width:0,height:-10)
shadow.shadowColor=NSColor.black.withAlphaComponent(0.28)
NSGraphicsContext.saveGraphicsState();shadow.set()
NSColor(srgbRed:0.98,green:0.80,blue:0.05,alpha:1).setFill();tilePath.fill()
NSGraphicsContext.restoreGraphicsState()

NSGraphicsContext.saveGraphicsState()
tilePath.addClip()
if let art=gameArtwork() {
    NSImage(cgImage:art,size:tile.size).draw(in:tile)
} else {
    NSGradient(starting:NSColor(srgbRed:1,green:0.84,blue:0.1,alpha:1),ending:NSColor(srgbRed:0.95,green:0.66,blue:0.0,alpha:1))!.draw(in:tilePath,angle:-90)
    let config=NSImage.SymbolConfiguration(pointSize:430,weight:.black).applying(.init(paletteColors:[.black]))
    if let symbol=NSImage(systemSymbolName:"figure.martial.arts",accessibilityDescription:nil)?.withSymbolConfiguration(config) {
        let s=symbol.size;symbol.draw(in:NSRect(x:(size-s.width)/2,y:(size-s.height)/2+20,width:s.width,height:s.height))
    }
}
// Subtle inner edge so the artwork reads as a tile on light and dark Docks.
NSColor.black.withAlphaComponent(0.18).setStroke();tilePath.lineWidth=6;tilePath.stroke()
NSGraphicsContext.restoreGraphicsState()

// "Automatic" badge: game-red disc, white ring, white cycle arrows.
let badge=NSRect(x:612,y:92,width:330,height:330)
NSGraphicsContext.saveGraphicsState()
let badgeShadow=NSShadow();badgeShadow.shadowBlurRadius=18;badgeShadow.shadowOffset=NSSize(width:0,height:-6)
badgeShadow.shadowColor=NSColor.black.withAlphaComponent(0.35);badgeShadow.set()
NSColor.white.setFill();NSBezierPath(ovalIn:badge).fill()
NSGraphicsContext.restoreGraphicsState()
NSGradient(starting:NSColor(srgbRed:0.93,green:0.20,blue:0.17,alpha:1),ending:NSColor(srgbRed:0.72,green:0.08,blue:0.08,alpha:1))!
    .draw(in:NSBezierPath(ovalIn:badge.insetBy(dx:18,dy:18)),angle:-90)
let glyph=NSImage.SymbolConfiguration(pointSize:170,weight:.bold).applying(.init(paletteColors:[.white]))
if let arrows=NSImage(systemSymbolName:"arrow.triangle.2.circlepath",accessibilityDescription:nil)?.withSymbolConfiguration(glyph) {
    let s=arrows.size
    arrows.draw(in:NSRect(x:badge.midX-s.width/2,y:badge.midY-s.height/2,width:s.width,height:s.height))
}
image.unlockFocus()

let rep=NSBitmapImageRep(data:image.tiffRepresentation!)!
try! rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:CommandLine.arguments[1]))
