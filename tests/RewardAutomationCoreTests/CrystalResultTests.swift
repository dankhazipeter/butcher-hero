import XCTest
import ImageIO
@testable import RewardAutomationCore

/// Opened-crystal log: reviewed CRYSTAL STATS result frames (all five tile colours seen so far,
/// all three crystal colours, four window sizes). Labels were read from the frames by eye.
final class CrystalResultTests:XCTestCase {
    private var project:URL {URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()}
    private func image(_ name:String)throws->CGImage {
        let url=project.appendingPathComponent("docs/references/2026-11-05/crystal-results/\(name)")
        let source=try XCTUnwrap(CGImageSourceCreateWithURL(url as CFURL,nil))
        return try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
    }

    func testReviewedResultFramesNeverGiveAWrongValue()throws {
        // (file, rarity, gem, level, stat, amount as shown). The amount may stay nil when the
        // OCR renderings disagree, but it must never be a different number.
        let samples:[(String,String,String,Int,String,String)]=[
            ("grey-blue-cutdef148k-l41-637.png","grey","blue",41,"Cut Defense","148K"),
            ("blue-green-healthregen20k-l41-637.png","blue","green",41,"Health Regen","20.2K"),
            ("blue-red-cutdmg166k-l41-637.png","blue","red",41,"Cut Damage","166K"),
            ("purple-green-health3780k-623.png","purple","green",40,"Health","3.78M"),
            ("orange-blue-cutdef626k-623.png","orange","blue",40,"Cut Defense","626K"),
            ("green-red-smashdmg189k-623.png","green","red",40,"Smash Damage","189K"),
            ("grey-green-lifesteal6430-788.png","grey","green",40,"Lifesteal","6.43K"),
            ("blue-blue-piercedef291k-642.png","blue","blue",40,"Pierce Defense","291K"),
            // 2026-11-05: two of three renderings read "#12.7K"; the sign is not required.
            ("grey-green-healthregen12700-l41-637.png","grey","green",41,"Health Regen","12.7K"),
            // 2026-11-06: the M looks like an H; OCR read "1.574"/"1.574"/"1.574".
            ("grey-green-health1570k-l41-637.png","grey","green",41,"Health","1.57M"),
        ]
        var amounts=0
        for (name,rarity,gem,level,stat,shown) in samples {
            let r=CrystalResultReader.read(try image(name))
            XCTAssertEqual(r.rarity,rarity,name)
            XCTAssertEqual(r.gem,gem,name)
            XCTAssertEqual(r.level,level,name)
            XCTAssertEqual(r.stat,stat,name)
            if let amount=r.amount {XCTAssertEqual(amount,RewardAmount.parse(shown),name);amounts+=1}
            XCTAssertEqual(CrystalResultReader.gemColour(forStat:stat),gem,"gem colour follows the stat group: \(name)")
        }
        XCTAssertGreaterThanOrEqual(amounts,9,"Most amounts are read, not just left empty")
    }

    func testUnitIsReadFromTheGlyphShape()throws {
        // K: only its arms reach the right edge; M (drawn like an H): a full right stem.
        for (name,unit) in [("grey-blue-cutdef148k-l41-637.png","K"),("purple-green-health3780k-623.png","M"),
                            ("grey-green-health1570k-l41-637.png","M"),("grey-green-lifesteal6430-788.png","K")] {
            let p=try XCTUnwrap(CrystalResultReader.Pixels(try image(name))),t=try XCTUnwrap(CrystalResultReader.tile(p))
            let line=CGRect(x:t.midX-t.width*1.22,y:t.maxY+t.height*1.2,width:t.width*3.1,height:t.height*0.38)
            XCTAssertEqual(CrystalResultReader.unitShape(p,line),unit,name)
        }
    }

    func testStatLineToleratesOCRLettersButNotDigits() {
        XCTAssertEqual(CrystalResultReader.statName("Gut Bamage +105K"),"Cut Damage")
        XCTAssertEqual(CrystalResultReader.statName("‘ Health Regen +12.5K"),"Health Regen")
        XCTAssertEqual(CrystalResultReader.statName("Health +1.51M"),"Health")
        XCTAssertNil(CrystalResultReader.statName("CONTINUE"))
        XCTAssertEqual(CrystalResultReader.parseStatLine("Smash Defense +275K")?.raw,"275K")
        XCTAssertNil(CrystalResultReader.parseStatLine("Health +3.78h"),"An unreadable unit is no amount")
        XCTAssertNil(CrystalResultReader.parseStatLine("Pierce Defense +2S1K"))
        XCTAssertEqual(CrystalResultReader.parseStatLine("Health Regen #12.7K")?.raw,"12.7K","OCR turns + into #")
        XCTAssertEqual(CrystalResultReader.parseStatLine("Health Regen 14.7K")?.raw,"14.7K")
        XCTAssertNil(CrystalResultReader.parseStatLine("Health +1.574"),"A crystal amount always has a unit; this is a misread 1.57M")
        XCTAssertNil(CrystalResultReader.parseStatLine("Cut Defense +G26K"))
        // With the unit read from the glyph's shape (an M here looks like an H).
        XCTAssertEqual(CrystalResultReader.parseStatLine("Health +1.51h",unit:"M")?.raw,"1.51M")
        XCTAssertEqual(CrystalResultReader.parseStatLine("Health +1.574",unit:"M")?.raw,"1.57M")
        XCTAssertEqual(CrystalResultReader.parseStatLine("Health +3.78\"",unit:"M")?.raw,"3.78M")
        XCTAssertEqual(CrystalResultReader.parseStatLine("Health +1.51M",unit:"M")?.raw,"1.51M")
        XCTAssertNil(CrystalResultReader.parseStatLine("Health +1.51K",unit:"M"),"OCR unit must agree with the shape")
        XCTAssertNil(CrystalResultReader.parseStatLine("Health +1518",unit:"M"),"No decimal point: nothing is guessed away")
        XCTAssertNil(CrystalResultReader.parseStatLine("Health +1.51hx",unit:"M"))
    }

    private func journal(_ lines:[[String:String]])throws->URL {
        let root=FileManager.default.temporaryDirectory.appendingPathComponent("crystal-log-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at:root.appendingPathComponent("evidence"),withIntermediateDirectories:true)
        addTeardownBlock{try? FileManager.default.removeItem(at:root)}
        let text=try lines.map{String(decoding:try JSONSerialization.data(withJSONObject:$0),as:UTF8.self)}.joined(separator:"\n")+"\n"
        try text.write(to:root.appendingPathComponent("events.jsonl"),atomically:true,encoding:.utf8)
        return root
    }

    func testRepeatedResultScreenIsOneCrystalButNewStrikesMakeAnother()throws {
        func e(_ id:String,_ event:String,_ message:String,_ t:String,_ evidence:String?=nil)->[String:String] {
            var d=["claimID":id,"event":event,"message":message,"timestamp":"2026-11-05T00:00:\(t)Z"]
            if let evidence {d["evidence"]=evidence}
            return d
        }
        let root=try journal([
            // Re-observed after a blocked Continue: one crystal (3184274F on 2026-11-03).
            e("A","crystal_click_sent","strike","01"),
            e("A","crystal_screen","result; [CONTINUE]","02","evidence/A-result-1.png"),
            e("A","crystal_click_sent","proceed","03"),
            e("A","crystal_screen","result; [CONTINUE]","04","evidence/A-result-2.png"),
            // Continue led to a second geode and new strikes: two crystals (DC8756F5).
            e("B","crystal_click_sent","strike","05"),
            e("B","crystal_screen","result; [CONTINUE]","06","evidence/B-result-1.png"),
            e("B","crystal_click_sent","proceed","07"),
            e("B","crystal_click_sent","strike","08"),
            e("B","crystal_screen","result; [CONTINUE]","09","evidence/B-result-2.png"),
            // A result without any strike is not an opened crystal.
            e("C","crystal_screen","result; [CONTINUE]","10","evidence/C-result-1.png"),
        ])
        let found=CrystalResultLog.pending(journal:root.appendingPathComponent("events.jsonl"))
        XCTAssertEqual(found.map(\.evidence),["evidence/A-result-1.png","evidence/B-result-1.png","evidence/B-result-2.png"])
    }

    func testNewerReaderSupersedesAnIncompleteEntryOnceAndKeepsWhatWasRead()throws {
        let root=try journal([
            ["claimID":"A","event":"crystal_click_sent","message":"strike","timestamp":"2026-11-05T00:00:01.000Z"],
            ["claimID":"A","event":"crystal_screen","message":"result; []","timestamp":"2026-11-05T00:00:02.000Z","evidence":"evidence/A-result.png"],
        ])
        try FileManager.default.copyItem(at:project.appendingPathComponent("docs/references/2026-11-05/crystal-results/grey-green-healthregen12700-l41-637.png"),
                                         to:root.appendingPathComponent("evidence/A-result.png"))
        let results=root.appendingPathComponent("results.jsonl")
        let old=CrystalResultEntry(openedAt:"2026-11-05T00:00:02.000Z",claimID:"A",evidence:"evidence/A-result.png",source:"app",
                                   reader:"crystal-result-v1",readAt:"2026-11-05T00:00:07.000Z",evidenceMissing:nil,
                                   result:CrystalResult(rarity:"grey",gem:"green",level:41,stat:"Health Regen",statLine:"Health Regen #12.7K"))
        try CrystalResultLog.append(old,to:results)
        let before=try Data(contentsOf:results)
        let reread=try CrystalResultLog.update(root:root,results:results,source:"app")
        XCTAssertEqual(reread.count,1)
        XCTAssertTrue(try Data(contentsOf:results).starts(with:before),"The original line stays")
        let loaded=CrystalResultLog.load(results)
        XCTAssertEqual(loaded.count,1,"One crystal, not two")
        XCTAssertEqual(loaded.first?.result.amount,"12700")
        XCTAssertEqual(loaded.first?.result.level,41)
        XCTAssertEqual(CrystalResultLog.lines(results).count,2)
        XCTAssertTrue(try CrystalResultLog.update(root:root,results:results,source:"app").isEmpty,"Each reader version re-reads once")
    }

    func testLogIsAppendOnlyIdempotentAndWaitsForMissingFrames()throws {
        let root=try journal([
            ["claimID":"A","event":"crystal_click_sent","message":"strike","timestamp":"2026-11-05T00:00:01.000Z"],
            ["claimID":"A","event":"crystal_screen","message":"result; []","timestamp":"2026-11-05T00:00:02.000Z","evidence":"evidence/A-result.png"],
        ])
        try FileManager.default.copyItem(at:project.appendingPathComponent("docs/references/2026-11-05/crystal-results/grey-blue-cutdef148k-l41-637.png"),
                                         to:root.appendingPathComponent("evidence/A-result.png"))
        let results=root.appendingPathComponent("results.jsonl")
        let first=try CrystalResultLog.update(root:root,results:results,source:"app")
        XCTAssertEqual(first.count,1)
        XCTAssertEqual(first.first?.result.stat,"Cut Defense")
        let bytes=try Data(contentsOf:results)
        XCTAssertTrue(try CrystalResultLog.update(root:root,results:results,source:"app").isEmpty)
        XCTAssertEqual(try Data(contentsOf:results),bytes,"A second run writes nothing")

        // A frame that is not there yet is skipped, and logged as missing only when old.
        let late=try journal([
            ["claimID":"B","event":"crystal_click_sent","message":"strike","timestamp":"2026-11-05T00:00:01.000Z"],
            ["claimID":"B","event":"crystal_screen","message":"result; []","timestamp":"2026-11-05T00:00:02.000Z","evidence":"evidence/B-result.png"],
        ])
        let lateResults=late.appendingPathComponent("results.jsonl")
        let at=ISO8601DateFormatter().date(from:"2026-11-05T00:00:02Z")!
        XCTAssertTrue(try CrystalResultLog.update(root:late,results:lateResults,source:"app",now:at.addingTimeInterval(30)).isEmpty)
        let missing=try CrystalResultLog.update(root:late,results:lateResults,source:"app",now:at.addingTimeInterval(3600))
        XCTAssertEqual(missing.first?.evidenceMissing,true)
        XCTAssertNil(missing.first?.result.stat)
    }
}
