import Foundation
import ImageIO
import UniformTypeIdentifiers
import RewardAutomationCore

/// Same line schema as the old `data/*/events.jsonl` journals, so old tools can read it.
struct JournalEvent:Codable {
    let schemaVersion:Int
    let event:String,timestamp:String,runID:String
    let claimID:String?
    let reward:FreeReward?
    let evidence:String?
    let message:String?
}

enum JournalDomain:String,CaseIterable {
    case free,crystal,event
    var label:String {
        switch self {case .free:L("Free","Free");case .crystal:L("Kristály","Crystal");case .event:L("Esemény","Event")}
    }
    var root:URL {
        switch self {case .free:AppPaths.free;case .crystal:AppPaths.crystal;case .event:AppPaths.event}
    }
}

enum AppPaths {
    static let root:URL = {
        let base=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0]
        return base.appendingPathComponent("Butcher Hero",isDirectory:true)
    }()
    static let free=root.appendingPathComponent("free-rewards",isDirectory:true)
    static let crystal=root.appendingPathComponent("crystal-rewards",isDirectory:true)
    static let event=root.appendingPathComponent("event-dismissals",isDirectory:true)
    static let statSession=root.appendingPathComponent("stat-session.json")
    static let evidenceRetention:TimeInterval=7*24*3600
}

enum Stamp {
    // Formatter creation is expensive (ICU); ISO8601DateFormatter is thread-safe, so share them.
    private static let fractional:ISO8601DateFormatter={
        let f=ISO8601DateFormatter();f.formatOptions=[.withInternetDateTime,.withFractionalSeconds];return f
    }()
    private static let plain=ISO8601DateFormatter()
    static func string(_ date:Date=Date())->String {fractional.string(from:date)}
    static func date(_ text:String)->Date? {
        fractional.date(from:text) ?? plain.date(from:text)
    }
}

/// Append-only JSONL journal with fsync per line, plus evidence images next to it.
final class Journal {
    let root:URL,runID=UUID().uuidString
    private let encoder=JSONEncoder(),handle:FileHandle
    /// Called on the main actor after every durable append.
    var onAppend:((JournalEvent)->Void)?

    init(root:URL)throws {
        self.root=root
        try FileManager.default.createDirectory(at:root.appendingPathComponent("evidence"),withIntermediateDirectories:true)
        let fd=open(root.appendingPathComponent("events.jsonl").path,O_CREAT|O_WRONLY|O_APPEND,mode_t(0o600))
        guard fd>=0 else{throw AppError("A napló nem nyitható meg: \(root.path)")}
        handle=FileHandle(fileDescriptor:fd,closeOnDealloc:true)
        encoder.outputFormatting=[.sortedKeys,.withoutEscapingSlashes]
    }
    deinit{try? handle.close()}

    var eventsURL:URL {root.appendingPathComponent("events.jsonl")}

    func append(_ event:String,claimID:String?=nil,reward:FreeReward?=nil,evidence:String?=nil,message:String?=nil,at:Date=Date())throws {
        let e=JournalEvent(schemaVersion:1,event:event,timestamp:Stamp.string(at),runID:runID,claimID:claimID,reward:reward,evidence:evidence,message:message)
        var data=try encoder.encode(e);data.append(10)
        guard flock(handle.fileDescriptor,LOCK_EX)==0 else{throw AppError("A napló nem zárolható.")}
        defer{flock(handle.fileDescriptor,LOCK_UN)}
        try handle.write(contentsOf:data);try handle.synchronize()
        onAppend?(e)
    }

    func image(_ image:CGImage,id:String,suffix:String)throws->String {
        let relative="evidence/\(id)-\(suffix).png",url=root.appendingPathComponent(relative)
        guard let destination=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)
        else{throw AppError("Bizonyítékkép nem menthető.")}
        CGImageDestinationAddImage(destination,image,nil)
        guard CGImageDestinationFinalize(destination) else{throw AppError("Bizonyítékkép mentése sikertelen.")}
        return relative
    }

    static func read(_ url:URL)->(events:[JournalEvent],malformed:Int) {
        guard let text=try? String(contentsOf:url,encoding:.utf8) else{return ([],0)}
        var events:[JournalEvent]=[],malformed=0
        let decoder=JSONDecoder()
        for line in text.split(separator:"\n") {
            if let e=try? decoder.decode(JournalEvent.self,from:Data(line.utf8)) {events.append(e)} else {malformed+=1}
        }
        return (events,malformed)
    }

    /// Deletes evidence images older than the retention window; the journal lines stay.
    static func pruneEvidence(in roots:[URL],olderThan age:TimeInterval=AppPaths.evidenceRetention) {
        let cutoff=Date().addingTimeInterval(-age),fm=FileManager.default
        for root in roots {
            let folder=root.appendingPathComponent("evidence")
            guard let files=try? fm.contentsOfDirectory(at:folder,includingPropertiesForKeys:[.contentModificationDateKey]) else{continue}
            for file in files where file.pathExtension=="png" {
                if let date=try? file.resourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate,date<cutoff {
                    try? fm.removeItem(at:file)
                }
            }
        }
    }
}
