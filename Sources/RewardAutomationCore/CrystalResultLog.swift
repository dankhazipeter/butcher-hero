import Foundation
import CoreGraphics
import ImageIO

/// One opened crystal, as logged in `crystal-rewards/results.jsonl` (append-only).
public struct CrystalResultEntry:Codable,Equatable {
    public var schemaVersion=1
    public var event="crystal_result_read"
    /// When the CRYSTAL STATS result screen was seen (UTC ISO 8601).
    public let openedAt:String
    public let claimID:String
    /// Result frame, relative to the crystal journal folder of `source`.
    public let evidence:String
    /// "app" for the native app's journal, "cli" for the older command-line collector's.
    public let source:String
    public let reader:String
    public let readAt:String
    /// The frame had already been pruned when the log caught up: the crystal is counted,
    /// its kind stays unknown.
    public var evidenceMissing:Bool?
    public let result:CrystalResult
}

/// Turns the crystal journal's result screens into one log line per opened crystal.
/// Runs offline on saved frames only; it never touches the collector or sends input.
public enum CrystalResultLog {
    public struct Pending:Equatable {
        public let claimID:String,timestamp:String,evidence:String
    }

    /// Result screens that are new crystals. Within one transaction a result counts only if a
    /// strike was sent since the previous counted result: a result frame re-observed after a
    /// timeout or a retried Continue is the same crystal, a result after new strikes is the next.
    public static func pending(journal:URL)->[Pending] {
        guard let text=try? String(contentsOf:journal,encoding:.utf8) else{return []}
        var struck:[String:Bool]=[:],found:[Pending]=[]
        for line in text.split(separator:"\n") {
            guard let object=try? JSONSerialization.jsonObject(with:Data(line.utf8)) as? [String:Any],
                  let id=object["claimID"] as? String,let event=object["event"] as? String else{continue}
            let message=object["message"] as? String ?? ""
            if event=="crystal_click_sent",message.hasPrefix("strike") {struck[id]=true}
            if event=="crystal_screen",message.hasPrefix("result"),struck[id]==true,
               let evidence=object["evidence"] as? String,let timestamp=object["timestamp"] as? String {
                found.append(.init(claimID:id,timestamp:timestamp,evidence:evidence))
                struck[id]=false
            }
        }
        return found
    }

    /// Every line of the log, oldest first, including superseded re-reads.
    public static func lines(_ results:URL)->[CrystalResultEntry] {
        guard let text=try? String(contentsOf:results,encoding:.utf8) else{return []}
        let decoder=JSONDecoder()
        return text.split(separator:"\n").compactMap{try? decoder.decode(CrystalResultEntry.self,from:Data($0.utf8))}
    }

    /// One entry per opened crystal: a later line for the same frame (a re-read by a newer
    /// reader) supersedes the earlier one, so corrections stay append-only.
    public static func load(_ results:URL)->[CrystalResultEntry] {
        var latest:[String:Int]=[:],entries:[CrystalResultEntry]=[]
        for entry in lines(results) {
            let key=entry.source+"/"+entry.evidence
            if let index=latest[key] {entries[index]=entry} else {latest[key]=entries.count;entries.append(entry)}
        }
        return entries
    }

    static func complete(_ r:CrystalResult)->Bool {
        r.rarity != nil && r.gem != nil && r.level != nil && r.stat != nil && r.amount != nil
    }

    /// Fields read before are kept; the newer reading only fills what was missing.
    static func merged(_ old:CrystalResult,_ new:CrystalResult)->CrystalResult {
        var r=new
        r.rarity=old.rarity ?? new.rarity;r.gem=old.gem ?? new.gem;r.level=old.level ?? new.level
        if old.stat != nil {r.stat=old.stat;r.amount=old.amount ?? (new.stat==old.stat ? new.amount:nil)
            r.rawAmount=old.rawAmount ?? (new.stat==old.stat ? new.rawAmount:nil)}
        r.statLine=old.statLine ?? new.statLine
        return r
    }

    static func stamp(_ date:Date=Date())->String {
        let f=ISO8601DateFormatter();f.formatOptions=[.withInternetDateTime,.withFractionalSeconds];return f.string(from:date)
    }

    /// Appends one line under an exclusive lock with O_APPEND and fsync, like the journals.
    static func append(_ entry:CrystalResultEntry,to results:URL)throws {
        let encoder=JSONEncoder();encoder.outputFormatting=[.sortedKeys,.withoutEscapingSlashes]
        var data=try encoder.encode(entry);data.append(10)
        let fd=open(results.path,O_CREAT|O_WRONLY|O_APPEND,mode_t(0o600))
        guard fd>=0 else{throw NSError(domain:"CrystalResultLog",code:1,userInfo:[NSLocalizedDescriptionKey:"results.jsonl cannot be opened"])}
        defer{close(fd)}
        guard flock(fd,LOCK_EX)==0 else{throw NSError(domain:"CrystalResultLog",code:2,userInfo:[NSLocalizedDescriptionKey:"results.jsonl cannot be locked"])}
        defer{flock(fd,LOCK_UN)}
        let written=data.withUnsafeBytes{write(fd,$0.baseAddress,$0.count)}
        guard written==data.count,fsync(fd)==0 else{throw NSError(domain:"CrystalResultLog",code:3,userInfo:[NSLocalizedDescriptionKey:"results.jsonl write failed"])}
    }

    /// Reads every not yet logged crystal of `root/events.jsonl` and appends it to `results`;
    /// incomplete entries of an older reader are re-read once and superseded by a new line.
    /// A frame that is missing is logged as missing only once it is older than `missingAfter`
    /// (it may still be being written). Returns the new entries.
    @discardableResult
    public static func update(root:URL,results:URL,source:String,missingAfter:TimeInterval=600,now:Date=Date())throws->[CrystalResultEntry] {
        var existing:[String:CrystalResultEntry]=[:]
        for entry in load(results) where entry.source==source {existing[entry.evidence]=entry}
        let parser=ISO8601DateFormatter();parser.formatOptions=[.withInternetDateTime,.withFractionalSeconds]
        var added:[CrystalResultEntry]=[]
        for item in pending(journal:root.appendingPathComponent("events.jsonl")) {
            let url=root.appendingPathComponent(item.evidence)
            let image=CGImageSourceCreateWithURL(url as CFURL,nil).flatMap{CGImageSourceCreateImageAtIndex($0,0,nil)}
            if let old=existing[item.evidence] {
                // Re-read an incomplete entry once per newer reader, if its frame still exists.
                guard old.evidenceMissing != true,!complete(old.result),old.reader != CrystalResultReader.version,let image else{continue}
                let entry=CrystalResultEntry(openedAt:old.openedAt,claimID:old.claimID,evidence:old.evidence,source:source,
                                             reader:CrystalResultReader.version,readAt:stamp(now),evidenceMissing:nil,
                                             result:merged(old.result,CrystalResultReader.read(image)))
                try append(entry,to:results)
                added.append(entry)
                continue
            }
            var result=CrystalResult(),missing:Bool?=nil
            if let image {
                result=CrystalResultReader.read(image)
            } else {
                guard let at=parser.date(from:item.timestamp),now.timeIntervalSince(at)>missingAfter else{continue}
                missing=true
            }
            let entry=CrystalResultEntry(openedAt:item.timestamp,claimID:item.claimID,evidence:item.evidence,source:source,
                                         reader:CrystalResultReader.version,readAt:stamp(now),evidenceMissing:missing,result:result)
            try append(entry,to:results)
            added.append(entry)
        }
        return added
    }
}
