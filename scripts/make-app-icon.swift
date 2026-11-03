import AppKit

// Renders the app icon PNG (1024×1024) used to build AppIcon.icns.
// Usage: swift scripts/make-app-icon.swift <output.png>
let size=CGFloat(1024)
let image=NSImage(size:NSSize(width:size,height:size))
image.lockFocus()
let rect=NSRect(x:0,y:0,width:size,height:size).insetBy(dx:100,dy:100)
let path=NSBezierPath(roundedRect:rect,xRadius:185,yRadius:185)
NSGradient(starting:NSColor(srgbRed:0.20,green:0.45,blue:0.22,alpha:1),ending:NSColor(srgbRed:0.09,green:0.24,blue:0.12,alpha:1))!
    .draw(in:path,angle:-90)
let config=NSImage.SymbolConfiguration(pointSize:430,weight:.semibold).applying(.init(paletteColors:[.white]))
if let symbol=NSImage(systemSymbolName:"gift.fill",accessibilityDescription:nil)?.withSymbolConfiguration(config) {
    let s=symbol.size
    symbol.draw(in:NSRect(x:(size-s.width)/2,y:(size-s.height)/2,width:s.width,height:s.height))
}
image.unlockFocus()
let rep=NSBitmapImageRep(data:image.tiffRepresentation!)!
try! rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:CommandLine.arguments[1]))
