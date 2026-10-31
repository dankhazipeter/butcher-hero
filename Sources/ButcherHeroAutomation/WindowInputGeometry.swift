import AppKit
import CoreGraphics
import RewardAutomationCore

@MainActor enum WindowInputGeometry {
    static func bounds(windowID:CGWindowID,pid:pid_t)->CGRect? {
        guard let rows=CGWindowListCopyWindowInfo([.optionIncludingWindow],windowID) as? [[String:Any]],
              let row=rows.first(where:{($0[kCGWindowNumber as String] as? NSNumber)?.uint32Value==windowID}),
              (row[kCGWindowOwnerPID as String] as? NSNumber)?.int32Value==pid,
              (row[kCGWindowIsOnscreen as String] as? NSNumber)?.boolValue==true,
              let raw=row[kCGWindowBounds as String] as? [String:Any] else{return nil}
        return CGRect(dictionaryRepresentation:raw as CFDictionary)
    }
    static func displays()->[CGRect] {
        var ids=[CGDirectDisplayID](repeating:0,count:32),count:UInt32=0
        guard CGGetActiveDisplayList(32,&ids,&count) == .success else{return []}
        return ids.prefix(Int(count)).map{CGDisplayBounds($0)}
    }
    static func target(normalized:CGPoint,image:CGImage,capturedWindow:CGRect,windowID:CGWindowID,pid:pid_t)throws->CGPoint {
        let current=bounds(windowID:windowID,pid:pid),active=displays()
        guard NSWorkspace.shared.frontmostApplication?.processIdentifier==pid,
              let current,let point=RewardInputGeometry.target(
            normalized:normalized,imageSize:.init(width:image.width,height:image.height),
            capturedWindow:capturedWindow,currentWindow:current,activeDisplays:active)
        else{throw InputGeometryError("Input geometry rejected;window=\(windowID);captureFrame=\(capturedWindow);quartzFrame=\(String(describing:current));image=\(image.width)x\(image.height);activeDisplays=\(active);foregroundPID=\(NSWorkspace.shared.frontmostApplication?.processIdentifier ?? 0)")}
        return point
    }
    static func verifyCursor(point:CGPoint)throws {
        let actual=CGEvent(source:nil)?.location
        guard let actual,RewardInputGeometry.cursorMatches(expected:point,actual:actual)
        else{throw InputGeometryError("Cursor did not reach intended global point;expected=\(point);actual=\(String(describing:actual));mouse-down cancelled")}
    }
    static func diagnostic(point:CGPoint,image:CGImage,frame:CGRect,windowID:CGWindowID)->String {
        let actual=CGEvent(source:nil)?.location ?? .init(x:Double.nan,y:Double.nan)
        return "quartz-points;window=\(windowID);frame=\(frame);image=\(image.width)x\(image.height);target=\(point);cursor=\(actual);activeDisplays=\(displays())"
    }
}

private struct InputGeometryError:LocalizedError {
    let errorDescription:String?
    init(_ message:String){errorDescription=message}
}
