import XCTest
import ImageIO
import CryptoKit
@testable import RewardAutomationCore

final class RewardCorpusTests: XCTestCase {
    private struct Corpus: Decodable {
        let schemaVersion: Int
        let review: String
        let samples: [Sample]
    }
    private struct Sample: Decodable {
        let id: String
        let image: String
        let hud: Bool
        let card: Bool
        let kind: String?
        let amount: String?
        let note: String
    }
    private let kinds: Set<String> = ["hp", "regeneration", "piercing_damage", "cutting_damage",
        "smash_damage", "piercing_defense", "cutting_defense", "smash_defense"]
    private var project: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
    }
    private func corpus() throws -> Corpus {
        try JSONDecoder().decode(Corpus.self, from: Data(contentsOf:
            project.appendingPathComponent("tests/reward-reading-corpus.json")))
    }
    func testCorpusIsReviewedDistinctAndCoversEveryRewardAtLeastTwice() throws {
        let corpus = try corpus()
        XCTAssertEqual(corpus.schemaVersion, 1)
        XCTAssertFalse(corpus.review.isEmpty)
        var ids = Set<String>(), images = Set<String>(), hashes = Set<String>()
        var counts: [String: Int] = [:]
        for sample in corpus.samples {
            let label = "\(sample.id): \(sample.image)"
            XCTAssertTrue(ids.insert(sample.id).inserted, "Duplicate fixture ID: \(label)")
            XCTAssertTrue(images.insert(sample.image).inserted, "Duplicate image path: \(label)")
            XCTAssertFalse(sample.note.isEmpty, "Missing visual review: \(label)")
            XCTAssertTrue(sample.image.hasPrefix("docs/references/") || sample.image.hasPrefix("docs/runs/"))
            XCTAssertFalse(sample.image.split(separator: "/").contains(".."))
            let data = try Data(contentsOf: project.appendingPathComponent(sample.image))
            let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            XCTAssertTrue(hashes.insert(hash).inserted, "Duplicating the same bytes is not a second sample: \(label)")
            if let kind = sample.kind {
                XCTAssertTrue(kinds.contains(kind), "Unknown ground-truth kind: \(label)")
                XCTAssertTrue(sample.hud && sample.card, "Positive reward requires HUD and card: \(label)")
                let amount = try XCTUnwrap(sample.amount, "Missing ground-truth amount: \(label)")
                XCTAssertEqual(RewardAmount.parse(amount), amount, "Amount must be canonical: \(label)")
                counts[kind, default: 0] += 1
            } else {
                XCTAssertNil(sample.amount, "Negative image must not invent an amount: \(label)")
            }
        }
        for kind in kinds {
            XCTAssertGreaterThanOrEqual(counts[kind, default: 0], 2, "Need multiple independent images for \(kind)")
        }
        XCTAssertGreaterThanOrEqual(corpus.samples.filter { $0.kind == nil && $0.hud }.count, 3)
        XCTAssertGreaterThanOrEqual(corpus.samples.filter { !$0.hud }.count, 2)
    }
    func testEveryReviewedScreenshotMatchesItsFixedExpectedReading() throws {
        let vision = RewardVision()
        for sample in try corpus().samples {
            let label = "\(sample.id) [\(sample.image)]: \(sample.note)"
            let source = try XCTUnwrap(CGImageSourceCreateWithURL(
                project.appendingPathComponent(sample.image) as CFURL, nil), label)
            let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil), label)
            let actual = try vision.observe(image)
            let diagnostics = "\(label); actual reward=\(String(describing: actual.reward)); OCR=\(actual.texts)"
            XCTAssertEqual(actual.gameHUDVisible, sample.hud, "HUD: \(label)")
            XCTAssertEqual(actual.freeCardVisible, sample.card, "Card presence: \(label)")
            XCTAssertEqual(actual.reward?.kind, sample.kind, "Kind: \(diagnostics)")
            XCTAssertEqual(actual.reward?.amount, sample.amount, "Normalized amount: \(diagnostics)")
            if sample.kind == nil { XCTAssertNil(actual.reward, "Must not create a reward: \(label)") }
        }
    }
}
