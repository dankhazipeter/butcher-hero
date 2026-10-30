import XCTest
import ImageIO
@testable import RewardAutomationCore

final class RewardTests:XCTestCase {
    private var project:URL {URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()}
    private func image(_ path:String)throws->CGImage {
        let source=try XCTUnwrap(CGImageSourceCreateWithURL(project.appendingPathComponent(path) as CFURL,nil))
        return try XCTUnwrap(CGImageSourceCreateImageAtIndex(source,0,nil))
    }
    func testRealFreeDefenseRewardAndNegativeScreens()throws {
        let vision=RewardVision()
        let positive=try vision.observe(image("docs/runs/20261029-224727-a64e5f83-observe/frame-00000.png"))
        XCTAssertEqual(positive.reward?.kind,"cutting_defense","Gold axe inside cyan shield is defense, not damage")
        XCTAssertEqual(positive.reward?.amount,"591")
        let smash=try vision.observe(image("docs/references/2026-10-30/free-smash-680-before.png"))
        XCTAssertEqual(smash.reward?.kind,"smash_damage")
        XCTAssertEqual(smash.reward?.amount,"680")
        for path in ["docs/runs/20261029-223657-10037739-observe/frame-00000.png","docs/references/2026-10-30/reward-stats-top.png","docs/references/2026-10-30/reward-stats-bottom.png"] {
            XCTAssertNil(try vision.observe(image(path)).reward,"No Free click on idle HUD or stats modals")
        }
    }
    func testEightNamedStatsIconsSurviveScaling()throws {
        let classifier=RewardIconClassifier()
        let samples:[(String,String,CGRect)]=[
            ("hp","top",.init(x:309,y:608,width:53,height:56)),
            ("regeneration","top",.init(x:309,y:690,width:53,height:57)),
            ("piercing_damage","top",.init(x:309,y:775,width:53,height:56)),
            ("cutting_damage","top",.init(x:309,y:945,width:53,height:56)),
            ("smash_damage","top",.init(x:309,y:1113,width:53,height:57)),
            ("piercing_defense","bottom",.init(x:309,y:582,width:53,height:56)),
            ("cutting_defense","bottom",.init(x:309,y:753,width:53,height:57)),
            ("smash_defense","bottom",.init(x:309,y:922,width:53,height:57))]
        for (kind,page,rect) in samples {
            let full=try image("docs/references/2026-10-30/reward-stats-\(page).png")
            let crop=try XCTUnwrap(full.cropping(to:rect))
            // Half-resolution capture, as used by the live screenshot pipeline.
            let context=try XCTUnwrap(CGContext(data:nil,width:27,height:29,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue))
            context.interpolationQuality = .high;context.draw(crop,in:.init(x:0,y:0,width:27,height:29))
            let result=classifier.match(try XCTUnwrap(context.makeImage()),rect:.init(x:0,y:0,width:1,height:1))
            XCTAssertEqual(result.kind,kind,"\(kind): error=\(result.error) margin=\(result.margin)")
        }
    }
    func testUserReported18KWithOverlappingWorldTimer()throws {
        let observed=try RewardVision().observe(image("docs/references/2026-10-30/free-hp-18k-occluded.png"))
        XCTAssertEqual(observed.reward?.kind,"hp")
        XCTAssertEqual(observed.reward?.amount,"18000","Merged timer text must not hide18K or become millions")
    }
    func testHealth183KPreservesLeadingDigitAndSuffix()throws {
        let observed=try RewardVision().observe(image("docs/references/2026-10-30/free-health-18-3k-misread.png"))
        XCTAssertEqual(observed.reward?.kind,"hp")
        XCTAssertEqual(observed.reward?.amount,"18300","Not8.3,8300 or a cropped token")
    }
    func testHighContrastNumberFallbackReadsOccluded18K()throws {
        let full=try image("docs/references/2026-10-30/free-hp-18k-occluded.png")
        let vision=RewardVision()
        let observation=try vision.observe(full)
        let reward=try XCTUnwrap(observation.reward)
        let texts=try vision.recognize(full,roi:.init(x:0.065,y:reward.badgeY+0.046,width:0.085,height:0.043),highContrast:true)
        XCTAssertTrue(texts.contains{RewardAmount.parse($0.text)=="18000"},"White-number fallback: \(texts)")
    }
    func testDefenseIconSurvivesSmallOCRBadgeAlignmentDifferences()throws {
        let full=try image("docs/references/2026-10-30/corpus-cutdef593.png")
        let observation=try RewardVision().observe(full)
        let badge=try XCTUnwrap(observation.texts.first{$0.text=="FREE"})
        let rect=CGRect(x:0.025,y:badge.y+badge.height+0.001,width:0.100,height:0.052)
        for dy in [-2.0,0,2.0] {
            let match=RewardIconClassifier().match(full,rect:rect.offsetBy(dx:0,dy:dy/Double(full.height)))
            XCTAssertEqual(match.kind,"cutting_defense","dy=\(dy); error=\(match.error); margin=\(match.margin)")
        }
    }
    func testGreenTerrainMustNotHideSmashDamageOrDefense()throws {
        for suffix in ["a","b","c"] {
            let observation=try RewardVision().observe(image("docs/references/2026-10-30/free-smash-688-green-\(suffix).png"))
            XCTAssertEqual(observation.reward?.kind,"smash_damage","Same hammer, no shield; green terrain is not part of its silhouette")
            XCTAssertEqual(observation.reward?.amount,"688")
        }
        let defense=try RewardVision().observe(image("docs/references/2026-10-30/free-smash-defense-809-green.png"))
        XCTAssertEqual(defense.reward?.kind,"smash_defense","Shield must remain distinguishable")
        XCTAssertEqual(defense.reward?.amount,"809")
    }
    func testCurrentRunReconcilePreservesHistoryAndExistingCorrections()throws {
        let dir=FileManager.default.temporaryDirectory.appendingPathComponent("butcher-current-reconcile-\(UUID().uuidString)")
        let root=dir.appendingPathComponent("data/free-rewards")
        try FileManager.default.createDirectory(at:root,withIntermediateDirectories:true)
        defer{try? FileManager.default.removeItem(at:dir)}
        try FileManager.default.copyItem(at:project.appendingPathComponent("docs/references/2026-10-30/free-smash-688-green-a.png"),to:root.appendingPathComponent("before.png"))
        let unknown=FreeReward(kind:"unknown",amount:"688",rawAmount:"688",classification:"fixture",texts:[],tapX:0.07,tapY:0.64,badgeX:0.02,badgeY:0.58,iconFeatures:[:])
        let fixed=FreeReward(kind:"smash_damage",amount:"688",rawAmount:"688",classification:"fixture",texts:[],tapX:0.07,tapY:0.64,badgeX:0.02,badgeY:0.58,iconFeatures:[:])
        func row(_ event:String,_ time:String,_ id:String?,_ reward:FreeReward?)throws->[String:Any] {
            var result:[String:Any]=["schemaVersion":1,"event":event,"timestamp":"2026-10-30T\(time).000Z","runID":"fixture"]
            if let id {result["claimID"]=id;result["evidence"]="before.png"}
            if let reward {result["reward"]=try JSONSerialization.jsonObject(with:JSONEncoder().encode(reward))}
            return result
        }
        let records=try [row("click_sent","10:00:00","old",unknown),row("watcher_started","10:01:00",nil,nil),
            row("click_sent","10:02:00","current",unknown),row("claim_confirmed_ui","10:02:02","current",unknown),
            row("click_sent","10:03:00","done",unknown),row("claim_confirmed_ui","10:03:02","done",unknown),
            row("reward_corrected","10:03:03","done",fixed)]
        var bytes=Data()
        for record in records {bytes.append(try JSONSerialization.data(withJSONObject:record));bytes.append(10)}
        let log=root.appendingPathComponent("events.jsonl");try bytes.write(to:log)
        let process=Process(),pipe=Pipe()
        process.executableURL=project.appendingPathComponent(".build/debug/ButcherHeroAutomation")
        process.currentDirectoryURL=dir;process.arguments=["reconcile","--current-run"];process.standardOutput=pipe
        try process.run();_=pipe.fileHandleForReading.readDataToEndOfFile();process.waitUntilExit()
        XCTAssertEqual(process.terminationStatus,0)
        let final=try Data(contentsOf:log)
        XCTAssertEqual(final.prefix(bytes.count),bytes,"Original events must be byte-for-byte preserved")
        let rows=try String(decoding:final,as:UTF8.self).split(separator:"\n").map{try JSONSerialization.jsonObject(with:Data($0.utf8)) as! [String:Any]}
        XCTAssertEqual(rows.count,8)
        XCTAssertEqual(rows.last?["event"] as? String,"reward_corrected")
        XCTAssertEqual(rows.last?["claimID"] as? String,"current")
        XCTAssertEqual((rows.last?["reward"] as? [String:Any])?["kind"] as? String,"smash_damage")
        XCTAssertEqual(rows.filter{($0["event"] as? String)=="claim_confirmed_ui"}.count,2,"No invented confirmations")
    }
    func testGreenGrassIsNotAFreeBadgeButActualBadgesAre()throws {
        let absent=try image("docs/references/2026-10-30/free-absent-grass-false-positive.jpg")
        let observed=try RewardVision().observe(absent)
        XCTAssertTrue(observed.gameHUDVisible)
        XCTAssertNil(observed.reward)
        XCTAssertFalse(observed.freeCardVisible,"Green grass alone must not block confirmation forever")
        for path in ["docs/references/2026-10-30/free-health-18-3k-misread.png",
                     "docs/references/2026-10-30/free-578-moving-before.png",
                     "docs/references/2026-10-30/free-hp-18k-occluded.png"] {
            XCTAssertTrue(try Pixels(image(path)).hasFreeBadge(),"Keep conservative presence protection on real green FREE badges")
        }
    }
    func testHeldMouseAndReleaseCooldown(){
        XCTAssertFalse(RewardInputPolicy.permitsClick(anyButtonDown:true,secondsSinceButtonActivity:100))
        XCTAssertFalse(RewardInputPolicy.permitsClick(anyButtonDown:false,secondsSinceButtonActivity:0.1))
        XCTAssertTrue(RewardInputPolicy.permitsClick(anyButtonDown:false,secondsSinceButtonActivity:0.25))
        XCTAssertTrue(RewardInputPolicy.permitsClick(anyButtonDown:false,secondsSinceButtonActivity:10))
    }
    func testVisibleCardRetriesAfterOneSecondAndOnlyAbsenceConfirms(){
        var verification=RewardClaimVerification(sentAt:100)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:true,matchingOfferVisible:true,now:100.9),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:true,matchingOfferVisible:true,now:101),.retry)
        // A retry creates a new verification, not a permanent reservation.
        verification=RewardClaimVerification(sentAt:101)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:true,matchingOfferVisible:true,now:102),.retry)
        verification=RewardClaimVerification(sentAt:102)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:false,matchingOfferVisible:false,now:103),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:false,matchingOfferVisible:false,now:104),.confirm)
    }
    func testOccludedHUDAndUnreadableVisibleCardNeverConfirmOrRetry(){
        var verification=RewardClaimVerification(sentAt:100)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:false,matchingOfferVisible:false,now:101),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:false,cardVisible:false,matchingOfferVisible:false,now:102),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:false,matchingOfferVisible:false,now:103),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:true,matchingOfferVisible:false,now:104),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:false,matchingOfferVisible:false,now:105),.wait)
        XCTAssertEqual(verification.observe(gameHUDVisible:true,cardVisible:true,matchingOfferVisible:true,now:106),.retry)
    }
    func testActualFailed578CardAndSuccessful18KDisappearance()throws {
        let vision=RewardVision()
        for suffix in ["before","unconfirmed"] {
            let observation=try vision.observe(image("docs/references/2026-10-30/free-578-moving-\(suffix).png"))
            XCTAssertEqual(observation.reward?.kind,"cutting_defense")
            XCTAssertEqual(observation.reward?.amount,"578")
            XCTAssertTrue(observation.freeCardVisible)
        }
        let after=try vision.observe(image("docs/references/2026-10-30/free-18k-confirmed-after.png"))
        XCTAssertTrue(after.gameHUDVisible)
        XCTAssertNil(after.reward)
        XCTAssertFalse(after.freeCardVisible,"Successful +18K proof must not still contain a Free card")
    }
    func testStatsCountsRetriedClaimOnceAndOnlyInFinalAttemptInterval()throws {
        let directory=FileManager.default.temporaryDirectory.appendingPathComponent("butcher-retry-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        defer{try? FileManager.default.removeItem(at:directory)}
        let reward=FreeReward(kind:"cutting_defense",amount:"578",rawAmount:"578",classification:"fixture",texts:[],tapX:0.07,tapY:0.64,badgeX:0.02,badgeY:0.58,iconFeatures:[:])
        let encoded=try JSONSerialization.jsonObject(with:JSONEncoder().encode(reward))
        let events=[("retry","click_sent","00"),("retry","click_not_confirmed","01"),
            ("retry","click_sent","02"),("retry","claim_confirmed_ui","04"),
            ("pending","click_sent","05"),("pending","click_sent","07")]
        var log=Data()
        for (id,event,second) in events {
            let object:[String:Any]=["schemaVersion":1,"claimID":id,"event":event,
                "timestamp":"2026-10-30T10:00:\(second).000Z","runID":"fixture","reward":encoded]
            log.append(try JSONSerialization.data(withJSONObject:object));log.append(10)
        }
        let path=directory.appendingPathComponent("events.jsonl");try log.write(to:path)
        func stats(_ from:String,_ to:String)throws->[String:Any] {
            let process=Process(),pipe=Pipe()
            process.executableURL=project.appendingPathComponent(".build/debug/ButcherHeroAutomation")
            process.arguments=["stats","--log",path.path,"--from","2026-10-30T10:00:\(from).000Z","--to","2026-10-30T10:00:\(to).000Z"]
            process.standardOutput=pipe
            try process.run()
            let data=pipe.fileHandleForReading.readDataToEndOfFile();process.waitUntilExit()
            XCTAssertEqual(process.terminationStatus,0)
            return try XCTUnwrap(JSONSerialization.jsonObject(with:data) as? [String:Any])
        }
        let full=try stats("00","10")
        XCTAssertEqual(full["click_attempts"] as? Int,4)
        XCTAssertEqual(full["confirmed_ui_claims"] as? Int,1)
        XCTAssertEqual(full["unconfirmed_or_pending"] as? Int,1)
        XCTAssertEqual((full["totals"] as? [String:String])?["cutting_defense"],"578")
        let failedInterval=try stats("00","01")
        XCTAssertEqual(failedInterval["click_attempts"] as? Int,1)
        XCTAssertEqual(failedInterval["confirmed_ui_claims"] as? Int,0)
        let successInterval=try stats("02","03")
        XCTAssertEqual(successInterval["confirmed_ui_claims"] as? Int,1)
        XCTAssertEqual((successInterval["totals"] as? [String:String])?["cutting_defense"],"578")
    }
    func testAbortedPreClickValidationCanRetryButSentClicksStayBlocked(){
        let reward=FreeReward(kind:"hp",amount:"18000",rawAmount:"18K",classification:"fixture",texts:[],tapX:0.07,tapY:0.64,badgeX:0.02,badgeY:0.58,iconFeatures:[:])
        var gate=RewardGate();gate.reserve(reward)
        XCTAssertFalse(gate.permits(reward))
        gate.releaseUnsent(reward)
        XCTAssertTrue(gate.permits(reward),"A click rejected before input must not deadlock the visible offer")
        gate.reserve(reward);gate.observe(reward);gate.observe(reward)
        XCTAssertFalse(gate.permits(reward),"A sent click is not released by observing the same card")
    }
    func testRewardNumbersPreserveMagnitudeAndRejectTimersPricesAndNoise(){
        for (text,value) in [("591","591"),("+1,25M","1250000"),("1.5K","1500"),("473M","473000000"),("0.5","0.5"),("18.3К","18300")] {
            XCTAssertEqual(RewardAmount.parse(text),value)
        }
        for text in ["3h 12m","200 gems","FREE","1.2%","740GKC","-12","0",""]{XCTAssertNil(RewardAmount.parse(text))}
    }
    func testUnchangedOfferCannotBeClickedTwiceOrByRestart(){
        let r=FreeReward(kind:"hp",amount:"591",rawAmount:"591",classification:"fixture",texts:[],tapX:0.1,tapY:0.6,badgeX:0.02,badgeY:0.55,iconFeatures:[:])
        var gate=RewardGate();XCTAssertTrue(gate.permits(r));gate.reserve(r)
        XCTAssertFalse(gate.permits(r));gate.observe(nil);gate.observe(r);XCTAssertFalse(gate.permits(r))
        let uncertain=FreeReward(kind:"unknown",amount:"591",rawAmount:"591",classification:"uncertain frame",texts:[],tapX:0.1,tapY:0.6,badgeX:0.02,badgeY:0.55,iconFeatures:[:])
        XCTAssertFalse(gate.permits(uncertain),"An unstable icon label must not allow another click")
        var restored=RewardGate(blockedFingerprint:gate.blockedFingerprint);XCTAssertFalse(restored.permits(r))
        restored.observe(nil);restored.observe(nil);XCTAssertFalse(restored.permits(r));restored.observe(nil);XCTAssertTrue(restored.permits(r))
    }
}
