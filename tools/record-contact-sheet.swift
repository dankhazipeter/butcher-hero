import AppKit

// Read-only visual index of a recording. Original PNGs remain untouched.
let args=Array(CommandLine.arguments.dropFirst())
guard args.count>=2 else{fatalError("output.png input.png ...")}
let files=Array(args.dropFirst()),cols=6,tw=190,th=285
let rows=(files.count+cols-1)/cols
let canvas=NSImage(size:NSSize(width:cols*tw,height:rows*th))
canvas.lockFocus()
NSColor.black.setFill();NSRect(x:0,y:0,width:cols*tw,height:rows*th).fill()
for (i,path) in files.enumerated() {
    guard let image=NSImage(contentsOfFile:path) else{continue}
    let x=(i%cols)*tw,y=(rows-1-i/cols)*th
    image.draw(in:NSRect(x:x,y:y+20,width:tw,height:th-20))
    (URL(fileURLWithPath:path).deletingPathExtension().lastPathComponent as NSString).draw(
        at:NSPoint(x:x+3,y:y+2),withAttributes:[.foregroundColor:NSColor.white,.font:NSFont.monospacedSystemFont(ofSize:12,weight:.regular)])
}
canvas.unlockFocus()
guard let data=canvas.tiffRepresentation,let rep=NSBitmapImageRep(data:data),let png=rep.representation(using:.png,properties:[:]) else{fatalError("render failed")}
try png.write(to:URL(fileURLWithPath:args[0]))
