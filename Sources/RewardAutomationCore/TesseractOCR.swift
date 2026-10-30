import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct OCRWord {
    let text:String
    let confidence:Float
    let rect:CGRect
}

enum TesseractOCR {
    static var executable:URL? {
        let folders=(ProcessInfo.processInfo.environment["PATH"] ?? "").split(separator:":").map(String.init)
            + ["/opt/homebrew/bin","/usr/local/bin"]
        return folders.map{URL(fileURLWithPath:$0).appendingPathComponent("tesseract")}
            .first{FileManager.default.isExecutableFile(atPath:$0.path)}
    }
    static func parseTSV(_ text:String)->[OCRWord] {
        text.split(separator:"\n").compactMap {line in
            let fields=line.split(separator:"\t",maxSplits:11,omittingEmptySubsequences:false)
            guard fields.count==12,fields[0]=="5",let x=Double(fields[6]),let y=Double(fields[7]),
                  let width=Double(fields[8]),let height=Double(fields[9]),let confidence=Float(fields[10]),
                  x>=0,y>=0,width>0,height>0,confidence>=0,confidence<=100,!fields[11].isEmpty else{return nil}
            return OCRWord(text:String(fields[11]),confidence:confidence/100,
                           rect:CGRect(x:x,y:y,width:width,height:height))
        }
    }
    static func recognize(_ image:CGImage)throws->[OCRWord] {
        guard let executable else{throw NSError(domain:"RewardOCR",code:1,userInfo:[NSLocalizedDescriptionKey:"Tesseract is required: brew install tesseract"])}
        guard let bytes=CFDataCreateMutable(nil,0),
              let destination=CGImageDestinationCreateWithData(bytes,UTType.png.identifier as CFString,1,nil) else{return []}
        CGImageDestinationAddImage(destination,image,nil)
        guard CGImageDestinationFinalize(destination) else{return []}
        let process=Process(),input=Pipe(),output=Pipe()
        process.executableURL=executable
        process.arguments=["stdin","stdout","--psm","7","-l","eng",
            "-c","load_system_dawg=0","-c","load_freq_dawg=0","tsv"]
        process.standardInput=input;process.standardOutput=output;process.standardError=FileHandle.nullDevice
        var environment=ProcessInfo.processInfo.environment;environment["OMP_THREAD_LIMIT"]="1"
        process.environment=environment
        try process.run()
        let deadline=DispatchWorkItem{if process.isRunning {process.terminate()}}
        DispatchQueue.global().asyncAfter(deadline:.now()+3,execute:deadline)
        defer{deadline.cancel();if process.isRunning {process.terminate()}}
        try input.fileHandleForWriting.write(contentsOf:bytes as Data)
        try input.fileHandleForWriting.close()
        let result=output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus==0 else{throw NSError(domain:"RewardOCR",code:2,userInfo:[NSLocalizedDescriptionKey:"Tesseract failed or exceeded the3s deadline; no reward inferred."])}
        return parseTSV(String(decoding:result,as:UTF8.self))
    }
}
