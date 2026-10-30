import AppKit
import ApplicationServices
import CoreGraphics
import Darwin
import Foundation
import ImageIO
import ScreenCaptureKit
import UniformTypeIdentifiers
import Vision

private let gameBundleIdentifier = "com.multicastgames.butcher"
private let gameNameFragment = "butcher hero"

private struct Options {
    enum Mode: String {
        case observe
        case play
        case replay
        case nudge
        case tap
        case scroll
        case mapPan = "map-pan"
        case record
    }

    var mode: Mode = .observe
    var seconds: Double = 15
    var frames: Int = 3
    var interval: Double = 0.30
    var saveEvery: Int = 10
    var debug = false
    var foreground = false
    var minUserIdle: Double = 1.5
    var controlledBossTrials = false
    var shopOnly = false
    var kitingTrial = false
    var replayPath: String?
    var replayNavigationPath: String?
    var replayPlayerPath: String?
    var nudgeX = 0.0
    var nudgeY = 0.0
    var nudgeSteps = 1
    var nudgeDuration = 0.62
    var tapX: Double?
    var tapY: Double?

    static func parse(_ arguments: [String]) throws -> Options {
        var result = Options()
        var index = 0

        if let first = arguments.first, let mode = Mode(rawValue: first) {
            result.mode = mode
            index = 1
        }

        if result.mode == .replay, index < arguments.count, !arguments[index].hasPrefix("-") {
            result.replayPath = arguments[index]
            index += 1
        }

        while index < arguments.count {
            let argument = arguments[index]
            func value() throws -> String {
                guard index + 1 < arguments.count else {
                    throw BotError.badArguments("Hiányzó érték: \(argument)")
                }
                index += 1
                return arguments[index]
            }

            switch argument {
            case "--seconds":
                guard let parsed = Double(try value()), parsed > 0 else {
                    throw BotError.badArguments("A --seconds pozitív szám legyen.")
                }
                result.seconds = parsed
            case "--frames":
                guard let parsed = Int(try value()), parsed > 0 else {
                    throw BotError.badArguments("A --frames pozitív egész legyen.")
                }
                result.frames = parsed
            case "--interval":
                guard let parsed = Double(try value()), parsed >= 0.05 else {
                    throw BotError.badArguments("A --interval legalább 0.05 legyen.")
                }
                result.interval = parsed
            case "--save-every":
                guard let parsed = Int(try value()), parsed >= 0 else {
                    throw BotError.badArguments("A --save-every nemnegatív egész legyen.")
                }
                result.saveEvery = parsed
            case "--debug":
                result.debug = true
            case "--foreground":
                result.foreground = true
            case "--min-user-idle":
                guard let parsed = Double(try value()), parsed >= 0 else {
                    throw BotError.badArguments("A --min-user-idle nemnegatív szám legyen.")
                }
                result.minUserIdle = parsed
            case "--controlled-boss-trials":
                result.controlledBossTrials = true
            case "--shop-only":
                result.shopOnly = true
            case "--kite-boss":
                result.kitingTrial = true
                result.controlledBossTrials = true
            case "--replay-navigation-state":
                guard result.mode == .replay else {
                    throw BotError.badArguments("A --replay-navigation-state csak replay módban használható.")
                }
                result.replayNavigationPath = try value()
            case "--replay-player-state":
                guard result.mode == .replay else {
                    throw BotError.badArguments("A --replay-player-state csak replay módban használható.")
                }
                result.replayPlayerPath = try value()
            case "--dx":
                guard let parsed = Double(try value()) else {
                    throw BotError.badArguments("A --dx szám legyen.")
                }
                result.nudgeX = parsed
            case "--dy":
                guard let parsed = Double(try value()) else {
                    throw BotError.badArguments("A --dy szám legyen.")
                }
                result.nudgeY = parsed
            case "--steps":
                guard let parsed = Int(try value()), parsed > 0 else {
                    throw BotError.badArguments("A --steps pozitív egész legyen.")
                }
                result.nudgeSteps = parsed
            case "--duration":
                guard let parsed = Double(try value()), parsed >= 0.10 else {
                    throw BotError.badArguments("A --duration legalább 0.10 legyen.")
                }
                result.nudgeDuration = parsed
            case "--x":
                guard let parsed = Double(try value()), parsed >= 0 else {
                    throw BotError.badArguments("A --x nemnegatív szám legyen.")
                }
                result.tapX = parsed
            case "--y":
                guard let parsed = Double(try value()), parsed >= 0 else {
                    throw BotError.badArguments("A --y nemnegatív szám legyen.")
                }
                result.tapY = parsed
            case "--help", "-h":
                printUsageAndExit()
            default:
                throw BotError.badArguments("Ismeretlen kapcsoló: \(argument)")
            }
            index += 1
        }
        return result
    }
}

private enum BotError: LocalizedError {
    case badArguments(String)
    case gameWindowMissing
    case captureFailed(String)
    case imageConversionFailed
    case inputPermissionMissing

    var errorDescription: String? {
        switch self {
        case .badArguments(let message): return message
        case .gameWindowMissing:
            return "Nem találom a futó Butcher Hero játékablakot. Indítsd el és hagyd láthatóan."
        case .captureFailed(let message): return "Nem sikerült képet készíteni: \(message)"
        case .imageConversionFailed: return "Nem sikerült a képet elemezhető pixelekké alakítani."
        case .inputPermissionMissing:
            return "A bot nem kapott Kisegítő lehetőségek (Accessibility) engedélyt, ezért nem küldhet swipe-okat."
        }
    }
}

private struct PixelImage {
    let width: Int
    let height: Int
    let rgba: [UInt8]

    init(_ image: CGImage) throws {
        let imageWidth = image.width
        let imageHeight = image.height
        var storage = [UInt8](repeating: 0, count: imageWidth * imageHeight * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue |
            CGImageAlphaInfo.premultipliedLast.rawValue

        let drewImage = storage.withUnsafeMutableBytes { bytes -> Bool in
            guard let context = CGContext(
                data: bytes.baseAddress,
                width: imageWidth,
                height: imageHeight,
                bitsPerComponent: 8,
                bytesPerRow: imageWidth * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else { return false }

            // A ScreenCaptureKit CGImage első memóriasora már a kép teteje.
            context.interpolationQuality = .none
            context.draw(image, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
            return true
        }

        guard drewImage else { throw BotError.imageConversionFailed }
        width = imageWidth
        height = imageHeight
        rgba = storage
    }

    func color(x: Int, y: Int) -> (r: Int, g: Int, b: Int) {
        let offset = (y * width + x) * 4
        return (Int(rgba[offset]), Int(rgba[offset + 1]), Int(rgba[offset + 2]))
    }

    func safestTouchAnchor() -> Vector2 {
        // A játék a játéktér bármely üres pontjáról induló swipe-ot elfogadja.
        // Több, az alsó fegyversor fölötti jelöltből a leginkább fűszínű, tehát
        // takarópaneltől, időzítőtől és tereptárgytól legszabadabb foltot választjuk.
        let candidates = [
            // A nagy előtéri falomb a kép alsó 2/3-át teljesen lefedheti, és
            // színben ugyanúgy fűzöld, ezért a régi pontozás tévesen tökéletes
            // érintési felületnek látta. Felső-középső alternatívák kellenek;
            // az enyhe függőleges tie-break lent ezeket választja azonos
            // fűpontszámnál.
            Vector2(x: 0.50, y: 0.52),
            Vector2(x: 0.35, y: 0.50),
            Vector2(x: 0.65, y: 0.50),
            Vector2(x: 0.72, y: 0.52),
            Vector2(x: 0.25, y: 0.52),
            Vector2(x: 0.50, y: 0.67),
            Vector2(x: 0.38, y: 0.66),
            Vector2(x: 0.62, y: 0.66),
            Vector2(x: 0.50, y: 0.61),
            Vector2(x: 0.30, y: 0.62),
            Vector2(x: 0.70, y: 0.62),
            Vector2(x: 0.38, y: 0.57),
            Vector2(x: 0.62, y: 0.57),
            // Island 2-n a középső képet gyakran szekér, ház vagy előtéri
            // szikla takarja. A jobb alsó narancs udvarok ilyenkor üres,
            // megbízható érintési felületet adnak a fegyversor fölött.
            Vector2(x: 0.78, y: 0.58),
            Vector2(x: 0.80, y: 0.68),
            Vector2(x: 0.82, y: 0.74),
            Vector2(x: 0.72, y: 0.74)
        ]

        func score(_ candidate: Vector2) -> Double {
            let centerX = Int(candidate.x * Double(width))
            let centerY = Int(candidate.y * Double(height))
            var grass = 0
            var orangeGround = 0
            var dark = 0
            var vividUI = 0
            var paleCover = 0
            var samples = 0
            for y in stride(from: max(0, centerY - 22), through: min(height - 1, centerY + 22), by: 3) {
                for x in stride(from: max(0, centerX - 22), through: min(width - 1, centerX + 22), by: 3) {
                    let c = color(x: x, y: y)
                    samples += 1
                    if c.g >= 55, c.g >= c.r + 8, c.g >= c.b + 5 { grass += 1 }
                    // A Dusty Gulch járható talaja sötétebb, vörösesbarna,
                    // kevés kék komponenssel. A világos lazacszínű előtéri
                    // sziklafalak és a fehér ponyvás szekér nem férnek bele.
                    if c.r >= 150, c.r <= 235,
                       c.g >= 55, c.g <= 150,
                       c.b <= 78,
                       c.r >= c.g + 45,
                       c.r >= c.b + 85 {
                        orangeGround += 1
                    }
                    if max(c.r, max(c.g, c.b)) <= 58 { dark += 1 }
                    if c.r >= 175, c.g >= 155, c.b >= 125 { paleCover += 1 }
                    if (c.r >= 190 && c.r >= c.g + 65) ||
                       (c.g >= 190 && c.g >= c.r + 65) ||
                       (c.b >= 180 && c.b >= c.r + 45) { vividUI += 1 }
                }
            }
            guard samples > 0 else { return -.infinity }
            let safeTerrain = Double(grass + orangeGround)
            var visualScore = (
                2.2 * safeTerrain - 2.8 * Double(dark) -
                1.6 * Double(vividUI) - 2.4 * Double(paleCover)
            ) / Double(samples)
            // Ha egy jobb oldali jelölt régiójának legalább harmada biztos
            // narancs talaj, az Island 2-n sokkal megbízhatóbb, mint a
            // karakterközeli szekér/ház zsebe. Ez a bónusz csak a szigorú,
            // kevés-kék talajmaszk után él, ezért jobb oldali menügomb vagy
            // világos szikla nem kaphatja meg.
            if candidate.x >= 0.72, orangeGround * 3 >= samples {
                visualScore += 0.75
            }
            // Azonos vizuális pontszámnál a kissé magasabb kezdőpont kevésbé
            // valószínű, hogy előtéri lomb vagy az alsó fegyversor takarja.
            return visualScore - candidate.y * 0.08
        }

        return candidates.max { score($0) < score($1) } ?? Vector2(x: 0.50, y: 0.67)
    }
}

private struct IntRect: Codable, Equatable, CustomStringConvertible {
    var minX: Int
    var minY: Int
    var maxX: Int
    var maxY: Int
    var pixels: Int

    var width: Int { maxX - minX + 1 }
    var height: Int { maxY - minY + 1 }
    var centerX: Double { Double(minX + maxX) / 2 }
    var centerY: Double { Double(minY + maxY) / 2 }
    var description: String { "(x:\(minX), y:\(minY), w:\(width), h:\(height), px:\(pixels))" }
}

private struct Target: Codable {
    let bar: IntRect
    let x: Double
    let y: Double
    let distance: Double
    let level: Int?
    let levelOCRNumbers: [Int]
    let displayedHP: Int?
    let ocrStrings: [String]
    let treeConfidence: Double
    let heartIconEvidence: Double
    let axeIconEvidence: Double
    let weaponDropIconEvidence: Double
    let objectiveStructureConfidence: Double
    let barOutlineConfidence: Double
    let bossEvidence: Bool
}

private struct FrameAnalysis: Codable {
    let width: Int
    let height: Int
    let expandedMapVisible: Bool?
    let shop: ShopObservation?
    let minimapPose: MinimapPose?
    let redBars: [IntRect]
    let greenBars: [IntRect]
    let touchAnchor: Vector2
    let sceneFingerprint: [Int]
    let explorationDirection: Vector2?
    let localFarmDirection: Vector2?
    let localFarmOffset: Vector2?
    let golemMapOffset: Vector2?
    let mapObjectives:[MapObjectiveDetector.Icon]
    let mapPlayerPosition:Vector2?
    let island2SkullDirection: Vector2?
    let innerMapEnemyVisible: Bool
    let edgeObjectiveVisible: Bool
    let specialLandmarkDirection: Vector2?
    let landmarkDirection: Vector2?
    let questRouteDirection: Vector2?
    let playerOCRStrings: [String]
    let playerLocalizedOCRStrings: [String]?
    let rewardOCRStrings: [String]
    let dialogueOCRStrings: [String]
    let titanQuestOCRStrings: [String]
    let discoveredChestCount: Int?
    // A korlátozott felső ládaplatón több órás időzítő a kép középső
    // tartományába kerül. A sík Dusty Gulchban jellemzően legfeljebb egy,
    // képszéli ládaidőzítő látható, ezért ezt külön rétegjelként tároljuk.
    let centralLongRespawnTimerCount: Int
    // A bal oldali "UNLOCKS AT ISLAND 4" a következő fegyverhely HUD-ja,
    // nem világkapu vagy földrajzi határ.
    let island4WeaponSlotLockVisible: Bool
    let orangeRockBiomeVisible: Bool
    let orangeRockCoverage: Double
    let continueButtonVisible: Bool
    let claimRewardVisible: Bool
    let openButtonVisible: Bool
    let openButtonCenter: Vector2?
    let worldChestDirection: Vector2?
    let worldChestCandidate: IntRect?
    let worldChestGoldSamples: Int?
    let worldChestSparkleSamples: Int?
    let worldChestBrightGlowSamples: Int?
    let dialogueCanAdvance: Bool
    let titanGemQuestVisible: Bool
    let deepMinesPotionQuestVisible: Bool
    let recentRewardValue: Int?
    let recentRewardSequence: Int?
    let confirmedMaximumIncreaseSequence: Int?
    let confirmedMaximumDisplayedHP: Int?
    let nearbyRespawnTimer: Bool
    let playerDisplayedHP: Int?
    let playerPixelHealthFraction: Double?
    let playerHealthFraction: Double?
    let playerHealthSource: String
    let hudConfidence: Double
    let visibleTargets: [Target]
    let target: Target?
    let nearestThreat: Target?
    let nearbyThreatCount: Int
    let popupClose: IntRect?
    let settingsClose: IntRect?
    let unstuckCooldownSeconds: Int?
}

private final class NumberRecognizer {
    func enlargedBarStrings(in image: CGImage, topLeftROI: CGRect, scale:Int=3) -> [String] {
        let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        let roi = topLeftROI.intersection(bounds).integral
        guard roi.width >= 3, roi.height >= 3,
              let crop = image.cropping(to: roi),
              let context = CGContext(data: nil, width: crop.width * scale,
                  height: crop.height * scale, bitsPerComponent: 8, bytesPerRow: 0,
                  space: CGColorSpaceCreateDeviceRGB(),
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [] }
        context.interpolationQuality = .high
        let rect = CGRect(x: 0, y: 0, width: crop.width * scale, height: crop.height * scale)
        context.draw(crop, in: rect)
        guard let enlarged = context.makeImage() else { return [] }
        return recognizedStrings(in: enlarged, topLeftROI: rect)
    }

    func integers(in image: CGImage, topLeftROI: CGRect) -> [Int] {
        recognizedStrings(in: image, topLeftROI: topLeftROI).flatMap(integerSequences)
    }

    func recognizedStrings(in image: CGImage, topLeftROI: CGRect,
                           verticalCenterRange: ClosedRange<Double>? = nil) -> [String] {
        let imageBounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        let roi = topLeftROI.intersection(imageBounds)
        guard roi.width >= 3, roi.height >= 3 else { return [] }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.004
        request.regionOfInterest = CGRect(
            x: roi.minX / Double(image.width),
            y: (Double(image.height) - roi.maxY) / Double(image.height),
            width: roi.width / Double(image.width),
            height: roi.height / Double(image.height)
        )
        do {
            try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
        } catch {
            return []
        }

        var result: [String] = []
        for observation in request.results ?? [] {
            if let verticalCenterRange {
                // Vision observations are normalized inside regionOfInterest.
                let centerY=roi.maxY-observation.boundingBox.midY*roi.height
                guard verticalCenterRange.contains(centerY) else {continue}
            }
            for candidate in observation.topCandidates(3) {
                result.append(candidate.string)
            }
        }
        return result
    }

    private func integerSequences(in text: String) -> [Int] {
        var groups: [Int] = []
        var current = ""
        for character in text {
            if character.isNumber {
                current.append(character)
            } else if !current.isEmpty {
                if let value = Int(current) { groups.append(value) }
                current = ""
            }
        }
        if !current.isEmpty, let value = Int(current) { groups.append(value) }
        return groups
    }
}

private struct ComponentDetector {
    typealias Predicate = (_ r: Int, _ g: Int, _ b: Int) -> Bool

    static func components(
        in image: PixelImage,
        yRange: Range<Int>,
        predicate: Predicate
    ) -> [IntRect] {
        let width = image.width
        let height = image.height
        let lowerY = max(0, yRange.lowerBound)
        let upperY = min(height, yRange.upperBound)
        guard lowerY < upperY else { return [] }

        var mask = [UInt8](repeating: 0, count: width * (upperY - lowerY))
        for y in lowerY..<upperY {
            for x in 0..<width {
                let c = image.color(x: x, y: y)
                if predicate(c.r, c.g, c.b) {
                    mask[(y - lowerY) * width + x] = 1
                }
            }
        }

        var result: [IntRect] = []
        var queueX: [Int] = []
        var queueY: [Int] = []

        for localY in 0..<(upperY - lowerY) {
            for x in 0..<width {
                let start = localY * width + x
                guard mask[start] == 1 else { continue }

                mask[start] = 2
                queueX.removeAll(keepingCapacity: true)
                queueY.removeAll(keepingCapacity: true)
                queueX.append(x)
                queueY.append(localY)
                var head = 0
                var minX = x
                var maxX = x
                var minY = localY
                var maxY = localY
                var count = 0

                while head < queueX.count {
                    let currentX = queueX[head]
                    let currentY = queueY[head]
                    head += 1
                    count += 1
                    minX = min(minX, currentX)
                    maxX = max(maxX, currentX)
                    minY = min(minY, currentY)
                    maxY = max(maxY, currentY)

                    for delta in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                        let nextX = currentX + delta.0
                        let nextY = currentY + delta.1
                        guard nextX >= 0, nextX < width, nextY >= 0, nextY < upperY - lowerY else { continue }
                        let next = nextY * width + nextX
                        guard mask[next] == 1 else { continue }
                        mask[next] = 2
                        queueX.append(nextX)
                        queueY.append(nextY)
                    }
                }

                if count >= 6 {
                    result.append(IntRect(
                        minX: minX,
                        minY: minY + lowerY,
                        maxX: maxX,
                        maxY: maxY + lowerY,
                        pixels: count
                    ))
                }
            }
        }
        return result
    }
}

private final class Analyzer {
    private let localFarmTracker = MinimapFarmTracker()
    private let shopInspector = ShopInspector()
    private let expandedMapDetector = ExpandedMapDetector()
    private let mapObjectiveDetector = MapObjectiveDetector()
    private let minimapAnchorDetector = MinimapAnchorDetector()
    private var learnedFullHealthWidth: Double = 0
    private var learnedMaximumDisplayedHP: Int
    private var learnedDiscoveredChestCount = 0
    private var lastDisplayedHP: Int?
    private var recentRedThreatFrames = 0
    private var pendingLargeDropFrames = 0
    private var pendingLargeDropValue: Int?
    private var pendingLargeRiseFrames = 0
    private var pendingLargeRiseValue: Int?
    private var pendingSmallMaximumFrames = 0
    private var pendingSmallMaximumValue: Int?
    private var pendingLargeMaximumFrames = 0
    private var pendingLargeMaximumValue: Int?
    private var pendingLargeMaximumMissFrames = 0
    private let numberRecognizer = NumberRecognizer()
    private var previousTargets: [Target] = []
    // A nagy boss egyetlen OCR-képre teljesen eltűnhet, majd a `18.8K`
    // vezető `1`-ét és pontját elveszítve `8K` alakban térhet vissza. A sima
    // previousTargets ezt a köztes üres képen elveszíti; rövid, helyhez kötött
    // memória kell, hogy ugyanaz a boss ne nyisson hamis új erősávot.
    private var recentExplicitLargeBossHP: Int?
    private var recentExplicitLargeBossX: Double?
    private var recentExplicitLargeBossY: Double?
    private var recentExplicitLargeBossFrames = 0
    private var rememberedRewardValue: Int?
    private var rememberedRewardFrames = 0
    private var rewardSequence = 0
    private var rewardWasVisible = false
    private var maximumIncreaseSequence = 0
    private var expectedStatRewardValue: Int?
    private var expectedStatRewardFrames = 0
    private let knowledgeURL: URL
    private let readOnlyKnowledge: Bool

    private struct PersistentKnowledge: Codable {
        let maximumDisplayedHP: Int
        let discoveredChestCount: Int?
    }

    init(readOnlyKnowledge: Bool = false, playerFixturePath: String? = nil) {
        self.readOnlyKnowledge = readOnlyKnowledge
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        knowledgeURL = playerFixturePath.map { URL(fileURLWithPath: $0) } ??
            root.appendingPathComponent("docs/bot-state.json")
        if let data = try? Data(contentsOf: knowledgeURL),
           let state = try? JSONDecoder().decode(PersistentKnowledge.self, from: data) {
            learnedMaximumDisplayedHP = max(100, state.maximumDisplayedHP)
            learnedDiscoveredChestCount = max(0, state.discoveredChestCount ?? 0)
        } else {
            learnedMaximumDisplayedHP = 100
        }
        // A tartós maximum egy új folyamat első képkockáján is hiteles
        // időbeli előzmény. Enélkül a 3.38K stilizált feliratából
        // keletkező `BET`/`X8ET`/`8E` OCR-zaj 8 HP-ként indította a botot.
        lastDisplayedHP = learnedMaximumDisplayedHP
    }

    func adoptProvenMaximumDisplayedHP(_ value: Int) {
        guard value > learnedMaximumDisplayedHP else { return }
        learnedMaximumDisplayedHP = value
        persistKnowledge()
    }

    func analyze(_ image: PixelImage, cgImage: CGImage) -> FrameAnalysis {
        let expandedMapVisible = expandedMapDetector.matches(cgImage)
        let redComponents = ComponentDetector.components(
            in: image,
            // A közvetlenül a játékos alatt álló 67.5K boss csíkja a kép
            // 85%-án volt, ezért a régi 72%-os alsó vágás teljesen láthatatlanná
            // tette a veszélyőrnek. A fekete barOutline-kapu már kiszűri a
            // terep vörös éleit, így biztonságosan vizsgálhatjuk az alsó HUD
            // fölötti teljes játékrészt is.
            yRange: 20..<Int(Double(image.height) * 0.90)
        ) { r, g, b in
            r >= 225 && g >= 25 && g <= 115 && b <= 165 && r >= g + 105 && r >= b + 65
        }

        let rawRedBars = redComponents.filter {
            $0.width >= 8 && $0.width <= 100 &&
            $0.height >= 2 && $0.height <= 18 &&
            Double($0.width) / Double($0.height) >= 1.0 &&
            $0.pixels >= 14
        }
        let redBars = mergeHorizontalBarPieces(rawRedBars).filter {
            if $0.width >= 16 && $0.width <= 100 &&
               Double($0.width) / Double($0.height) >= 2.5 {return true}
            // Depleted close-range bars may retain only a 12x8 red stub.
            // Require a dark horizontal frame; damage text alone is not a bar.
            guard $0.width>=8,$0.width<=40,$0.height<=10,$0.pixels>=30,
                  abs($0.centerX-Double(image.width)*0.5)<180,
                  abs($0.centerY-Double(image.height)*0.515)<180 else{return false}
            if isOverlappingContactBar($0, image: image) { return true }
            var dark=0,total=0
            for y in [max(0,$0.minY-2),min(image.height-1,$0.maxY+2)] {
                for x in $0.minX...$0.maxX {
                    let c=image.color(x:x,y:y);total+=1
                    if c.r<=90 && c.g<=90 && c.b<=90 {dark+=1}
                }
            }
            guard total>0 && Double(dark)/Double(total)>=0.45 else{return false}
            // A depleted bar retains its long empty frame. The player's red
            // boot can have a dark outline too, but not parallel horizontal
            // borders extending18px beyond the tiny red component.
            for side in [-1,1] {
                var topBest=0.0,bottomBest=0.0
                for offset in 1...3 {
                    var top=0,bottom=0,count=0
                    for step in 2...19 {
                        let x=side<0 ? $0.minX-step:$0.maxX+step
                        guard x>=0,x<image.width,$0.minY-offset>=0,
                              $0.maxY+offset<image.height else{continue}
                        let a=image.color(x:x,y:$0.minY-offset)
                        let b=image.color(x:x,y:$0.maxY+offset)
                        count+=1
                        if a.r<=90 && a.g<=90 && a.b<=90 {top+=1}
                        if b.r<=90 && b.g<=90 && b.b<=90 {bottom+=1}
                    }
                    if count>0 {
                        topBest=max(topBest,Double(top)/Double(count))
                        bottomBest=max(bottomBest,Double(bottom)/Double(count))
                    }
                }
                if topBest>=0.55 && bottomBest>=0.55 {return true}
            }
            return false
        }

        // A kör alakú minimapon a sárga háromszög a játékos, a kis piros
        // komponensek a célok. Ez ad irányt akkor is, ha a fő nézetben nincs
        // HP-csík; a vak négyzetjárőr csak tartalék.
        let mapCenter = Vector2(x: Double(image.width) * 0.865, y: Double(image.height) * 0.14)
        let mapRadius = Double(image.width) * 0.115
        let mapYRange = max(0, Int(mapCenter.y - mapRadius))..<min(image.height, Int(mapCenter.y + mapRadius))
        let yellowMapComponents = ComponentDetector.components(in: image, yRange: mapYRange) { r, g, b in
            r >= 180 && g >= 135 && b <= 95 && r >= b + 90 && g >= b + 55
        }.filter {
            $0.width >= 2 && $0.width <= 15 && $0.height >= 2 && $0.height <= 15 &&
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <= mapRadius
        }
        let redMapComponents = ComponentDetector.components(in: image, yRange: mapYRange) { r, g, b in
            r >= 205 && g <= 90 && b <= 125 && r >= g + 110 && r >= b + 85
        }.filter {
            $0.width >= 2 && $0.width <= 10 && $0.height >= 2 && $0.height <= 10 &&
            $0.pixels >= 3 &&
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <= mapRadius
        }
        // Ha a kijelölt ellenfél a minimap látható körén kívül van, a játék nem
        // apró belső pontot, hanem a perem fölé kilógó piros fejsze/kalapács
        // irányjelzőt rajzol. A `155618-play` zöld Titan-területén ez a jel
        // tisztán balra-felfelé mutatott, de a régi `mapRadius` és 10 px-es
        // méretkapu miatt az elemzés egyáltalán nem látott piros célt, ezért
        // négyzetspirálra váltott. A keskeny felső térképsávban külön keressük a
        // nagyobb, peremközeli piros ikont; ha van, elsőbbséget kap a köztes
        // passzív farmpontokkal szemben.
        let redEdgeObjectiveComponents = ComponentDetector.components(in: image, yRange: mapYRange) { r, g, b in
            r >= 205 && g <= 95 && b <= 135 && r >= g + 105 && r >= b + 75
        }.filter {
            $0.width >= 3 && $0.width <= 26 && $0.height >= 3 && $0.height <= 26 &&
            $0.pixels >= 6 &&
            // A valódi kilógó fegyverjel mért középpontja 1,27–1,31 sugárra
            // van. A 0,78-as első kapu még befogta a körön belüli, 0,91-es
            // közönséges piros pontot, amely tévesen egy 1.28K-s kaktusz felé
            // fordította a botot. Csak a ténylegesen körön kívüli gyűrű marad.
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) >= mapRadius * 1.10 &&
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <= mapRadius * 1.45
        }
        let playerMapMarker = yellowMapComponents.min {
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <
                hypot($1.centerX - mapCenter.x, $1.centerY - mapCenter.y)
        }
        // A régi Island2-szűrő minden zöld oldali piros pontot elrejtett.
        // A külön helyi farmcsatorna szigetfüggetlen, és nem követ külső bossikont.
        let localFarmOffset: Vector2? = playerMapMarker.flatMap { marker in
            let offsets = redMapComponents.map {
                MinimapFarmTracker.Point(x:$0.centerX-marker.centerX,y:$0.centerY-marker.centerY)
            }
            return localFarmTracker.select(offsets).map { Vector2(x:$0.x,y:$0.y) }
        }
        let localFarmDirection = localFarmOffset?.normalized
        // Relative bearing only: the identical face must not name a global origin.
        let orangeGolemPose = !expandedMapVisible ? playerMapMarker.flatMap { marker in
            minimapAnchorDetector.detect(cgImage,playerX:marker.centerX,playerY:marker.centerY)
        } : nil
        let nearestInnerMapTarget = playerMapMarker.flatMap { marker in
            redMapComponents.filter {
                guard hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) >= 8 else{return false}
                // At the island border, the nearest red dot often belongs to
                // Meadowlands. Do not undo an Island 2 entry to chase it.
                guard learnedMaximumDisplayedHP >= 4_000 else{return true}
                var green=0,orange=0
                for dy in -7...7 {for dx in -7...7 where dx*dx+dy*dy>=16 && dx*dx+dy*dy<=49 {
                    let x=Int($0.centerX)+dx,y=Int($0.centerY)+dy
                    guard x>=0,x<image.width,y>=0,y<image.height else{continue}
                    let c=image.color(x:x,y:y)
                    if c.g>c.r+18 && c.g>c.b+8 {green+=1}
                    if c.r>c.g+35 && c.g>c.b+18 && c.r>160 {orange+=1}
                }}
                return !(green>=18 && green>orange*2)
            }.min {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) <
                    hypot($1.centerX - marker.centerX, $1.centerY - marker.centerY)
            }
        }
        let nearestMapTarget = playerMapMarker.flatMap { marker in
            // A körön belüli piros pont képernyőn lévő, közeli ellenfél. Ez
            // mindig megelőzi a körön kívüli irányikont: a 162633-as futásban
            // három 672-es lovag jobbra-felfelé állt, de a külső piros ikon
            // balra egy épületnek vezette a botot. A peremjel csak akkor lesz
            // aktív úticél, amikor nincs belső piros ellenfélpont.
            if let nearestInnerMapTarget { return nearestInnerMapTarget }
            return redEdgeObjectiveComponents.min {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) <
                    hypot($1.centerX - marker.centerX, $1.centerY - marker.centerY)
            }
        }
        let edgeObjectiveActive = nearestInnerMapTarget == nil &&
            playerMapMarker != nil &&
            !redEdgeObjectiveComponents.isEmpty
        let explorationDirection: Vector2? = {
            guard let marker = playerMapMarker, let dot = nearestMapTarget else { return nil }
            return Vector2(x: dot.centerX - marker.centerX, y: dot.centerY - marker.centerY).normalized
        }()
        // Orange heads are golem candidates on multiple islands, not a unique
        // boss identity. Match the face/eyes template in ANY direction; the
        // previous northwest-only gate missed the eastern500-heart guardian.
        // This bearing does not grant combat permission or identify a world map.
        let pinkSkullMapComponents = ComponentDetector.components(in: image, yRange: mapYRange) { r, g, b in
            r >= 180 && g <= 100 && b >= 65 && b <= 205 &&
                r >= g + 90 && b >= g + 25
        }.filter {
            $0.width >= 2 && $0.width <= 22 &&
            $0.height >= 2 && $0.height <= 22 &&
            $0.pixels >= 5 &&
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <= mapRadius
        }
        let island2SkullDirection: Vector2? = playerMapMarker.flatMap { marker in
            guard !expandedMapVisible else { return nil }
            if let golem = orangeGolemPose,
               hypot(golem.x,golem.y)>8 {
                return Vector2(x:-golem.x,y:-golem.y).normalized
            }
            let pinkSkull = pinkSkullMapComponents.filter {
                $0.centerY <= marker.centerY - 18 &&
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) >= 20
            }.min {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) <
                    hypot($1.centerX - marker.centerX, $1.centerY - marker.centerY)
            }
            guard let skull = pinkSkull else { return nil }
            return Vector2(x: skull.centerX - marker.centerX, y: skull.centerY - marker.centerY).normalized
        }
        // A lila, kb. 9×9 pixeles minimapjel különleges helyszínt jelöl (a
        // megfigyelt képeken portál-/oltárikon). Ezt külön tartjuk a piros
        // harci pontoktól és a zöld farm-landmarkoktól: jutalomhiányos hurokban
        // érdemes felderíteni, de nem szabad ellenségnek nézni.
        let purpleMapComponents = ComponentDetector.components(in: image, yRange: mapYRange) { r, g, b in
            b >= 110 && r >= 65 && g <= 120 &&
                b >= g + 40 && r >= g + 25
        }.filter {
            $0.width >= 5 && $0.width <= 18 &&
            $0.height >= 5 && $0.height <= 18 &&
            $0.pixels >= 20 &&
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <= mapRadius
        }
        let nearestSpecialLandmark = playerMapMarker.flatMap { marker in
            purpleMapComponents.filter {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) >= 12
            }.min {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) <
                    hypot($1.centerX - marker.centerX, $1.centerY - marker.centerY)
            }
        }
        let specialLandmarkDirection: Vector2? = {
            guard let marker = playerMapMarker,
                  let landmark = nearestSpecialLandmark else { return nil }
            return Vector2(
                x: landmark.centerX - marker.centerX,
                y: landmark.centerY - marker.centerY
            ).normalized
        }()
        // A minimap a piros harci pontokon kívül tartós, négyzetes zöld
        // helyszínjelzőket is mutat. Ha a helyi farmkészlet teljesen cooldownon
        // van, ezek értékesebbek a vak spirálnál: új NPC-hez, területhez vagy
        // játékrendszerhez vezethetnek. Piros cél mindig elsőbbséget élvez.
        let greenMapComponents = ComponentDetector.components(in: image, yRange: mapYRange) { r, g, b in
            g >= 130 && r <= 155 && b <= 135 && g >= r + 25 && g >= b + 25
        }.filter {
            $0.width >= 5 && $0.width <= 16 &&
            $0.height >= 5 && $0.height <= 16 &&
            $0.pixels >= 15 &&
            hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) <= mapRadius
        }
        let nearestMapLandmark = playerMapMarker.flatMap { marker in
            greenMapComponents.filter {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) >= 12
            }.min {
                hypot($0.centerX - marker.centerX, $0.centerY - marker.centerY) <
                    hypot($1.centerX - marker.centerX, $1.centerY - marker.centerY)
            }
        }
        let landmarkDirection: Vector2? = {
            guard explorationDirection == nil,
                  let marker = playerMapMarker,
                  let landmark = nearestMapLandmark else { return nil }
            return Vector2(
                x: landmark.centerX - marker.centerX,
                y: landmark.centerY - marker.centerY
            ).normalized
        }()

        // A Cursed Girl feladata világos türkiz, szaggatott "sínt" rajzol a
        // világba a Deep Mines irányába. Ez közvetlenebb történeti útjelző,
        // mint a piros minimappontok (azok közeli farmcélok is lehetnek).
        // A távolabbi pixelszakaszok nagyobb súlyt kapnak, hogy ne csak a
        // karakter alatt áthaladó vonalra álljunk rá, hanem annak folytatása
        // felé haladjunk.
        let questRouteDirection: Vector2? = {
            let centerX = Double(image.width) * 0.5
            let centerY = Double(image.height) * 0.515
            let lowerY = Int(Double(image.height) * 0.25)
            let upperY = Int(Double(image.height) * 0.66)
            let isRouteColor: ComponentDetector.Predicate = { r, g, b in
                r <= 85 && g >= 175 && b >= 170 &&
                    g >= r + 90 && b >= r + 90 && abs(g - b) <= 75
            }

            // A pályán türkiz hidak, sziklaélek és fák is vannak. A valódi
            // sín ezzel szemben hosszú, összefüggő szakaszként a karakter
            // közelében halad át. Csak olyan komponenst fogadunk el, amely
            // legalább 100 px kiterjedésű és a téglalapja 175 px-en belül ér
            // a játékoshoz; így a távoli híd/szikladísz nem húzhat félre.
            let routeComponents = ComponentDetector.components(
                in: image,
                yRange: lowerY..<upperY,
                predicate: isRouteColor
            ).filter { component in
                guard max(component.width, component.height) >= 100,
                      component.pixels >= 80 else { return false }
                let closestX = min(max(centerX, Double(component.minX)), Double(component.maxX))
                let closestY = min(max(centerY, Double(component.minY)), Double(component.maxY))
                return hypot(closestX - centerX, closestY - centerY) <= 175
            }
            guard !routeComponents.isEmpty else { return nil }

            var sumX = 0.0
            var sumY = 0.0
            var totalWeight = 0.0
            var matchingPixels = 0
            for y in stride(from: lowerY, to: upperY, by: 2) {
                for x in stride(from: 0, to: image.width, by: 2) {
                    let color = image.color(x: x, y: y)
                    guard isRouteColor(color.r, color.g, color.b),
                          routeComponents.contains(where: {
                              x >= $0.minX && x <= $0.maxX && y >= $0.minY && y <= $0.maxY
                          }) else { continue }
                    let dx = Double(x) - centerX
                    let dy = Double(y) - centerY
                    let distance = hypot(dx, dy)
                    guard distance >= 65, distance <= Double(image.width) * 0.68 else { continue }
                    let weight = pow(distance / 100.0, 2)
                    sumX += dx / distance * weight
                    sumY += dy / distance * weight
                    totalWeight += weight
                    matchingPixels += 1
                }
            }
            guard matchingPixels >= 24, totalWeight > 0 else { return nil }
            let concentration = hypot(sumX, sumY) / totalWeight
            guard concentration >= 0.24 else { return nil }
            let route = Vector2(x: sumX, y: sumY).normalized
            // A Deep Mines a havas, északi oldalon van. A kanyargó sín két
            // ága a karakter közelében egyszerre látszik, ezért a súlyozott
            // tömegközéppont képről képre előre/hátra váltott. A sín tengelyét
            // mindig az északi félirányba tájoljuk; ettől a bot a kapuig halad,
            // nem ugyanazon íven ingázik.
            return route.y > 0
                ? Vector2(x: -route.x, y: -route.y)
                : route
        }()

        // Rögzített, UI-t és a középső karaktert kerülő háttérminták. A döntő
        // csak a ténylegesen végrehajtható döntések fingerprintjeit hasonlítja,
        // ezért a köztes felhasználói-aktivitásos képek nem rejtik el, hogy egy
        // swipe után valóban elmozdult-e a kamera.
        let sceneSamplePoints: [(Double, Double)] = [
            (0.12, 0.24), (0.30, 0.24), (0.50, 0.24), (0.70, 0.24),
            (0.12, 0.38), (0.30, 0.38), (0.70, 0.38),
            (0.12, 0.66), (0.30, 0.66), (0.50, 0.66), (0.70, 0.66)
        ]
        var sceneFingerprint: [Int] = []
        for (fractionX, fractionY) in sceneSamplePoints {
            let centerX = Int(Double(image.width) * fractionX)
            let centerY = Int(Double(image.height) * fractionY)
            var redTotal = 0
            var greenTotal = 0
            var blueTotal = 0
            var count = 0
            for sampleY in stride(from: centerY - 4, through: centerY + 4, by: 2) {
                for sampleX in stride(from: centerX - 4, through: centerX + 4, by: 2) {
                    guard sampleX >= 0, sampleX < image.width,
                          sampleY >= 0, sampleY < image.height else { continue }
                    let color = image.color(x: sampleX, y: sampleY)
                    redTotal += color.r
                    greenTotal += color.g
                    blueTotal += color.b
                    count += 1
                }
            }
            let divisor = max(1, count * 16)
            sceneFingerprint.append(redTotal / divisor)
            sceneFingerprint.append(greenTotal / divisor)
            sceneFingerprint.append(blueTotal / divisor)
        }

        let greenComponents = ComponentDetector.components(
            in: image,
            yRange: Int(Double(image.height) * 0.28)..<Int(Double(image.height) * 0.63)
        ) { r, g, b in
            g >= 155 && r <= 175 && b <= 160 && g >= r + 35 && g >= b + 35
        }

        let rawGreenBars = greenComponents.filter {
            let ordinaryBar = $0.width >= 8 && $0.width <= 100 &&
                $0.height >= 2 && $0.height <= 20 &&
                Double($0.width) / Double($0.height) >= 1.5 && $0.pixels >= 18
            // A fehér HP-szám kettévágja a teljes zöld csíkot. A bal 13×9
            // darabot a régi 1.5 képarány kiszűrte, így csak a jobb 14px
            // maradt: hamis 23% életerő. Kizárólag a saját csík szűk helyén
            // kisebb darabokat is megőrzünk az összeillesztéshez.
            let ownBarFragment = $0.minX >= Int(Double(image.width) * 0.44) &&
                $0.maxX <= Int(Double(image.width) * 0.56) &&
                abs($0.centerY - Double(image.height) * 0.455) <= Double(image.height) * 0.025 &&
                $0.width >= 3 && $0.height >= 2 && $0.height <= 12 && $0.pixels >= 8
            return ordinaryBar || ownBarFragment
        }
        let greenBars = mergeHorizontalBarPieces(rawGreenBars)

        let popupComponents = ComponentDetector.components(
            in: image,
            yRange: Int(Double(image.height) * 0.06)..<Int(Double(image.height) * 0.68)
        ) { r, g, b in
            r >= 205 && g <= 105 && b >= 55 && b <= 180 && r >= b + 60
        }
        let popupClose = popupComponents.first { component in
            guard component.width >= 45 && component.width <= 105 &&
                component.height >= 22 && component.height <= 55 &&
                component.centerX >= Double(image.width) * 0.25 &&
                component.centerX <= Double(image.width) * 0.95 else { return false }
            // A red roof is not a close button: require the white central X.
            var white = 0
            let cx=Int(component.centerX),cy=Int(component.centerY)
            for y in (cy-component.height/3)...(cy+component.height/3) {
                for x in (cx-component.width/4)...(cx+component.width/4) {
                    let c=image.color(x:x,y:y)
                    if c.r>220 && c.g>220 && c.b>220 {white+=1}
                }
            }
            return white>=8
        }
        // A nagy Settings panel X-e a korábbi, szűk magenta-szűrőn kívülre
        // eshetett. Külön, pozícióval erősen korlátozott rózsaszín detektor kell,
        // mert az Unstuck állapotgép csak a panel tényleges megjelenése után
        // nyomhatja meg a gombot, és csak az X eltűnését tekintheti teleportnak.
        let settingsCloseComponents = ComponentDetector.components(
            in: image,
            yRange: Int(Double(image.height) * 0.07)..<Int(Double(image.height) * 0.18)
        ) { r, g, b in
            r >= 175 && g <= 145 && b >= 65 &&
                r >= g + 55 && r >= b + 15
        }
        let settingsClose = settingsCloseComponents.first {
            $0.width >= 45 && $0.width <= 115 &&
            $0.height >= 22 && $0.height <= 65 &&
            $0.centerX >= Double(image.width) * 0.58 &&
            $0.centerX <= Double(image.width) * 0.74 &&
            $0.centerY >= Double(image.height) * 0.085 &&
            $0.centerY <= Double(image.height) * 0.155
        }
        let unstuckCooldownSeconds: Int? = {
            guard settingsClose != nil else { return nil }
            let timerStrings = numberRecognizer.recognizedStrings(
                in: cgImage,
                topLeftROI: CGRect(
                    x: Double(image.width) * 0.39,
                    y: Double(image.height) * 0.70,
                    width: Double(image.width) * 0.26,
                    height: Double(image.height) * 0.075
                )
            )
            return timerStrings.compactMap { raw -> Int? in
                let normalized = raw.uppercased()
                    .replacingOccurrences(of: "O", with: "0")
                    .replacingOccurrences(of: "I", with: "1")
                    .replacingOccurrences(of: "L", with: "1")
                    .replacingOccurrences(of: ".", with: ":")
                let parts = normalized.split(separator: ":")
                guard parts.count == 2,
                      let minutes = Int(parts[0].filter(\.isNumber)),
                      let seconds = Int(parts[1].filter(\.isNumber)),
                      (0...20).contains(minutes),
                      (0...59).contains(seconds) else { return nil }
                return minutes * 60 + seconds
            }.min()
        }()

        let expectedPlayerBarY = Double(image.height) * 0.455
        let expectedPlayerX = Double(image.width) * 0.5
        let playerBar = greenBars.min { left, right in
            let leftScore = abs(left.centerY - expectedPlayerBarY) + 0.35 * abs(left.centerX - expectedPlayerX)
            let rightScore = abs(right.centerY - expectedPlayerBarY) + 0.35 * abs(right.centerX - expectedPlayerX)
            return leftScore < rightScore
        }.flatMap { candidate -> IntRect? in
            let yOK = abs(candidate.centerY - expectedPlayerBarY) < Double(image.height) * 0.09
            let xOK = abs(candidate.centerX - expectedPlayerX) < Double(image.width) * 0.18
            return yOK && xOK ? candidate : nil
        }

        var pixelHealthFraction: Double?
        if let playerBar {
            // A valódi teljes játékoscsík ezen a 623 px széles nézeten 58 px.
            // Egy összeolvadt zöld UI-komponens korábban 90–100 px-re növelhette
            // a tanult szélességet, amitől a láthatóan teljes csík már nem érte el
            // a 65%-os OCR-vétót. A játékoscsík életszerű felső határa a kép 12%-a.
            let maximumPlausiblePlayerBarWidth = Double(image.width) * 0.10
            learnedFullHealthWidth = min(
                maximumPlausiblePlayerBarWidth,
                max(Double(image.width) * 0.09, learnedFullHealthWidth, Double(playerBar.width))
            )
            if learnedFullHealthWidth > 0 {
                pixelHealthFraction = min(1, Double(playerBar.width) / learnedFullHealthWidth)
            }
        }

        var playerStrings = numberRecognizer.recognizedStrings(
            in: cgImage,
            topLeftROI: CGRect(
                x: Double(image.width) * 0.417,
                y: Double(image.height) * 0.429,
                width: Double(image.width) * 0.177,
                height: Double(image.height) * 0.081
            )
        )
        // A zöld csík saját sora nem azonos a tág karakter-ROI-val. A 125457
        // harcban ez utóbbiban az animáció/ellenfél összeragasztotta a HP-t;
        // újraéledéskor a távoli Titan-buborék sem takarta a valódi csíkot.
        let localizedPlayerStrings: [String]
        if let playerBar {
            localizedPlayerStrings = numberRecognizer.enlargedBarStrings(
                in: cgImage,
                topLeftROI: CGRect(x: Double(image.width) * 0.5 - 43,
                    y: Double(playerBar.minY) - 6, width: 86,
                    height: Double(playerBar.height) + 12))
        } else {
            localizedPlayerStrings = []
        }
        let cleanLocalizedPlayerStrings = localizedPlayerStrings.filter { raw in
            let compact = raw.replacingOccurrences(of: " ", with: "")
            return compact.range(of: "^[0-9]+([.,:][0-9]+)?[kK]?$",
                                 options: .regularExpression) != nil &&
                !parseHealthValues(compact).isEmpty
        }
        let localizedPlayerHealthVisible = cleanLocalizedPlayerStrings.count == 1 &&
            localizedPlayerStrings.count == 1 &&
            (learnedMaximumDisplayedHP < 1_000 ||
             cleanLocalizedPlayerStrings[0].lowercased().contains("k"))
        let preciseLocalizedHealthVisible = localizedPlayerHealthVisible &&
            cleanLocalizedPlayerStrings[0].range(of: "^[0-9]+[.,:][0-9]+[kK]$",
                                                options: .regularExpression) != nil
        if localizedPlayerHealthVisible {
            playerStrings = cleanLocalizedPlayerStrings
        }
        let rewardStrings = numberRecognizer.recognizedStrings(
            in: cgImage,
            topLeftROI: CGRect(
                x: Double(image.width) * 0.54,
                y: Double(image.height) * 0.39,
                width: Double(image.width) * 0.24,
                height: Double(image.height) * 0.18
            )
        )
        let dialogueStrings = numberRecognizer.recognizedStrings(
            in: cgImage,
            topLeftROI: CGRect(
                x: Double(image.width) * 0.17,
                y: Double(image.height) * 0.60,
                width: Double(image.width) * 0.66,
                height: Double(image.height) * 0.24
            )
        )
        // A mozgó feladatbuborék kicsúszott az öt régi OCR-kivágás közül.
        // Egy összefüggő játéktér-OCR lefedi az oldalra tolódott Deep Mines
        // és Titan szöveget is; az egyedi kulcsszavas ellenőrzés megmarad.
        let titanQuestStrings = numberRecognizer.recognizedStrings(
            in: cgImage,
            topLeftROI: CGRect(
                x: 0,
                y: Double(image.height) * 0.03,
                width: Double(image.width),
                height: Double(image.height) * 0.86
            )
        )
        let centralLongRespawnTimerCount = dialogueStrings.filter { raw in
            let lower = raw.lowercased()
            return lower.contains("h") && lower.contains("m") &&
                lower.filter(\.isNumber).count >= 2
        }.count
        let titanQuestText = titanQuestStrings.joined(separator: " ").lowercased()
        let shopVisible = titanQuestStrings.contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "SHOP" }
        let shop = shopInspector.inspect(cgImage, visible: shopVisible)
        let discoveredChestCount = parseWorldChestDiscoveryCount(titanQuestText)
        if let discoveredChestCount,
           discoveredChestCount > learnedDiscoveredChestCount {
            learnedDiscoveredChestCount = discoveredChestCount
            persistKnowledge()
        }
        let titanSubjectVisible = titanQuestText.contains("titan") ||
            titanQuestText.contains("power")
        let titanGemInstructionVisible = titanQuestText.contains("gem") &&
            (titanQuestText.contains("collect") || titanQuestText.contains("unleash"))
        let titanCounterVisible = titanQuestText.contains("/7") ||
            titanQuestText.contains("0/7")
        // Az oltár buboréka függőlegesen követi a karaktert. A 124335-ös élő
        // futásban a teljes, egyedi feladatmondat stabilan felismerődött, miközben
        // a 0/7 sor a régi ROI alsó szélén kívülre került. A Titan + gemutasítás
        // együtt önmagában biztosabb állapotjel, mint a mozgó számlálósor.
        let titanGemQuestVisible =
            (titanSubjectVisible && titanGemInstructionVisible) ||
            titanCounterVisible
        // A Deep Mines anti-stone feladat ugyanabban a karakterközeli fekete
        // buborékban jelenik meg, mint a Titan-utasítás. A 0/1 számláló közvetlenül
        // a HP OCR-régiójába lógott, és teljes zöld csík mellett 1 HP-nak látszott.
        // A Deep szó több élő képen Hines/Nines/Wines alakra torzult, az egyedi
        // "anti-stone potion" kifejezés viszont elég stabil állapotazonosító.
        let deepMinesPotionInstructionVisible =
            (titanQuestText.contains("anti-stone") &&
             titanQuestText.contains("deep mines") && titanQuestText.contains("0/1")) ||
            titanQuestText.contains("anti-stone") && titanQuestText.contains("potion") ||
            titanQuestText.contains("potion") &&
                (titanQuestText.contains("deep") || titanQuestText.contains("mines") ||
                 titanQuestText.contains("hines") || titanQuestText.contains("nines") ||
                 titanQuestText.contains("wines"))
        // A jelenlegi 0/1 állapot zárt kaput jelent. Ha később biztos `1/1`
        // jelenik meg, a régi hűtés nem tarthatja távol a karaktert a már
        // teljesített követelményű kaputól; a célzott visszatérés ismét engedett.
        let deepMinesPotionQuestVisible = deepMinesPotionInstructionVisible &&
            !titanQuestText.contains("1/1")
        let questHealthOccluded = (titanGemQuestVisible || deepMinesPotionQuestVisible) &&
            !localizedPlayerHealthVisible
        let equipmentPanelVisible =
            (titanQuestText.contains("inventory") && titanQuestText.contains("equipped")) ||
            (titanQuestText.contains("attack cooldown") && titanQuestText.contains("damage"))
        let lockedIslandStrings = numberRecognizer.recognizedStrings(
            in: cgImage,
            topLeftROI: CGRect(
                x: 0,
                y: Double(image.height) * 0.34,
                width: Double(image.width) * 0.34,
                height: Double(image.height) * 0.30
            )
        )
        let lockedIslandText = lockedIslandStrings.joined(separator: " ").uppercased()
        let island4WeaponSlotLockVisible = lockedIslandText.contains("UNLOCK") ||
            (lockedIslandText.contains("ISLAND") && lockedIslandText.contains("4"))
        // A Dusty Gulch narancsszínű kanyon-biomját ettől a globális
        // fegyverhely-felirattól teljesen függetlenül mérjük.
        var orangeTerrainSamples = 0
        var terrainSamples = 0
        for sampleY in stride(
            from: Int(Double(image.height) * 0.18),
            to: Int(Double(image.height) * 0.78),
            by: 18
        ) {
            for sampleX in stride(
                from: Int(Double(image.width) * 0.08),
                to: Int(Double(image.width) * 0.92),
                by: 18
            ) {
                let color = image.color(x: sampleX, y: sampleY)
                terrainSamples += 1
                if color.r >= 145,
                   color.g >= 55, color.g <= 170,
                   color.b <= 125,
                   color.r >= color.g + 35,
                   color.r >= color.b + 55 {
                    orangeTerrainSamples += 1
                }
            }
        }
        let orangeRockCoverage = terrainSamples > 0
            ? Double(orangeTerrainSamples) / Double(terrainSamples)
            : 0
        let orangeRockBiomeVisible = orangeRockCoverage >= 0.08
        let dialogueCanAdvance = dialogueStrings.contains {
            let lower = $0.lowercased()
            return lower.contains("tap to continue") || lower.contains("cursed girl")
        }
        let continueButtonVisible = dialogueStrings.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "continue"
        }
        let claimRewardVisible = dialogueStrings.contains {
            let normalized = $0.lowercased().filter { $0.isLetter || $0.isWhitespace }
            return normalized.contains("tap to claim")
        }
        // Az OPEN gomb a világ ládájával együtt mozog a képen, ezért nem lehet
        // rögzített középső ponthoz kötni. Előbb a nagy, lapos narancssárga
        // gombtéglalapokat keressük a játéktérben, majd minden jelölt saját
        // régióján kérünk OCR-t. A szín vagy a szöveg külön-külön nem elég.
        let openButtonCandidates = ComponentDetector.components(
            in: image,
            yRange: Int(Double(image.height) * 0.18)..<Int(Double(image.height) * 0.82)
        ) { r, g, b in
            r >= 210 && g >= 95 && g <= 210 && b <= 80 && r >= g + 40
        }.filter {
            $0.centerX >= Double(image.width) * 0.08 &&
                $0.centerX <= Double(image.width) * 0.90 &&
                $0.width >= 55 && $0.width <= 150 &&
                $0.height >= 14 && $0.height <= 58 &&
                Double($0.width) / Double($0.height) >= 2.0 &&
                $0.pixels >= 180
        }
        var openButtonCenter: Vector2?
        for candidate in openButtonCandidates.sorted(by: { $0.pixels > $1.pixels }) {
            let openStrings = numberRecognizer.recognizedStrings(
                in: cgImage,
                topLeftROI: CGRect(
                    x: Double(max(0, candidate.minX - 10)),
                    y: Double(max(0, candidate.minY - 8)),
                    width: Double(min(image.width - 1, candidate.maxX + 10) - max(0, candidate.minX - 10) + 1),
                    height: Double(min(image.height - 1, candidate.maxY + 8) - max(0, candidate.minY - 8) + 1)
                )
            )
            let normalized = openStrings.map { $0.uppercased().filter(\.isLetter) }
            if normalized.contains(where: { $0 == "OPEN" || $0 == "NEDU" }) {
                openButtonCenter = Vector2(x: candidate.centerX, y: candidate.centerY)
                break
            }
        }
        let openButtonVisible = openButtonCenter != nil

        // A világban álló láda már jóval az OPEN gomb megjelenése előtt látszik:
        // ezüstfehér, hordószerű testét sárga-arany fény veszi körül. A fehér
        // csontokat, feliratokat és lakatokat a közeli aranyfény hiánya szűri ki,
        // a rögzített oldalsó/alsó UI-sáv pedig nem része a keresési területnek.
        let worldChestDetection: (
            direction: Vector2?, candidate: IntRect?, goldSamples: Int?,
            sparkleSamples: Int?, brightGlowSamples: Int?
        ) = {
            let silverComponents = ComponentDetector.components(
                in: image,
                yRange: Int(Double(image.height) * 0.18)..<Int(Double(image.height) * 0.86)
            ) { r, g, b in
                r >= 160 && g >= 150 && b >= 125 &&
                    abs(r - g) <= 55 && abs(g - b) <= 75
            }.filter {
                $0.centerX >= Double(image.width) * 0.08 &&
                    $0.centerX <= Double(image.width) * 0.90 &&
                    $0.width >= 40 && $0.width <= 90 &&
                    $0.height >= 25 && $0.height <= 60 &&
                    Double($0.width) / Double($0.height) >= 1.30 &&
                    $0.pixels >= 450 &&
                    hypot($0.centerX - mapCenter.x, $0.centerY - mapCenter.y) > mapRadius + 24 &&
                    hypot(
                        $0.centerX - Double(image.width) * 0.5,
                        $0.centerY - Double(image.height) * 0.515
                    ) >= 120
            }

            var best: (
                component: IntRect, score: Int, goldSamples: Int,
                sparkleSamples: Int, brightGlowSamples: Int
            )?
            for component in silverComponents {
                let minX = max(Int(Double(image.width) * 0.06), component.minX - 42)
                let maxX = min(Int(Double(image.width) * 0.91), component.maxX + 42)
                let minY = max(Int(Double(image.height) * 0.16), component.minY - 42)
                let maxY = min(Int(Double(image.height) * 0.88), component.maxY + 42)
                var goldSamples = 0
                var sparkleSamples = 0
                var brightGlowSamples = 0
                for y in stride(from: minY, through: maxY, by: 2) {
                    for x in stride(from: minX, through: maxX, by: 2) {
                        let c = image.color(x: x, y: y)
                        if c.r >= 205, c.g >= 120, c.g <= 225, c.b <= 105,
                           c.r >= c.g + 20, c.g >= c.b + 40 {
                            goldSamples += 1
                        }
                        let outsideSilverBody = x < component.minX - 3 || x > component.maxX + 3 ||
                            y < component.minY - 3 || y > component.maxY + 3
                        if outsideSilverBody,
                           c.r >= 235, c.g >= 228, c.b >= 205,
                           max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)) <= 45 {
                            sparkleSamples += 1
                        }
                        if outsideSilverBody,
                           c.r >= 240, c.g >= 150, c.g <= 225, c.b <= 65,
                           c.r >= c.g + 25, c.g >= c.b + 85 {
                            brightGlowSamples += 1
                        }
                    }
                }
                guard goldSamples >= 250,
                      sparkleSamples >= 6,
                      brightGlowSamples >= 4 else { continue }
                let score = goldSamples * 3 + sparkleSamples * 20 +
                    brightGlowSamples * 12 + component.pixels
                if best == nil || score > best!.score {
                    best = (component, score, goldSamples, sparkleSamples, brightGlowSamples)
                }
            }
            guard let best else { return (nil, nil, nil, nil, nil) }
            return (
                Vector2(
                    x: best.component.centerX - Double(image.width) * 0.5,
                    y: best.component.centerY - Double(image.height) * 0.515
                ).normalized,
                best.component,
                best.goldSamples,
                best.sparkleSamples,
                best.brightGlowSamples
            )
        }()
        let worldChestDirection = worldChestDetection.direction
        let isTimerText: (String) -> Bool = { text in
            let lower = text.lowercased()
            let digitCount = lower.filter(\.isNumber).count
            return lower.contains("m") && (lower.contains("s") || digitCount >= 2)
        }
        let narrowPlayerTimer = playerStrings.contains(where: isTimerText)
        let nearbyTimerArc = greenComponents.contains {
            $0.width >= 4 && $0.width <= 22 &&
            $0.height >= 2 && $0.height <= 12 &&
            $0.centerX >= Double(image.width) * 0.50 &&
            $0.centerX <= Double(image.width) * 0.60 &&
            $0.centerY >= Double(image.height) * 0.52 &&
            $0.centerY <= Double(image.height) * 0.62
        }
        let centeredShortTimer = titanQuestStrings.contains {
            let lower = $0.lowercased()
            return !lower.contains("h") && isTimerText($0)
        }
        // A 300-szíves kaktusz halála után a `5m49s` szöveg közvetlenül a
        // játékos alatt jelent meg, de a szűk HP-ROI nem látta; a tágabb Titan-
        // ROI igen. A közeli zöld körívvel együtt ez biztos harczár. A háttérben
        // látható 8 órás körök nem kapják meg ezt az ágat, ezért nem zárhatnak le
        // egy másik, még élő kaktuszt.
        let nearbyRespawnTimer = narrowPlayerTimer || (nearbyTimerArc && centeredShortTimer)
        let detectedReward = rewardStrings.compactMap(parseRewardValue).map { rawValue in
            // Élő példa: a képen látható „+1 [kék fejsze]” szöveget a Vision
            // „+12”-nek olvasta, mert az ikon egy részét záró kettesnek vette.
            // A közvetlenül megelőző cél statértéke független ellenőrzés.
            guard expectedStatRewardFrames > 0,
                  let expectedStatRewardValue,
                  rawValue != expectedStatRewardValue,
                  String(rawValue).hasPrefix(String(expectedStatRewardValue)) else {
                return rawValue
            }
            return expectedStatRewardValue
        }.max()
        if let detectedReward {
            if !rewardWasVisible { rewardSequence += 1 }
            rewardWasVisible = true
            rememberedRewardValue = detectedReward
            rememberedRewardFrames = 30
        } else {
            rewardWasVisible = false
            if rememberedRewardFrames > 0 {
                rememberedRewardFrames -= 1
            } else {
                rememberedRewardValue = nil
            }
        }
        // Az OCR több sort is adhat; közelharcban az első gyakran az ellenfél
        // száma, miközben a másodikban ott a helyes játékos-HP (pl. "25", "178").
        let rawHealthCandidates = playerStrings.flatMap(parseHealthValues)
        var healthCandidates = rawHealthCandidates.filter { $0 <= learnedMaximumDisplayedHP + 60 }
        let timerTextVisible = playerStrings.contains {
            let lower = $0.lowercased()
            return lower.contains("m") || lower.contains("h")
        }
        let unexpectedLetterInTinyHealthOCR = learnedMaximumDisplayedHP >= 1_000 &&
            !healthCandidates.isEmpty &&
            healthCandidates.allSatisfy { $0 <= max(30, learnedMaximumDisplayedHP / 20) } &&
            playerStrings.contains { rawText in
                let lower = rawText.lowercased()
                let containsLetter = lower.unicodeScalars.contains {
                    CharacterSet.letters.contains($0)
                }
                return containsLetter &&
                    !lower.contains("k") &&
                    !lower.contains("m") &&
                    !lower.contains("h") &&
                    !lower.contains("s")
            }
        if unexpectedLetterInTinyHealthOCR {
            // A játék K-val rövidített, stilizált saját HP-ját a Vision
            // néha teljesen betűkké bontja, de egyetlen görbét 8-asnak tart:
            // élő minták `BET`, `X8ET`, `8E` a látható 3.38K helyett.
            // A valódi kritikus `8` pusztán szám, ezért továbbra is átjut;
            // a K-/idősuffixes szövegeket a meglévő külön ágak kezelik.
            healthCandidates = []
        }
        if shopVisible || expandedMapVisible || equipmentPanelVisible || (popupClose != nil && playerBar == nil) {
            // Az inventory és a tárgyrészletező modal ugyanarra a képernyőrészre
            // rajzol számokat, mint ahol játék közben a HP OCR-régiója van.
            // Élő példa: a Bat Cleaver „DAMAGE PER COPY 50” értékét a rendszer
            // 50 HP-nak olvasta. Nyitott, biztosan bezárható felugró ablakban a
            // harci HP nem értelmezhető, ezért ezek a számok nem frissíthetik a
            // tartós HP-memóriát.
            healthCandidates = []
        }
        if questHealthOccluded {
            // Mindkét fekete feladatbuborék pontosan a játékos HP-feliratára
            // takar. A Titan `0/7` sora 70, a Deep Mines `0/1` sora 1 hamis
            // HP-t adott. Egy részleges zöld komponens ilyenkor nem teszi az
            // overlay számát életerővé; a memória és a következő tiszta kép a
            // hiteles forrás.
            healthCandidates = []
        }
        // A `230318-play/91-107` sorban a 4,31K/500-as szívfa eltűnése után a
        // saját zöld HP-csík fölött legalább hat képen `2.47K` állt. A
        // korábbi maximumszűrő minden, +60-nál nagyobb értéket még a konszenzus
        // előtt kidobott, ezért a bizonyított 1.97K→2.47K (+500) jutalom sem
        // tanulódhatott meg. Nagy maximumot csak öt, egymáshoz közeli, biztos
        // saját csíkhoz tartozó OCR-kép fogadhat el; a felső korlát kiszűri a `12.47K`
        // és hasonló előtagzajt. Ez nem egyképes jutalom-heurisztika, hanem
        // közvetlenül a tartós új saját HP-kijelzés konszenzusa.
        let roundedHealthOCR = playerStrings.contains { $0.lowercased().contains("k") }
        // A repeated corrupt glyph is not independent confirmation: 7.06K
        // became `740GKC`/`740GKI` five times between clean 7.06K frames.
        // Keep the tolerant current-HP parser, but never learn a larger maximum
        // from text containing letters other than the numeric K suffix.
        let reliableMaximumCandidates = playerStrings.filter { text in
            !text.lowercased().unicodeScalars.contains {
                CharacterSet.letters.contains($0) && $0 != "k"
            }
        }.flatMap(parseHealthValues)
        let largeMaximumCandidates = reliableMaximumCandidates.filter {
            $0 > learnedMaximumDisplayedHP + (roundedHealthOCR ? 30 : 60) &&
                $0 <= learnedMaximumDisplayedHP + 800 &&
                Double($0) <= Double(learnedMaximumDisplayedHP) * 1.60
        }
        if popupClose == nil, !equipmentPanelVisible, !expandedMapVisible, !shopVisible,
           !questHealthOccluded,
           playerBar != nil,
           let largeCandidate = largeMaximumCandidates.min() {
            if let pending = pendingLargeMaximumValue,
               abs(pending - largeCandidate) <= 35 {
                pendingLargeMaximumFrames += 1
                pendingLargeMaximumValue = Int(round(Double(pending + largeCandidate) / 2.0 / 10.0)) * 10
            } else {
                pendingLargeMaximumValue = largeCandidate
                pendingLargeMaximumFrames = 1
            }
            pendingLargeMaximumMissFrames = 0
            if pendingLargeMaximumFrames >= 5,
               let confirmedLargeMaximum = pendingLargeMaximumValue {
                learnedMaximumDisplayedHP = confirmedLargeMaximum
                maximumIncreaseSequence += 1
                pendingLargeMaximumFrames = 0
                pendingLargeMaximumValue = nil
                pendingLargeMaximumMissFrames = 0
                pendingSmallMaximumFrames = 0
                pendingSmallMaximumValue = nil
                lastDisplayedHP = confirmedLargeMaximum
                healthCandidates = [confirmedLargeMaximum]
                persistKnowledge()
            }
        } else if shopVisible || expandedMapVisible || equipmentPanelVisible || popupClose != nil || questHealthOccluded {
            pendingLargeMaximumFrames = 0
            pendingLargeMaximumValue = nil
            pendingLargeMaximumMissFrames = 0
        } else if reliableMaximumCandidates.contains(where: { $0 <= learnedMaximumDisplayedHP }),
                  pendingLargeMaximumFrames > 0 {
            // A clean old/lower reading contradicts an unconfirmed increase;
            // do not accumulate repeated noise around it into a new maximum.
            pendingLargeMaximumFrames = 0
            pendingLargeMaximumValue = nil
            pendingLargeMaximumMissFrames = 0
        } else if pendingLargeMaximumFrames > 0 {
            // A K-kijelzés Vision-olvasata élőben `2.47K`, `2147K` és
            // `12.47K` között váltakozott. Ezekből csak az első érvényes, de a
            // hibás köztes képek nem cáfolják a többképes saját-HP konszenzust.
            // Tizenkét egymást követő találat nélküli kép viszont már új állapot.
            pendingLargeMaximumMissFrames += 1
            if pendingLargeMaximumMissFrames >= 12 {
                pendingLargeMaximumFrames = 0
                pendingLargeMaximumValue = nil
                pendingLargeMaximumMissFrames = 0
            }
        }
        let hasDecimalHealthOCR = playerStrings.contains {
            $0.contains(".") || $0.contains(":") || $0.contains(",")
        }
        if let pixelHealthFraction, healthCandidates.count > 1, hasDecimalHealthOCR {
            // A zöld csík bal széle a 85.8/88.8 kijelzést néha 185.8/188.8-
            // nak olvastatja. Ilyenkor a 85/185 jelöltek közül a pixelarányhoz
            // közeli nagyságrend az erősebb bizonyíték.
            let pixelConsistentCandidates = healthCandidates.filter {
                abs(Double($0) / Double(learnedMaximumDisplayedHP) - pixelHealthFraction) <= 0.18
            }
            if !pixelConsistentCandidates.isEmpty {
                healthCandidates = pixelConsistentCandidates
            }
        }
        if let pixelHealthFraction, pixelHealthFraction >= 0.65,
           !localizedPlayerHealthVisible {
            // Ha a zöld csík nagyrészt tele van, a timer 3/55 jelöltjei nem
            // versenyezhetnek a helyes 214-gyel pusztán azért, mert egy korábbi
            // OCR-hiba alacsony temporális előzményt hagyott. Csak akkor szűrünk,
            // ha marad a csíkkal összhangban lévő numerikus jelölt.
            let minimumNumericFraction = max(0.35, pixelHealthFraction - 0.30)
            let pixelConsistentCandidates = healthCandidates.filter {
                Double($0) / Double(learnedMaximumDisplayedHP) >= minimumNumericFraction
            }
            if !pixelConsistentCandidates.isEmpty {
                healthCandidates = pixelConsistentCandidates
            } else {
                // Példa: a teljes csík és HP fölött csak "4h 57m" olvasható.
                // A 4/57 egyikét sem szabad életerőnek beállítani; pontos szám
                // nélkül az elemzés a pixelHealthFraction arányára támaszkodik.
                healthCandidates = []
            }
        }
        if let pixelHealthFraction, pixelHealthFraction >= 0.85 {
            // A lila sziklazónában a stilizált 778-at a Vision ismételten
            // 82L0/820/821-nek olvasta. A maximumőr eleve nem fogad 30-nál
            // nagyobb, jutalom nélküli ugrást; ugyanaz a lehetetlen jelölt az
            // aktuális HP-t se írhatja felül egyetlen képre. Valódi nagyobb
            // maximum csak a külön jutalom-/konszenzusfolyamatban tanulható meg.
            healthCandidates = healthCandidates.filter {
                $0 <= learnedMaximumDisplayedHP + 30
            }
        }
        if healthCandidates.isEmpty {
            // A nagy esés megerősítése csak egymást követő, valódi OCR-
            // mérésekből állhat. Egy üres/takart képkockán át nem visszük
            // tovább a korábbi gyanús értéket.
            pendingLargeDropFrames = 0
            pendingLargeDropValue = nil
        }
        let playerDisplayedHP: Int?
        if let lastDisplayedHP, !healthCandidates.isEmpty {
            let closest = healthCandidates.min { abs($0 - lastDisplayedHP) < abs($1 - lastDisplayedHP) }
            playerDisplayedHP = closest.map { candidate in
                // Egyetlen tiszta tizedes-K sor pontosan a zöld csíkon erősebb,
                // mint az animációfüggő pixel és a háromképes konstans szám.
                // Valódi 320-as találatsor nem lehet örökké régi, magas HP.
                if preciseLocalizedHealthVisible, candidate <= learnedMaximumDisplayedHP {
                    pendingLargeDropFrames = 0
                    pendingLargeDropValue = nil
                    pendingLargeRiseFrames = 0
                    pendingLargeRiseValue = nil
                    return candidate
                }
                if abs(candidate - lastDisplayedHP) <= 40 {
                    pendingLargeDropFrames = 0
                    pendingLargeDropValue = nil
                    pendingLargeRiseFrames = 0
                    pendingLargeRiseValue = nil
                    return candidate
                }
                // Közeli ellenfelek számai időnként belelógnak a játékos OCR-
                // régiójába (élő példa: valós ~124 mellett "T21"). Egyetlen
                // 60 HP-nál nagyobb esést nem fogadunk el; három egymást követő,
                // egymáshoz közeli alacsony mérés már valódi halál/respawn-
                // sorozat lehet. Kettő kevés: a fa újratermelődési időzítője
                // élőben két képkockán át olvastatta 232 helyett 32-nek a HP-t.
                if candidate < lastDisplayedHP - 60 {
                    pendingLargeRiseFrames = 0
                    pendingLargeRiseValue = nil
                    if (nearbyRespawnTimer || timerTextVisible),
                       lastDisplayedHP >= Int(Double(learnedMaximumDisplayedHP) * 0.75),
                       candidate <= Int(Double(learnedMaximumDisplayedHP) * 0.35) {
                        // A közeli kör szövege a 467-ből ismételten 7/37-et
                        // hagyott. Ez ugyanannak a már felismert takarásnak a
                        // része, ezért nem gyűjthet háromképes nagy-esés
                        // megerősítést sem.
                        pendingLargeDropFrames = 0
                        pendingLargeDropValue = nil
                        return lastDisplayedHP
                    }
                    // Nagy OCR-esést nem gyorsítunk fel a pixelcsíkkal: a
                    // respawnkör egyszerre takarhatja mindkettőt, így nem két
                    // független bizonyíték. Közeli támadásnál a stratégia a
                    // pixeles esésre ettől függetlenül azonnal reagál.
                    if !localizedPlayerHealthVisible,
                       let pixelHealthFraction,
                       pixelHealthFraction >= 0.65,
                       Double(candidate) / Double(learnedMaximumDisplayedHP) <= 0.35 {
                        pendingLargeDropFrames = 0
                        pendingLargeDropValue = nil
                        return lastDisplayedHP
                    }
                    if let previousDrop = pendingLargeDropValue,
                       abs(previousDrop - candidate) <= (localizedPlayerHealthVisible
                           ? max(25, learnedMaximumDisplayedHP * 8 / 100) : 25) {
                        pendingLargeDropFrames += 1
                    } else {
                        pendingLargeDropFrames = 1
                    }
                    pendingLargeDropValue = candidate
                    if pendingLargeDropFrames < 3 { return lastDisplayedHP }
                    pendingLargeDropFrames = 0
                    pendingLargeDropValue = nil
                    return candidate
                }
                pendingLargeDropFrames = 0
                pendingLargeDropValue = nil
                // A zöld gyógyítómedence és az újraéledés nagyon gyorsan
                // visszaviheti az értéket a megtanult maximum közelébe. Egy
                // tiszta 3 jegyű, felső tartománybeli értéket ezért akkor is
                // elfogadunk, ha a megelőző, alacsony HP-tól nagyot ugrik.
                if candidate >= Int(Double(learnedMaximumDisplayedHP) * 0.75) {
                    pendingLargeRiseFrames = 0
                    pendingLargeRiseValue = nil
                    return candidate
                }
                if candidate > lastDisplayedHP + 60 {
                    if let previousRise = pendingLargeRiseValue,
                       abs(previousRise - candidate) <= 25 {
                        pendingLargeRiseFrames += 1
                    } else {
                        pendingLargeRiseFrames = 1
                    }
                    pendingLargeRiseValue = candidate
                    if pendingLargeRiseFrames < 2 { return lastDisplayedHP }
                    pendingLargeRiseFrames = 0
                    pendingLargeRiseValue = nil
                    return candidate
                }
                pendingLargeRiseFrames = 0
                pendingLargeRiseValue = nil
                if let pixelHealthFraction {
                    let numericFraction = min(1, Double(candidate) / Double(learnedMaximumDisplayedHP))
                    if abs(numericFraction - pixelHealthFraction) <= 0.25 { return candidate }
                }
                return lastDisplayedHP
            }
        } else {
            let fullBarCandidates = healthCandidates.filter { $0 >= 90 }
            let initialCandidates = fullBarCandidates.isEmpty ? healthCandidates : fullBarCandidates
            playerDisplayedHP = initialCandidates.min {
                abs($0 - learnedMaximumDisplayedHP) < abs($1 - learnedMaximumDisplayedHP)
            } ?? lastDisplayedHP
        }
        if let playerDisplayedHP {
            let plausibleMaximumIncrease = learnedMaximumDisplayedHP == 100
                ? playerDisplayedHP <= 160
                // A 20-as szívértékű fa közvetlen +20 max-HP jutalmat adott
                // (340 -> 360). A korábbi +15-ös őr ezt bizonyított képi/OCR
                // egyezés mellett sem mentette el a következő futásnak.
                : playerDisplayedHP <= learnedMaximumDisplayedHP + 30
            // Csak a jelenlegi képből ténylegesen kiolvasott szám igazolhat új
            // maximumot. A playerDisplayedHP szándékosan megtarthatja az előző
            // értéket egy hibás képen; ez a memória nem lehet a második
            // megerősítés (a 768 utáni egyetlen 781-es OCR-zaj ezt tette).
            let candidateIncrease = playerDisplayedHP - learnedMaximumDisplayedHP
            let rewardBackedThirty = roundedHealthOCR || candidateIncrease != 30 ||
                rememberedRewardValue == 30 ||
                expectedStatRewardValue == 30
            if playerDisplayedHP > learnedMaximumDisplayedHP,
               plausibleMaximumIncrease,
               rewardBackedThirty,
               healthCandidates.contains(playerDisplayedHP) {
                let increase = candidateIncrease
                // Egyetlen képen a teljes 463-at 464-nek olvasta a Vision,
                // jutalom nélkül, majd rögtön visszatért 463-ra. A +3/+4/+10/+20
                // közvetlen lépcsőket továbbra is azonnal elfogadjuk. Az általános
                // +N OCR azonban a piros szív és a kék fejsze jutalmat nem tudja
                // megkülönböztetni. Emiatt minden +1/+2/+3 HP-jelölt csak két
                // egymást követő azonos OCR után válik tartós maximummá; így egy
                // fejsze melletti vagy pusztán terepi egyképes HP-zaj sem szennyezi
                // a tudást. A 778→781 téves +3 élőben másodszor is előfordult.
                // A `715→745` egyképes OCR-zaj pontosan belefért a történeti
                // +30-as felső korlátba, ezért jutalom nélkül tartós állapot lett.
                // Egyképes gyorsút csak a közvetlenül bizonyított elemi
                // +4/+5/+10/+20 lépcsőknek jár. Az összetett csoportugrások
                // (+6/+9/+14 stb.) valósak lehetnek, de két egymást követő,
                // azonos teljes-HP OCR-rel kell őket megerősíteni.
                let oneFrameSupportedIncrease = !roundedHealthOCR && [4, 5, 10, 20].contains(increase)
                if increase <= 2 || !oneFrameSupportedIncrease {
                    if pendingSmallMaximumValue == playerDisplayedHP {
                        pendingSmallMaximumFrames += 1
                    } else {
                        pendingSmallMaximumValue = playerDisplayedHP
                        pendingSmallMaximumFrames = 1
                    }
                    // A havas kapunál a stilizált 778 három egymást követő
                    // képen is 779 lett, majd visszaállt. A kis +1/+2/+3
                    // növekedésekhez ezért öt tiszta, azonos aktuális OCR kell.
                    // A stilizált 868 középső 6-osát az OCR sok képen 9-nek
                    // olvasta. A fenti kapu ezért a pontos +30 jelöltet csak
                    // közvetlen vagy a célból előre ismert 30-as jutalom mellett
                    // engedi ide; ekkor is az ötképes őr erősíti meg.
                    let requiredConfirmationFrames = (roundedHealthOCR || increase <= 3 || increase == 30) ? 5 : 2
                    if pendingSmallMaximumFrames >= requiredConfirmationFrames {
                        learnedMaximumDisplayedHP = playerDisplayedHP
                        maximumIncreaseSequence += 1
                        pendingSmallMaximumFrames = 0
                        pendingSmallMaximumValue = nil
                        persistKnowledge()
                    }
                } else {
                    learnedMaximumDisplayedHP = playerDisplayedHP
                    maximumIncreaseSequence += 1
                    pendingSmallMaximumFrames = 0
                    pendingSmallMaximumValue = nil
                    persistKnowledge()
                }
            } else if playerDisplayedHP <= learnedMaximumDisplayedHP {
                pendingSmallMaximumFrames = 0
                pendingSmallMaximumValue = nil
            }
            lastDisplayedHP = playerDisplayedHP
        }
        let numericHealthFraction = playerDisplayedHP.map {
            min(1, Double($0) / Double(learnedMaximumDisplayedHP))
        }
        let hasCurrentNumericMeasurement = playerDisplayedHP.map {
            healthCandidates.contains($0)
        } ?? false
        let redBarNearPlayer = redBars.contains { bar in
            let entityY = Double(bar.maxY) + max(28, min(42, Double(bar.width) * 0.60))
            return hypot(
                bar.centerX - Double(image.width) * 0.50,
                entityY - Double(image.height) * 0.515
            ) <= 170
        }
        recentRedThreatFrames = redBarNearPlayer ? 8 : max(0, recentRedThreatFrames - 1)
        let unsupportedPixelCrashGuard = !hasCurrentNumericMeasurement &&
            recentRedThreatFrames == 0 &&
            (numericHealthFraction ?? 0) >= 0.85 &&
            (pixelHealthFraction ?? 1) <= (numericHealthFraction ?? 0) - 0.20
        // A friss, elfogadott számszerű HP a pontosabb mérés. A pixelcsíkot
        // csak akkor használjuk taktikai főértékként, ha az adott képen nincs
        // elfogadott numerikus mérés. Így egy háttérben lévő zöld UI-darab vagy
        // túl nagyra tanult csíkszélesség nem tarthatja örökké menekülésben a
        // botot, miközben a tiszta OCR már egyértelmű gyógyulást mutat.
        let healthFraction: Double?
        let healthSource: String
        if hasCurrentNumericMeasurement, let numericHealthFraction {
            healthFraction = numericHealthFraction
            healthSource = "ocr-current"
        } else if unsupportedPixelCrashGuard, let numericHealthFraction {
            healthFraction = numericHealthFraction
            healthSource = timerTextVisible
                ? "ocr-memory-timer-guard"
                : "ocr-memory-no-threat-guard"
        } else if let pixelHealthFraction {
            healthFraction = pixelHealthFraction
            healthSource = "pixel-fallback"
        } else {
            healthFraction = numericHealthFraction
            healthSource = numericHealthFraction == nil ? "unavailable" : "ocr-memory"
        }

        let playerX = Double(image.width) * 0.50
        let playerY = Double(image.height) * 0.515
        var viableTargets = redBars.prefix(10).compactMap { bar -> Target? in
            // A bal oldali 2x Reward/szív panel 590–609 körül két vörös,
            // fekete kontúros UI-csíkot rajzol. A 093024 élő futásban ezek
            // 132 és 2 HP-s célként, egyszer pedig bossként jelentek meg.
            // Ez rögzített HUD-terület, nem világobjektum; a panel által amúgy
            // is takart keskeny sávot már a Target létrehozása előtt kizárjuk.
            let lowerLeftRewardPanelBar = bar.maxX <= Int(Double(image.width) * 0.14) &&
                bar.centerY >= Double(image.height) * 0.67 &&
                bar.centerY <= Double(image.height) * 0.72
            if lowerLeftRewardPanelBar { return nil }
            // A lény közepe a HP-csík alatt van; a szintszám és a minimap pontjai így kiesnek.
            let entityX = bar.centerX
            let entityY = Double(bar.maxY) + max(28, min(42, Double(bar.width) * 0.60))
            let dx = entityX - playerX
            let dy = entityY - playerY
            let distance = hypot(dx, dy)
            guard (distance >= 45 || isOverlappingContactBar(bar, image: image)),
                  distance <= Double(image.height) * 0.64 else { return nil }
            // A valódi cél-HP csíkot vastag, közel fekete kontúr keretezi. A
            // vörös sziklaívek vízszintes élei ugyan átmehetnek a puszta
            // vörös-komponens geometriáján, de nincs körülöttük ilyen UI-keret.
            // A mérőszámot először diagnosztikaként naplózzuk; a regressziós
            // képek alapján választott küszöbbel alább lesz belőle célkapu.
            var darkOutlineSamples = 0
            var outlineSamples = 0
            let outlineMinX = max(0, bar.minX - 3)
            let outlineMaxX = min(image.width - 1, bar.maxX + 3)
            let outlineMinY = max(0, bar.minY - 3)
            let outlineMaxY = min(image.height - 1, bar.maxY + 3)
            if outlineMinX <= outlineMaxX, outlineMinY <= outlineMaxY {
                for sampleY in outlineMinY...outlineMaxY {
                    for sampleX in outlineMinX...outlineMaxX {
                        let outsideRedBounds = sampleX < bar.minX || sampleX > bar.maxX ||
                            sampleY < bar.minY || sampleY > bar.maxY
                        guard outsideRedBounds else { continue }
                        let c = image.color(x: sampleX, y: sampleY)
                        outlineSamples += 1
                        if c.r <= 75, c.g <= 75, c.b <= 75 {
                            darkOutlineSamples += 1
                        }
                    }
                }
            }
            let barOutlineConfidence = outlineSamples > 0
                ? Double(darkOutlineSamples) / Double(outlineSamples)
                : 0
            // A teljes 023210-es replayben a hamis sziklaív öt egymást követő
            // képen pontosan 0, a leggyengébb vizuálisan igazolt valódi csík
            // 0,109 volt. A 0,06-os rés biztonságosan kizárja az ívet, miközben
            // a részben takart valódi HP-kereteket megtartja.
            guard barOutlineConfidence >= 0.06 else { return nil }
            let levelNumbers = numberRecognizer.integers(
                in: cgImage,
                topLeftROI: CGRect(x: bar.minX - 25, y: bar.minY - 34, width: 45, height: 32)
            )
            var hpStrings = numberRecognizer.recognizedStrings(
                in: cgImage,
                // A 1.22K felirat felső fele a csíkhoz túl közel kezdődő régi
                // régióból kilógott, és csak „7” maradt. Felfelé és oldalra is
                // nagyobb margó kell; a HP-jelöltek közül úgyis a legnagyobbat
                // választjuk, ezért egy bekerülő szintszám nem írja felül a HP-t.
                topLeftROI: CGRect(
                    x: bar.centerX - 42,
                    // Az alsó képszélen álló 67.5K boss felirata magasabban
                    // volt a csík fölött; a régi -18 margó csak a 3-as
                    // statikont látta. A -46 a teljes rövidített HP-t befogja.
                    y: Double(bar.minY) - 46,
                    width: 84,
                    height: Double(bar.height) + 64
                ),
                // The wider image context helps OCR; only text geometrically
                // centred on this bar is HP. The reward row is not a candidate.
                verticalCenterRange:(Double(bar.minY)-6)...(Double(bar.maxY)+5)
            )
            if (hpStrings.flatMap(parseTargetHealthValues).max() ?? 0) <= 20 || bar.minY < 65 {
                // Kicsi ablakban a széles ROI csak a fölötte álló stat-1-et
                // olvasta ki a látható 428/765 helyett. A csík saját sorát
                // külön, háromszoros méretben kérdezzük; a statikon kívül marad.
                let enlargedStrings = numberRecognizer.enlargedBarStrings(
                    in: cgImage,
                    topLeftROI: CGRect(x: bar.centerX - 43,
                        y: Double(bar.minY) - 6, width: 86,
                        height: Double(bar.height) + 12))
                // A képszéli széles ROI több egymás fölötti csíkot is lát.
                // A csík saját felnagyított sora elsődleges, ha explicit
                // tizedes K-alakot olvas: nem keverjük hozzá a hibás 11GK-t.
                let explicitThousands = enlargedStrings.filter {
                    $0.lowercased().contains("k") &&
                    ($0.contains(".") || $0.contains(":") || $0.contains(",")) &&
                    !parseTargetHealthValues($0).isEmpty
                }
                if bar.minY < 65, !explicitThousands.isEmpty {
                    hpStrings = explicitThousands
                } else {
                    hpStrings += enlargedStrings
                }
            }
            // Empty normal/tight OCR is not proof of an unknown threat. On
            // 205144 the clear1.22K row vanished at3x. Require agreement from
            // two distinct crops/scales; never trust the observed22/122K noise.
            if hpStrings.flatMap(parseTargetHealthValues).isEmpty,
               barOutlineConfidence>=0.12,(40...80).contains(bar.width),
               (5...12).contains(bar.height),bar.minY>90,
               Double(bar.maxY)<Double(image.height)*0.75 {
                func decimalK(_ strings:[String])->Set<Int> {
                    Set(strings.filter {
                        $0.lowercased().contains("k") &&
                        ($0.contains(".") || $0.contains(",") || $0.contains(":"))
                    }.flatMap(parseTargetHealthValues).filter{(800...30_000).contains($0)})
                }
                let tight=numberRecognizer.enlargedBarStrings(in:cgImage,
                    topLeftROI:CGRect(x:bar.minX-12,y:bar.minY-4,
                        width:bar.width+24,height:bar.height+8),scale:6)
                let padded=numberRecognizer.enlargedBarStrings(in:cgImage,
                    topLeftROI:CGRect(x:bar.minX-12,y:bar.minY-10,
                        width:bar.width+24,height:bar.height+20),scale:2)
                let agreement=decimalK(tight).intersection(decimalK(padded))
                if agreement.count==1,let hp=agreement.first {
                    hpStrings += tight.filter{parseTargetHealthValues($0).contains(hp)}
                }
            }
            // Az ablak címcsíkjánál hiányos szám nem igazolt nagy boss-HP.
            // Csak ebben a képszéli zónában vetjük el a pont nélküli K-alakot;
            // teljes látható 18.8K/67.5K és a világ többi része változatlan.
            if bar.minY < 65 {
                hpStrings.removeAll { text in
                    text.lowercased().contains("k") &&
                    !text.contains(".") && !text.contains(":") && !text.contains(",")
                }
            }
            // The shield label can wrap as two OCR rows: "0." then "5".
            // Remove only that adjacent, observed reward fragment, not a
            // standalone legitimate5HP measurement or a following64HP row.
            if hpStrings.count>=2 {
                for i in stride(from:hpStrings.count-2,through:0,by:-1) {
                    guard i+1<hpStrings.count else {continue}
                    let a=hpStrings[i].trimmingCharacters(in:.whitespacesAndNewlines)
                    let b=hpStrings[i+1].trimmingCharacters(in:.whitespacesAndNewlines)
                    if ["0.","0,","0:"].contains(a),["5","50"].contains(b) {
                        hpStrings.removeSubrange(i...i+1)
                    }
                }
            }
            let hpNumbers = hpStrings.flatMap(parseTargetHealthValues)
            let previous = previousTargets.min { left, right in
                hypot(left.x - entityX, left.y - entityY) < hypot(right.x - entityX, right.y - entityY)
            }.flatMap { hypot($0.x - entityX, $0.y - entityY) <= 85 ? $0 : nil }
            // A kék fejsze alakját a Vision a mellette álló 1-eshez ragasztva
            // 16-nak olvasta. Közvetlen jutalomképeken eddig csak az alábbi
            // statértékek bizonyítottak; a 100+ nyers számokat a külön bossőr
            // továbbra is levelNumbers-ból látja, itt viszont nem válhatnak
            // hamis célhozammá.
            let supportedStatLevels = Set([1, 2, 3, 4, 5, 10, 20])
            let detectedLevel = levelNumbers.first { supportedStatLevels.contains($0) }
            let level: Int?
            if let previousLevel = previous?.level, let detectedLevel, abs(previousLevel - detectedLevel) > 2 {
                level = previousLevel
            } else {
                level = detectedLevel ?? previous?.level
            }
            // A 67.5K alsó képszéli boss OCR-je helyesen 67 500-ra bomlott,
            // de a régi 5000-es technikai plafon utána kidobta. Nagy értéket
            // megőrzünk; a >=800-as bossőr úgyis kizárja a farmból.
            let rawDetectedHPBeforeLeadingDigitRecovery = hpNumbers
                .filter { $0 >= 1 && $0 <= 1_000_000 }
                .max()
            let leadingDecimalKWasClipped = hpStrings.contains { text in
                let compact = text
                    .lowercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return compact.contains("k") &&
                    (compact.hasPrefix(".") || compact.hasPrefix(":"))
            }
            let rawDetectedHP: Int?
            if let partialHP = rawDetectedHPBeforeLeadingDigitRecovery,
               partialHP < 1_000,
               let previousHP = previous?.displayedHP,
               previousHP >= 1_000,
               leadingDecimalKWasClipped {
                // A képszélről beúszó 1.22K páncélos feliratát a Vision
                // `.22K`/`:22K` alakban is adja. A játék 1000 alatt nem K-val
                // írja a HP-t, ezért az ilyen 220 nem valódi új érték. Ugyanazon
                // csík előző ezres részével állítjuk helyre (1220→.22K→1220).
                // Ugyanez általánosan megtartja például a 4.31K→:31K alakot is.
                let recovered = (previousHP / 1_000) * 1_000 + partialHP
                rawDetectedHP = abs(recovered - previousHP) <= 300
                    ? recovered
                    : partialHP
            } else {
                rawDetectedHP = rawDetectedHPBeforeLeadingDigitRecovery
            }
            // A normál célok HP-ja egy találat után tizedes lehet. A Vision a
            // `94.1` pontját időnként elhagyja, és `941`-et ad; a 136 HP-s
            // kaktuszt ettől a >=800-as bossőr tévesen bossnak minősítette.
            // Ha ugyanazon cél csíkja közben egyértelműen rövidült, a korábbi
            // HP alá eső háromjegyű tizedes nélküli alakot tizedként állítjuk
            // helyre (941 -> 94). Valódi, új bossnál nincs ilyen azonos-célú
            // csíkzsugorodás; a külön 500-as statikonőr ettől független marad.
            let detectedHP: Int?
            if let rawDetectedHP,
               (800...999).contains(rawDetectedHP),
               let previous,
               let previousHP = previous.displayedHP,
               bar.width <= previous.bar.width - 8 {
                let recoveredTenths = rawDetectedHP / 10
                if recoveredTenths >= 1,
                   recoveredTenths <= previousHP,
                   previousHP - recoveredTenths <= 100 {
                    detectedHP = recoveredTenths
                } else {
                    detectedHP = rawDetectedHP
                }
            } else {
                detectedHP = rawDetectedHP
            }
            let displayedHP: Int?
            let rawHPRepeated = rawDetectedHP.map { current in
                previous?.ocrStrings.flatMap(parseTargetHealthValues).contains(current) ?? false
            } ?? false
            let explicitDecimalThousandsConfirmed = hpStrings.contains { text in
                let normalized = text.lowercased()
                return normalized.contains("k") &&
                    (normalized.contains(".") || normalized.contains(":") || normalized.contains(","))
            } && (detectedHP ?? 0) >= 1_000
            if let previousHP = previous?.displayedHP,
               let detectedHP,
               detectedHP > previousHP + 40,
               !rawHPRepeated,
               !explicitDecimalThousandsConfirmed {
                // Ugyanazon ellenfél HP-ja harc közben nem nőhet többszörösére.
                // Ez a második védőháló a pontvesztett tizedes és összeragadt
                // OCR ellen, keskeny maradékcsíknál is. A képszélről beúszó
                // 291 HP-s fa első részleges OCR-je viszont csak appcímből
                // származó 1 volt. Két egymást követő azonos nyers 291 ezért
                // új célazonosságot igazol és feloldja ezt a lefelé ragasztást.
                displayedHP = previousHP
            } else if bar.width >= 45,
                      let previousHP = previous?.displayedHP,
                      let detectedHP,
                      abs(previousHP - detectedHP) > 40,
                      !rawHPRepeated,
                      !explicitDecimalThousandsConfirmed {
                displayedHP = previousHP
            } else {
                displayedHP = detectedHP ?? previous?.displayedHP
            }

            var brightFoliage = 0
            var foliageSamples = 0
            let foliageMinX = max(0, Int(entityX) - 26)
            let foliageMaxX = min(image.width - 1, Int(entityX) + 26)
            let foliageMinY = max(0, bar.maxY + 5)
            let foliageMaxY = min(image.height - 1, bar.maxY + 58)
            if foliageMinX <= foliageMaxX, foliageMinY <= foliageMaxY {
                for sampleY in stride(from: foliageMinY, through: foliageMaxY, by: 2) {
                    for sampleX in stride(from: foliageMinX, through: foliageMaxX, by: 2) {
                        let c = image.color(x: sampleX, y: sampleY)
                        foliageSamples += 1
                        if c.g >= 145, c.b >= 65, c.g >= c.r + 35, c.g >= c.b + 15 {
                            brightFoliage += 1
                        }
                    }
                }
            }
            let foliageConfidence = foliageSamples > 0
                ? Double(brightFoliage) / Double(foliageSamples)
                : 0

            // A cél statikonja közvetlenebb típusbizonyíték, mint a mögötte lévő
            // növényzet. A 10-szíves humanoidot korábban egy közeli türkiz bokor
            // tette 0,40 körüli „fává”. A szív/fejsze a szám mellett, közvetlenül
            // a HP-csík fölött van; ezt a keskeny régiót külön mintázzuk.
            var heartPixels = 0
            var axePixels = 0
            var iconSamples = 0
            let iconMinX = max(0, Int(bar.centerX) - 18)
            let iconMaxX = min(image.width - 1, Int(bar.centerX) + 31)
            let iconMinY = max(0, bar.minY - 28)
            let iconMaxY = min(image.height - 1, bar.minY - 5)
            if iconMinX <= iconMaxX, iconMinY <= iconMaxY {
                for sampleY in iconMinY...iconMaxY {
                    for sampleX in iconMinX...iconMaxX {
                        let c = image.color(x: sampleX, y: sampleY)
                        iconSamples += 1
                        if c.r >= 185, c.b >= 55, c.r >= c.g + 70, c.r >= c.b + 45 {
                            heartPixels += 1
                        }
                        if c.b >= 125, c.g >= 95, c.b >= c.r + 25, c.b >= c.g - 25 {
                            axePixels += 1
                        }
                    }
                }
            }
            let heartIconEvidence = iconSamples > 0
                ? Double(heartPixels) / Double(iconSamples)
                : 0
            let axeIconEvidence = iconSamples > 0
                ? Double(axePixels) / Double(iconSamples)
                : 0
            // A 499 HP-s fegyverhordozó humanoid statikonja nem a kék
            // fejszejutalom: a csík bal felső sarkánál egy külön, élénkzöld
            // fegyverkártya-ikon látszik. A korábbi, középre igazított régió
            // ennek nagy részét levágta. Szűk, balra tolt régióban a telített
            // zöld pixelek stabilan elkülönítik a sima füves háttértől.
            var weaponDropPixels = 0
            var weaponDropSamples = 0
            let weaponIconMinX = max(0, bar.minX - 4)
            let weaponIconMaxX = min(image.width - 1, bar.minX + 22)
            let weaponIconMinY = max(0, bar.minY - 28)
            let weaponIconMaxY = min(image.height - 1, bar.minY - 5)
            if weaponIconMinX <= weaponIconMaxX, weaponIconMinY <= weaponIconMaxY {
                for sampleY in weaponIconMinY...weaponIconMaxY {
                    for sampleX in weaponIconMinX...weaponIconMaxX {
                        let c = image.color(x: sampleX, y: sampleY)
                        weaponDropSamples += 1
                        if c.g >= 160,
                           c.g >= c.r + 60,
                           c.g >= c.b + 45,
                           c.r <= 130,
                           c.b <= 145 {
                            weaponDropPixels += 1
                        }
                    }
                }
            }
            let weaponDropIconEvidence = weaponDropSamples > 0
                ? Double(weaponDropPixels) / Double(weaponDropSamples)
                : 0
            // A Titan-terület lila rituálé-/portálobjektumán is van 200-as,
            // vörösnek érzékelt csík, de hosszan rajta állva sem sebződik.
            // A csík alatti nagy magenta aura elkülöníti a normál testektől.
            var magentaPixels = 0
            var bodySamples = 0
            let bodyMinX = max(0, Int(entityX) - 44)
            let bodyMaxX = min(image.width - 1, Int(entityX) + 44)
            let bodyMinY = max(0, bar.maxY + 6)
            let bodyMaxY = min(image.height - 1, bar.maxY + 82)
            if bodyMinX <= bodyMaxX, bodyMinY <= bodyMaxY {
                for sampleY in stride(from: bodyMinY, through: bodyMaxY, by: 2) {
                    for sampleX in stride(from: bodyMinX, through: bodyMaxX, by: 2) {
                        let c = image.color(x: sampleX, y: sampleY)
                        bodySamples += 1
                        if c.r >= 145, c.b >= 130,
                           c.r >= c.g + 40, c.b >= c.g + 35 {
                            magentaPixels += 1
                        }
                    }
                }
            }
            let objectiveStructureConfidence = bodySamples > 0
                ? Double(magentaPixels) / Double(bodySamples)
                : 0
            // A boss fölötti 500-as szívikon külön bizonyíték. A 4.31K HP
            // szöveg K-ja vagy vezető 4-ese a szűk OCR-régióban időnként
            // lemaradt, és a veszély 31 HP-s farmcéllá vált. A háromjegyű
            // statérték ezért a HP-OCR-től független boss-őr.
            // Sűrű csoportban a bal oldali szomszéd 253-as HP-ja belelóghat
            // a jelenlegi cél statikon-ROI-jába. Ha ugyanaz a szám a cél saját
            // HP-régiójában is szerepel, az nem független 500-as boss-statikon.
            // A valódi 500-as ikon a 4.31K/31 HP-OCR-től eltér, ezért megmarad.
            let independentBossLevelEvidence = levelNumbers.contains {
                // Közvetlenül bizonyított tartalék ikon a 4.31K boss 500-as
                // szíve (OCR-ben 501). A 20h-s timer a statikonmezőben 202-re
                // torzult; a korábbi 100-as alsó kapu ezt hamis bossá tette.
                ($0 == 500 || $0 == 501) && !hpNumbers.contains($0)
            }
            let rawBossLooksLikeKnownLevelConcatenation: Bool = {
                guard let previous,
                      let previousHP = previous.displayedHP,
                      previousHP < 800,
                      let previousLevel = previous.level,
                      let currentLevel = level,
                      previousLevel == currentLevel,
                      let detectedHP,
                      detectedHP >= 800,
                      displayedHP == previousHP,
                      !rawHPRepeated else { return false }
                let previousDigits = String(previousHP)
                return hpStrings.contains { text in
                    let digits = String(text.filter(\.isNumber))
                    return (digits.hasPrefix(previousDigits) || digits.hasSuffix(previousDigits)) &&
                        digits.count > previousDigits.count &&
                        digits.count <= previousDigits.count + 2
                }
            }()
            let rawBossLooksLikeOrangeClusterConcatenation: Bool = {
                // A sűrű Dusty Gulch-i 253-as csoport egyetlen megmaradó tagja
                // is adott `2531`-et. A saját simított HP 1–2 jegyű toldaléka
                // itt nem önálló bossjel; a terület ettől még farmolható.
                guard orangeRockBiomeVisible,
                      entityX < Double(image.width) * 0.36,
                      let displayedHP,
                      displayedHP < 800,
                      let detectedHP,
                      detectedHP >= 800 else { return false }
                let hpDigits = String(displayedHP)
                return hpStrings.contains { text in
                    let digits = String(text.filter(\.isNumber))
                    return (digits.hasPrefix(hpDigits) || digits.hasSuffix(hpDigits)) &&
                        digits.count > hpDigits.count && digits.count <= hpDigits.count + 2
                }
            }()
            let knownDustyGulchEliteTruncation: Bool = {
                // Ugyanaz a jobb oldali, fegyveres 1,927K elit élőben 192,
                // majd 92 alakot és HUD-takart 19 px-es csíkot is adott.
                // Island 4 jobb oldalán, ismeretlen szinttel és jutalomikon
                // nélkül ez már ismételt helyi entitásbizonyíték. Bossként
                // számoljuk, hogy ne csak passzívan tiltsuk, hanem az ötödik
                // eredménytelen kör után respawn-rövidítéshez is használhassuk.
                guard orangeRockBiomeVisible,
                      entityX >= Double(image.width) * 0.36,
                      level == nil,
                      heartIconEvidence < 0.03,
                      axeIconEvidence < 0.03,
                      // A pontos 499-es Bat Cleaver-hordozó HP-OCR-je élőben
                      // egy képre 199-re csonkolódott, miközben a zöld
                      // fegyverkártya 0,037 maradt. Ez jutalomazonosító, ezért
                      // nem ugyanaz az ikon nélküli 1,927K helyi elit.
                      weaponDropIconEvidence < 0.006,
                      foliageConfidence < 0.20,
                      let truncatedHP = detectedHP ?? displayedHP else { return false }
                return (90...199).contains(truncatedHP)
            }()
            let bossEvidence = independentBossLevelEvidence ||
                knownDustyGulchEliteTruncation ||
                // A célazonossági memória egy kameramozgás után ugyanarra a
                // képpozícióra kerülő 923 HP-s fát egy korábbi 40 HP-s célként
                // simított tovább. A tizedespont-helyreállítás UTÁNI aktuális
                // OCR ezért a simított kijelzett értéktől független bossjel.
                // A valódi 94.1→941 eset fent már 94-re állt vissza.
                ((detectedHP ?? 0) >= 800 &&
                    !rawBossLooksLikeKnownLevelConcatenation &&
                    !rawBossLooksLikeOrangeClusterConcatenation) ||
                (displayedHP ?? 0) >= 800 ||
                (previous?.bossEvidence ?? false) && distance <= 260
            // A statikon a jutalmat, nem a testtípust jelöli: láttunk szíves
            // fenyőt és szíves humanoidot is. Közelharcban a játékos eltakarja
            // a fenyő lombját, ezért ugyanazon, már fának bizonyult közeli célt
            // 0,30-as hiszterézissel fának tartjuk a csík eltűnéséig.
            let treeConfidence = (previous?.treeConfidence ?? 0) >= 0.25 && distance <= 100
                ? max(foliageConfidence, 0.30)
                : foliageConfidence
            let verifiedPassiveTree=PassiveTreePolicy.verified(hp:displayedHP,
                rawHP:detectedHP,foliage:foliageConfidence,axe:axeIconEvidence,
                heart:heartIconEvidence,outline:barOutlineConfidence,
                independentBoss:independentBossLevelEvidence || knownDustyGulchEliteTruncation)
            return Target(
                bar: bar,
                x: entityX,
                y: entityY,
                distance: distance,
                level: level,
                levelOCRNumbers: levelNumbers,
                displayedHP: displayedHP,
                ocrStrings: hpStrings,
                treeConfidence: treeConfidence,
                heartIconEvidence: heartIconEvidence,
                axeIconEvidence: axeIconEvidence,
                weaponDropIconEvidence: weaponDropIconEvidence,
                objectiveStructureConfidence: objectiveStructureConfidence,
                barOutlineConfidence: barOutlineConfidence,
                bossEvidence: bossEvidence && !verifiedPassiveTree
            )
        }
        // Sűrű, azonos HP-jú csoportban két cél felirata egymásba lóghat:
        // élőben a 253-as humanoidok `1253`/`2534` HP-alakokat és 2534-es
        // statikon-OCR-t adtak. Ha legalább két aktuális cél ugyanazon 800
        // alatti, simított HP-n áll, és a nagy nyers alak csak ennek 1–2 jegyű
        // elő-/utótagos változata, az első képen nem boss. Valódi célcsere
        // következő ismételt nyers OCR-je feloldja a HP-simítást; addig a
        // 150-es ismeretlenszint-őr miatt a célhoz sem indulunk el.
        let normalDisplayedHPValues = Set(viableTargets.compactMap { target -> Int? in
            guard let hp = target.displayedHP, hp < 800 else { return nil }
            return hp
        })
        let targetsBeforeClusterConsensus = viableTargets
        viableTargets = targetsBeforeClusterConsensus.map { target in
            guard target.bossEvidence else { return target }
            let consensusHP = normalDisplayedHPValues.first { hp in
                let hpDigits = String(hp)
                let hasConcatenation = target.ocrStrings.contains { text in
                    let digits = String(text.filter(\.isNumber))
                    return (digits.hasPrefix(hpDigits) || digits.hasSuffix(hpDigits)) &&
                        digits.count > hpDigits.count && digits.count <= hpDigits.count + 2
                }
                guard hasConcatenation else { return false }
                // Az azonos csoport tagjainak OCR-je 253/255 között is ugrált,
                // ezért ±3 HP ugyanannak a konszenzusnak számít. A nagy nyers
                // értéket csak két KÖZELI normál társ írhatja felül.
                let nearbyMatches = targetsBeforeClusterConsensus.filter { other in
                    guard other.bar != target.bar,
                          let otherHP = other.displayedHP,
                          otherHP < 800 else { return false }
                    return abs(otherHP - hp) <= 3 &&
                        hypot(other.x - target.x, other.y - target.y) <= 150.0
                }.count
                if (target.displayedHP ?? 0) >= 800 {
                    // A sűrű Dusty Gulch-i 253-as csoportnál két közeli, azonos
                    // normál társ felülírhatja az összefűzött nagy OCR-t.
                    return orangeRockBiomeVisible &&
                        target.x < Double(image.width) * 0.36 && nearbyMatches >= 2
                }
                // A saját alacsony simított HP-ja az egyik konszenzustag.
                return nearbyMatches >= 1
            }
            guard let consensusHP else { return target }
            return Target(
                bar: target.bar,
                x: target.x,
                y: target.y,
                distance: target.distance,
                level: target.level,
                levelOCRNumbers: target.levelOCRNumbers,
                displayedHP: (target.displayedHP ?? 0) >= 800 ? consensusHP : target.displayedHP,
                ocrStrings: target.ocrStrings,
                treeConfidence: target.treeConfidence,
                heartIconEvidence: target.heartIconEvidence,
                axeIconEvidence: target.axeIconEvidence,
                weaponDropIconEvidence: target.weaponDropIconEvidence,
                objectiveStructureConfidence: target.objectiveStructureConfidence,
                barOutlineConfidence: target.barOutlineConfidence,
                bossEvidence: false
            )
        }
        if recentExplicitLargeBossFrames > 0 {
            recentExplicitLargeBossFrames -= 1
            if recentExplicitLargeBossFrames == 0 {
                recentExplicitLargeBossHP = nil
                recentExplicitLargeBossX = nil
                recentExplicitLargeBossY = nil
            }
        }
        if let rememberedHP = recentExplicitLargeBossHP,
           rememberedHP >= 10_000,
           let rememberedX = recentExplicitLargeBossX,
           let rememberedY = recentExplicitLargeBossY {
            viableTargets = viableTargets.map { target in
                guard let hp = target.displayedHP,
                      (8_000...9_999).contains(hp),
                      target.bossEvidence,
                      target.ocrStrings.contains(where: { raw in
                          let compact = raw.uppercased().replacingOccurrences(of: " ", with: "")
                          return compact == "8K" || compact == "8:K" || compact == "8.K"
                      }),
                      hypot(target.x - rememberedX, target.y - rememberedY) <= 90 else {
                    return target
                }
                return Target(
                    bar: target.bar,
                    x: target.x,
                    y: target.y,
                    distance: target.distance,
                    level: target.level,
                    levelOCRNumbers: target.levelOCRNumbers,
                    displayedHP: rememberedHP,
                    ocrStrings: target.ocrStrings,
                    treeConfidence: target.treeConfidence,
                    heartIconEvidence: target.heartIconEvidence,
                    axeIconEvidence: target.axeIconEvidence,
                    weaponDropIconEvidence: target.weaponDropIconEvidence,
                    objectiveStructureConfidence: target.objectiveStructureConfidence,
                    barOutlineConfidence: target.barOutlineConfidence,
                    bossEvidence: true
                )
            }
        }
        if let explicitLargeBoss = viableTargets.first(where: { target in
            guard (target.displayedHP ?? 0) >= 10_000 else { return false }
            return target.ocrStrings.contains { raw in
                let text = raw.lowercased()
                return text.contains("k") &&
                    (text.contains(".") || text.contains(":") || text.contains(","))
            }
        }) {
            recentExplicitLargeBossHP = explicitLargeBoss.displayedHP
            recentExplicitLargeBossX = explicitLargeBoss.x
            recentExplicitLargeBossY = explicitLargeBoss.y
            recentExplicitLargeBossFrames = 12
        }
        // A nagy térkép / helyszín-overlay piros `Enemy weapon` címkéje a
        // `011309-play/75,190` képeken 30–31 px-es piros komponensként hamis
        // világcélt alkotott (HP és szint nélkül, stabilan 204–216 px-re).
        // Ez navigációs felirat, nem támadható entitás; sem célként, sem
        // fenyegetésként nem kerülhet a stratégiába.
        viableTargets.removeAll { target in
            target.ocrStrings.contains { text in
                text.lowercased().contains("enemy weap")
            }
        }
        previousTargets = viableTargets
        // A megbízhatóan felismert fák nem támadnak vissza, ezért célpontok, de
        // nem fenyegetések. A menekülési és túlerőlogika csak humanoidokra épül.
        let hostileTargets = viableTargets.filter {
            ($0.treeConfidence < 0.25 || $0.bossEvidence) && $0.objectiveStructureConfidence < 0.06
        }
        // A háromfős 41 HP-s csoport tagjai a fő nézetben 110–120 px-re is
        // széthúzódtak, ezért a korábbi 105 px-es sugár az alsó tagot tévesen
        // izoláltnak minősítette. A 150 px már egy harci klaszterként kezeli őket.
        let hostileClusterRadius = 150.0
        // Egy közelebbi normál humanoid nem takarhatja el a 360 px-es
        // biztonsági sugáron belüli bosst. A döntő egyetlen nearestThreat
        // mezőt használ, ezért itt a közeli boss kap elsőbbséget; távoli boss
        // mellett továbbra is a ténylegesen legközelebbi normál fenyegetés marad.
        let nearbyBossThreat = hostileTargets.filter {
            ($0.bossEvidence || ($0.displayedHP ?? 0) >= 800) && $0.distance <= 360
        }.min { $0.distance < $1.distance }
        let nearestThreat = nearbyBossThreat ?? hostileTargets.min { $0.distance < $1.distance }
        let safeTargets = viableTargets.filter { candidate in
            // A 499 HP-s, zöld fegyverkártyás hordozó minden legyőzése +50
            // Bat Cleaver sebzést adott. A 091457 élő futásban a szabad spirál
            // 293→260→252 pixelre hozta, de az általános ismeretlenfenyegetés-
            // kitérés ezután 395 pixelre távolította. A 150 alatti közeli kapu
            // továbbra is elég gyenge ikonbizonyítékkal; a 150–270 pixeles
            // felderítő megközelítéshez erősebb zöld jel, pontos 499 HP, teljes
            // csík és legalább 15%-os képbelső helyzet kell. A 281–349 pixeles,
            // korábban mért kerítés-túloldali nézet így változatlanul tiltott.
            let verifiedCloseWeaponDropCarrier = learnedMaximumDisplayedHP >= 600 &&
                candidate.displayedHP == 499 &&
                candidate.weaponDropIconEvidence >= 0.006 &&
                candidate.distance <= 150 &&
                (45...65).contains(candidate.bar.width)
            let verifiedWeaponDropCarrierScout = learnedMaximumDisplayedHP >= 600 &&
                candidate.displayedHP == 499 &&
                candidate.weaponDropIconEvidence >= 0.02 &&
                candidate.distance <= 270 &&
                candidate.x >= Double(image.width) * 0.15 &&
                (45...65).contains(candidate.bar.width)
            // A pusztán képszéli, részlegesen látható lényt nem
            // üldözzük. Ezt csak a farmcéloknál szabad alkalmazni: a korábbi,
            // Target-létrehozás előtti guard a bal szélen részlegesen látható
            // 1.22K páncélost a bossőr elől is elrejtette. Veszélyként minden
            // fekete keretes, olvasható csík megmarad.
            if candidate.x < Double(image.width) * 0.25,
               !verifiedWeaponDropCarrierScout { return false }
            // A kép felső peremén csak a csík és az objektum apró része látszik;
            // ilyen volt a kerítés túloldali 200-as Titan-portál. Távoli,
            // részleges célhoz ne induljon közvetlen üldözés: a minimap/útvonal
            // előbb vigye képernyőn belülre, ahol a test is osztályozható.
            if candidate.bar.centerY < Double(image.height) * 0.10 { return false }
            // Az alsó képszéli részleges test ugyanúgy nem közvetlen farmcél,
            // mint a felső. Előbb a navigáció/bossőr hozza biztonságos, teljes
            // osztályozási helyzetbe; a 67.5K boss csíkjához így akkor sem
            // indulunk, ha az OCR éppen csonkolódik.
            if candidate.bar.centerY > Double(image.height) * 0.82 { return false }
            // A jobb képszélen egy nagy ellenfél csíkjából csak néhány pixel
            // maradhat. A `055128/frame-00234` 18 px-es, OCR nélküli részletét
            // a régi „rövid csík” próbaág olcsó humanoidnak tekintette, noha
            // ugyanitt az 1,927K elit korábban 192/92-re csonkolódott. A levágott
            // csík fenyegetésként megmarad, de közvetlen farmcél csak akkor lehet,
            // ha a navigáció előbb teljesen a képre hozta.
            if candidate.bar.maxX >= image.width - 12 { return false }
            // A lila, 200 HP-s rituáléobjektum nem reagált több száz közeli
            // támadási döntésre. Nem farmcél; valószínűleg külön feltételhez kötött.
            if candidate.objectiveStructureConfidence >= 0.06 { return false }
            if candidate.bossEvidence { return false }
            let isTree = candidate.treeConfidence >= 0.25
            let companions = hostileTargets.filter { other in
                guard other.bar != candidate.bar else { return false }
                return hypot(other.x - candidate.x, other.y - candidate.y) <= hostileClusterRadius
            }.count
            if isTree {
                // A fák nem ütnek vissza, és a kék fejszeszámukkal egyező
                // támadóerőt adnak. A 150 fölötti fa-HP ezért csak idő-, nem
                // közvetlen életveszély; a hozamot a fejszeszinttel pontozzuk.
                return candidate.displayedHP.map {
                    $0 <= max(300, learnedMaximumDisplayedHP + 90)
                } ?? true
            }
            // A büntetésmentes újraéledés és a jelenlegi, kétütéses 672-es
            // lovagok mellett a teljes izoláció túl óvatos: a térképen jelzett
            // három-négyes csoporthoz oda sem engedte a botot. Teljes saját HP,
            // legfeljebb három közeli társ és a saját maximumnál nem erősebb
            // egyedi cél esetén vállaljuk a csoportharcot. Erősebb humanoidnál
            // továbbra is a kontrollált bosspróba méri a valódi kockázatot.
            let manageableGroupTarget = (healthFraction ?? 0) >= 0.90 &&
                companions <= 3 &&
                candidate.displayedHP.map { $0 <= learnedMaximumDisplayedHP } == true
            guard manageableGroupTarget ||
                ((healthFraction ?? 0) >= 0.85 && companions == 0) else { return false }
            if manageableGroupTarget { return true }
            // Az ezres rövidítésből korábban csak a tizedes rész maradt meg
            // ("1.22K" -> 22), ezért egy 1220 HP-s elit olcsó cél lett. Ismert,
            // 300 fölötti humanoidot nem próbálunk ki normál farmcélként.
            if let hp = candidate.displayedHP,
               hp > max(300, learnedMaximumDisplayedHP + 60) {
                return false
            }
            // A `011302-play/frame-00002` 1.22K-s páncélosából a levágott
            // HP-OCR mindössze 7-et adott. Ismeretlen szintű, nem-fa lény teljes
            // szélességű csíkján a 20 alatti szám ezért csonkolási bizonyíték,
            // nem olcsó farmcél. Ismert 1–2. szint továbbra is külön ágon élhet.
            if candidate.level == nil,
               let hp = candidate.displayedHP,
               hp < 100,
               candidate.bar.width >= 45 {
                // A jobb képszéli 1,927K elit előbb 192-nek, majd ugyanazon
                // teljes, 57 pixeles csíkon 92-nek látszott (`051233-play`).
                // Az egy- és kétjegyű K-csonkolás tehát nem áll meg 20 alatt.
                // Ismert 1–4. szintű kis humanoidok a külön szintágon továbbra
                // is átmehetnek; csak az ismeretlen szint + széles csík páros
                // marad tiltott.
                return false
            }
            // Island 4 jobb oldalán a teljesen látható 1,927K elit vörös
            // csíkrészét a jobb oldali játékgombok 19 px-re takarták, az OCR
            // pedig ismét csak `92`-t adott (`060446/frame-00011`). Ebben a
            // biomban az ismeretlen szint + 100 alatti HP ezért a látható
            // csíkhossztól függetlenül tiltott. Más biomban az ismert kis
            // célok és a rövidcsík-próba történeti viselkedése megmarad.
            if orangeRockBiomeVisible,
               candidate.level == nil,
               let hp = candidate.displayedHP,
               hp < 100 {
                return false
            }
            if verifiedCloseWeaponDropCarrier || verifiedWeaponDropCarrierScout { return true }
            if let hp = candidate.displayedHP, hp <= 150 { return true }
            if let level = candidate.level, level <= 2,
               (candidate.displayedHP ?? 300) <= 300 { return true }
            // Az 1.22K elitből élőben „221” is lett, nem csak „22”. Ismeretlen
            // szintű, 150 fölöttinek olvasott humanoidot ezért nem engedünk át
            // pusztán a 400-as saját HP miatt. OCR nélküli, széles csík ugyanígy
            // kockázatos; csak a kifejezetten rövid csík marad próbacél.
            if candidate.displayedHP != nil { return false }
            return candidate.bar.width < 45
        }
        func targetCost(_ candidate: Target) -> Double {
            let hpCost = Double(candidate.displayedHP ?? 120) * 1.20
            // A szigorított türkizzöld feltétellel a valódi fák 0,54–0,61,
            // a humanoidok 0,00–0,07 arányt adtak. A 0,25 alatti rész ezért
            // nem kap farm-bónuszt; a füves háttér már nem tesz ellenséget fává.
            let treeEvidence = min(1, max(0, (candidate.treeConfidence - 0.25) / 0.25))
            // A jutalmat a statikon, nem a testforma jelzi: kék fejsze
            // támadóerő, piros szív maximális HP. Mindkét testtípusnál lehet
            // szív; fejszét eddig biztosan fenyőn láttunk.
            let axeRewardEvidence = min(1, candidate.axeIconEvidence / 0.03)
            let heartRewardEvidence = min(1, candidate.heartIconEvidence / 0.05)
            let knownRewardEvidence = max(axeRewardEvidence, heartRewardEvidence)
            let rewardCoefficient: Double
            if axeRewardEvidence > heartRewardEvidence {
                rewardCoefficient = axeRewardEvidence * 8 + (1 - knownRewardEvidence) * 4
            } else if heartRewardEvidence > axeRewardEvidence {
                rewardCoefficient = heartRewardEvidence * 10 + (1 - knownRewardEvidence) * 4
            } else {
                rewardCoefficient = 4
            }
            let statReward = Double(candidate.level ?? 0) * rewardCoefficient
            let progressionBonus = learnedMaximumDisplayedHP >= 160 && (healthFraction ?? 0) >= 0.85
                ? (1 - treeEvidence) * 180
                : 0
            let nearbyCompanions = hostileTargets.filter { other in
                guard other.bar != candidate.bar else { return false }
                return hypot(other.x - candidate.x, other.y - candidate.y) <= hostileClusterRadius
            }.count
            let clusterPenalty = Double(nearbyCompanions) * 135
            return candidate.distance + hpCost - treeEvidence * 260 - statReward
                - progressionBonus + clusterPenalty
        }
        let target = safeTargets.min { targetCost($0) < targetCost($1) }
        if let target,
           let level = target.level,
           max(target.heartIconEvidence, target.axeIconEvidence) >= 0.02 {
            expectedStatRewardValue = level
            expectedStatRewardFrames = 40
        } else if expectedStatRewardFrames > 0 {
            expectedStatRewardFrames -= 1
        } else {
            expectedStatRewardValue = nil
        }

        var hudConfidence = 0.0
        if playerBar != nil { hudConfidence += 0.65 }
        if !redBars.isEmpty { hudConfidence += 0.20 }
        if redBars.count >= 2 { hudConfidence += 0.30 }
        // Biztonságos regeneráció közben lehet, hogy nincs egyetlen piros csík
        // sem, a játékos részleges zöld csíkját pedig egy respawn-időzítő
        // töri darabokra. A felismerhető sárga játékosjel + piros minimappont
        // ekkor is erős bizonyíték arra, hogy normál játéknézetben vagyunk.
        if explorationDirection != nil || specialLandmarkDirection != nil || landmarkDirection != nil || questRouteDirection != nil {
            hudConfidence += 0.45
        }
        if !playerStrings.isEmpty { hudConfidence += 0.20 }
        // Fal, kapu vagy nagy karakteranimáció a zöld csík komponensét teljesen
        // szétszedheti, miközben a közvetlen játékosrégióból frissen elfogadott
        // numerikus HP továbbra is erős, helyspecifikus játékkép-bizonyíték.
        // OCR-memória ezt a pluszt nem kapja, ezért menüben nem tartja életben a HUD-ot.
        if healthSource == "ocr-current" { hudConfidence += 0.30 }
        // A Titan 0/7 feladata nem átvezető vagy menü: teljesen érvényes
        // játéktér, csak a karaktercsíkot takarja. Engedjük tovább navigálni,
        // hogy el tudjon lépni az oltártól és megkereshesse a hét gemet.
        if titanGemQuestVisible || deepMinesPotionQuestVisible { hudConfidence += 0.80 }
        if image.width >= 500 && image.height >= 700 { hudConfidence += 0.15 }
        hudConfidence = min(1, hudConfidence)

        return FrameAnalysis(
            width: image.width,
            height: image.height,
            expandedMapVisible: expandedMapVisible,
            shop: shop,
            minimapPose: playerMapMarker.flatMap { marker in
                // A zöld fegyverikon több szigeten azonos; a narancs koponya
                // az elsődleges támpont, ha mindkettő látható (245).
                minimapAnchorDetector.detect(cgImage,playerX:marker.centerX,playerY:marker.centerY) ??
                (orangeRockCoverage >= 0.40 ? minimapAnchorDetector.detectVenom(cgImage,playerX:marker.centerX,playerY:marker.centerY) : nil)
            },
            redBars: redBars,
            greenBars: greenBars,
            touchAnchor: image.safestTouchAnchor(),
            sceneFingerprint: sceneFingerprint,
            explorationDirection: explorationDirection,
            localFarmDirection: localFarmDirection,
            localFarmOffset: localFarmOffset,
            golemMapOffset: orangeGolemPose.map {Vector2(x:-$0.x,y:-$0.y)},
            mapObjectives: mapObjectiveDetector.detect(cgImage,expanded:expandedMapVisible),
            mapPlayerPosition: expandedMapVisible ? nil:playerMapMarker.map {
                Vector2(x:$0.centerX*637/Double(image.width),y:$0.centerY*882/Double(image.height))
            },
            island2SkullDirection: island2SkullDirection,
            innerMapEnemyVisible: nearestInnerMapTarget != nil,
            edgeObjectiveVisible: edgeObjectiveActive,
            specialLandmarkDirection: specialLandmarkDirection,
            landmarkDirection: landmarkDirection,
            questRouteDirection: questRouteDirection,
            playerOCRStrings: playerStrings,
            playerLocalizedOCRStrings: localizedPlayerStrings,
            rewardOCRStrings: rewardStrings,
            dialogueOCRStrings: dialogueStrings,
            titanQuestOCRStrings: titanQuestStrings,
            discoveredChestCount: discoveredChestCount,
            centralLongRespawnTimerCount: centralLongRespawnTimerCount,
            island4WeaponSlotLockVisible: island4WeaponSlotLockVisible,
            orangeRockBiomeVisible: orangeRockBiomeVisible,
            orangeRockCoverage: orangeRockCoverage,
            continueButtonVisible: continueButtonVisible,
            claimRewardVisible: claimRewardVisible,
            openButtonVisible: openButtonVisible,
            openButtonCenter: openButtonCenter,
            worldChestDirection: worldChestDirection,
            worldChestCandidate: worldChestDetection.candidate,
            worldChestGoldSamples: worldChestDetection.goldSamples,
            worldChestSparkleSamples: worldChestDetection.sparkleSamples,
            worldChestBrightGlowSamples: worldChestDetection.brightGlowSamples,
            dialogueCanAdvance: dialogueCanAdvance,
            titanGemQuestVisible: titanGemQuestVisible,
            deepMinesPotionQuestVisible: deepMinesPotionQuestVisible,
            recentRewardValue: rememberedRewardValue,
            recentRewardSequence: rememberedRewardValue == nil ? nil : rewardSequence,
            confirmedMaximumIncreaseSequence: maximumIncreaseSequence == 0 ? nil : maximumIncreaseSequence,
            confirmedMaximumDisplayedHP: learnedMaximumDisplayedHP,
            nearbyRespawnTimer: nearbyRespawnTimer,
            playerDisplayedHP: playerDisplayedHP,
            playerPixelHealthFraction: pixelHealthFraction,
            playerHealthFraction: healthFraction,
            playerHealthSource: healthSource,
            hudConfidence: hudConfidence,
            visibleTargets: viableTargets,
            target: target,
            nearestThreat: nearestThreat,
            nearbyThreatCount: hostileTargets.filter { $0.distance <= hostileClusterRadius }.count,
            popupClose: popupClose,
            settingsClose: settingsClose,
            unstuckCooldownSeconds: unstuckCooldownSeconds
        )
    }

    private func persistKnowledge() {
        // A replay determinisztikus, írásmentes regresszió. Korábbi változatban
        // egy tesztfuttatás legitimnek vélt jutalommal módosíthatta volna az élő
        // bot maximumát; a visszajátszás ezentúl csak olvassa a kiinduló tudást.
        guard !readOnlyKnowledge else { return }
        let state = PersistentKnowledge(
            maximumDisplayedHP: learnedMaximumDisplayedHP,
            discoveredChestCount: learnedDiscoveredChestCount
        )
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: knowledgeURL, options: .atomic)
    }

    private func parseWorldChestDiscoveryCount(_ text: String) -> Int? {
        let compact = text.lowercased().filter { !$0.isWhitespace }
        guard compact.contains("chest") || compact.contains("/57"),
              let range = compact.range(of: "/57") else { return nil }
        var digits: [Character] = []
        for character in compact[..<range.lowerBound].reversed() {
            if character.isNumber {
                digits.append(character)
            } else if !digits.isEmpty {
                break
            }
        }
        guard !digits.isEmpty else { return nil }
        return Int(String(digits.reversed()))
    }

    private func parseHealthValues(_ text: String) -> [Int] {
        let lower = text.lowercased()
        if lower.contains("m") || lower.contains("s") || lower.contains("h") {
            // Az időzítő közvetlenül rá tud fedni a játékos számára és csíkjára.
            // Az összeragadt sorból nem lehet megbízhatóan eldönteni, mely számjegyek
            // a HP részei: a 330 + 3m56s élőben „83m 565”/„33m 56s” lett, és a
            // korábbi részablakos logika hamis kritikus visszavonulást indított.
            // Ilyen képen nincs numerikus HP-mérés; a temporális memória és a
            // fenyegetéssel hitelesített pixelcsík együtt biztonságosabb.
            return []
        }
        if lower.contains("k") {
            // 999 fölött a saját HP is rövidített alakra váltott: a 300-szíves
            // kaktusz után a pontos 999+300 = 1299 értéket a játék `1.3K`-ként
            // rajzolta. Egy tizedes százasra, kettő tízesre kerekít, ezért ha egy már jutalommal
            // bizonyított pontos maximum közel van, azt tartjuk meg; különben
            // a rövidített értéket csak közelítő aktuális HP-ként használjuk.
            let groups = text.split { !$0.isNumber }.map(String.init)
            var approximates: [Int] = []
            if let wholeText = groups.first,
               let whole = Int(wholeText),
               whole >= 1, whole <= 99 {
                let fractionText = String((groups.dropFirst().first ?? "").prefix(2))
                let fraction = Int(fractionText) ?? 0
                let scale = fractionText.count <= 1 ? 100 : 10
                approximates.append(whole * 1_000 + fraction * scale)
            }
            var compactDigits = String(text.filter(\.isNumber))
            if compactDigits.count == 4 {
                let characters = Array(compactDigits)
                if characters[0] == "1" {
                    // Élő minták: `1.64K` -> `1164K`, `1.94K` -> `1194K`.
                    // Az első 1 a zöld csík széle; a maradék három jegy a
                    // valódi egy egész + két tizedesjegyes K-kijelzés.
                    compactDigits.removeFirst()
                } else if characters[1] == "1" {
                    // A 27,7K-s lovag élő sebzéssora alatt `2.69K` -> `2169K`,
                    // `2.43K` -> `2143K` lett: ugyanaz a csíkél-artefaktum a
                    // vezető egész és a tizedesrész közé került.
                    compactDigits.remove(at: compactDigits.index(after: compactDigits.startIndex))
                }
            }
            if !text.contains(".") && !text.contains(",") && !text.contains(":"),
               compactDigits.count == 3,
               let whole = Int(String(compactDigits.prefix(1))),
               (1...9).contains(whole),
               let fraction = Int(compactDigits.dropFirst()) {
                approximates.append(whole * 1_000 + fraction * 10)
            }
            approximates = Array(Set(approximates.filter { (1_000...99_900).contains($0) }))
            guard !approximates.isEmpty else { return [] }
            // A 4.46K nem azonos a korábbi 4450-nel: a régi ±60-as kapu
            // több valódi farmjutalmat elnyelt. Csak a kijelzés saját fél
            // kvantumán belül tartjuk meg a bizonyított pontos maximumot.
            let fractionDigits = groups.dropFirst().first?.count
            let roundingTolerance = fractionDigits == 1 ? 50 : 5
            if learnedMaximumDisplayedHP >= 1_000,
               let closeApproximation = (approximates
                    .filter { value in abs(value - learnedMaximumDisplayedHP) <= roundingTolerance }
                    .min(by: { lhs, rhs in
                        abs(lhs - learnedMaximumDisplayedHP) < abs(rhs - learnedMaximumDisplayedHP)
                    })),
               abs(closeApproximation - learnedMaximumDisplayedHP) <= roundingTolerance {
                return [learnedMaximumDisplayedHP]
            }
            return approximates.sorted {
                abs($0 - learnedMaximumDisplayedHP) < abs($1 - learnedMaximumDisplayedHP)
            }
        }
        if text.contains(".") || text.contains(":") || text.contains(",") {
            let groups = text.split { !$0.isNumber }.map(String.init)
            guard let whole = groups.first, let wholeValue = Int(whole) else { return [] }
            if learnedMaximumDisplayedHP >= 1_000,
               (lastDisplayedHP ?? 0) >= Int(Double(learnedMaximumDisplayedHP) * 0.75),
               (1...9).contains(wholeValue), groups.count == 2,
               groups[1].count == 2 {
                // 5.23K → 5:23: nem tudjuk, hiányzó K vagy valódi 5,23 HP.
                // Nem gyártunk magas értéket, de friss 5 HP-t sem igazolhat.
                // A külön pixeles kritikus őr és a következő tiszta OCR dönt.
                return []
            }
            // A játék 100 HP alatt tizedes értéket mutat (például 67.3).
            // A pont előtti rész az egész HP; tilos elé automatikusan 1-et vagy
            // 2-t tenni, mert ettől a 67.3-at korábban 167 HP-nak hittük.
            var values = (1...999).contains(wholeValue) ? [wholeValue] : []
            // A Vision néha a zöld csík bal szélét "1"-nek olvassa:
            // "69.7" -> "169.7". A temporális stabilizáló a két jelöltből
            // választ; ez nem azonos azzal, hogy minden kétjegyű szám elé
            // találomra százast teszünk.
            if whole.count == 3, whole.hasPrefix("1"),
               let withoutBarArtifact = Int(whole.dropFirst()),
               withoutBarArtifact >= 10 {
                values.append(withoutBarArtifact)
            }
            return values
        }
        let digits = String(text.filter(\.isNumber))
        guard !digits.isEmpty else { return [] }
        var values: [Int] = []
        func add(_ value: Int?) {
            guard let value, value >= 1, value <= 999, !values.contains(value) else { return }
            values.append(value)
        }

        // A játékos HP-ja már a kezdeti 100 fölé is nőhet (élőben 102-t
        // láttunk). Az OCR néha szomszédos képrészletet ragaszt elé vagy mögé,
        // ezért minden életszerű 2/3 jegyű ablakot megtartunk, majd a temporális
        // stabilizáló választja ki az előző HP-hoz legközelebbit.
        if digits.count <= 3 {
            add(Int(digits))
        }
        let characters = Array(digits)
        // Csak valóban összeragadt, 3 karakternél hosszabb OCR-szövegben
        // keresünk részablakokat. Egy tiszta "176" elsőbbséget élvez, és nem
        // válhat belőle a korábbi értékhez közelebb eső, hibás "17".
        if characters.count > 3 {
            for start in 0...(characters.count - 3) {
                let value = Int(String(characters[start..<(start + 3)]))
                if let value, value >= 100 { add(value) }
            }
        }
        if characters.count > 3 {
            for start in 0...(characters.count - 2) {
                let value = Int(String(characters[start..<(start + 2)]))
                if let value, value >= 10 { add(value) }
            }
        }
        return values
    }

    private func parseTargetHealthValues(_ text: String) -> [Int] {
        let lower = text.lowercased()
        // A cél HP-régiójába is belóghat a 20h 13m respawn-időzítő. Élőben
        // `24k 3m` lett belőle, amit a K-bővítő 243 ezres hamis bossá tett.
        // Időegységes sor ugyanúgy nem HP-forrás itt, mint a játékos HUD-ján.
        if lower.contains("m") || lower.contains("s") || lower.contains("h") {
            return []
        }
        // A lebegő sebzésszámok mínuszosak; sűrű táborban a cél HP-régiójába
        // lóghatnak (élő példa: -3390 egy 253 HP-s humanoid mellett). Ezek
        // nem a megmaradt cél-HP értékei, a mínusz eldobása hamis bosst gyárt.
        if lower.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("-") {
            return []
        }
        if lower.contains("k") {
            // A nagy elit/boss HP-ja rövidítve jelenik meg (például 1.22K).
            // A tizedespont vagy vessző előtti/utáni szám együtt ezres érték.
            let normalized = lower.map { character -> Character in
                // A Vision a stilizált tizedespontot rendszeresen kettőspontnak
                // olvassa (`4:31K`). Ha ezt eldobjuk, 4.31K-ból 431K lesz, és a
                // kontrollált 4.31K-s próba tévesen el sem indul.
                (character == "," || character == ":") ? "." : character
            }
            let numericText = String(normalized.filter { $0.isNumber || $0 == "." })
            if let value = Double(numericText) {
                let expanded = Int((value * 1_000).rounded())
                return expanded >= 100 ? [expanded] : []
            }
            return []
        }
        let normalized = lower.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: ":", with: ".")
        // Fractional shield rewards sit above the HP bar: 0.5 / 0.50 / 0.5€.
        // Splitting them into integers invents a 5/50-HP enemy and poisons
        // temporal target identity even when the next frame correctly reads64.
        if normalized.trimmingCharacters(in:.whitespacesAndNewlines)
            .range(of:"^0\\.[0-9]+[^0-9]*$",options:.regularExpression) != nil {
            return []
        }
        let decimalGroups = normalized.split(separator: ".")
        if decimalGroups.count == 2,
           decimalGroups[0].count <= 2,
           decimalGroups[1].count == 2,
           decimalGroups.allSatisfy({ $0.allSatisfy(\.isNumber) }),
           let value = Double(decimalGroups.joined(separator: ".")),
           value >= 1, value < 10 {
            // A Vision a jobb szélső K-t néha levágja, miközben a 4.31
            // tizedes alak megmarad. Normál cél-HP nem tizedes, ezért ez
            // biztonságosan ugyanaz a 4.31K→4310 rövidítés.
            return [Int((value * 1_000).rounded())]
        }
        return text.split { !$0.isNumber }.compactMap { Int($0) }
    }

    private func parseRewardValue(_ text: String) -> Int? {
        // A zöld jutalomfelirat közvetlenül „+N” alakban jelenik meg. Pluszjel
        // nélkül sem időzítőt, sem HP-t, sem találati számot nem tekintünk
        // jutalomnak ebben a tágabb játékos körüli OCR-régióban. A +0.5-szerű
        // tizedes effektus külön mechanika: a pont eldobásával sem lehet +5 egész
        // statjutalom, ezért minden tizedes alakot itt kizárunk.
        guard text.contains("+") else { return nil }
        guard !text.contains("."), !text.contains(",") else { return nil }
        let digits = String(text.filter(\.isNumber))
        guard let value = Int(digits) else { return nil }
        // Közvetlen képeken eddig ezek az egész statlépcsők bizonyítottak.
        // Egy +1 kék fejsze ikonját a Vision a számhoz ragasztotta, és +12-t
        // adott. Ismeretlen értéket inkább nem teszünk jutalommemóriába; a
        // játékos friss HP-ja ettől még önállóan menti a valódi fejlődést.
        guard [1, 2, 3, 4, 5, 10, 20].contains(value) else { return nil }
        return value
    }

    /// A verified red stub immediately beneath our green HP bar may lose its
    /// upper black edge. Require that green overlap AND a long lower frame;
    /// red clothing alone cannot satisfy this exception.
    private func isOverlappingContactBar(_ bar: IntRect, image: PixelImage) -> Bool {
        guard (8...24).contains(bar.width), (4...10).contains(bar.height), bar.pixels>=45,
              abs(bar.centerX-Double(image.width)*0.5)<60,
              abs(bar.centerY-Double(image.height)*0.455)<24 else {return false}
        let left=max(0,bar.minX), right=min(image.width-1,bar.maxX+20)
        guard right-left>=28 else{return false}
        var bestBottom=0.0,bestGreen=0
        for offset in 1...3 {
            let y=bar.maxY+offset
            guard y<image.height else{continue}
            var dark=0
            for x in left...right {let c=image.color(x:x,y:y)
                if c.r<90 && c.g<90 && c.b<90 {dark+=1}}
            bestBottom=max(bestBottom,Double(dark)/Double(right-left+1))
        }
        for offset in 2...8 {
            let y=bar.minY-offset
            guard y>=0 else{continue}
            var green=0
            for x in left...right {let c=image.color(x:x,y:y)
                if c.g>150 && c.g>c.r+35 && c.g>c.b+40 {green+=1}}
            bestGreen=max(bestGreen,green)
        }
        return bestBottom>=0.85 && bestGreen>=10
    }

    private func mergeHorizontalBarPieces(_ rectangles: [IntRect]) -> [IntRect] {
        var pending = rectangles.sorted { ($0.minY, $0.minX) < ($1.minY, $1.minX) }
        var result: [IntRect] = []

        while !pending.isEmpty {
            var current = pending.removeFirst()
            var changed = true
            while changed {
                changed = false
                for index in pending.indices.reversed() {
                    let other = pending[index]
                    let verticalOverlap = min(current.maxY, other.maxY) - max(current.minY, other.minY) + 1
                    let horizontalGap = max(0, max(current.minX, other.minX) - min(current.maxX, other.maxX) - min(current.width, other.width))
                    if verticalOverlap >= 1 && horizontalGap <= 26 && abs(current.centerY - other.centerY) <= 5 {
                        current = IntRect(
                            minX: min(current.minX, other.minX),
                            minY: min(current.minY, other.minY),
                            maxX: max(current.maxX, other.maxX),
                            maxY: max(current.maxY, other.maxY),
                            pixels: current.pixels + other.pixels
                        )
                        pending.remove(at: index)
                        changed = true
                    }
                }
            }
            result.append(current)
        }
        return result.filter { $0.width <= 110 && $0.height <= 24 }
    }
}

@MainActor
private final class GameCapture {
    struct Frame {
        let cgImage: CGImage
        let pixelImage: PixelImage
        let windowFrame: CGRect
        let windowID: CGWindowID
        let processID: pid_t
    }

    func capture() async throws -> Frame {
        let content: SCShareableContent
        do {
            content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        } catch {
            throw BotError.captureFailed(error.localizedDescription)
        }

        let candidates = content.windows.filter { window in
            let bundleMatches = window.owningApplication?.bundleIdentifier == gameBundleIdentifier
            let titleMatches = (window.title ?? "").lowercased().contains(gameNameFragment)
            let ownerMatches = (window.owningApplication?.applicationName ?? "").lowercased().contains(gameNameFragment)
            return bundleMatches || titleMatches || ownerMatches
        }
        guard let window = candidates.max(by: { $0.frame.width * $0.frame.height < $1.frame.width * $1.frame.height }),
              window.frame.width >= 400,
              window.frame.height >= 600 else {
            throw BotError.gameWindowMissing
        }

        let configuration = SCStreamConfiguration()
        configuration.width = Int(window.frame.width.rounded())
        configuration.height = Int(window.frame.height.rounded())
        configuration.showsCursor = false
        configuration.ignoreShadowsSingleWindow = true
        configuration.captureResolution = .best
        let filter = SCContentFilter(desktopIndependentWindow: window)

        do {
            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )
            return Frame(
                cgImage: image,
                pixelImage: try PixelImage(image),
                windowFrame: window.frame,
                windowID: window.windowID,
                processID: window.owningApplication?.processID ?? 0
            )
        } catch let error as BotError {
            throw error
        } catch {
            throw BotError.captureFailed(error.localizedDescription)
        }
    }
}

private struct Vector2: Codable {
    var x: Double
    var y: Double

    var normalized: Vector2 {
        let length = hypot(x, y)
        guard length > 0.001 else { return Vector2(x: 0, y: -1) }
        return Vector2(x: x / length, y: y / length)
    }
}

private enum ActionDecision: Encodable, CustomStringConvertible {
    case wait(reason: String)
    case swipe(directionX: Double, directionY: Double, duration: Double, reason: String)
    case tap(x: Double, y: Double, reason: String)
    case scrollShop(up: Bool, reason: String)
    case stop(reason: String)

    var description: String {
        switch self {
        case .wait(let reason): return "VÁR — \(reason)"
        case .swipe(let x, let y, let duration, let reason):
            return String(format: "SWIPE (%.2f, %.2f), %.2fs — %@", x, y, duration, reason)
        case .tap(let x, let y, let reason):
            return String(format: "KOPPINTÁS (%.0f, %.0f) — %@", x, y, reason)
        case .scrollShop(let up, let reason): return "BOLTLISTA \(up ? "LEFELÉ" : "TETEJÉRE") — \(reason)"
        case .stop(let reason): return "STOP — \(reason)"
        }
    }

    enum CodingKeys: String, CodingKey { case type, x, y, duration, reason }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .wait(let reason):
            try container.encode("wait", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .swipe(let x, let y, let duration, let reason):
            try container.encode("swipe", forKey: .type)
            try container.encode(x, forKey: .x)
            try container.encode(y, forKey: .y)
            try container.encode(duration, forKey: .duration)
            try container.encode(reason, forKey: .reason)
        case .tap(let x, let y, let reason):
            try container.encode("tap", forKey: .type)
            try container.encode(x, forKey: .x)
            try container.encode(y, forKey: .y)
            try container.encode(reason, forKey: .reason)
        case .stop(let reason):
            try container.encode("stop", forKey: .type)
            try container.encode(reason, forKey: .reason)
        case .scrollShop(let up, let reason):
            try container.encode("shop-scroll", forKey: .type)
            try container.encode(up ? -1 : 1, forKey: .y)
            try container.encode(reason, forKey: .reason)
        }
    }
}

private final class Strategy {
    private let shopAuditor: ShopAuditor
    private let kiter = BossKitingTrial()
    var kitingTrialEnabled = false
    var kitingTrialFinished: Bool {kiter.finished}
    var shopOnly = false
    private let controlledBossTrialsEnabled: Bool
    private var noHUDFrames = 0
    private let hpObservationProbeBudget = HPObservationProbeBudget()
    private var closeTargetFrames = 0
    private var exploreDirectionIndex = 0
    private var exploreLegLength = 4
    private var exploreLegStepsRemaining = 4
    private var exploreCompletedLegsAtLength = 0
    private var lastTargetBarWidth: Int?
    private var lastTargetX: Double?
    private var lastTargetY: Double?
    private var lastTargetDistance: Double?
    private var stagnantApproachFrames = 0
    private var detourFrames = 0
    private var nextDetourSign = -1.0
    private var persistentDetourFrames = 0
    private var persistentDetourDirection: Vector2?
    private var weaponCarrierCornerTurnFrames = 0
    private var weaponCarrierCornerTurnDirection: Vector2?
    private var failedApproachCycles = 0
    private var blockedAreaEscapeFrames = 0
    private var blockedAreaEscapeDirection: Vector2?
    private var unreachableTargetDisplayedHP: Int?
    private var unreachableTargetWasTree = false
    private var unreachableTargetCooldownFrames = 0
    private var unreachableTargetSceneFingerprint: [Int]?
    private var blockedRouteDirection: Vector2?
    private var blockedRouteCooldownFrames = 0
    private var blockedRouteBypassSign = 1.0
    private var blockedRouteBypassPhaseSteps = 0
    private var blockedRouteBypassSawMovement = false
    private var lastPursuitDirection: Vector2?
    private var lostTargetFrames = 0
    private var lastTargetDisplayedHP: Int?
    private var lastTargetWasVerifiedTree = false
    private var lastTargetWasVerifiedWeaponCarrier = false
    private var engagedVerifiedTree = false
    private var lastConsumedRewardSequence = 0
    private var sawCriticalHealth = false
    private var retreatMode = false
    private let visualRoutes = VisualRouteNavigator()
    private var recentThreatEscapeDirection: Vector2?
    private var retreatFullPixelFrames = 0
    private var lastHealthFraction: Double?
    private var recentDamageFrames = 0
    private var pendingRemotePixelDropFraction: Double?
    private var pendingRemotePixelDropFrames = 0
    private var cachedExplorationDirection: Vector2?
    private var cachedExplorationDirectionFrames = 0
    private var pendingExplorationFlipDirection: Vector2?
    private var pendingExplorationFlipFrames = 0
    private var cachedQuestRouteDirection: Vector2?
    private var cachedQuestRouteDirectionFrames = 0
    private var cachedSpecialLandmarkDirection: Vector2?
    private var cachedSpecialLandmarkDirectionFrames = 0
    private var pendingSpecialLandmarkFlipDirection: Vector2?
    private var pendingSpecialLandmarkFlipFrames = 0
    private var cachedTitanExitDirection: Vector2?
    private var cachedTitanExitDirectionFrames = 0
    private var lastMinimapDirection: Vector2?
    private var stagnantMinimapFrames = 0
    private var minimapDetourFrames = 0
    private var minimapDetourSign = 1.0
    private var failedMinimapDetourCycles = 0
    private var edgeObjectiveRouteAssistFrames = 0
    private var edgeObjectiveRouteAssistDirection: Vector2?
    private var consecutiveNoSafeTargetDecisions = 0
    private var equipmentInspectionMode = false
    private var inventoryCardSelectionAttempted = false
    private var batCleaverEquipAttempted = false
    // A láda egyszeri kutatása elkészült: a Bat Cleaver felszerelve, a Stats
    // képernyő dokumentálva. Új folyamatban sem szabad 24 cél nélküli lépés
    // után újranyitni; ha az inventory nyitva maradt, csak a biztos X-et zárjuk.
    private let equipmentInspectionCompleted = true
    private var mailInspectionMode = false
    private var mailInspectionCompleted = false
    private var mailInspectionStage = 0
    private var mailInspectionCooldownFrames = 0
    private var lastSceneFingerprint: [Int]?
    private var consecutiveStaticSceneDecisions = 0
    private var staticSceneEscapeFrames = 0
    private var staticSceneEscapeDirectionIndex = 0
    private var staticSceneEscapeDirection: Vector2?
    private var failedStaticEscapePhases = 0
    private var staticSceneEscapeSawMovement = false
    private var bossEscapeFrames = 0
    private var bossEscapeDirection: Vector2?
    private var bossEncountersWithoutProgress = 0
    private var elevationSeparatedBossBand: Int?
    private var elevationSeparatedWallFollowFrames = 0
    private var elevationSeparatedBossCooldownFrames = 0
    private var elevationSeparatedWallSign = 1.0
    private var alternateGreenEnemyRouteFrames = 0
    private var alternateGreenEnemyRouteAttempted = false
    private var hasSeenAnyWorldTargetThisProcess = false
    private var orangeEnemyEntryRouteFrames = 0
    private var orangeEnemyEntryRouteAttempted = false
    private var orangeBoundaryGateRecoveryFrames = 0
    private var orangeBoundaryGateRecoveryAttempted = false
    private var island2CentralApproachRouteFrames = 0
    private var island2CentralApproachRouteAttempted = false
    // Az Island 2 narancs oldalán a közeli narancs koponya és az északi piros
    // ellenféljel közvetlen északnyugati vektora a nagy, Island 4 alatti
    // sziklafalnak vezet. A fal tövében álló ház miatt előbb délre kell kijutni
    // a nyílt Dusty Gulch-síkra, onnan nyugaton megkeresni a fal végét, végül
    // északra visszafordulni. Ez külön, egyszeri topológiai próba; az általános
    // képaláírásos akadálymemória nem írhatja felül.
    private var island2ReturnSearchPhase = 0
    private var island2ReturnSearchFrames = 0
    private var island2MeasuredReturnStage = 0
    private var island2MeasuredReturnFrames = 0
    private var controlledBossTrialActive = false
    private var controlledBossTrialFrames = 0
    private var controlledBossTrialLostFrames = 0
    private var controlledBossTrialInitialHP: Int?
    private var controlledBossTrialLowestHP: Int?
    private var controlledBossTrialInitialHeartEvidence = 0.0
    private var controlledBossTrialInitialAxeEvidence = 0.0
    private var controlledBossTrialInitialTreeConfidence = 0.0
    private var controlledBossTrialDirection: Vector2?
    private var controlledBossTrialOrbitSign = 1.0
    private var controlledBossTrialLastDistance: Double?
    private var controlledBossTrialStagnantApproachFrames = 0
    private var controlledBossTrialCloseNoDamageFrames = 0
    private var controlledBossTrialDetourFrames = 0
    private var controlledBossTrialDetourDirection: Vector2?
    private var controlledBossTrialDetourSign = 1.0
    private var controlledBossTrialDetourCycles = 0
    private var controlledBossTrialStructureDetourCount = 0
    private var controlledBossTrialElevatedRampFrames = 0
    private var controlledBossTrialElevatedRampDirection: Vector2?
    private var controlledBossTrialElevatedRoutePhase = 0
    private var docFortressEntryRouteFrames = 0
    // A jobb oldali DOC-kerülő `050935-play/131–160` alatt nem a 4.4K-s őr
    // járható oldalára, hanem az egyszeri felső plató peremére vitt. A síkbeli
    // próbák ott teljesen kimerültek és Unstuck kellett. Amíg új, képi bejárat-
    // bizonyíték nincs, ezt a káros makrót minden folyamatban letiltjuk.
    private var docFortressEntryRouteAttempted = true
    private var docFortressEntryRouteMode = 0
    private var titanTreeGateRouteFrames = 0
    private var titanTreeGateRouteAttempted = false
    private var controlledBossTrialNoDamageOverlapGraceFrames = 0
    private var controlledBossTrialReachedCloseRange = false
    private var controlledBossTrialInitialNearbyRespawnTimer = false
    private var controlledBossTrialHealthReward = 0
    private var controlledBossTrialRewardApplied = false
    private var attemptedBossTrialBands = Set<Int>()
    // A YOU DIED overlay alatt a numerikus HP eltűnik, a háttér zöld elemei
    // pedig teljes csíknak látszhatnak. A legutóbbi valódi, nem passzív
    // kontrollált boss kezdő HP-ját ezért rövid ideig külön őrizzük.
    private var recentHostileBossTrialHP: Int?
    private var recentHostileBossTrialFrames = 0
    private var deathRecoveryPending = false
    private var edgeObjectiveTrialBand: Int?
    private var lastProgressRewardSequence = 0
    private var lastProgressMaximumIncreaseSequence = 0
    private var decisionsSinceProgress = 0
    private var island4DroughtEscapeFrames = 0
    private var island4DroughtEscapeCooldownFrames = 0
    private var island4DroughtEscapeDirection: Vector2?
    private var island4DroughtEscapeSign = -1.0
    private var island4DroughtStaticTurns = 0
    private var protectedFreeExploreFrames = 0
    private var strategicRespawnMode = false
    private var strategicRespawnDirection: Vector2?
    private var strategicRespawnFramesRemaining = 0
    private var strategicRespawnSawDamage = false
    private var strategicRespawnSawHUDLoss = false
    private var strategicRespawnLastBossDistance: Double?
    private var strategicRespawnStagnantApproachFrames = 0
    private var strategicRespawnDetourFrames = 0
    private var strategicRespawnDetourDirection: Vector2?
    private var strategicRespawnDetourSign = 1.0
    private var unstuckRecoveryStage = 0
    private var unstuckRecoveryWaitFrames = 0
    private var unstuckRecoverySawHUDDrop = false
    private var unstuckRetryCooldownFrames = 0
    private var worldChestOpenVisibleFrames = 0
    private var rewardClaimVisibleFrames = 0
    private var titanAltarExploredCooldownFrames = 0
    private var titanExitFramesRemaining = 0
    // A Titan-medence és a Deep Mines 0/1 kapu között a sátor-/hajótest
    // miatt a közvetlen nyugati vektor ismétlődő konkáv csapda. A kézzel
    // kimért topológiai él hat, megszakíthatatlan szakasza külön állapot.
    private var titanToDeepMinesRouteStage = 0
    private var titanToDeepMinesRouteFrames = 0
    private var titanToDeepMinesRouteAttempted = false
    // Új folyamatban is fel kell ismerni, hogy közvetlenül a Titan 0/7
    // buborék mellett éledtünk újra. Rövid OCR-pulzálás nem fegyverezheti újra
    // végtelenül a kijáratot; legalább tizenkét távolléti kép kell hozzá.
    private var titanQuestAbsentFrames = 30
    private var postTitanWesternTargetRouteFrames = 0
    private var postTitanWesternTargetRouteAttempted = false
    private var hasReachedIsland2ThisProcess = false
    private var island2OutsideFrames = 0
    private var island2BoundaryReentryStage = 0
    private var island2BoundaryReentryFrames = 0
    private var island2SkullDetourFrames = 0
    private var island2SkullDetourDirection: Vector2?
    private var island2SkullDetourSign = -1.0
    // A nagy, vízszintes narancs kőhíd alól a koponya légvonala visszamutat a
    // felső sziklába. A tényleges járható gráf dél → nyugat → dél az alsó
    // Dusty-arénába; külön állapot kell, hogy egy új képi koponyamérés se
    // szakítsa félbe minden lépés után.
    private var cachedIsland2SkullDirection: Vector2?
    private var cachedIsland2SkullDirectionFrames = 0
    private var recentOrangeRockBiomeFrames = 0
    private var exhaustedOneShotHighlandBranch = false
    private var pendingOneShotHighlandExit = false
    private var deepMinesGateBossCooldownFrames = 0
    private var deepMinesExitFramesRemaining = 0
    private var failedBossBandsAtMaximum: [Int: Int] = [:]
    private var rejectedSkullCooldownFrames = 0
    private var passiveContactLastHP: Int?
    private var passiveContactStagnantFrames = 0
    private var knownMaximumDisplayedHP = 0
    private var knownDiscoveredChestCount = 0
    private let navigationKnowledgeURL: URL
    private let readOnlyNavigationKnowledge: Bool

    private struct PersistentNavigationKnowledge: Codable {
        var titanAltarIgnoreUntil: Date?
        var deepMinesGateIgnoreUntil: Date?
        var unstuckRetryUntil: Date?
        var elevatedBossRouteIgnoreUntil: Date?
        var elevatedBossRouteBand: Int?
        var exhaustedOneShotHighlandBranch: Bool?
        var pendingOneShotHighlandExit: Bool?
        var failedBossBandsAtMaximum: [String: Int]?
    }

    private struct PersistentPlayerKnowledge: Codable {
        var maximumDisplayedHP: Int
        var discoveredChestCount: Int?
    }

    init(controlledBossTrialsEnabled: Bool = false, readOnlyKnowledge: Bool = false,
         loadNavigationKnowledge: Bool = true, navigationFixturePath: String? = nil,
         playerFixturePath: String? = nil) {
        shopAuditor = ShopAuditor(readOnly: readOnlyKnowledge, loadState: !readOnlyKnowledge)
        self.controlledBossTrialsEnabled = controlledBossTrialsEnabled
        readOnlyNavigationKnowledge = readOnlyKnowledge
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        navigationKnowledgeURL = navigationFixturePath.map { URL(fileURLWithPath: $0) } ??
            root.appendingPathComponent("docs/navigation-state.json")
        let playerKnowledgeURL = playerFixturePath.map { URL(fileURLWithPath: $0) } ??
            root.appendingPathComponent("docs/bot-state.json")
        if let data = try? Data(contentsOf: playerKnowledgeURL),
           let playerState = try? JSONDecoder().decode(PersistentPlayerKnowledge.self, from: data) {
            knownMaximumDisplayedHP = playerState.maximumDisplayedHP
            knownDiscoveredChestCount = max(0, playerState.discoveredChestCount ?? 0)
        }
        if loadNavigationKnowledge,
           let data = try? Data(contentsOf: navigationKnowledgeURL),
           let state = try? JSONDecoder().decode(PersistentNavigationKnowledge.self, from: data) {
            let now = Date()
            if let until = state.titanAltarIgnoreUntil, until > now {
                titanAltarExploredCooldownFrames = max(1, Int(ceil(until.timeIntervalSince(now) / 0.70)))
            }
            if let until = state.deepMinesGateIgnoreUntil, until > now {
                deepMinesGateBossCooldownFrames = max(1, Int(ceil(until.timeIntervalSince(now) / 0.70)))
            }
            if let until = state.unstuckRetryUntil, until > now {
                unstuckRetryCooldownFrames = max(1, Int(ceil(until.timeIntervalSince(now) / 0.70)))
            }
            if let until = state.elevatedBossRouteIgnoreUntil,
               let band = state.elevatedBossRouteBand,
               until > now {
                elevationSeparatedBossCooldownFrames = max(
                    1,
                    Int(ceil(until.timeIntervalSince(now) / 0.70))
                )
                elevationSeparatedBossBand = band
            }
            exhaustedOneShotHighlandBranch = state.exhaustedOneShotHighlandBranch ?? false
            pendingOneShotHighlandExit = state.pendingOneShotHighlandExit ?? false
            failedBossBandsAtMaximum = Dictionary(uniqueKeysWithValues:
                (state.failedBossBandsAtMaximum ?? [:]).compactMap { key, value in
                    Int(key).map { ($0, value) }
                }
            )
        }
    }

    var provenMaximumDisplayedHP: Int { knownMaximumDisplayedHP }

    private func persistNavigationCooldown(
        titan: Bool = false,
        deepMinesGate: Bool = false,
        unstuckCooldownSeconds: TimeInterval? = nil,
        elevatedBossRouteHP: Int? = nil,
        exhaustedOneShotHighland: Bool = false,
        oneShotHighlandExitPending: Bool? = nil
    ) {
        guard !readOnlyNavigationKnowledge else { return }
        let now = Date()
        var state = (try? Data(contentsOf: navigationKnowledgeURL))
            .flatMap { try? JSONDecoder().decode(PersistentNavigationKnowledge.self, from: $0) }
            ?? PersistentNavigationKnowledge(
                titanAltarIgnoreUntil: nil,
                deepMinesGateIgnoreUntil: nil,
                unstuckRetryUntil: nil,
                elevatedBossRouteIgnoreUntil: nil,
                elevatedBossRouteBand: nil,
                exhaustedOneShotHighlandBranch: nil,
                pendingOneShotHighlandExit: nil,
                failedBossBandsAtMaximum: nil
            )
        // Titan 0/7 állapotban nincs rövid távú hozam: a `231139-play` a régi
        // hétperces hűtés lejárta után újra ugyanabba a sátor–kerítés zsebbe
        // vitte a karaktert. Egyórás zár teret ad a két nagy térképes ellenfél,
        // a gemforrások és az északi láda felderítésének; új 0/7 overlay
        // továbbra is explicit kijáratot épít.
        if titan { state.titanAltarIgnoreUntil = now.addingTimeInterval(3600) }
        if deepMinesGate { state.deepMinesGateIgnoreUntil = now.addingTimeInterval(420) }
        if let unstuckCooldownSeconds {
            state.unstuckRetryUntil = now.addingTimeInterval(unstuckCooldownSeconds)
        }
        if let elevatedBossRouteHP {
            state.elevatedBossRouteIgnoreUntil = now.addingTimeInterval(1800)
            state.elevatedBossRouteBand = (elevatedBossRouteHP / 250) * 250
        }
        if exhaustedOneShotHighland {
            state.exhaustedOneShotHighlandBranch = true
            exhaustedOneShotHighlandBranch = true
        }
        if let oneShotHighlandExitPending {
            state.pendingOneShotHighlandExit = oneShotHighlandExitPending
            pendingOneShotHighlandExit = oneShotHighlandExitPending
        }
        state.failedBossBandsAtMaximum = Dictionary(uniqueKeysWithValues:
            failedBossBandsAtMaximum.map { (String($0.key), $0.value) }
        )
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: navigationKnowledgeURL, options: .atomic)
        }
    }

    private func persistBossFailure(bossHP: Int) {
        guard !readOnlyNavigationKnowledge, knownMaximumDisplayedHP > 0 else { return }
        let band = (bossHP / 250) * 250
        failedBossBandsAtMaximum[band] = max(
            failedBossBandsAtMaximum[band] ?? 0,
            knownMaximumDisplayedHP
        )
        persistNavigationCooldown()
    }

    private func bossBandIsStillAboveProvenStrength(_ bossHP: Int) -> Bool {
        let band = (bossHP / 250) * 250
        guard let failedAtMaximum = failedBossBandsAtMaximum[band] else { return false }
        return knownMaximumDisplayedHP < Int(ceil(Double(failedAtMaximum) * 1.20))
    }

    func decide(_ analysis: FrameAnalysis) -> ActionDecision {
        // Bounded trials: small guards and the separately proven500-heart
        // guardian. No global boss-mode enablement; DOC/failed bosses stay out.
        let smallGuardResearchTarget = analysis.visibleTargets.filter {
            guard let hp=$0.displayedHP else{return false}
            let smallGuard=$0.treeConfidence<0.25 && (800...1600).contains(hp)
            let knownHeart=KnownHeartGuardianPolicy.matches(hp:hp,heart:$0.heartIconEvidence,
                rewardNumbers:$0.levelOCRNumbers,structure:$0.objectiveStructureConfidence)
            return (smallGuard || knownHeart) && $0.distance<=300 &&
                $0.bar.minY>90 && $0.bar.maxX<analysis.width-12 &&
                $0.barOutlineConfidence>=0.12 && knownMaximumDisplayedHP>=4000 &&
                (analysis.playerHealthFraction ?? 0)>=0.95 && analysis.playerHealthSource=="ocr-current" &&
                !bossBandIsStillAboveProvenStrength(hp)
        }.min{$0.distance<$1.distance}
        let nearbyQuickFarm = analysis.target.map {
            $0.distance<=400 &&
                (($0.displayedHP ?? Int.max)<=min(800,knownMaximumDisplayedHP/3) ||
                 (!$0.bossEvidence && $0.treeConfidence>=0.45 && ($0.displayedHP ?? Int.max)<=1600))
        } ?? (smallGuardResearchTarget != nil)
        if analysis.expandedMapVisible == true {
            return .wait(reason: "Kinagyított térkép: nincs játékvezérlés és nem fogy navigációs állapot")
        }
        if let shop = analysis.shop,
           let action = shopAuditor.next(shop, safeToOpen:
                (shopOnly || !readOnlyNavigationKnowledge) &&
                analysis.hudConfidence >= 0.8 && analysis.popupClose == nil &&
                analysis.playerHealthSource == "ocr-current" &&
                (analysis.playerHealthFraction ?? 0) >= 0.95 &&
                recentDamageFrames == 0 && !controlledBossTrialActive &&
                bossEscapeFrames == 0 && analysis.nearbyThreatCount == 0) {
            switch action {
            case .wait(let reason): return .wait(reason: "Bolti Free-audit: \(reason)")
            case .open: return .tap(x:Double(analysis.width)*0.948,y:Double(analysis.height)*0.515,
                                    reason:"Piros bolti jelzés: ingyenes statjutalmak külön auditja")
            case .selectStats: return .tap(x:Double(analysis.width)*0.28,y:Double(analysis.height)*0.96,
                                          reason:"Bolti statellenőrzés: CHESTS-ről a STATS lapra; ládaajánlatot nem indítok")
            case .tap(let button): return .tap(x:button.x*Double(analysis.width),y:button.y*Double(analysis.height),
                                               reason:"Biztos zöld, piros jelzésű \(button.label) átvétele; költés nélkül")
            case .scroll(let up): return .scrollShop(up:up,reason:"Csak biztos SHOP-panelen; minden statkártya ellenőrzése")
            case .close(let result):
                if let close=analysis.popupClose { return .tap(x:close.centerX,y:close.centerY,reason:"Bolti audit lezárása: \(result)") }
                return .wait(reason:"Bolti audit kész, de biztos X nélkül nem kattintok")
            }
        }
        if shopOnly { return .wait(reason: "Külön boltfelügyelet: nincs aktuális audit; játékmozgás tiltva") }
        let trialDeathText=(analysis.titanQuestOCRStrings+analysis.dialogueOCRStrings+analysis.playerOCRStrings).joined(separator:" ").uppercased()
        if trialDeathText.contains("YOU DIED") {kiter.cancel()}
        if kitingTrialEnabled,!deathRecoveryPending,analysis.hudConfidence>=0.8,
           (analysis.popupClose==nil || analysis.playerHealthSource=="ocr-current"),analysis.shop?.visible != true {
            let enemies=analysis.visibleTargets.compactMap {target -> BossKitingTrial.Enemy? in
                guard let hp=target.displayedHP,target.bossEvidence || hp>=6_500 else{return nil}
                return .init(hp:hp,x:target.x-Double(analysis.width)*0.5,
                             y:target.y-Double(analysis.height)*0.53,distance:target.distance)
            }
            let dead=(analysis.titanQuestOCRStrings+analysis.dialogueOCRStrings).contains{$0.uppercased().contains("YOU DIED")}
            if let action=kiter.next(hp:analysis.playerHealthFraction,fresh:analysis.playerHealthSource=="ocr-current",enemies:enemies,dead:dead) {
                switch action {
                case .wait(let reason):return .wait(reason:reason)
                case .move(let move):return .swipe(directionX:move.x,directionY:move.y,duration:move.duration,reason:move.reason)
                }
            }
        }
        if rejectedSkullCooldownFrames > 0 { rejectedSkullCooldownFrames -= 1 }
        // Az Island 2 biztos, nagy narancsszikla-lefedettsége egyirányú
        // munkamenet-állapot. Ház, szekér, lomb vagy bányabejárat később
        // eltakarhatja a talajt, de ettől még nem kerültünk vissza Island 1-re,
        // és a szigetkapu útvonala nem indulhat újra.
        if analysis.orangeRockCoverage >= 0.68 {
            hasReachedIsland2ThisProcess = true
            island2OutsideFrames = 0
            island2BoundaryReentryStage = 0
            island2BoundaryReentryFrames = 0
        } else if hasReachedIsland2ThisProcess,
                  analysis.orangeRockCoverage < 0.40 {
            island2OutsideFrames += 1
            if island2OutsideFrames >= 3 {
                // A `024704-play/81` képen a bot egy rövid helyi farm után a
                // zöld oldalra csúszott vissza, de az egyirányú folyamatjelző
                // miatt ezt továbbra is Island 2-nek hitte. Három egymást
                // követő, 40% alatti narancs-kép valódi határátlépés. Innen a
                // `024335`→`024413` mért kapuláb közvetlenül újra használható.
                hasReachedIsland2ThisProcess = false
                if analysis.orangeRockCoverage >= 0.12 {
                    island2BoundaryReentryStage = 1
                    island2BoundaryReentryFrames = 12
                } else {
                    // Mély zöld területről a rövid kapuláb helyfüggő és hibás.
                    // Ott a Deep Mines-sínt használó teljes mért visszaút indul.
                    island2BoundaryReentryStage = 0
                    island2BoundaryReentryFrames = 0
                }
                island2ReturnSearchPhase = 0
                island2ReturnSearchFrames = 0
            }
        } else if hasReachedIsland2ThisProcess {
            island2OutsideFrames = 0
        }
        if analysis.target != nil || !analysis.visibleTargets.isEmpty {
            hasSeenAnyWorldTargetThisProcess = true
        }
        let newlyDiscoveredWorldChest: Bool
        if let discoveredChestCount = analysis.discoveredChestCount,
           discoveredChestCount > knownDiscoveredChestCount {
            knownDiscoveredChestCount = discoveredChestCount
            newlyDiscoveredWorldChest = true
        } else {
            newlyDiscoveredWorldChest = false
        }
        if let displayedHP = analysis.playerDisplayedHP,
           (analysis.playerHealthFraction ?? 0) >= 0.97 {
            knownMaximumDisplayedHP = max(knownMaximumDisplayedHP, displayedHP)
        }
        if recentHostileBossTrialFrames > 0 {
            recentHostileBossTrialFrames -= 1
            if recentHostileBossTrialFrames == 0 {
                recentHostileBossTrialHP = nil
                recentThreatEscapeDirection = nil
            }
        }
        // A boss nemcsak explicit kutatási módban támadhat. A 131134/132
        // 18.88K-s kontaktusa menekülés közben történt, ezért a régi kizárólag
        // próbaindításkor írt memória nem tudta a valódi halál okát eltárolni.
        if let closeBoss = analysis.visibleTargets.filter({
            $0.distance <= 230 && $0.treeConfidence < 0.25 &&
            (canonicalControlledTrialHP($0) ?? 0) >= 5_000
        }).min(by: { $0.distance < $1.distance }),
           let hp = canonicalControlledTrialHP(closeBoss) {
            let previous = recentHostileBossTrialHP
            if previous == nil || hp > previous! || hp < previous! / 2 {
                recentHostileBossTrialHP = hp
            }
            recentHostileBossTrialFrames = 90
            recentThreatEscapeDirection = Vector2(
                x: Double(analysis.width) * 0.5 - closeBoss.x,
                y: Double(analysis.height) * 0.515 - closeBoss.y).normalized
        }
        let deathOverlayVisible = analysis.titanQuestOCRStrings.contains { raw in
            raw.uppercased().replacingOccurrences(of: " ", with: "")
                .contains("YOUDIED")
        }
        if deathOverlayVisible {
            kiter.cancel()
            let failureBossHP = (kitingTrialEnabled ? kiter.initialHP:nil) ?? recentHostileBossTrialHP
            // Kiting returns before the generic contact tracker. Use its
            // initial identity, never the wounded bar on the death frame.
            // Repeated overlay frames must not create additional boss bands.
            if !deathRecoveryPending,
               let recentBossHP = failureBossHP {
                persistBossFailure(bossHP: recentBossHP)
            }
            deathRecoveryPending = true
            recentHostileBossTrialHP = nil
            recentHostileBossTrialFrames = 0
            recentThreatEscapeDirection = nil
            controlledBossTrialActive = false
            controlledBossTrialDirection = nil
            controlledBossTrialLastDistance = nil
            controlledBossTrialStagnantApproachFrames = 0
            controlledBossTrialDetourFrames = 0
            controlledBossTrialDetourDirection = nil
            return .wait(reason: "Biztos YOU DIED overlay; kezdő bossHP \(failureBossHP.map(String.init) ?? "ismeretlen"), az automatikus újraéledést várom")
        }
        if deathRecoveryPending {
            guard analysis.playerHealthSource == "ocr-current",
                  (analysis.playerHealthFraction ?? 0) >= 0.90 else {
                return .wait(reason: "Igazolt halál után friss numerikus 90% HP-ig helyben regenerálódunk")
            }
            deathRecoveryPending = false
            sawCriticalHealth = false
            retreatMode = false
            bossEscapeFrames = 0
            bossEscapeDirection = nil
            return .wait(reason: "Az újraéledés utáni gyógyulást friss numerikus HP igazolja")
        }
        if recentHostileBossTrialFrames > 0,
           let escape = recentThreatEscapeDirection,
           let displayed = analysis.playerDisplayedHP,
           Double(displayed) < Double(knownMaximumDisplayedHP) * 0.65,
           (analysis.playerHealthSource == "ocr-current" || retreatMode) {
            retreatMode = true
            controlledBossTrialActive = false
            controlledBossTrialDirection = nil
            if analysis.playerHealthSource == "ocr-current",
               Double(displayed) < Double(knownMaximumDisplayedHP) * 0.35,
               let bossHP = recentHostileBossTrialHP {
                persistBossFailure(bossHP: bossHP)
            }
            return .swipe(directionX: escape.x, directionY: escape.y, duration: 0.68,
                          reason: "Friss alacsony HP nagy boss mellett: azonnali, folyamatos kifelé menekülés")
        }
        if deepMinesGateBossCooldownFrames > 0 {
            deepMinesGateBossCooldownFrames -= 1
        }
        if elevationSeparatedBossCooldownFrames > 0 {
            elevationSeparatedBossCooldownFrames -= 1
            if elevationSeparatedBossCooldownFrames == 0,
               elevationSeparatedWallFollowFrames == 0 {
                elevationSeparatedBossBand = nil
            }
        }
        if analysis.titanGemQuestVisible {
            // Egyetlen biztos feladatkép elég az oltár eléréséhez. A buborék és
            // a lila ikon is pulzál, ezért az egyképes törlés után különben
            // rögtön visszafordulnánk. A hosszú hűtés alatt más célok és a hét
            // gem lehetséges forrásai kapnak teret.
            let newlyReachedTitanAltar = titanQuestAbsentFrames >= 12
            titanQuestAbsentFrames = 0
            titanAltarExploredCooldownFrames = 5_400
            if newlyReachedTitanAltar && !titanToDeepMinesRouteAttempted {
                titanExitFramesRemaining = 0
                titanToDeepMinesRouteAttempted = true
                titanToDeepMinesRouteStage = 1
                titanToDeepMinesRouteFrames = 12
                island2ReturnSearchPhase = 0
                island2ReturnSearchFrames = 0
                persistNavigationCooldown(titan: true)
            }
        } else {
            titanQuestAbsentFrames = min(60, titanQuestAbsentFrames + 1)
            if titanAltarExploredCooldownFrames > 0 {
                titanAltarExploredCooldownFrames -= 1
            }
        }
        if analysis.orangeRockBiomeVisible {
            recentOrangeRockBiomeFrames = 12
        } else if recentOrangeRockBiomeFrames > 0 {
            recentOrangeRockBiomeFrames -= 1
        }
        if analysis.continueButtonVisible {
            return .tap(
                x: Double(analysis.width) * 0.50,
                y: Double(analysis.height) * 0.80,
                reason: "Felismert jutalomablak CONTINUE gombjának megnyomása"
            )
        }
        if analysis.claimRewardVisible {
            rewardClaimVisibleFrames += 1
            if rewardClaimVisibleFrames == 1 || rewardClaimVisibleFrames == 10 {
                return .tap(
                    x: Double(analysis.width) * 0.50,
                    y: Double(analysis.height) * 0.82,
                    reason: rewardClaimVisibleFrames == 1
                        ? "Biztos TAP TO CLAIM világ-ládajutalom átvétele"
                        : "A TAP TO CLAIM képernyő maradt; egyetlen késleltetett újrapróbálás"
                )
            }
            return .wait(reason: "A ládajutalom képernyője még látszik; tap-spam helyett figyelek")
        }
        rewardClaimVisibleFrames = 0
        if analysis.openButtonVisible, let openButtonCenter = analysis.openButtonCenter {
            if analysis.orangeRockCoverage >= 0.75,
               analysis.centralLongRespawnTimerCount > 0 {
                // A felső, időzítős ládaplatón biztos OPEN gomb jelzi, hogy
                // az egyszeri ág hozamát éppen begyűjtjük. Az ezt követő
                // célmentes állapotban jogos a gyors rétegkijutás.
                persistNavigationCooldown(
                    exhaustedOneShotHighland: true,
                    oneShotHighlandExitPending: true
                )
            }
            worldChestOpenVisibleFrames += 1
            if worldChestOpenVisibleFrames == 1 || worldChestOpenVisibleFrames == 10 {
                return .tap(
                    x: openButtonCenter.x,
                    y: openButtonCenter.y,
                    reason: worldChestOpenVisibleFrames == 1
                        ? "Biztos helyszíni láda OPEN gombjának egyszeri megnyomása"
                        : "A láda OPEN gombja tartósan látszik; egyetlen késleltetett újrapróbálás"
                )
            }
            return .wait(reason: "A helyszíni láda OPEN gombja még látszik; ismételt koppintás helyett figyelek")
        }
        worldChestOpenVisibleFrames = 0
        var observedProgress = newlyDiscoveredWorldChest
        if let rewardSequence = analysis.recentRewardSequence,
           rewardSequence > lastProgressRewardSequence {
            lastProgressRewardSequence = rewardSequence
            observedProgress = true
        }
        if let maximumSequence = analysis.confirmedMaximumIncreaseSequence,
           maximumSequence > lastProgressMaximumIncreaseSequence {
            lastProgressMaximumIncreaseSequence = maximumSequence
            observedProgress = true
        }
        if observedProgress {
            bossEncountersWithoutProgress = 0
            controlledBossTrialActive = false
            controlledBossTrialFrames = 0
            controlledBossTrialLostFrames = 0
            controlledBossTrialInitialHP = nil
            controlledBossTrialLowestHP = nil
            controlledBossTrialDirection = nil
            controlledBossTrialLastDistance = nil
            controlledBossTrialStagnantApproachFrames = 0
            controlledBossTrialDetourFrames = 0
            controlledBossTrialDetourDirection = nil
            edgeObjectiveTrialBand = nil
            decisionsSinceProgress = 0
            island4DroughtEscapeFrames = 0
            island4DroughtEscapeCooldownFrames = 0
            island4DroughtEscapeDirection = nil
            island4DroughtStaticTurns = 0
            protectedFreeExploreFrames = 0
            failedStaticEscapePhases = 0
            // Ha a boss-hurokból kifelé tartva mégis valódi fejlődést szerzünk,
            // az újraéledési rövidítés oka megszűnt. A normál sebzésőr ezután
            // szükség esetén biztonságosan kiviszi a karaktert a harcból.
            strategicRespawnMode = false
            strategicRespawnDirection = nil
            strategicRespawnFramesRemaining = 0
            strategicRespawnSawDamage = false
            strategicRespawnSawHUDLoss = false
        } else {
            decisionsSinceProgress += 1
        }
        if island4DroughtEscapeCooldownFrames > 0 {
            island4DroughtEscapeCooldownFrames -= 1
        }
        if analysis.dialogueCanAdvance {
            // A Cursed Girl küldetés párbeszéde teljes képernyőre vált és
            // elrejti a HUD-ot. A képen explicit "Tap to continue" látható;
            // ez az egyetlen HUD nélküli állapot, amelyben általános tap
            // megengedett. A dialógusmező jobb alsó részét érintjük.
            return .tap(
                x: Double(analysis.width) * 0.72,
                y: Double(analysis.height) * 0.80,
                reason: "Felismert 'Tap to continue' küldetéspárbeszéd léptetése"
            )
        }
        if mailInspectionCooldownFrames > 0 {
            mailInspectionCooldownFrames -= 1
            if mailInspectionCooldownFrames == 0 { mailInspectionCompleted = false }
        }
        if unstuckRecoveryStage == 0,
           exhaustedOneShotHighlandBranch,
           failedStaticEscapePhases >= 6,
           decisionsSinceProgress >= 150,
           analysis.orangeRockCoverage >= 0.75,
           (
               analysis.nearbyRespawnTimer ||
               (pendingOneShotHighlandExit && analysis.centralLongRespawnTimerCount > 0)
           ),
           unstuckRetryCooldownFrames == 0,
           analysis.target == nil,
           !analysis.innerMapEnemyVisible,
           !analysis.edgeObjectiveVisible {
            // A `213307-play/49,68,123` képei alapján a már kifosztott városi
            // felső rétegen egyszerre magas a tömör narancsszikla-arány és a
            // középső ROI-ban órás ládaidőzítő látszik. A `220802-play/256`
            // visszatérésén az OCR a közeli 3h44m kört a célzott
            // `nearbyRespawnTimer` jellel azonosította akkor is, amikor a
            // középső szöveglista üres maradt. Dusty Gulch alsó, járható
            // síkján a `214244-play` összehasonlító képein ez a közeli jel
            // végig hamis volt; az ottani elszórt középső OCR-találat csak a
            // friss OPEN utáni `pending` bittel együtt számít. A tartósan
            // kimerített ág ezért újabb feljutáskor sem vár ál-kerülőkre.
            failedStaticEscapePhases = 0
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            blockedRouteCooldownFrames = 0
            blockedRouteDirection = nil
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
            controlledBossTrialActive = false
            controlledBossTrialDirection = nil
            unstuckRecoveryStage = 1
            unstuckRecoveryWaitFrames = 0
            persistNavigationCooldown(
                exhaustedOneShotHighland: true,
                oneShotHighlandExitPending: true
            )
            return .tap(
                x: Double(analysis.width) * 0.061,
                y: Double(analysis.height) * 0.076,
                reason: "Tartós térkép szerint kifosztott magaslati ládaplató: azonnali Unstuck"
            )
        }
        if unstuckRecoveryStage == 0,
           elevationSeparatedBossCooldownFrames > 0,
           failedStaticEscapePhases >= 6,
           decisionsSinceProgress >= 150,
           elevationSeparatedBossBand != nil,
           analysis.orangeRockCoverage >= 0.24,
           unstuckRetryCooldownFrames == 0,
           analysis.target == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A magaslati különlegesládás ág egyszer kimeríthető. A `201915`
            // élő ellenőrzésben a karakter teljes HP-n, cél nélkül maradt a
            // narancssziklás felső rétegen: a háttér a sok különböző swipe-tól
            // mozgott, de egyik út sem hagyta el a szintet. A felhasználó
            // megerősítette, hogy innen a járhatóság szándékosan korlátozott.
            // A már bevált Unstuck ilyenkor nem végső statikussági tartalék,
            // hanem az egyszeri mellékág determinisztikus lezárása.
            failedStaticEscapePhases = 0
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            blockedRouteCooldownFrames = 0
            blockedRouteDirection = nil
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
            controlledBossTrialActive = false
            controlledBossTrialDirection = nil
            unstuckRecoveryStage = 1
            unstuckRecoveryWaitFrames = 0
            return .tap(
                x: Double(analysis.width) * 0.061,
                y: Double(analysis.height) * 0.076,
                reason: "Kimerített egyszeri magaslati ládaág: azonnali Unstuck-helyreállítás megnyitása"
            )
        }
        if unstuckRecoveryStage == 1 {
            unstuckRecoveryWaitFrames += 1
            guard analysis.settingsClose != nil else {
                if unstuckRecoveryWaitFrames >= 12 {
                    unstuckRecoveryStage = 0
                    unstuckRetryCooldownFrames = 300
                    persistNavigationCooldown(
                        unstuckCooldownSeconds: 210,
                        oneShotHighlandExitPending: false
                    )
                    return .wait(reason: "A Settings panel nem jelent meg biztosan; az Unstuck-próba megszakítva")
                }
                return .wait(reason: "A Settings panel biztos X-ének megjelenését várom az Unstuck előtt")
            }
            unstuckRecoveryStage = 2
            unstuckRecoveryWaitFrames = 0
            unstuckRecoverySawHUDDrop = false
            return .tap(
                x: Double(analysis.width) * 0.529,
                y: Double(analysis.height) * 0.735,
                reason: "A beállításmenü bizonyított Unstuck gombjának egyszeri megnyomása"
            )
        }
        if unstuckRecoveryStage == 2 {
            unstuckRecoveryWaitFrames += 1
            // A Settings panel elsötétített háttere élőben 80%-os ál-HUD-ot
            // adott. Mivel az előző állapotban már külön igazoltuk a panelt,
            // most kizárólag a Settings saját X-ének eltűnése bizonyítja, hogy
            // a tap tényleges teleportátmenetet indított.
            if analysis.settingsClose == nil {
                unstuckRecoverySawHUDDrop = true
            }
            if unstuckRecoverySawHUDDrop, unstuckRecoveryWaitFrames >= 30 {
                unstuckRecoveryStage = 0
                unstuckRetryCooldownFrames = 900
                persistNavigationCooldown(
                    unstuckCooldownSeconds: 630,
                    oneShotHighlandExitPending: false
                )
                failedStaticEscapePhases = 0
                consecutiveStaticSceneDecisions = 0
                // A teleport után semmilyen, a régi zárfalnál felépített mozgási
                // terv nem élhet tovább. Különben a statikus kiszabadítás még a
                // friss helyi spirál előtt visszarántja a karaktert ugyanoda.
                staticSceneEscapeFrames = 0
                staticSceneEscapeDirection = nil
                staticSceneEscapeSawMovement = false
                minimapDetourFrames = 0
                stagnantMinimapFrames = 0
                persistentDetourFrames = 0
                persistentDetourDirection = nil
                weaponCarrierCornerTurnFrames = 0
                weaponCarrierCornerTurnDirection = nil
                blockedAreaEscapeFrames = 0
                blockedAreaEscapeDirection = nil
                blockedRouteCooldownFrames = 0
                blockedRouteDirection = nil
                blockedRouteBypassPhaseSteps = 0
                blockedRouteBypassSawMovement = false
                island4DroughtEscapeFrames = 0
                island4DroughtEscapeCooldownFrames = 0
                island4DroughtEscapeDirection = nil
                island4DroughtEscapeSign = -1.0
                island4DroughtStaticTurns = 0
                // A medence minimapja ugyanazt a régi piros célt mutathatja,
                // amelyből épp kiszabadultunk. Rövid helyi spirál kell, hogy a
                // karakter elhagyja a teleport közvetlen tárgyait, de a korábbi
                // 120 döntés élőben már a nagy térképen látható ellenfélhez
                // haladást is fölöslegesen elnyomta. A Dusty-bosshurok külön
                // 120-as védelme változatlan; ez az Unstuck-utáni ablak csak 24.
                protectedFreeExploreFrames = 24
                resetFallbackExploration()
                return .wait(reason: "Az Unstuck és a gyógyulás letelt; 24 döntéses helyi kijutás indul, utána a piros minimapcél visszakapcsol")
            }
            let readableUnstuckCountdown = analysis.unstuckCooldownSeconds != nil
            if !unstuckRecoverySawHUDDrop,
               ((readableUnstuckCountdown && unstuckRecoveryWaitFrames >= 5) ||
                unstuckRecoveryWaitFrames >= 14) {
                // Sikeres teleportnál a Settings panel eltűnik (popupClose=nil),
                // illetve egyes átmeneteknél a HUD-biztonság is leesik. Ha az X
                // és olvasható `mm:ss` öt képen át megmarad, biztosan időzár
                // futott, ezért annak pontos lejáratát mentjük. A `195052-play`
                // során viszont az elindult teleport alatt is még öt képen
                // látszott a panel, számláló nélkül; a régi ág túl korán bezárta,
                // majd a következő képen már a zöld medence jelent meg. Ismeretlen
                // gombfeliratnál ezért tizennégy képet adunk a megkésett
                // panel-eltűnésnek, és csak utána használjuk a tartalék hűtést.
                unstuckRecoveryStage = 0
                let cooldownSeconds = analysis.unstuckCooldownSeconds.map { $0 + 5 } ?? 630
                unstuckRetryCooldownFrames = max(
                    1,
                    Int(ceil(Double(cooldownSeconds) / 0.70))
                )
                persistNavigationCooldown(
                    unstuckCooldownSeconds: TimeInterval(cooldownSeconds),
                    oneShotHighlandExitPending: false
                )
                return .tap(
                    x: analysis.settingsClose?.centerX ?? Double(analysis.width) * 0.665,
                    y: analysis.settingsClose?.centerY ?? Double(analysis.height) * 0.127,
                    reason: analysis.unstuckCooldownSeconds.map {
                        "Az Unstuck számlálója \($0) másodperc; Settings bezárása és pontos tartós időzár"
                    } ?? "Az Unstuck visszaszámlálós maradt; Settings bezárása és tartalék tízperces hűtés"
                )
            }
            return .wait(reason: "Az Unstuck áthelyezését és a zöld medence gyógyítását input nélkül kivárom")
        }
        if unstuckRetryCooldownFrames > 0 {
            unstuckRetryCooldownFrames -= 1
        }
        if elevationSeparatedBossCooldownFrames > 0,
           analysis.orangeRockCoverage >= 0.24,
           unstuckRetryCooldownFrames > 0,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A `202322` és `202954` élő futások ugyanarról a felső rétegről
            // délkeleti tartással visszaértek a zöld mezőre. Aktív Unstuck-
            // időzár alatt ne induljon új spirál, lila jel vagy kétes csík után:
            // a 24% fölötti narancsszikla-arány valódi magaslati belső állapot,
            // míg a zöld határ téves pozitív képe csak 10,1% volt.
            cachedExplorationDirection = nil
            cachedExplorationDirectionFrames = 0
            cachedQuestRouteDirection = nil
            cachedQuestRouteDirectionFrames = 0
            cachedSpecialLandmarkDirection = nil
            cachedSpecialLandmarkDirectionFrames = 0
            lostTargetFrames = 0
            lastPursuitDirection = nil
            return .swipe(
                directionX: 0.79,
                directionY: 0.61,
                duration: 0.56,
                reason: "Kimerített magaslati ág: délkeleti területelhagyás az Unstuck időzár alatt"
            )
        }
        if mailInspectionMode {
            if let close = analysis.popupClose,
               close.centerX >= Double(analysis.width) * 0.60,
               close.centerX <= Double(analysis.width) * 0.78,
               close.centerY <= Double(analysis.height) * 0.28 {
                mailInspectionMode = false
                mailInspectionCompleted = true
                mailInspectionStage = 0
                mailInspectionCooldownFrames = 2_572
                return .tap(
                    x: close.centerX,
                    y: close.centerY,
                    reason: "A jelzett Mailboxot ellenőriztem; az ismert X-szel bezárom"
                )
            }
            if mailInspectionStage == 1 {
                // A boríték első tapja csak lehajtja/átalakítja a HUD-ikont; a
                // `MAILBOX` panel a második tapra nyílik meg. Ez nem dupla véletlen
                // input, hanem élőben kétszer igazolt kétlépcsős UI.
                mailInspectionStage = 2
                return .tap(
                    x: Double(analysis.width) * 0.141,
                    y: Double(analysis.height) * 0.070,
                    reason: "A jelzett boríték második, panelnyitó tapja"
                )
            }
            mailInspectionStage += 1
            if mailInspectionStage >= 8 {
                mailInspectionMode = false
                mailInspectionCompleted = true
                mailInspectionStage = 0
                mailInspectionCooldownFrames = 600
                return .wait(reason: "A Mailbox nem nyílt meg biztosan; rövid hűtés után újraellenőrzöm")
            }
            return .wait(reason: "A jelzett Mailbox tartalmát elemzem; ismeretlen műveletet nem indítok")
        }

        let equipmentDetailStrings = analysis.playerOCRStrings + analysis.rewardOCRStrings + analysis.titanQuestOCRStrings
        let batCleaverDetailsVisible = equipmentDetailStrings.contains {
            let text = $0.uppercased()
            return text.contains("TRIBUTE") || text.contains("SPECIAL ABILITY")
        }
        if batCleaverDetailsVisible {
            // A SPECIAL ABILITY minden fegyver paneljén szerepel, nem Bat Cleaver
            // azonosító. A 20260919 Venom Shard auditja cáfolta a régi felismerést.
            // Automatikus csere helyett a felügyelő hasonlítja össze a statokat.
            if let close = analysis.popupClose {
                return .tap(
                    x: close.centerX,
                    y: close.centerY,
                    reason: "Fegyverrészletező bezárása; csere csak igazolt statösszehasonlítás után"
                )
            }
            return .wait(reason: "Fegyverrészletező: biztos bezárógombot várok")
        }

        let inventoryVisible = (analysis.playerOCRStrings + analysis.titanQuestOCRStrings).contains {
            $0.uppercased().contains("INVENTORY")
        }
        if inventoryVisible {
            if equipmentInspectionCompleted {
                equipmentInspectionMode = false
                if let close = analysis.popupClose {
                    return .tap(
                        x: close.centerX,
                        y: close.centerY,
                        reason: "A befejezett felszereléskutatás után az ismert inventory-X bezárása"
                    )
                }
                return .wait(reason: "Inventory felismerve, de a biztos bezárógomb ezen a képen nem mérhető")
            }
            equipmentInspectionMode = true
            if batCleaverEquipAttempted {
                return .wait(reason: "Bat Cleaver felszerelési kísérlete kész; az inventory új statjait elemzem")
            }
            if !inventoryCardSelectionAttempted {
                inventoryCardSelectionAttempted = true
                return .tap(
                    x: Double(analysis.width) * 0.276,
                    y: Double(analysis.height) * 0.609,
                    reason: "A piros jelzésű zöld fegyverkártya egyszeri kiválasztása; utána csak elemzés"
                )
            }
            return .wait(reason: "A kiválasztott inventory-fegyverkártya részleteit elemzem")
        }
        if equipmentInspectionMode {
            return .wait(reason: "Felszerelésláda megnyitva; az ismeretlen menüt csak elemzem")
        }
        if let close = analysis.popupClose,
           analysis.hudConfidence < 0.60,
           close.centerX >= Double(analysis.width) * 0.60 {
            // Az ismert Rate us/inventory/shop bezárók a panel jobb oldalán
            // vannak. A Cursed Girl piros hajdísze 46x40-es pink komponensként
            // ugyan átment a régi méretszűrőn, de a kép bal-középső részén van.
            // A narancs bányatábor sziklaíve jobb oldali 73x31-es komponenst
            // adott: normál, 100%-os HUD mellett ezért általános X-tap tilos.
            return .tap(x: close.centerX, y: close.centerY, reason: "Ismert értékelési felugró ablak bezárása")
        }

        if engagedVerifiedTree,
           let reward = analysis.recentRewardValue,
           let rewardSequence = analysis.recentRewardSequence,
           rewardSequence > lastConsumedRewardSequence {
            lastConsumedRewardSequence = rewardSequence
            closeTargetFrames = 0
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastPursuitDirection = nil
            lostTargetFrames = 0
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            stagnantApproachFrames = 0
            detourFrames = 0
            return .wait(reason: "+\(reward) jutalom felismerve; a befejezett harci memória lezárva")
        }

        if engagedVerifiedTree, analysis.target == nil, analysis.nearbyRespawnTimer {
            closeTargetFrames = 0
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastPursuitDirection = nil
            lostTargetFrames = 0
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            stagnantApproachFrames = 0
            detourFrames = 0
            return .wait(reason: "Közeli újratermelődési időzítő jelent meg; a passzív cél biztosan befejeződött")
        }

        if analysis.hudConfidence < 0.60 {
            noHUDFrames += 1
            if strategicRespawnMode {
                strategicRespawnSawHUDLoss = true
            }
            // Halálkor néhány másodpercre eltűnhetnek a csíkok, majd a játék
            // automatikusan újraéleszt a medencében. Kritikus HP után hosszabb
            // átmenetet engedünk, más ismeretlen képernyőn marad a szigorú őr.
            // A felügyelt botnak explicit felhasználói leállításig életben kell
            // maradnia. Ismeretlen HUD nélküli képen ezért nem küld inputot és
            // nem fejezi be a folyamatot: tovább rögzít és a HUD visszatérését
            // figyeli. A Cursed Girl kővé váló átvezetője ezt élőben igényelte.
            if noHUDFrames >= (sawCriticalHealth ? 15 : 6) {
                return .wait(reason: "Tartós HUD-hiány; input nélkül figyelem az átvezető/újraéledési képernyő végét")
            }
            return .wait(reason: sawCriticalHealth
                ? "Valószínű halál/újraéledés átmenet; HUD visszatérésére várok"
                : "HUD nélküli átvezető vagy párbeszéd; passzívan figyelek")
        }
        noHUDFrames = 0

        // Hosszú Island 4-jutalomhiánynál, illetve már megkezdett statikus
        // kiszabadításnál a néhány pixeles karaktercsúszás és
        // kamerakorrekció nem valódi előrehaladás. A híd–sátor zsebben ugyanaz
        // a két háttérállapot váltakozott, és a nagy ujjlenyomat-különbség minden
        // második kiszabadítási fázis után tévesen törölte az elakadás bizonyítékát.
        // Hosszú droughtnál, illetve az első valóban sikertelen fázis után csak
        // új jutalom/cél vagy a fal eltűnése nullázhatja a fázisbizonyítékot.
        let preserveStaticFailureEvidence = decisionsSinceProgress >= 150 ||
            (failedStaticEscapePhases > 0 && analysis.target == nil)

        if let previous = lastSceneFingerprint,
           previous.count == analysis.sceneFingerprint.count {
            let difference = zip(previous, analysis.sceneFingerprint).reduce(0) {
                $0 + abs($1.0 - $1.1)
            }
            if difference <= 12 {
                consecutiveStaticSceneDecisions += 1
            } else {
                consecutiveStaticSceneDecisions = 0
                if difference > 44 {
                    if !preserveStaticFailureEvidence {
                        failedStaticEscapePhases = 0
                    }
                    if staticSceneEscapeFrames > 0 {
                        staticSceneEscapeSawMovement = true
                    }
                }
            }
        }
        lastSceneFingerprint = analysis.sceneFingerprint

        // A minimap apró piros/sárga komponense egy-egy képen a fényes köd és
        // UI-átfedés miatt eltűnhet. Rövid felismerési résnél ne váltsunk az
        // ellentétes első spirállépésre, hanem tartsuk az utolsó mért vektort.
        let effectiveExplorationDirection: Vector2?
        if let currentDirection = analysis.explorationDirection {
            if let cached = cachedExplorationDirection,
               cached.x * currentDirection.x + cached.y * currentDirection.y < -0.45 {
                // Több közeli piros pontnál a „legközelebbi” cél egyetlen
                // kamerarezzenéstől képenként átugorhat a játékos két oldalára.
                // Ez a 165856-os futásban pontosan ellentétes észak/dél
                // swipe-okkal helyben tartotta a karaktert. Egy valódi cél-
                // áthaladás után az új oldal több képen át megmarad, ezért csak
                // három egymást követő, egymással egyező mérés fordíthatja meg a
                // stabil piros célirányt.
                if let pending = pendingExplorationFlipDirection,
                   pending.x * currentDirection.x + pending.y * currentDirection.y >= 0.88 {
                    pendingExplorationFlipFrames += 1
                } else {
                    pendingExplorationFlipDirection = currentDirection
                    pendingExplorationFlipFrames = 1
                }
                if pendingExplorationFlipFrames >= 3 {
                    cachedExplorationDirection = currentDirection
                    cachedExplorationDirectionFrames = 4
                    pendingExplorationFlipDirection = nil
                    pendingExplorationFlipFrames = 0
                    effectiveExplorationDirection = currentDirection
                } else {
                    cachedExplorationDirectionFrames = 4
                    effectiveExplorationDirection = cached
                }
            } else {
                cachedExplorationDirection = currentDirection
                cachedExplorationDirectionFrames = 4
                pendingExplorationFlipDirection = nil
                pendingExplorationFlipFrames = 0
                effectiveExplorationDirection = currentDirection
            }
        } else if cachedExplorationDirectionFrames > 0,
                  let cachedExplorationDirection {
            cachedExplorationDirectionFrames -= 1
            effectiveExplorationDirection = cachedExplorationDirection
        } else {
            cachedExplorationDirection = nil
            pendingExplorationFlipDirection = nil
            pendingExplorationFlipFrames = 0
            effectiveExplorationDirection = nil
        }

        // A türkiz, szaggatott küldetésútvonal a tereptárgyak és effektek
        // takarásában gyakran csak egyetlen képen ismerhető fel. Az utolsó
        // közvetlenül mért irányt néhány valódi döntésig őrizzük, hogy egy
        // rövid felismerési rés ne dobja vissza a botot minimap-bolyongásba.
        var effectiveQuestRouteDirection: Vector2?
        if let currentDirection = analysis.questRouteDirection {
            cachedQuestRouteDirection = currentDirection
            cachedQuestRouteDirectionFrames = 6
            effectiveQuestRouteDirection = currentDirection
        } else if cachedQuestRouteDirectionFrames > 0,
                  let cachedQuestRouteDirection {
            cachedQuestRouteDirectionFrames -= 1
            effectiveQuestRouteDirection = cachedQuestRouteDirection
        } else {
            cachedQuestRouteDirection = nil
            effectiveQuestRouteDirection = nil
        }
        if deepMinesGateBossCooldownFrames > 0 {
            // A türkiz Deep Mines-sín ugyanahhoz a lila kőkapuhoz vezetett,
            // amelyet a kétoldali bosspróba fizikailag zártnak bizonyított.
            // A hűtés alatt ne húzza vissza a botot ugyanahhoz a falhoz.
            cachedQuestRouteDirection = nil
            cachedQuestRouteDirectionFrames = 0
            effectiveQuestRouteDirection = nil
        }

        // A lila portál-/oltárjel pulzáló animációja élőben minden második
        // képen a küszöb alá esett. Rövid memória nélkül a bot a vele ellentétes
        // piros ponttal felváltva jobbra-balra swipe-olt. Öt döntésnyi memória
        // áthidalja az animációt, de eltűnt vagy elért helyet nem őriz sokáig.
        let effectiveSpecialLandmarkDirection: Vector2?
        if analysis.orangeRockBiomeVisible || recentOrangeRockBiomeFrames > 0 {
            // Az Island 2 az aktuális küldetési terület. A `014420-play/0`
            // képen a lila minimapjel egyetlen északnyugati swipe-pal azonnal
            // visszateleportálta a karaktert a zöld Titan-oltárhoz, miközben a
            // 18,8K-s őr és az 1,28K-s kaktusz már ténylegesen előttünk állt.
            // Narancs biomon ezért a lila portál soha nem navigációs cél; a
            // piros ellenféljel és a helyi vizuális célok maradnak aktívak.
            cachedSpecialLandmarkDirection = nil
            cachedSpecialLandmarkDirectionFrames = 0
            pendingSpecialLandmarkFlipDirection = nil
            pendingSpecialLandmarkFlipFrames = 0
            effectiveSpecialLandmarkDirection = nil
        } else if analysis.titanGemQuestVisible || titanAltarExploredCooldownFrames > 0 ||
            deepMinesGateBossCooldownFrames > 0 {
            // Az overlay bizonyítja, hogy az oltárt elértük. A célpont rövid
            // memóriáját azonnal töröljük, és a pulzáló overlay felismerési
            // réseiben sem építjük újra; különben visszanyomnánk a karaktert a
            // középpontba ahelyett, hogy gemeket keresne. A kétoldali próbával
            // lezárt Deep Mines-kapunál ugyanez a lila jel a zárt kaput mutatja;
            // a kapuhűtés alatt azt is némítjuk, hogy ne írja felül a dél felé
            // tartó területelhagyást.
            cachedSpecialLandmarkDirection = nil
            cachedSpecialLandmarkDirectionFrames = 0
            pendingSpecialLandmarkFlipDirection = nil
            pendingSpecialLandmarkFlipFrames = 0
            effectiveSpecialLandmarkDirection = nil
        } else if let currentDirection = analysis.specialLandmarkDirection {
            if let cached = cachedSpecialLandmarkDirection,
               cached.x * currentDirection.x + cached.y * currentDirection.y < -0.70 {
                // A 163736-as élő futásban ugyanazon a kövezett úton a lila
                // ikon detektora minden második képen pontosan megfordult, így
                // 100+ swipe-on át helyben ingázott. Valódi áthaladáskor az új
                // oldal legalább három egymást követő képen megmarad; egyetlen
                // ellentétes felvillanás nem írhatja felül a stabil irányt.
                if let pending = pendingSpecialLandmarkFlipDirection,
                   pending.x * currentDirection.x + pending.y * currentDirection.y >= 0.90 {
                    pendingSpecialLandmarkFlipFrames += 1
                } else {
                    pendingSpecialLandmarkFlipDirection = currentDirection
                    pendingSpecialLandmarkFlipFrames = 1
                }
                if pendingSpecialLandmarkFlipFrames >= 3 {
                    cachedSpecialLandmarkDirection = currentDirection
                    cachedSpecialLandmarkDirectionFrames = 5
                    pendingSpecialLandmarkFlipDirection = nil
                    pendingSpecialLandmarkFlipFrames = 0
                    effectiveSpecialLandmarkDirection = currentDirection
                } else {
                    cachedSpecialLandmarkDirectionFrames = 5
                    effectiveSpecialLandmarkDirection = cached
                }
            } else {
                cachedSpecialLandmarkDirection = currentDirection
                cachedSpecialLandmarkDirectionFrames = 5
                pendingSpecialLandmarkFlipDirection = nil
                pendingSpecialLandmarkFlipFrames = 0
                effectiveSpecialLandmarkDirection = currentDirection
            }
        } else if cachedSpecialLandmarkDirectionFrames > 0,
                  let cachedSpecialLandmarkDirection {
            cachedSpecialLandmarkDirectionFrames -= 1
            effectiveSpecialLandmarkDirection = cachedSpecialLandmarkDirection
        } else {
            cachedSpecialLandmarkDirection = nil
            pendingSpecialLandmarkFlipDirection = nil
            pendingSpecialLandmarkFlipFrames = 0
            effectiveSpecialLandmarkDirection = nil
        }

        // A felismert oltár puszta figyelmen kívül hagyása nem elég: a növekvő
        // négyzetspirál terepakadályok mellett fizikailag visszakanyarodhat hozzá.
        // A minimapon tovább látható lila irány ilyenkor kiváló kifelé-mutató jel:
        // az ellentettjét tartjuk, amíg az oltár ki nem kerül a minimap környezetéből.
        // A pulzálást külön, rövid kijárati memória hidalja át.
        let effectiveTitanExitDirection: Vector2?
        if titanAltarExploredCooldownFrames > 0,
           titanExitFramesRemaining > 0 {
            if let altarDirection = analysis.specialLandmarkDirection {
                let exit = Vector2(x: -altarDirection.x, y: -altarDirection.y).normalized
                cachedTitanExitDirection = exit
                cachedTitanExitDirectionFrames = 6
                effectiveTitanExitDirection = exit
            } else if cachedTitanExitDirectionFrames > 0,
                      let cachedTitanExitDirection {
                cachedTitanExitDirectionFrames -= 1
                effectiveTitanExitDirection = cachedTitanExitDirection
            } else {
                cachedTitanExitDirection = nil
                effectiveTitanExitDirection = nil
            }
        } else {
            cachedTitanExitDirection = nil
            cachedTitanExitDirectionFrames = 0
            effectiveTitanExitDirection = nil
        }

        // A globális UNLOCKS AT ISLAND 4 HUD önmagában nem bizonyítja, hogy egy
        // piros minimapcél a zárt kapu mögött van. Csak a két oldalról fizikailag
        // kipróbált Deep Mines-kapu aktív memóriája alatt némítjuk a hozzá vezető
        // erősen balra mutató irányt. Minden más piros cél valódi ellenféljelölt.
        let blockedDeepMinesGateSuppressesRed = deepMinesGateBossCooldownFrames > 0 &&
            (effectiveExplorationDirection?.x ?? 0) < -0.75
        // A kifosztott magaslati láda csak magát a ládaágat meríti ki, nem a
        // teljes északnyugati térképszeletet. A `232649-play` bizonyította,
        // hogy ugyanebben a szögben egy külön, még élő narancs ellenféljel is
        // van: az Analyzer stabilan (-0,75; -0,66) irányt adott, a régi globális
        // némítás mégis elfordult róla. Csak a frissen, tényleges harcban
        // magasságkülönbség miatt sikertelen boss kap rövid irányzárat.
        let blockedExhaustedHighlandSuppressesRed =
            elevationSeparatedBossCooldownFrames > 0 &&
            (effectiveExplorationDirection?.x ?? 0) < -0.45 &&
            (effectiveExplorationDirection?.y ?? 0) < -0.15
        let navigableExplorationDirection =
            (blockedDeepMinesGateSuppressesRed || blockedExhaustedHighlandSuppressesRed)
            ? nil
            : effectiveExplorationDirection
        // A minimap peremére kitolt piros fegyverjel nem közeli, tetszőleges
        // farmpont: a játék egy távoli kijelölt ellenfél irányát mutatja vele.
        // Ezt ne írja felül egy út közben felvillanó türkiz Deep Mines-sín,
        // különben a bot a már megtalált ellenféltől fordulna el. A normál apró
        // piros pontoknál megmarad a történeti küldetésútvonal elsőbbsége.
        let innerEnemyDirection = analysis.innerMapEnemyVisible &&
            !blockedExhaustedHighlandSuppressesRed
            ? effectiveExplorationDirection
            : nil
        let edgeObjectiveDirection = analysis.edgeObjectiveVisible &&
            !blockedExhaustedHighlandSuppressesRed
            ? effectiveExplorationDirection
            : nil
        // A körön belüli piros pont és a nagy térkép peremére kitolt piros
        // fegyverjel egyaránt kijelölt ellenfél. A `011150` nagy térképe két
        // koponyát mutatott Island 2-n, miközben a régi sorrend a játékost a
        // déli lila oltárhoz vitte vissza. A már külön kiszűrt `Enemy weapon`
        // világfelirat után a peremcél is megelőzi a türkiz/lila landmarkokat.
        let preferredNavigationDirection = analysis.worldChestDirection ?? innerEnemyDirection ??
            edgeObjectiveDirection ?? effectiveQuestRouteDirection ??
            navigableExplorationDirection ?? effectiveSpecialLandmarkDirection ?? analysis.landmarkDirection

        if !hasReachedIsland2ThisProcess,
           titanToDeepMinesRouteStage > 0,
           !nearbyQuickFarm,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A `094122-play/48` bizonyította, hogy a Deep Mines `0/1`
            // buborék nem a Titan→Island 2 makró végpontja, hanem a negyedik
            // és ötödik szakasz közti biztos köztes csomópont. A korábbi reset
            // itt eldobta a még szükséges déli kapukijáratot, majd a hajófal
            // általános keresésére váltott. A hat szakaszos út ezért a buborék
            // láthatóságától függetlenül, narancs biomig fut.
            if titanToDeepMinesRouteFrames == 0 {
                titanToDeepMinesRouteStage += 1
                switch titanToDeepMinesRouteStage {
                case 2: titanToDeepMinesRouteFrames = 14
                case 3: titanToDeepMinesRouteFrames = 10
                case 4: titanToDeepMinesRouteFrames = 18
                case 5: titanToDeepMinesRouteFrames = 13
                case 6: titanToDeepMinesRouteFrames = 12
                default:
                    titanToDeepMinesRouteStage = 0
                }
            }
            if titanToDeepMinesRouteStage > 0 {
                let direction: Vector2
                let phase: String
                switch titanToDeepMinesRouteStage {
                case 1:
                    direction = Vector2(x: 0, y: -1)
                    phase = "12 észak a Titan-kőkörtől az oltár felső oldaláig"
                case 2:
                    direction = Vector2(x: -1, y: 0)
                    phase = "14 nyugat a hajó felső kapuoszlopáig"
                case 3:
                    direction = Vector2(x: 1, y: 0)
                    phase = "10 kelet a hajótest konkáv zsebéből"
                case 4:
                    direction = Vector2(x: 0, y: -1)
                    phase = "18 észak a hajó fölötti átlós kőfalig"
                case 5:
                    direction = Vector2(x: 0, y: 1)
                    phase = "13 dél a Deep Mines déli útkereszteződéséhez"
                default:
                    // `101110`→`101525`: a kereszteződésről a tiszta nyugat
                    // a hajótest konkáv zsebébe visz. Enyhén észak felé tartva
                    // tizenkét swipe közvetlenül átlépi a narancs határkaput.
                    direction = Vector2(x: -1, y: -0.25).normalized
                    phase = "12 nyugat-északnyugat a hajó fölötti Island 2-kapun át"
                }
                titanToDeepMinesRouteFrames -= 1
                resetFallbackExploration()
                return .swipe(
                    directionX: direction.x,
                    directionY: direction.y,
                    duration: 0.55,
                    reason: "Titan→Deep Mines mért gráfél: \(phase)"
                )
            }
        }

        // Ha már jártunk Island 2-n, majd három képre visszakerültünk a zöld
        // kapuoldalra, nem kell újra megjárni a Deep Mines-t. A jelenlegi zöld
        // sziklafal mért csomópontjától 12 északi, majd 8 nyugati lépés visz át.
        if !hasReachedIsland2ThisProcess,
           island2BoundaryReentryStage > 0,!nearbyQuickFarm {
            if island2BoundaryReentryFrames == 0 {
                island2BoundaryReentryStage += 1
                if island2BoundaryReentryStage == 2 {
                    island2BoundaryReentryFrames = 8
                } else {
                    island2BoundaryReentryStage = 0
                }
            }
            if island2BoundaryReentryStage > 0 {
                let northPhase = island2BoundaryReentryStage == 1
                island2BoundaryReentryFrames -= 1
                return .swipe(
                    directionX: northPhase ? 0 : -1,
                    directionY: northPhase ? -1 : 0,
                    duration: 0.62,
                    reason: northPhase
                        ? "Island 2 határőr: 12 észak a fémkapuig"
                        : "Island 2 határőr: 8 nyugat vissza Dusty Gulchba"
                )
            }
        }

        // A hosszabb kerülők a hajó melletti magas sziklafal zárt peremére vagy
        // a kék hajótest konkávjába vitték a karaktert. A `101110`→`101525`
        // kézi mérés és a Titanról induló hatlépcsős makró két utolsó éle ugyanaz:
        // a Deep Mines 0/1 déli kapujától 13 dél a kőburkolatú kereszteződéshez,
        // majd 12 nyugat-északnyugat közvetlenül a narancs kapun át. A szakasz a
        // buborék eltűnése után is tartja az állapotát; helyi farmcél, piros pont
        // és az általános akadálymemória nem szakíthatja meg.
        if hasReachedIsland2ThisProcess {
            island2MeasuredReturnStage = 0
            island2MeasuredReturnFrames = 0
        } else if analysis.deepMinesPotionQuestVisible,
                  island2MeasuredReturnStage == 0 {
            island2MeasuredReturnStage = 1
            island2MeasuredReturnFrames = 13
            island2ReturnSearchPhase = 0
            island2ReturnSearchFrames = 0
        }
        if !hasReachedIsland2ThisProcess,
           island2MeasuredReturnStage > 0,!nearbyQuickFarm {
            if island2MeasuredReturnFrames == 0 {
                island2MeasuredReturnStage += 1
                switch island2MeasuredReturnStage {
                case 2: island2MeasuredReturnFrames = 12
                default: island2MeasuredReturnStage = 0
                }
            }
            if island2MeasuredReturnStage > 0 {
                let direction: Vector2
                let phase: String
                switch island2MeasuredReturnStage {
                case 1:
                    direction = Vector2(x: 0, y: 1)
                    phase = "13 dél a központi útkereszteződéshez"
                default:
                    direction = Vector2(x: -1, y: -0.25).normalized
                    phase = "12 nyugat-északnyugat a bizonyított Island 2-kapun át"
                }
                island2MeasuredReturnFrames -= 1
                return .swipe(
                    directionX: direction.x,
                    directionY: direction.y,
                    duration: 0.62,
                    reason: "Island 2 mért visszaút: \(phase)"
                )
            }
        }

        // A `194114-play` újra megmutatta, hogy a zárt kapu egyszeri déli
        // swipe-ja kevés. Amint a 0/1 buborék egy képre eltűnt, a havas oldali
        // piros minimappont visszafordította a karaktert, majd több mint száz
        // döntésen át ugyanazt a kapukörnyéket járta. A kapu lezárása ezért
        // külön, tartós területelhagyási szakaszt indít. Ez a szakasz a buborék
        // felismerési réseiben is elsőbbséget élvez minden távoli célhoz képest;
        // a végrehajtás utáni akadálytérkép továbbra is eltérítheti egy helyi
        // kerítés mellett, de északi célzárat nem építhet újra.
        if deepMinesGateBossCooldownFrames > 0,
           analysis.deepMinesPotionQuestVisible,
           deepMinesExitFramesRemaining == 0 {
            deepMinesExitFramesRemaining = 36
        }
        if deepMinesExitFramesRemaining > 0,!nearbyQuickFarm {
            deepMinesExitFramesRemaining -= 1
            lostTargetFrames = 0
            lastPursuitDirection = nil
            edgeObjectiveRouteAssistFrames = 0
            edgeObjectiveRouteAssistDirection = nil
            cachedQuestRouteDirection = nil
            cachedQuestRouteDirectionFrames = 0
            cachedSpecialLandmarkDirection = nil
            cachedSpecialLandmarkDirectionFrames = 0
            cachedExplorationDirection = nil
            cachedExplorationDirectionFrames = 0
            pendingExplorationFlipDirection = nil
            pendingExplorationFlipFrames = 0
            consecutiveStaticSceneDecisions = 0
            return .swipe(
                directionX: 0,
                directionY: 1,
                duration: 0.68,
                reason: "Zárt Deep Mines-kapu: 36 döntéses, buborékfüggetlen déli területelhagyás"
            )
        }

        if knownMaximumDisplayedHP >= 2_470,
           knownDiscoveredChestCount >= 2,
           exhaustedOneShotHighlandBranch,
           titanAltarExploredCooldownFrames > 0,
           titanExitFramesRemaining == 0,
           deepMinesExitFramesRemaining == 0,
           !postTitanWesternTargetRouteAttempted,
           effectiveExplorationDirection == nil,
           analysis.target == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90,
           analysis.orangeRockCoverage < 0.25 {
            // A nagy térképen a Titan-medence játékosnyila és a nyugati
            // narancs ellenfél között a sárga kapu közel azonos magasságban
            // áll. Előbb tisztán nyugatra érjük el ezt a kapupontot, utána
            // északra fordulunk az első, még élő térképcélhoz. Ez külön ág a
            // már kifosztott magaslati ládától.
            postTitanWesternTargetRouteAttempted = true
            postTitanWesternTargetRouteFrames = 36
            resetFallbackExploration()
        }
        if postTitanWesternTargetRouteFrames > 0,
           analysis.target == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90,
           analysis.worldChestDirection == nil {
            let routeDirection = postTitanWesternTargetRouteFrames > 16
                ? Vector2(x: -1.0, y: 0.0)
                : Vector2(x: 0.0, y: -1.0)
            postTitanWesternTargetRouteFrames -= 1
            return .swipe(
                directionX: routeDirection.x,
                directionY: routeDirection.y,
                duration: 0.58,
                reason: postTitanWesternTargetRouteFrames >= 16
                    ? "Nagy térképes nyugati cél: húsz lépés a sárga határkapuhoz"
                    : "Nagy térképes nyugati cél: tizenhat északi lépés az első ellenfélhez"
            )
        }

        // A maximumváltozást az Analyzer saját, tartós maximumőre jelenti. Ez
        // megkülönbözteti a normál gyógyulást a valódi max-HP növekedéstől, és
        // ugyanabba a progress-resetbe fut, mint a közvetlen jutalomeffektus.
        let hasFreshNumericHealth = analysis.playerHealthSource == "ocr-current" &&
            analysis.playerDisplayedHP != nil
        hpObservationProbeBudget.observe(freshHighHP:hasFreshNumericHealth &&
            (analysis.playerHealthFraction ?? 0)>=0.95)
        let hpTimerVisible = HPTimerOcclusionPolicy.matches(analysis.playerOCRStrings + (analysis.playerLocalizedOCRStrings ?? []))
        if hpTimerVisible, !hasFreshNumericHealth,
           analysis.hudConfidence>=0.8, analysis.popupClose==nil,
           analysis.shop?.visible != true, analysis.settingsClose==nil,
           analysis.nearbyThreatCount==0, !controlledBossTrialActive,
           !sawCriticalHealth, !retreatMode, recentDamageFrames==0,
           (analysis.playerDisplayedHP ?? 0)>=knownMaximumDisplayedHP*9/10,
           hpObservationProbeBudget.consume(now:Date().timeIntervalSinceReferenceDate) {
            return .swipe(directionX:1,directionY:0,duration:0.30,
                reason:"HP-t takaró időzítő: egyszeri rövid oldalmozdulat friss számolvasáshoz; nem gyógyulásigazolás")
        }
        if var health = analysis.playerHealthFraction {
            let nearestDistance = analysis.nearestThreat?.distance ?? .infinity
            let pixelFallback = analysis.playerHealthSource == "pixel-fallback"
            let activeTrialThreat = controlledBossTrialActive
                ? analysis.visibleTargets
                    .filter { targetMatchesControlledTrial($0, in: analysis) }
                    .min { $0.distance < $1.distance }
                : nil
            let nearbyTrialBlockingStructure = activeTrialThreat.map { trialThreat in
                analysis.visibleTargets.contains { candidate in
                    candidate.bar != trialThreat.bar &&
                        candidate.objectiveStructureConfidence >= 0.06 &&
                        candidate.distance <= 140 &&
                        candidate.distance + 24 < trialThreat.distance
                }
            } ?? false
            let passiveCactusOccludesPlayerBar = pixelFallback &&
                controlledBossTrialActive &&
                (controlledBossTrialInitialHP ?? 0) > 8_000 &&
                controlledBossTrialInitialTreeConfidence >= 0.25 &&
                (activeTrialThreat?.distance ?? controlledBossTrialLastDistance ?? .infinity) <= 135 &&
                health < 0.82
            if passiveCactusOccludesPlayerBar {
                // A 165856-os kaktuszfarm közben az egymásra rajzolt test,
                // fegyvereffektus és piros célcsík egyetlen képre 14%-os saját
                // zöld csíkot hamisított. Az előtte és utána mért friss OCR is
                // teljes 953 HP volt, miközben a passzív növény 10.9K-ról
                // sebződött. A már igazolt nagy, közeli szívkaktusz ezért nem
                // hozhat létre pusztán pixeles visszavonulást; friss numerikus
                // HP-esés, HUD-vesztés és minden más cél továbbra is hiteles.
                health = lastHealthFraction ?? 1
                pendingRemotePixelDropFraction = nil
                pendingRemotePixelDropFrames = 0
            }
            let rememberedNumericHealthIsHigh = (analysis.playerDisplayedHP ?? 0) >=
                Int(Double(knownMaximumDisplayedHP) * 0.85)
            let nearbyAggressiveThreat = analysis.visibleTargets.contains {
                $0.treeConfidence < 0.25 && $0.distance <= 170
            }
            if pixelFallback,
               rememberedNumericHealthIsHigh,
               !nearbyAggressiveThreat,
               health < 0.55 {
                // Passzív kaktusz, timerkör vagy terepi zöld részlet a saját
                // csík töredékének látszhat. Ha a tartós numerikus mérés
                // magas és nincs közeli nem-növényi támadó, ez nem harci
                // sebzés. Egy valódi őr kontaktusa vagy friss OCR-esése azonnal
                // kikapcsolja ezt a takarásvédelmet.
                health = lastHealthFraction ?? 1
                pendingRemotePixelDropFraction = nil
                pendingRemotePixelDropFrames = 0
            }
            if pixelFallback,
               nearbyTrialBlockingStructure,
               controlledBossTrialLowestHP == controlledBossTrialInitialHP,
               health < 0.55 {
                // A 200 HP-s Titan-objektum közvetlenül a karakterre és annak
                // zöld csíkjára fedhet, miközben a távoli 4.31K boss változatlan
                // és az automatikus ütés 0-t sebez. Ilyenkor az egyképes 30%/13%
                // nem saját sebzés: a következő tiszta numerikus mérésig az
                // utolsó hiteles arányt tartjuk, és az útvonalkezelő újra kerül.
                health = lastHealthFraction ?? 1
                pendingRemotePixelDropFraction = nil
                pendingRemotePixelDropFrames = 0
            }
            if pixelFallback,
               analysis.nearbyRespawnTimer,
               analysis.nearbyThreatCount == 0,
               health < 0.55 {
                // Az első olyan képen, ahol a kör már takarja a csíkot, a
                // szöveges timerjelző néha még csak a külön timerdetektorban
                // biztos. Ne állítsunk `sawCriticalHealth`-et ugyanebből a
                // 13%-os közös takarási hibából; taktikailag tartsuk az utolsó
                // hiteles értéket. Valódi közeli fenyegetés vagy friss OCR-esés
                // ezt az ágat nem használja.
                health = lastHealthFraction ?? 1
            }
            if controlledBossTrialNoDamageOverlapGraceFrames > 0 {
                controlledBossTrialNoDamageOverlapGraceFrames -= 1
                if pixelFallback, health < 0.55 {
                    // A szintkülönbséggel elvesztett 4.4K-s boss után még két
                    // egymást követő képen a korábbi célcsík töredéke fedett a
                    // teljes saját 1.3K csíkra. Mivel a próba alatt egyik fél
                    // HP-ja sem változott, ezt rövid ideig takarásnak vesszük.
                    // Friss numerikus sérülés nem pixel-fallback, ezért átjut.
                    health = lastHealthFraction ?? 1
                    pendingRemotePixelDropFraction = nil
                    pendingRemotePixelDropFrames = 0
                }
            }
            var unconfirmedRemotePixelDrop = false
            let controlledTrialOverlapNeedsConfirmation = controlledBossTrialActive &&
                controlledBossTrialLowestHP == controlledBossTrialInitialHP
            let remoteThreatFreePixelDrop = !controlledBossTrialActive &&
                nearestDistance > 170 &&
                analysis.nearbyThreatCount == 0
            let remotePixelConfirmation = pixelFallback &&
                (remoteThreatFreePixelDrop || controlledTrialOverlapNeedsConfirmation)
            if remotePixelConfirmation,
               let pending = pendingRemotePixelDropFraction,
               abs(pending - health) <= 0.08 {
                pendingRemotePixelDropFrames += 1
                if pendingRemotePixelDropFrames >= 2 {
                    recentDamageFrames = 12
                    pendingRemotePixelDropFraction = nil
                    pendingRemotePixelDropFrames = 0
                } else {
                    unconfirmedRemotePixelDrop = true
                }
            } else if let previousHealth = lastHealthFraction,
                      previousHealth - health >= (pixelFallback ? 0.10 : 0.025) {
                // A zöld csík széle animáció/takarás miatt teljes HP-n is 95%-ra
                // billent (`010847-play` 84/107. esemény), miközben a következő
                // friss OCR továbbra is 424-et adott. A pixeles tartalék csak
                // legalább 10 százalékpontos zuhanásnál hoz létre sebzésemléket;
                // az aktuális numerikus OCR érzékenyebb marad.
                // A `022045-play` 178. képén egy 34 másodperces fekete
                // respawnkör a HP-csíkra fedett: távoli cél mellett egyetlen
                // hamis 61%-os pixelmérés született, a következő OCR 467/467
                // volt. A `180420-play` 46. képén a teljes 1.3K-s saját csíkra
                // fedő, változatlan 4.4K-s célcsík ugyanígy hamis 32%-ot adott.
                // Távoli fenyegetés nélkül, illetve változatlan kontrollált cél
                // átfedésénél ezért két hasonló pixeles kép kell. Képpel észlelt
                // közeli veszély vagy numerikus HP-esés továbbra is azonnali.
                if remotePixelConfirmation {
                    pendingRemotePixelDropFraction = health
                    pendingRemotePixelDropFrames = 1
                    unconfirmedRemotePixelDrop = true
                } else {
                    recentDamageFrames = 12
                    pendingRemotePixelDropFraction = nil
                    pendingRemotePixelDropFrames = 0
                }
            } else if recentDamageFrames > 0 {
                recentDamageFrames -= 1
                if !pixelFallback || health >= (lastHealthFraction ?? health) {
                    pendingRemotePixelDropFraction = nil
                    pendingRemotePixelDropFrames = 0
                }
            } else if !pixelFallback || health >= (lastHealthFraction ?? health) {
                pendingRemotePixelDropFraction = nil
                pendingRemotePixelDropFrames = 0
            }
            if unconfirmedRemotePixelDrop {
                // Egy távoli, fenyegetés nélküli vagy változatlan boss-csíkkal
                // átfedő pixeles zuhanás első képe nem állíthat kritikus állapotot.
                // A második hasonló kép már megerősíti; felismert közeli
                // támadásnál ez a késleltetés nincs.
                health = lastHealthFraction ?? 1
            }
            lastHealthFraction = health
            if health < 0.25 {
                sawCriticalHealth = true
            } else if sawCriticalHealth, health >= 0.90, hasFreshNumericHealth {
                sawCriticalHealth = false
                retreatMode = false
                if strategicRespawnMode {
                    strategicRespawnMode = false
                    strategicRespawnDirection = nil
                    strategicRespawnFramesRemaining = 0
                    strategicRespawnSawDamage = false
                    strategicRespawnSawHUDLoss = false
                    bossEncountersWithoutProgress = 0
                    return .wait(reason: "A stratégiai újraéledés teljes HP-val lezárult; friss területről újratervezek")
                }
                return .wait(reason: "Friss numerikus HP igazolja az újraéledést vagy teljes gyógyulást; új állapot rögzítése")
            }
            let underActiveAttack = recentDamageFrames > 0
            // 20260919-123241/42: a respawnkör a teljes 5.23K csíkot
            // 21%-os pixelnek takarta; ez tévesen a korábbi 2.49K boss
            // tartós vereségsávját írta. Biztonsági visszavonulás maradhat,
            // de tartós kudarchoz friss numerikus HP vagy YOU DIED kell.
            if health < 0.35 && hasFreshNumericHealth {
                let controlledPassiveHeartTree = controlledBossTrialInitialTreeConfidence >= 0.25 &&
                    controlledBossTrialInitialHeartEvidence >= 0.04
                if let initialHP = controlledBossTrialInitialHP,
                   controlledBossTrialActive,
                   !controlledPassiveHeartTree {
                    persistBossFailure(bossHP: initialHP)
                } else if let recentBossHP = recentHostileBossTrialHP,
                          recentHostileBossTrialFrames > 0 {
                    // A célzár rövid elvesztése után a csökkenő 18.3K/17.7K/
                    // 17.2K maradék HP-k nem külön bossok. A próba kezdő sávját
                    // őrizzük, ugyanazt, amelyet a YOU DIED ág is használja.
                    persistBossFailure(bossHP: recentBossHP)
                } else if let threat = analysis.nearestThreat,
                          let bossHP = canonicalControlledTrialHP(threat),
                          bossHP >= 800,
                          !(threat.treeConfidence >= 0.25 && threat.heartIconEvidence >= 0.04) {
                    persistBossFailure(bossHP: bossHP)
                }
            }
            let controlledTrialCanAbsorbDamage = controlledBossTrialActive &&
                controlledBossTrialsEnabled &&
                analysis.nearbyThreatCount <= 2
            if health < 0.35 && !controlledTrialCanAbsorbDamage {
                // Újraindítás után nincs előző képkockából származó sebzésemlék.
                // Az élő 11.4K-s csoportnál 38%-os állapotban indított folyamat
                // enélkül célkeresésbe kezdene a regeneráció helyett.
                retreatMode = true
            } else if (nearestDistance <= 125 &&
                (health < 0.16 || (analysis.nearbyThreatCount >= 3 && health < 0.30))) ||
                (underActiveAttack && health < 0.55 && !controlledTrialCanAbsorbDamage) {
                retreatMode = true
            } else if health >= 0.85, !sawCriticalHealth {
                if retreatMode,
                   controlledBossTrialActive,
                   (!hasFreshNumericHealth || recentDamageFrames > 0) {
                    // Boss-burst után a régi 778-as OCR-memória nem bizonyítja,
                    // hogy visszagyógyultunk. A próba csak friss numerikus HP-val
                    // oldhatja fel a visszavonulást; addig tovább építjük a teret.
                    retreatMode = true
                } else {
                    retreatMode = false
                }
            }
            if retreatMode,
               pixelFallback,
               health >= 0.97,
               analysis.nearbyThreatCount == 0,
               recentDamageFrames == 0 {
                retreatFullPixelFrames += 1
                if retreatFullPixelFrames >= 8 {
                    // A magaslati 8 órás körök közelében a numerikus OCR több
                    // mint száz képen át takart maradhatott, miközben a saját
                    // csík stabilan teljes volt és fenyegetés sem látszott. A
                    // régi, kizárólag friss számot elfogadó őr emiatt végtelen
                    // dél felé vonulást okozott. Nyolc független teljes pixeles
                    // kép már elég az üldözés biztonságos lezárásához, de új
                    // maximumot továbbra sem igazolhat.
                    retreatFullPixelFrames = 0
                    retreatMode = false
                    sawCriticalHealth = false
                    controlledBossTrialActive = false
                    controlledBossTrialFrames = 0
                    controlledBossTrialLostFrames = 0
                    controlledBossTrialInitialHP = nil
                    controlledBossTrialLowestHP = nil
                    controlledBossTrialDirection = nil
                    controlledBossTrialLastDistance = nil
                    return .wait(reason: "Nyolc teljes pixeles HP-kép és nulla közeli fenyegetés lezárta a visszavonulást; újratervezek")
                }
            } else {
                retreatFullPixelFrames = 0
            }
        }

        if strategicRespawnMode,
           strategicRespawnSawHUDLoss,
           hasFreshNumericHealth,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // Nagy sebzésnél a két mentett kép között is bekövetkezhet a halál,
            // így nem biztos, hogy külön kritikus-HP képet látunk. A mód alatt
            // megfigyelt HUD-hiány, majd friss teljes HP ugyanúgy újraéledés.
            strategicRespawnMode = false
            strategicRespawnDirection = nil
            strategicRespawnFramesRemaining = 0
            strategicRespawnSawDamage = false
            strategicRespawnSawHUDLoss = false
            bossEncountersWithoutProgress = 0
            retreatMode = false
            sawCriticalHealth = false
            return .wait(reason: "HUD-átmenet után friss teljes HP igazolja a stratégiai újraéledést")
        }

        if strategicRespawnMode {
            strategicRespawnFramesRemaining -= 1
            if (analysis.playerHealthFraction ?? 1) < 0.95 {
                strategicRespawnSawDamage = true
            }
            if strategicRespawnFramesRemaining <= 0 {
                // Ha a kiválasztott ellenfél mégsem ér el bennünket, a mód nem
                // maradhat végtelen. A normál visszavonulás/farm újra átveszi a
                // döntést, és újabb öt boss-találkozás kell a következő próbához.
                strategicRespawnMode = false
                strategicRespawnDirection = nil
                strategicRespawnSawDamage = false
                strategicRespawnSawHUDLoss = false
                strategicRespawnLastBossDistance = nil
                strategicRespawnStagnantApproachFrames = 0
                strategicRespawnDetourFrames = 0
                strategicRespawnDetourDirection = nil
                bossEncountersWithoutProgress = 0
            } else {
                let visibleBoss = analysis.nearestThreat.flatMap { threat -> Target? in
                    guard threat.bossEvidence || (threat.displayedHP ?? 0) >= 800 else {
                        return nil
                    }
                    return threat
                }
                if let boss = visibleBoss {
                    let toward = Vector2(
                        x: boss.x - Double(analysis.width) * 0.5,
                        y: boss.y - Double(analysis.height) * 0.515
                    ).normalized
                    strategicRespawnDirection = toward
                    if boss.distance <= 95 || recentDamageFrames > 0 {
                        return .wait(reason: "Stratégiai újraéledés: a boss támadási közelében kivárom az automata harcot")
                    }
                    if strategicRespawnDetourFrames > 0,
                       let detour = strategicRespawnDetourDirection {
                        strategicRespawnDetourFrames -= 1
                        if strategicRespawnDetourFrames == 0 {
                            strategicRespawnDetourDirection = nil
                            strategicRespawnLastBossDistance = nil
                        }
                        return .swipe(
                            directionX: detour.x,
                            directionY: detour.y,
                            duration: 0.58,
                            reason: "Stratégiai újraéledés: stagnáló célközelítés oldalkikerülése"
                        )
                    }
                    if let previousDistance = strategicRespawnLastBossDistance,
                       boss.distance >= previousDistance - 6 {
                        strategicRespawnStagnantApproachFrames += 1
                    } else {
                        strategicRespawnStagnantApproachFrames = 0
                    }
                    strategicRespawnLastBossDistance = boss.distance
                    if strategicRespawnStagnantApproachFrames >= 6 {
                        // A hídnál a közvetlen jobb irány a közelségi láda és
                        // korlát között 165–203 px-en ingázott. A cél függőleges
                        // oldala felé erősített, öt swipe-os kerülő után újramérjük
                        // a bosst; így nem égetjük el a teljes 120-as időablakot.
                        let verticalSign = strategicRespawnDetourSign
                        strategicRespawnDetourSign *= -1
                        let detour = Vector2(
                            x: toward.x * 0.35,
                            y: verticalSign
                        ).normalized
                        strategicRespawnDetourDirection = detour
                        strategicRespawnDetourFrames = 4
                        strategicRespawnStagnantApproachFrames = 0
                        strategicRespawnLastBossDistance = nil
                        return .swipe(
                            directionX: detour.x,
                            directionY: detour.y,
                            duration: 0.58,
                            reason: "Stratégiai újraéledés: stagnáló célközelítés oldalkikerülése"
                        )
                    }
                    return .swipe(
                        directionX: toward.x,
                        directionY: toward.y,
                        duration: boss.distance <= 165 ? 1.10 : 0.72,
                        reason: "Öt eredménytelen boss-találkozás után büntetésmentes újraéledési rövidítés"
                    )
                }
                if recentDamageFrames > 0 {
                    // A 044928-as élő próbán egy 95%-os pixeles billenés örökre
                    // beállította a sawDamage memóriát, miközben a boss eltűnt és
                    // a friss OCR már teljes HP-t mutatott. A rövid sebzésemlék
                    // idejére kivárunk, utána viszont a tárolt bossirányt újra
                    // tartjuk; különben a stratégiai respawn helyben állva sosem
                    // érhet el sem támadót, sem jutalmat.
                    return .wait(reason: "Stratégiai újraéledés: friss sebzés után röviden kivárom a következő támadást")
                }
                if let toward = strategicRespawnDirection {
                    return .swipe(
                        directionX: toward.x,
                        directionY: toward.y,
                        duration: 0.48,
                        reason: "Stratégiai újraéledés: a legutóbbi bossirányt tartom"
                    )
                }
                return .wait(reason: "Stratégiai újraéledés: új bossképre várok")
            }
        }

        let closeDangerousBoss = analysis.visibleTargets.contains {
            $0.distance < 180 && $0.treeConfidence < 0.25 &&
                (canonicalControlledTrialHP($0) ?? 0) >= 5_000
        }
        if !retreatMode, !sawCriticalHealth, recentDamageFrames == 0,
           !closeDangerousBoss,
           Double(analysis.playerDisplayedHP ?? 0) >= Double(knownMaximumDisplayedHP) * 0.90,
           let route = visualRoutes.next(signature: analysis.sceneFingerprint) {
            controlledBossTrialActive = false
            controlledBossTrialDirection = nil
            controlledBossTrialLastDistance = nil
            controlledBossTrialDetourFrames = 0
            controlledBossTrialDetourDirection = nil
            if route.duration == 0 { return .wait(reason: route.reason) }
            return .swipe(directionX: route.dx, directionY: route.dy,
                          duration: route.duration, reason: route.reason)
        } else if retreatMode || sawCriticalHealth || recentDamageFrames > 0 || closeDangerousBoss {
            visualRoutes.cancel()
        }

        // A fegyversebzés 10 Bat Cleavernél bizonyítottan 500, miközben a
        // tartós maximum 778. A korábbi általános 800 HP-s bosskapu ezért már
        // túl kevés információból következtetett vereségre. A külön kapcsolóval
        // indított kutatási mód folyamatonként egyetlen próbát enged minden
        // 250-es HP-sávban, és a tényleges HP-csökkenést, túlélhetőséget méri.
        // A mód támadási távolságban oldalazva kite-ol; ha másik boss látszik,
        // annak ellenirányát is hozzákeveri, így megpróbálja izolálni a célt.
        if controlledBossTrialActive, !retreatMode {
            if WeaponRewardEvidence.endsGuardTrial(
                texts:analysis.titanQuestOCRStrings + analysis.rewardOCRStrings,
                initialHP:controlledBossTrialInitialHP,lastDistance:controlledBossTrialLastDistance,
                targetVisible:analysis.target != nil,nearbyThreatCount:analysis.nearbyThreatCount) {
                controlledBossTrialActive=false
                controlledBossTrialDirection=nil
                controlledBossTrialLastDistance=nil
                controlledBossTrialLostFrames=0
                controlledBossTrialStagnantApproachFrames=0
                controlledBossTrialDetourFrames=0
                controlledBossTrialDetourDirection=nil
                controlledBossTrialStructureDetourCount=0
                lastPursuitDirection=nil
                lostTargetFrames=0
                return .wait(reason:"Friss LEVEL UP és fegyversebzés-jutalom: a közeli kisőr harci visszakeresését lezárom")
            }
            controlledBossTrialFrames += 1
            let explicitPlayerHPAfterCactus = explicitPlayerKHP(analysis.playerOCRStrings)
            let cactusGrowthVisible = explicitPlayerHPAfterCactus.map {
                $0 >= knownMaximumDisplayedHP + 250 &&
                    $0 <= knownMaximumDisplayedHP + 380
            } ?? false
            let newCactusRespawnVisible = !controlledBossTrialInitialNearbyRespawnTimer &&
                analysis.nearbyRespawnTimer &&
                (controlledBossTrialLowestHP ?? controlledBossTrialInitialHP ?? 0) <=
                    (controlledBossTrialInitialHP ?? 0) - 500
            if !controlledBossTrialRewardApplied,
               controlledBossTrialHealthReward > 0,
               (newCactusRespawnVisible || cactusGrowthVisible),
               (controlledBossTrialLastDistance ?? .greatestFiniteMagnitude) <= 100 {
                // Az `183754/204` képen a 11.4K-s, 300-szíves kaktusz helyén
                // közvetlenül a karakter alatt megjelent az új 5m56s-os
                // respawn-kör. Ez a csík eltűnésénél erősebb ölésbizonyíték.
                // A játékos felirata közben `1.6K` helyett rendszeresen
                // `IGK/MIGK` lett, ezért a már ismert 300-as szívjutalmat a
                // biztos ölési átmenetből vezetjük rá a maximumra.
                let rewardDerivedMaximum = knownMaximumDisplayedHP +
                    controlledBossTrialHealthReward
                // A 4.41K feliratot Vision egyetlen képen `451K`-nak, majd
                // több képen `4.11K`-nak olvasta. A közvetlen OCR csak akkor
                // finomíthatja a bizonyított régi maximum + látható szívjutalom
                // összeget, ha legfeljebb egy kis kerekítési lépésnyire van;
                // különben a determinisztikus jutalomösszeg az erősebb adat.
                if let explicitPlayerHPAfterCactus,
                   abs(explicitPlayerHPAfterCactus - rewardDerivedMaximum) <= 80 {
                    knownMaximumDisplayedHP = max(
                        rewardDerivedMaximum,
                        explicitPlayerHPAfterCactus
                    )
                } else {
                    knownMaximumDisplayedHP = rewardDerivedMaximum
                }
                controlledBossTrialRewardApplied = true
                controlledBossTrialActive = false
                controlledBossTrialDirection = nil
                controlledBossTrialLastDistance = nil
                controlledBossTrialStagnantApproachFrames = 0
                controlledBossTrialDetourFrames = 0
                controlledBossTrialDetourDirection = nil
                controlledBossTrialStructureDetourCount = 0
                return .wait(
                    reason: "Nagy szívkaktusz legyőzve: új közeli respawn-kör, +\(controlledBossTrialHealthReward) bizonyított maximum"
                )
            }
            let controlledTrialFrameLimit = (controlledBossTrialInitialHP ?? 0) > 8_000 &&
                controlledBossTrialInitialTreeConfidence >= 0.25 ? 180 : 90
            if controlledBossTrialFrames > controlledTrialFrameLimit {
                controlledBossTrialActive = false
                controlledBossTrialDirection = nil
                controlledBossTrialLastDistance = nil
                controlledBossTrialStagnantApproachFrames = 0
                controlledBossTrialDetourFrames = 0
                controlledBossTrialDetourDirection = nil
                controlledBossTrialElevatedRampFrames = 0
                controlledBossTrialElevatedRampDirection = nil
                controlledBossTrialElevatedRoutePhase = 0
            } else if titanTreeGateRouteFrames > 0 {
                // A `224547-play/31–35` képein a 4,31K-s szívfa a 200 HP-s
                // Titan-objektum fölött-balra, a játékos pedig már a középső
                // sziklatömb jobb oldalán állt. Innen az újabb vízszintes
                // tangens visszavitte a kapu elé; a járható völgy előbb tisztán
                // északra, majd a szikla felső vége mögött nyugatra fordul.
                let direction = titanTreeGateRouteFrames > 8
                    ? Vector2(x: 0, y: -1)
                    : Vector2(x: -1, y: 0)
                titanTreeGateRouteFrames -= 1
                if titanTreeGateRouteFrames == 0 {
                    controlledBossTrialLastDistance = nil
                    controlledBossTrialStagnantApproachFrames = 0
                    controlledBossTrialDetourCycles = 0
                }
                return .swipe(
                    directionX: direction.x,
                    directionY: direction.y,
                    duration: 0.62,
                    reason: titanTreeGateRouteFrames >= 8
                        ? "Titan-fa kapupont: északi völgyjárás a középső szikla jobb oldalán"
                        : "Titan-fa kapupont: nyugati ráfordulás a 4,31K-s fa felső oldalára"
                )
            } else if docFortressEntryRouteFrames > 0 {
                // A `002018-play/51–94` teljesen kizárta a régi nyugati
                // DOC-ágat: dél-nyugat, nyugat, észak sorrendben a sziget
                // vízparti függőleges rönkkerítéséhez jutottunk, és tizenhat
                // északi swipe sem adott rétegváltást. A nagy térképen a
                // narancs koponya és a türkiz helyjel e ponttól északra van;
                // ezért az új első próba a külső sziklafal keleti végét kerüli,
                // északon lép fel, majd nyugatra fordul vissza az őrre.
                let direction: Vector2
                let phase: String
                if docFortressEntryRouteMode == 2 {
                    if docFortressEntryRouteFrames > 33 {
                        direction = Vector2(x: 0, y: 1)
                        phase = "déli kijutás a szekér és a zárt sziklakapu alól"
                    } else if docFortressEntryRouteFrames > 15 {
                        direction = Vector2(x: 1, y: 0)
                        phase = "keleti kerülés a jobb oldali sziklafal alsó vége körül"
                    } else {
                        direction = Vector2(x: 0, y: -1)
                        phase = "északi visszafordulás a DOC-őr nyitott oldalára"
                    }
                } else if docFortressEntryRouteFrames > 30 {
                    direction = Vector2(x: 1, y: 0)
                    phase = "keleti falvégkeresés a vízparti zsákutca helyett"
                } else if docFortressEntryRouteFrames > 14 {
                    direction = Vector2(x: 0, y: -1)
                    phase = "északi rétegváltás a DOC-udvar keleti oldalán"
                } else {
                    direction = Vector2(x: -1, y: 0)
                    phase = "nyugati ráfordulás a 4,4K-s őr belső oldalára"
                }
                docFortressEntryRouteFrames -= 1
                if docFortressEntryRouteFrames == 0 {
                    docFortressEntryRouteMode = 0
                    controlledBossTrialLastDistance = nil
                    controlledBossTrialStagnantApproachFrames = 0
                    controlledBossTrialDetourCycles = 0
                }
                return .swipe(
                    directionX: direction.x,
                    directionY: direction.y,
                    duration: 0.62,
                    reason: "DOC kapupont: \(phase)"
                )
            } else if controlledBossTrialElevatedRampFrames > 0,
                      let rampDirection = controlledBossTrialElevatedRampDirection {
                let routePhase = controlledBossTrialElevatedRoutePhase
                controlledBossTrialElevatedRampFrames -= 1
                if controlledBossTrialElevatedRampFrames == 0 {
                    switch routePhase {
                    case 7:
                        controlledBossTrialElevatedRoutePhase = 8
                        controlledBossTrialElevatedRampDirection = Vector2(x: -1, y: 0)
                        controlledBossTrialElevatedRampFrames = 10
                    case 8:
                        controlledBossTrialElevatedRoutePhase = 9
                        controlledBossTrialElevatedRampDirection = Vector2(x: 0, y: -1)
                        controlledBossTrialElevatedRampFrames = 16
                    case 9:
                        controlledBossTrialElevatedRoutePhase = 0
                        controlledBossTrialElevatedRampDirection = nil
                        controlledBossTrialElevatedRampFrames = 0
                    case 1:
                        // A `215824/12–25` délnyugati lába kijutott a nagy
                        // szikla tövéből a szabad, vezetékes útra. A kibontott
                        // térképen a türkiz rétegváltó innen balra-délnyugatra,
                        // az élő képen a fa lépcső bal-fent látszik. A régi
                        // keleti kitérés innen bizonyítottan rossz oldal.
                        controlledBossTrialElevatedRoutePhase = 2
                        controlledBossTrialElevatedRampDirection = Vector2(x: -1, y: 0)
                        controlledBossTrialElevatedRampFrames = 18
                    case 2:
                        // A nyugati láb a fal alsó végét és a lépcsőtalpat
                        // keresi; csak ezután próbáljuk a tiszta északi
                        // rétegváltást, nem a sziklán át mutató átlót.
                        controlledBossTrialElevatedRoutePhase = 3
                        controlledBossTrialElevatedRampDirection = Vector2(x: 0, y: -1)
                        controlledBossTrialElevatedRampFrames = 22
                    case 3:
                        // A lépcsőpróba után friss képből döntünk; vak negyedik
                        // láb nem viheti vissza a karaktert ugyanabba a körbe.
                        controlledBossTrialElevatedRoutePhase = 0
                        controlledBossTrialElevatedRampDirection = nil
                        controlledBossTrialElevatedRampFrames = 0
                    default:
                        if let routeHP = controlledBossTrialInitialHP {
                            elevationSeparatedBossBand = (routeHP / 250) * 250
                            elevationSeparatedBossCooldownFrames = max(
                                elevationSeparatedBossCooldownFrames,
                                2_572
                            )
                            persistNavigationCooldown(elevatedBossRouteHP: routeHP)
                        }
                        controlledBossTrialActive = false
                        controlledBossTrialDirection = nil
                        controlledBossTrialLastDistance = nil
                        controlledBossTrialStagnantApproachFrames = 0
                        controlledBossTrialDetourFrames = 0
                        controlledBossTrialDetourDirection = nil
                        controlledBossTrialStructureDetourCount = 0
                        controlledBossTrialElevatedRoutePhase = 0
                        controlledBossTrialElevatedRampDirection = nil
                    }
                }
                return .swipe(
                    directionX: rampDirection.x,
                    directionY: rampDirection.y,
                    duration: 0.62,
                    reason: routePhase == 1
                        ? "18,8K-s magaslati őr: alsó kőívig tartó első rétegváltó szakasz"
                        : routePhase == 7
                        ? "18,8K-s őr: déli kijutás a szekér–házzsebből"
                        : routePhase == 8
                        ? "18,8K-s őr: rövid nyugati falvégkeresés a türkiz kapuhoz"
                        : routePhase == 9
                        ? "18,8K-s őr: északi feljárópróba a rövidített fordulóponttól"
                        : routePhase == 2
                        ? "18,8K-s magaslati őr: nyugati kapukeresés a türkiz rétegváltó felé"
                        : routePhase == 3
                        ? "18,8K-s magaslati őr: északi lépcsőpróba a fal alsó végétől"
                        : routePhase == 4
                        ? "18,8K-s magaslati őr: nyugati ráfordulás a kaktusz fölött"
                        : routePhase == 5
                        ? "18,8K-s magaslati őr: északi haladás a sziklafal külső oldalán"
                        : routePhase == 6
                        ? "Kimerített egyszeri magaslati ág: délkeleti kijutás a zöld csontmezőre"
                        : "18,8K-s magaslati őr: bizonyított topológiai kerülő"
                )
            } else if let threat = analysis.visibleTargets
                .filter({ targetMatchesControlledTrial($0, in: analysis) })
                .min(by: { $0.distance < $1.distance }) {
                controlledBossTrialLostFrames = 0
                let toward = Vector2(
                    x: threat.x - Double(analysis.width) * 0.5,
                    y: threat.y - Double(analysis.height) * 0.515
                ).normalized
                controlledBossTrialDirection = toward
                if let hp = canonicalControlledTrialHP(threat) ?? threat.displayedHP {
                    // A 013227-es próbán a stabil `4.4K` felirat egy képen
                    // `4:4`/`4` alakra csonkolódott. A célazonosítás ezt már
                    // helyesen ugyanannak az őrnek tekintette, de a nyers 4-et
                    // mégis minimumként tárolta (`4400→4 HP`). A minimumhoz is
                    // ugyanazt a kanonikus értéket használjuk, így csak valódi,
                    // erős aláírással elfogadott HP-csökkenés számít haladásnak.
                    controlledBossTrialLowestHP = min(controlledBossTrialLowestHP ?? hp, hp)
                }
                if threat.distance <= 112 {
                    controlledBossTrialReachedCloseRange = true
                }
                if threat.distance <= 112 && controlledBossTrialLowestHP == controlledBossTrialInitialHP {
                    controlledBossTrialCloseNoDamageFrames += 1
                } else { controlledBossTrialCloseNoDamageFrames = 0 }

                let otherBosses = analysis.visibleTargets.filter { candidate in
                    let sameBar = candidate.bar == threat.bar
                    return !sameBar &&
                        !targetMatchesControlledTrial(candidate, in: analysis) &&
                        (candidate.bossEvidence || (candidate.displayedHP ?? 0) >= 800) &&
                        candidate.distance <= 430
                }
                let separation = otherBosses.reduce(Vector2(x: 0, y: 0)) { partial, other in
                    let away = Vector2(
                        x: Double(analysis.width) * 0.5 - other.x,
                        y: Double(analysis.height) * 0.515 - other.y
                    ).normalized
                    return Vector2(x: partial.x + away.x, y: partial.y + away.y)
                }.normalized
                let blockingStructure = analysis.visibleTargets.first { candidate in
                    guard candidate.bar != threat.bar,
                          candidate.objectiveStructureConfidence >= 0.06,
                          candidate.distance + 24 < threat.distance else { return false }
                    let toStructure = Vector2(
                        x: candidate.x - Double(analysis.width) * 0.5,
                        y: candidate.y - Double(analysis.height) * 0.515
                    ).normalized
                    return toward.x * toStructure.x + toward.y * toStructure.y >= 0.58
                }
                let lowest = controlledBossTrialLowestHP ?? controlledBossTrialInitialHP ?? 0
                let progress = controlledBossTrialInitialHP.map { "\($0)→\(lowest) HP" } ?? "HP mérés alatt"

                if controlledBossTrialDetourCycles >= 2,
                   analysis.deepMinesPotionQuestVisible,
                   threat.distance >= 300,
                   recentDamageFrames == 0 {
                    // Két teljes, ellentétes oldalkerülő után a cél távolodni
                    // kezdhet vagy kicsúszhat, miközben a karakter ismét a
                    // `anti-stone potion 0/1` buborékos alsó táborban áll. Ez a
                    // kapu alsó oldalára való visszaérés erősebb bizonyíték, mint
                    // egy harmadik stagnáló ciklus kivárása.
                    let escape = Vector2(x: -toward.x, y: -toward.y).normalized
                    controlledBossTrialActive = false
                    controlledBossTrialDirection = nil
                    controlledBossTrialLastDistance = nil
                    controlledBossTrialStagnantApproachFrames = 0
                    controlledBossTrialDetourFrames = 0
                    controlledBossTrialDetourDirection = nil
                    controlledBossTrialStructureDetourCount = 0
                    deepMinesGateBossCooldownFrames = 600
                    deepMinesExitFramesRemaining = 36
                    persistNavigationCooldown(deepMinesGate: true)
                    bossEscapeDirection = escape
                    bossEscapeFrames = 5
                    return .swipe(
                        directionX: escape.x,
                        directionY: escape.y,
                        duration: 0.68,
                        reason: "Kétoldali próba után visszaértem a Deep Mines 0/1 táborába; a kapu zárt"
                    )
                }

                if threat.distance > 112 {
                    if blockingStructure != nil,
                       controlledBossTrialStructureDetourCount < 3,
                       controlledBossTrialDetourFrames == 0 {
                        // A 4.31K-s fa és a játékos között álló 200 HP-s Titan-
                        // objektum a közvetlen közelítést elnyelte, miközben a
                        // karakter és a HP-felirat takarásba került. A rögzített
                        // egyszeri kerülő élőben visszavezette ugyanabba a vonalba,
                        // ezért legfeljebb három, váltott oldalú kerülővel nyitunk
                        // valóban tiszta látóvonalat.
                        let tangent = Vector2(
                            x: -toward.y * controlledBossTrialDetourSign,
                            y: toward.x * controlledBossTrialDetourSign
                        )
                        let detour = Vector2(
                            x: tangent.x + toward.x * 0.15,
                            y: tangent.y + toward.y * 0.15
                        ).normalized
                        controlledBossTrialStructureDetourCount += 1
                        controlledBossTrialDetourSign *= -1
                        controlledBossTrialDetourFrames = 8
                        controlledBossTrialDetourDirection = detour
                        return .swipe(
                            directionX: detour.x,
                            directionY: detour.y,
                            duration: 0.66,
                            reason: "Kontrollált bosspróba: köztes Titan-objektum kerülése (\(controlledBossTrialStructureDetourCount)/3, váltott oldal)"
                        )
                    }
                    if let bestDistance = controlledBossTrialLastDistance {
                        // Egy egész 1.16K-s csoportnál a `nearestThreat` tagja
                        // képről képre változott, ezért a pillanatnyi távolság
                        // 307–361 px között ugrált, noha a karakter végig ugyanazt
                        // a havas fennsík alatti sziklafalat nyomta. Ne az előző
                        // képhez, hanem a próba legjobb távolságához mérjünk;
                        // csak legalább 8 px új rekord bizonyít valódi közeledést.
                        if threat.distance < bestDistance - 8 {
                            controlledBossTrialLastDistance = threat.distance
                            controlledBossTrialStagnantApproachFrames = 0
                        } else {
                            controlledBossTrialStagnantApproachFrames += 1
                        }
                    } else {
                        controlledBossTrialLastDistance = threat.distance
                        controlledBossTrialStagnantApproachFrames = 0
                    }

                    if controlledBossTrialDetourFrames > 0,
                       let detour = controlledBossTrialDetourDirection {
                        controlledBossTrialDetourFrames -= 1
                        if controlledBossTrialDetourFrames == 0 {
                            controlledBossTrialDetourDirection = nil
                        }
                        return .swipe(
                            directionX: detour.x,
                            directionY: detour.y,
                            duration: 0.62,
                            reason: "Kontrollált bosspróba: stagnáló megközelítés oldalkerülője; a \(controlledBossTrialInitialHP ?? 0) HP-s célt tartom"
                        )
                    }

                    if controlledBossTrialStagnantApproachFrames >= 5 {
                        let reachedWagonGate = (controlledBossTrialLastDistance ?? .infinity) <= 190
                        if !titanTreeGateRouteAttempted,
                           (4_250...4_550).contains(controlledBossTrialInitialHP ?? 0),
                           controlledBossTrialLowestHP == controlledBossTrialInitialHP,
                           (controlledBossTrialLastDistance ?? .infinity) <= 340,
                           recentDamageFrames == 0,
                           analysis.orangeRockCoverage < 0.20 {
                            titanTreeGateRouteAttempted = true
                            titanTreeGateRouteFrames = 20
                            controlledBossTrialStagnantApproachFrames = 0
                            controlledBossTrialDetourFrames = 0
                            controlledBossTrialDetourDirection = nil
                            return .swipe(
                                directionX: 0,
                                directionY: -1,
                                duration: 0.62,
                                reason: "Titan-fa kapupont: a jobb oldali völgy északi bejárásának próbája"
                            )
                        }
                        if !docFortressEntryRouteAttempted,
                           (4_250...4_550).contains(controlledBossTrialInitialHP ?? 0),
                           controlledBossTrialLowestHP == controlledBossTrialInitialHP,
                           (threat.distance >= 350 || reachedWagonGate),
                           recentDamageFrames == 0,
                           analysis.orangeRockBiomeVisible {
                            docFortressEntryRouteAttempted = true
                            controlledBossTrialStagnantApproachFrames = 0
                            controlledBossTrialDetourFrames = 0
                            controlledBossTrialDetourDirection = nil
                            if reachedWagonGate {
                                // A `013227/74–105` élő ellenőrzés kizárta a
                                // szekértől balra, majd északra vezető U-alakot:
                                // egy nagy épület alá futott, a keleti láb pedig
                                // pontosan ugyanahhoz a zárt szekér–sziklakapuhoz
                                // hozta vissza a karaktert. A jobb oldali vörös
                                // sziklatömb alja viszont a képen nyitott; ezért
                                // délre kijutunk alóla, keleten megkerüljük, majd
                                // északról próbáljuk az őr nyitott oldalát.
                                docFortressEntryRouteMode = 2
                                docFortressEntryRouteFrames = 46
                                return .swipe(
                                    directionX: 0,
                                    directionY: 1,
                                    duration: 0.62,
                                    reason: "DOC kapupont: déli indulás a jobb oldali sziklafal megkerüléséhez"
                                )
                            }
                            // Az első keleti lépést most adjuk ki; a fennmaradó
                            // 47 lépést a cél eltűnése sem szakítja. A korábbi
                            // nyugati vízparti zsákágat nem próbáljuk újra.
                            docFortressEntryRouteMode = 1
                            docFortressEntryRouteFrames = 47
                            return .swipe(
                                directionX: 1,
                                directionY: 0,
                                duration: 0.62,
                                reason: "DOC kapupont: a keleti falvég felé indulás"
                            )
                        }
                        controlledBossTrialDetourCycles += 1
                        // 20260919-124302/58–69: a puszta HP-sáv + narancs biom
                        // nem azonosít rámpabejáratot. A régi 12 keleti swipe
                        // sziklafalnak vitt, majd hamis 30 perces útvonalhűtést
                        // írt. Helyette az alábbi rövid, váltott oldali kerülő
                        // fut; új hosszú út csak képi csomópontigazolással jöhet.
                        if controlledBossTrialDetourCycles >= 3,
                           analysis.questRouteDirection != nil,
                           threat.distance >= 220 {
                            // A Deep Mines havas bosscsoportját lila kőhíd/kapu
                            // választja el. Egy közvetlen és két ellentétes oldali
                            // teljes kerülő sem vitt 220 px alá, miközben sebzés
                            // nem történt: ez elérhetetlenség, nem harci kudarc.
                            let escape = Vector2(x: -toward.x, y: -toward.y).normalized
                            controlledBossTrialActive = false
                            controlledBossTrialDirection = nil
                            controlledBossTrialLastDistance = nil
                            controlledBossTrialStagnantApproachFrames = 0
                            controlledBossTrialDetourFrames = 0
                            controlledBossTrialDetourDirection = nil
                            controlledBossTrialStructureDetourCount = 0
                            deepMinesGateBossCooldownFrames = 600
                            deepMinesExitFramesRemaining = 36
                            persistNavigationCooldown(deepMinesGate: true)
                            bossEscapeDirection = escape
                            bossEscapeFrames = 5
                            return .swipe(
                                directionX: escape.x,
                                directionY: escape.y,
                                duration: 0.68,
                                reason: "Kétoldali próba után zárt Deep Mines-kapu; a bosscsoport jelenleg elérhetetlen"
                            )
                        }
                        if controlledBossTrialDetourCycles >= 3,
                           threat.distance >= 220,
                           recentDamageFrames == 0 {
                            // A Dusty Gulch fölötti havas fennsíkon sok 1.16K-s
                            // cél egymásra fed. Saját harci kontaktus nélkül is
                            // látszanak rajtuk 30/120 sebzések, ezért a távoli
                            // HP-csökkenés nem útvonalbizonyíték. Három, a próba
                            // legjobb távolságát sem javító oldalláb után a direkt
                            // üldözést hűtjük, és a szikla mentén keresünk bejáratot.
                            blockedRouteBypassSign *= -1
                            let perpendicular = Vector2(
                                x: -toward.y * blockedRouteBypassSign,
                                y: toward.x * blockedRouteBypassSign
                            )
                            let bypass = Vector2(
                                x: perpendicular.x - toward.x * 0.35,
                                y: perpendicular.y - toward.y * 0.35
                            ).normalized
                            if let initialHP = controlledBossTrialInitialHP,
                               controlledBossTrialLowestHP == initialHP {
                                let initialBand = (initialHP / 250) * 250
                                if edgeObjectiveTrialBand == initialBand {
                                    // A kijelölt 4.4K-s erődellenfélig még nem
                                    // jutott el a támadás: a három kerülő csak
                                    // útvonalpróba volt. A sáv újrapróbálható,
                                    // amikor a falmenti bejáratkeresés után újra
                                    // látható lesz; ez nem ismételt harci kockázat.
                                    attemptedBossTrialBands.remove(initialBand)
                                }
                            }
                            controlledBossTrialActive = false
                            controlledBossTrialDirection = nil
                            controlledBossTrialLastDistance = nil
                            controlledBossTrialStagnantApproachFrames = 0
                            controlledBossTrialDetourFrames = 0
                            controlledBossTrialDetourDirection = nil
                            controlledBossTrialStructureDetourCount = 0
                            blockedRouteDirection = toward
                            blockedRouteCooldownFrames = 160
                            blockedRouteBypassPhaseSteps = 1
                            blockedRouteBypassSawMovement = false
                            return .swipe(
                                directionX: bypass.x,
                                directionY: bypass.y,
                                duration: 0.58,
                                reason: "Három távoli, eredménytelen bosskerülő után falmenti bejáratkeresés indul"
                            )
                        }
                        let tangent = Vector2(
                            x: -toward.y * controlledBossTrialDetourSign,
                            y: toward.x * controlledBossTrialDetourSign
                        )
                        let detour = Vector2(
                            x: tangent.x + toward.x * 0.18 + separation.x * 0.35,
                            y: tangent.y + toward.y * 0.18 + separation.y * 0.35
                        ).normalized
                        controlledBossTrialDetourSign *= -1
                        controlledBossTrialStagnantApproachFrames = 0
                        controlledBossTrialDetourFrames = 6
                        controlledBossTrialDetourDirection = detour
                        return .swipe(
                            directionX: detour.x,
                            directionY: detour.y,
                            duration: 0.62,
                            reason: "Kontrollált bosspróba: öt stagnáló közelítés után hétlépéses oldalkerülő indul"
                        )
                    }

                    let isolatedApproach = Vector2(
                        x: toward.x + separation.x * (otherBosses.isEmpty ? 0 : 0.72),
                        y: toward.y + separation.y * (otherBosses.isEmpty ? 0 : 0.72)
                    ).normalized
                    return .swipe(
                        directionX: isolatedApproach.x,
                        directionY: isolatedApproach.y,
                        duration: threat.distance > 220 ? 0.58 : 0.40,
                        reason: "Kontrollált bosspróba: cél izolálása és támadási távolság keresése (\(progress))"
                    )
                }

                controlledBossTrialLastDistance = threat.distance
                controlledBossTrialStagnantApproachFrames = 0
                controlledBossTrialDetourFrames = 0
                controlledBossTrialDetourDirection = nil
                controlledBossTrialDetourCycles = 0
                controlledBossTrialStructureDetourCount = 0
                if (controlledBossTrialInitialHP ?? 0) > 8_000,
                   threat.treeConfidence >= 0.25,
                   threat.distance <= 100 {
                    let currentHP = canonicalControlledTrialHP(threat) ?? threat.displayedHP
                    if let currentHP, let previousHP = passiveContactLastHP,
                       currentHP >= previousHP - 30 {
                        passiveContactStagnantFrames += 1
                    } else {
                        passiveContactStagnantFrames = 0
                    }
                    passiveContactLastHP = currentHP
                    if passiveContactStagnantFrames >= 6 {
                        passiveContactStagnantFrames = 0
                        return .swipe(directionX: toward.x, directionY: toward.y, duration: 0.16,
                            reason: "A közeli szívkaktusz HP-ja hat tiszta képen nem csökken; rövid kontaktusfinomítás")
                    }
                    // A Dusty Gulch 300-szíves kaktusza nem sebzett, miközben
                    // két automata fegyvercsapás 11.4K-ról 10.4K-ra vitte. A
                    // korábbi hosszú oldalkite két kép alatt 287 px-re sodródott,
                    // mire a kaktusz teljesen visszagyógyult. A statikus növényt
                    // támadótávolságban állva kell folyamatosan ütni; a fenti
                    // általános sérülésfigyelő bármely valódi visszasebzésnél
                    // továbbra is azonnal megszakítja ezt.
                    return .wait(
                        reason: "A nagy szívkaktusz támadótávolságban van; helyben tartom a folyamatos automata sebzést, hogy ne regenerálódjon"
                    )
                }
                let initialTrialHP = controlledBossTrialInitialHP ?? 0
                let knownElevatedDOCGuard = analysis.orangeRockBiomeVisible &&
                    initialTrialHP >= 4_000 && initialTrialHP <= 5_000 &&
                    controlledBossTrialFrames >= 14 &&
                    controlledBossTrialReachedCloseRange
                let genericCloseNoContact = controlledBossTrialFrames >= 32 &&
                    threat.distance <= 84
                if (genericCloseNoContact || knownElevatedDOCGuard),
                   controlledBossTrialCloseNoDamageFrames >= 8,
                   controlledBossTrialLowestHP == controlledBossTrialInitialHP,
                   recentDamageFrames == 0 {
                    // A `181257-play` képein a játékos és a 4.4K-s őr vetülete
                    // 50–80 px-re összeért, de sok álló támadási ablak alatt
                    // egyik fél HP-ja sem mozdult. A teljes kép megmutatta, hogy
                    // a játékos a külső sziklapárkányon, az őr a belső DOC-udvar
                    // másik magassági szintjén áll. Ez útvonal-elérhetetlenség,
                    // nem harci vereség: kifelé-oldalra indulunk bejáratot keresni.
                    let tangent = Vector2(
                        x: -toward.y * controlledBossTrialDetourSign,
                        y: toward.x * controlledBossTrialDetourSign
                    )
                    let escape = Vector2(
                        x: -toward.x + tangent.x * 0.55,
                        y: -toward.y + tangent.y * 0.55
                    ).normalized
                    controlledBossTrialActive = false
                    controlledBossTrialDirection = nil
                    controlledBossTrialLastDistance = nil
                    controlledBossTrialStagnantApproachFrames = 0
                    controlledBossTrialDetourFrames = 0
                    controlledBossTrialDetourDirection = nil
                    controlledBossTrialStructureDetourCount = 0
                    blockedRouteDirection = toward
                    blockedRouteCooldownFrames = 180
                    controlledBossTrialNoDamageOverlapGraceFrames = 8
                    elevationSeparatedBossBand = ((controlledBossTrialInitialHP ?? 0) / 250) * 250
                    elevationSeparatedWallFollowFrames = 72
                    elevationSeparatedBossCooldownFrames = 900
                    elevationSeparatedWallSign = controlledBossTrialDetourSign
                    bossEscapeDirection = escape
                    bossEscapeFrames = 8
                    return .swipe(
                        directionX: escape.x,
                        directionY: escape.y,
                        duration: 0.68,
                        reason: "Magaslati szintkülönbség: közeli, mégsem sebezhető boss helyett külső bejáratkeresés"
                    )
                }
                let closeTrialHealth = analysis.playerHealthFraction ?? 1
                let largeNonTreeBossIsTakingDamage = initialTrialHP >= 4_000 &&
                    threat.treeConfidence < 0.25 &&
                    (controlledBossTrialLowestHP ?? initialTrialHP) < initialTrialHP &&
                    threat.distance <= 100 &&
                    closeTrialHealth >= 0.45
                if largeNonTreeBossIsTakingDamage {
                    // A `033155-play` pink koponyás lovagját az automata
                    // fegyverek állva 27.7K→24.0K-ra vitték, döntően teljes
                    // saját HP mellett. Az időszakos oldalkite északra sodorta
                    // a karaktert és megszakította a nyerhető kontaktust. Amíg
                    // ténylegesen fogy a boss és legalább 45% HP-nk van, nem
                    // mozdulunk ki az arénából; az általános kritikus őr alatta
                    // továbbra is kiszakít vagy hagy biztonságosan újraéledni.
                    return .wait(
                        reason: "Koponyaboss sebződik; a nyerhető automata kombót helyben tartom (\(progress), \(Int(closeTrialHealth * 100))% saját HP)"
                    )
                }
                if threat.distance <= 84,
                   closeTrialHealth >= 0.82,
                   controlledBossTrialFrames % 4 != 0 {
                    // A 4.4K-s pajzsos őr körüli folyamatos 0.42 s-os swipe-ok
                    // kilencven képen át életben tartották ugyan a játékost, de
                    // egyetlen automata támadás sem ért célba. A kaktusznál már
                    // bizonyított, hogy a fegyverek helyben állva megbízhatóbban
                    // támadnak. Közelharcban három rövid álló támadási képet egy
                    // orbitáló kite követ: így van sebzési ablak, de nem ragadunk
                    // tartósan a pajzs előtt. Numerikus sérülés és kétképes
                    // pixeles sérülés továbbra is a fenti menekülési őrhöz fut.
                    return .wait(
                        reason: "Kontrollált bosspróba: közeli álló támadási ablak az automata fegyvereknek (\(progress), \(Int(closeTrialHealth * 100))% saját HP)"
                    )
                }
                let tangent = Vector2(
                    x: -toward.y * controlledBossTrialOrbitSign,
                    y: toward.x * controlledBossTrialOrbitSign
                )
                let health = analysis.playerHealthFraction ?? 1
                let radialWeight = threat.distance < 68 ? -0.48 : (threat.distance > 94 ? 0.28 : 0.0)
                let lowHealthEscapeWeight = health < 0.65 ? -0.55 : 0.0
                let orbit = Vector2(
                    x: tangent.x + toward.x * (radialWeight + lowHealthEscapeWeight) + separation.x * 0.45,
                    y: tangent.y + toward.y * (radialWeight + lowHealthEscapeWeight) + separation.y * 0.45
                ).normalized
                if controlledBossTrialFrames % 12 == 0 {
                    controlledBossTrialOrbitSign *= -1
                }
                return .swipe(
                    directionX: orbit.x,
                    directionY: orbit.y,
                    duration: 0.42,
                    reason: "Kontrollált bosspróba: folyamatos oldalkite és automata támadás (\(progress), \(Int(health * 100))% saját HP)"
                )
            } else {
                controlledBossTrialCloseNoDamageFrames = 0
                if (controlledBossTrialInitialHP ?? 0) > 8_000,
                   controlledBossTrialInitialTreeConfidence >= 0.25,
                   (controlledBossTrialLastDistance ?? .greatestFiniteMagnitude) <= 100,
                   controlledBossTrialLostFrames < 120,
                   analysis.playerDisplayedHP != nil,
                   (analysis.playerHealthFraction ?? 0) >= 0.82 {
                    // Folyamatos ütés közben az animáció egy-egy képen teljesen
                    // letakarja a kaktusz piros csíkját, miközben a külön OCR még
                    // 10.1K/9.68K értéket lát. Az irányos „visszakeresés” ilyenkor
                    // megszakítja az automata sorozatot és regenerálni hagyja a
                    // statikus célt. A 11.4K-s kaktusz csíkját a saját ütéseink
                    // legalább 48 elemzési képen át eltakarták, miközben a
                    // mentett képeken 9.68K→1.57K valódi sebzés látszott. A 48.
                    // képen történő elmozdulás megszakította a majdnem kész
                    // farmot és 10.1K-ra regenerálta a növényt. Ezért a biztos
                    // közeli pozíciót akár 120 képig tartjuk; a jutalom-,
                    // sérülés- és halálőrök továbbra is előbb futnak.
                    controlledBossTrialLostFrames += 1
                    // A háttér szándékosan statikus, mert helyben állva támadunk.
                    // Ezt nem szabad navigációs elakadásként tovább gyűjteni.
                    consecutiveStaticSceneDecisions = 0
                    return .wait(
                        reason: "A közeli nagy szívkaktusz csíkját az ütés takarja; helyben tartom a megszakítás nélküli támadást"
                    )
                }
                let trialInitialHP = controlledBossTrialInitialHP ?? 0
                let trialLowestHP = controlledBossTrialLowestHP ?? trialInitialHP
                if trialInitialHP > 5_000,
                   controlledBossTrialInitialTreeConfidence < 0.25,
                   trialLowestHP < trialInitialHP,
                   controlledBossTrialLostFrames >= 3,
                   let toward = controlledBossTrialDirection {
                    // A 27.7K-s lovag 40 takart képen át folyamatosan ütött.
                    // Régi saját HP nem igazol hosszú helyben álló harcot.
                    let away = Vector2(x: -toward.x, y: -toward.y).normalized
                    controlledBossTrialActive = false
                    controlledBossTrialDirection = nil
                    retreatMode = true
                    bossEscapeDirection = away
                    bossEscapeFrames = 5
                    return .swipe(directionX: away.x, directionY: away.y,
                        duration: 0.68,
                        reason: "Sebző nagy boss tartósan takarásban: megszakítom a vak harcot és távolodom")
                }
                let numericPlayerStillHealthy = knownMaximumDisplayedHP > 0 &&
                    (analysis.playerDisplayedHP ?? 0) >= Int(Double(knownMaximumDisplayedHP) * 0.45)
                if trialInitialHP <= 5_000,
                   trialLowestHP <= trialInitialHP - 250,
                   (controlledBossTrialLastDistance ?? .greatestFiniteMagnitude) <= 112,
                   controlledBossTrialLostFrames < 40,
                   numericPlayerStillHealthy {
                    // A 3.06K-s Dusty Gulch-őr az első váltásban 2.57K-ra
                    // csökkent, a karakter pedig csak 60-at kapott. Az ütés- és
                    // testanimáció ezután időszakosan teljesen eltakarta a piros
                    // csíkot. Bizonyított közeli sebzés után nem indulunk el a
                    // minimap szerint: négy másodpercig helyben tartjuk az
                    // automata kombót, amíg a csík vagy a jutalom visszatér.
                    // A numerikus saját HP-őr a csíkátfedésből származó hamis
                    // 25%-os képpontméréstől függetlenül is megvédi a próbát.
                    controlledBossTrialLostFrames += 1
                    consecutiveStaticSceneDecisions = 0
                    return .wait(
                        reason: "Sebzett közeli kis őr csíkját takarja a közelharc; rövid automata támadási ablak"
                    )
                }
                if controlledBossTrialDetourFrames > 0,
                   let detour = controlledBossTrialDetourDirection,
                   analysis.playerDisplayedHP != nil,
                   (analysis.playerHealthFraction ?? 0) >= 0.45 {
                    // A struktúra körüli tangenciális mozgás természetesen
                    // kiviheti a távolabbi bosst a kamerából. Ez nem szakíthatja
                    // meg félúton a kerülőt a régi bossirányú visszakereséssel,
                    // mert az pontosan az objektumba vezet vissza. Előbb a teljes
                    // tervezett oldalláb fut le, csak utána keresünk rá a célra.
                    controlledBossTrialDetourFrames -= 1
                    if controlledBossTrialDetourFrames == 0 {
                        controlledBossTrialDetourDirection = nil
                    }
                    return .swipe(
                        directionX: detour.x,
                        directionY: detour.y,
                        duration: 0.62,
                        reason: "A megkezdett oldalkerülőt a képről lecsúszott boss mellett is végigviszem"
                    )
                }
                controlledBossTrialLostFrames += 1
                // A váltott oldali Titan-objektum-kerülő fizikailag kiviheti a
                // 4.31K-s fát a képből, miközben a tiszta megközelítési folyosó
                // már megnyílt. A normál háromképes takarást csak ilyen igazolt
                // struktúrakerülés után hosszabbítjuk nyolcra.
                let reachableIsland2GuardWasClose =
                    controlledBossTrialInitialTreeConfidence < 0.25 &&
                    (controlledBossTrialInitialHP ?? 0) <= 5_000 &&
                    (controlledBossTrialLastDistance ?? .greatestFiniteMagnitude) <= 180 &&
                    analysis.orangeRockBiomeVisible
                // A mozgó 3.06K-s alsó őr 157 pixelen egyetlen képre eltűnt a
                // saját test/ütés és a kamera eltolása mögött. A háromképes
                // memória még kontaktus előtt feladta, pedig a sáv azonnal
                // újrapróbálható maradt. A járható, már közeli Island 2-őrnek
                // tizenkét rövid, iránytartó képet adunk; ez még mindig jóval
                // rövidebb a statikus növényi kombó ablakánál.
                let lostSearchLimit = reachableIsland2GuardWasClose
                    ? 12
                    : (controlledBossTrialStructureDetourCount > 0 ? 8 : 3)
                if controlledBossTrialLostFrames <= lostSearchLimit,
                   let lastDirection = controlledBossTrialDirection,
                   analysis.playerDisplayedHP != nil,
                   (analysis.playerHealthFraction ?? 0) >= 0.45 {
                    return .swipe(
                        directionX: lastDirection.x,
                        directionY: lastDirection.y,
                        duration: 0.34,
                        reason: "A boss röviden takarásba került; a legutóbbi iránnyal visszakeresem"
                    )
                }
                if controlledBossTrialLostFrames == lostSearchLimit + 1 {
                    return .wait(reason: "A boss továbbra sem látszik; jutalomra vagy halálátmenetre várok")
                }
                if controlledBossTrialLowestHP == controlledBossTrialInitialHP {
                    controlledBossTrialNoDamageOverlapGraceFrames = 8
                    if let initialHP = controlledBossTrialInitialHP {
                        // Ha a cél még a tényleges kontaktus előtt kicsúszott a
                        // kamerából, az nem harci vereség és nem is teljesített
                        // próba. A régi sávzár miatt ugyanabban a menetben a
                        // következő, már járható oldalról sem indulhatott újra a
                        // támadás. Csak a nulla sebzéses, közeli kontaktust sem
                        // elérő megközelítés sávját nyitjuk vissza.
                        if !controlledBossTrialReachedCloseRange && controlledBossTrialDetourCycles == 0 {
                            attemptedBossTrialBands.remove((initialHP / 250) * 250)
                        } else if controlledBossTrialDetourCycles > 0 {
                            // A fal mögötti DOC-őr takarása után ugyanaz a próba
                            // két döntéssel később újraindult. Ez útvonalkudarc,
                            // nem vereség: rövid helyi sávhűtés, tartós HP-tiltás nélkül.
                            elevationSeparatedBossBand = (initialHP / 250) * 250
                            elevationSeparatedBossCooldownFrames = 120
                            attemptedBossTrialBands.remove((initialHP / 250) * 250)
                        }
                    }
                }
                controlledBossTrialActive = false
                controlledBossTrialDirection = nil
                controlledBossTrialLastDistance = nil
                controlledBossTrialStagnantApproachFrames = 0
                controlledBossTrialDetourFrames = 0
                controlledBossTrialDetourDirection = nil
                controlledBossTrialStructureDetourCount = 0
            }
        }

        if retreatMode, let health = analysis.playerHealthFraction {
            // A visszavonulás megszakítja az üldözést. Ha a fenyegetés később
            // eltűnik a képről, alacsony HP-n tilos az elveszett cél háromképes
            // memóriájából automatikusan visszafordulni ugyanabba az irányba.
            lostTargetFrames = 0
            lastPursuitDirection = nil
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            minimapDetourFrames = 0
            stagnantMinimapFrames = 0
            persistentDetourFrames = 0
            persistentDetourDirection = nil
            weaponCarrierCornerTurnFrames = 0
            weaponCarrierCornerTurnDirection = nil
            blockedAreaEscapeFrames = 0
            blockedAreaEscapeDirection = nil
            if sawCriticalHealth, !hasFreshNumericHealth {
                if recentHostileBossTrialFrames > 0,
                   let escape = recentThreatEscapeDirection {
                    return .swipe(directionX: escape.x, directionY: escape.y,
                        duration: 0.68,
                        reason: "Kritikus takarás a legutóbbi támadó mellett: folyamatos kifelé menekülés")
                }
                if bossEscapeFrames > 0, let escape = bossEscapeDirection {
                    bossEscapeFrames -= 1
                    return .swipe(directionX: escape.x, directionY: escape.y,
                        duration: 0.68,
                        reason: "Kritikus takarásban is folytatom a megkezdett menekülési irányt")
                }
                if controlledBossTrialActive,
                   let towardBoss = controlledBossTrialDirection {
                    // Kritikus pixeles HP bosskontaktusban nem lehet helyben
                    // várakozási ok. A boss ellenirányának és az oldalirányú
                    // komponensnek a keveréke a köztes oltárt is megkerüli;
                    // valódi halálátmenetnél a HUD-őr úgyis input nélkül vár.
                    let tangent = Vector2(x: -towardBoss.y, y: towardBoss.x)
                    let escape = Vector2(
                        x: -towardBoss.x * 0.35 + tangent.x,
                        y: -towardBoss.y * 0.35 + tangent.y
                    ).normalized
                    return .swipe(
                        directionX: escape.x,
                        directionY: escape.y,
                        duration: 0.70,
                        reason: "Kritikus bosskontaktus: oldalirányú kiszabadulás friss numerikus HP-ig"
                    )
                }
                let timerCoversHP = HPTimerOcclusionPolicy.matches(analysis.playerOCRStrings + (analysis.playerLocalizedOCRStrings ?? []))
                if timerCoversHP,
                   analysis.nearbyThreatCount == 0, !controlledBossTrialActive,
                   hpObservationProbeBudget.consume(now:Date().timeIntervalSinceReferenceDate) {
                    return .swipe(directionX:1,directionY:0,duration:0.30,
                        reason:"HP-t takaró időzítő: egyszeri rövid oldalmozdulat friss számolvasáshoz; nem gyógyulásigazolás")
                }
                return .wait(reason: "Kritikus állapot után friss numerikus HP-megerősítésre várok")
            }
            let threat = analysis.nearestThreat
            if threat == nil, recentDamageFrames == 0, health < 0.85 {
                return .wait(reason: String(format: "Biztonságos regeneráció %.0f%% életerőn; 85%%-ig nem indulok új célhoz", health * 100))
            }
            let away = Vector2(
                x: threat.map { Double(analysis.width) * 0.5 - $0.x } ?? 0,
                y: threat.map { Double(analysis.height) * 0.515 - $0.y } ?? 1
            ).normalized
            let reason: String
            if health < 0.20 {
                reason = String(format: "Kritikus visszavonulás %.0f%% életerőn", health * 100)
            } else if recentDamageFrames > 0 {
                reason = String(format: "Friss sebzésből visszavonulás %.0f%% életerőn", health * 100)
            } else if analysis.nearbyThreatCount >= 2 {
                reason = String(format: "Túlerőből visszavonulás (%d közeli cél, %.0f%% HP)", analysis.nearbyThreatCount, health * 100)
            } else {
                reason = String(format: "Visszavonulás folytatása %.0f%% életerőn", health * 100)
            }
            return .swipe(
                directionX: away.x,
                directionY: away.y,
                duration: 0.65,
                reason: reason
            )
        }

        // A 4.31K HP-s óriásfa már egyetlen találkozás alatt 340 HP-ról
        // megölt. A biztonságos célválasztás ugyan kizárja, de egy közeli kisebb
        // célhoz vagy minimap-jelhez tartva még bele lehet sétálni az
        // aggrókörébe. Ezért a többezer HP-s ellenfél közelsége teljes HP-n is
        // felülírja a célkövetést és az akadálykerülést.
        // Egy boss egyetlen swipe után takarásba kerülhet, miközben a minimap
        // továbbra is pontosan visszafelé, a veszélyes csoporthoz vezet. Az első
        // biztos távolodási vektort ezért hat tényleges mozdulatig megtartjuk;
        // felhasználói aktivitásos várakozás ezt a számlálót sem fogyasztja.
        if bossEscapeFrames > 0,
           let escape = bossEscapeDirection {
            bossEscapeFrames -= 1
            if bossEscapeFrames == 0 {
                bossEscapeDirection = nil
            }
            return .swipe(
                directionX: escape.x,
                directionY: escape.y,
                duration: 0.68,
                reason: "A legutóbbi boss eltakart; a bizonyított menekülési irányt tartom"
            )
        }

        if analysis.orangeRockCoverage >= 0.68 {
            island2ReturnSearchPhase = 0
            island2ReturnSearchFrames = 0
        } else if !hasReachedIsland2ThisProcess,
                  (analysis.playerHealthFraction ?? lastHealthFraction ?? 0) >= 0.90,
                  !controlledBossTrialActive,
                  !nearbyQuickFarm,
                  unstuckRecoveryStage == 0,
                  deepMinesExitFramesRemaining == 0 {
            // Az aktuális projektküldetés Island 2 két koponyája. A zöld
            // Meadowlands sok apró, gyorsan újratermelődő célja a `022651-play`
            // futásban azonnal átvette a célzárat, így a bot ismét helyi farmba
            // merült ahelyett, hogy visszatért volna a narancs szigetre. A
            // visszatérés ezért a helyi farmcélnál erősebb, de sebzés, gyógyulás,
            // menü és aktív kontrollált próba továbbra is megelőzi.
            //
            // A nyugat felé álló szikla-/sátorkonkáv nem oldható meg egyetlen
            // állandó vektorral. A mért makró nyugati próbákat vált rövid északi,
            // déli, majd keleti konkáv-kijutással; minden ciklus végén hosszabb
            // nyugati láb keresi az Island 2 átjáróját. Amint narancs biomot
            // legalább 68%-os, bizonyított narancs talajt látunk, a makró
            // azonnal megszűnik, és a piros célválasztás él. A határnál látszó
            // keskeny narancs sziklasáv önmagában még nem érkezés: a
            // `023120-play/25` képen ez túl korán engedte vissza a helyi farmot.
            if let questRoute = effectiveQuestRouteDirection {
                // A türkiz sín biztosan a Deep Mines 0/1 kapujához vezet. A
                // kaputól már mért, determinisztikus útvonalunk van Island 2-re,
                // ezért zöld terepen ez jobb köztes cél, mint a helyi farm vagy
                // a helyfüggő, nyolcfázisú általános keresés.
                return .swipe(
                    directionX: questRoute.x,
                    directionY: questRoute.y,
                    duration: 0.58,
                    reason: "Island 2 fő küldetés: a Deep Mines sínhez igazodó mért visszaút előkészítése"
                )
            }
            if island2ReturnSearchFrames == 0 {
                island2ReturnSearchPhase = (island2ReturnSearchPhase + 1) % 8
                switch island2ReturnSearchPhase {
                case 1: island2ReturnSearchFrames = 18
                case 2: island2ReturnSearchFrames = 14
                case 3: island2ReturnSearchFrames = 18
                case 4: island2ReturnSearchFrames = 24
                case 5: island2ReturnSearchFrames = 18
                case 6: island2ReturnSearchFrames = 10
                case 7: island2ReturnSearchFrames = 20
                default: island2ReturnSearchFrames = 30
                }
            }
            let direction: Vector2
            let phaseReason: String
            switch island2ReturnSearchPhase {
            case 1, 3, 5, 0:
                // A `104247-play` a tiszta nyugati lábbal kétszer is visszament
                // ugyanabba a kék hajótest és a sziklafal közti konkávba. A
                // `101110`→`101525` élő mérés szerint az enyhén északnak tartó
                // nyugati él ugyaninnen közvetlenül átvezet a narancs kapun.
                // Ezt a már bizonyított topológiai élt használjuk a határkereső
                // makró összes hosszú nyugati szakaszán.
                direction = Vector2(x: -1, y: -0.25).normalized
                phaseReason = "kimért nyugat-északnyugati Island 2-kapuél"
            case 2:
                direction = Vector2(x: 0, y: -1)
                phaseReason = "északi falvégkerülő"
            case 4:
                direction = Vector2(x: 0, y: 1)
                phaseReason = "déli falvégkerülő"
            case 6:
                direction = Vector2(x: 1, y: 0)
                phaseReason = "keleti konkáv-kijutás"
            default:
                direction = Vector2(x: 0, y: -1)
                phaseReason = "északi ráfordulás a hosszú nyugati láb előtt"
            }
            island2ReturnSearchFrames -= 1
            return .swipe(
                directionX: direction.x,
                directionY: direction.y,
                duration: 0.62,
                reason: "Island 2 fő küldetés: \(phaseReason)"
            )
        }

        // A 104751-es élő futás pontosította a hordozó nyugati kerítésének
        // geometriáját: nyolc bal swipe eléri a délnyugati sarkot, de három
        // északi swipe után a jobbra fordulás még ugyanannak a hosszú függőleges
        // palánknak ütközik. A negyedik északi lépés környékén megjelenő 1.22K-s
        // őr a veszélyes nyugati oldalon áll. Ha még legalább 250 pixelre van,
        // a játékos teljes HP-n van és nincs friss sebzés, nem töröljük a teljes
        // hordozóútvonalat: a tervezett északi mozgást a tábor felé, jobbra
        // keverjük. Ettől egyszerre haladunk a kerítés vége és az őrtől távolabbi
        // oldal felé. Közelebbi, erősebb vagy már sebző ellenfélnél a lenti
        // általános bossmenekülés változatlanul elsőbbséget kap.
        // Amikor a fenti átlós északi szakasz elfogy, a tiszta jobbra láb még
        // közvetlenebbül távolodik a nyugati őrtől. Ugyanazzal a szűk őr-, HP-,
        // távolság- és sebzéskapuval ezt sem szakítjuk meg pusztán azért, mert az
        // őr egy-két képen még látható. Az utolsó nyolc lépés után ez a kivétel
        // automatikusan megszűnik, és a normál bossőr ismét teljesen érvényes.
        if weaponCarrierCornerTurnFrames == 0,
           persistentDetourFrames > 0,
           lastTargetWasVerifiedWeaponCarrier,
           let returnTowardCamp = persistentDetourDirection,
           let threat = analysis.nearestThreat,
           let threatHP = threat.displayedHP,
           ((threatHP >= 900 && threatHP <= 1_500) ||
                (threatHP >= 120_000 && threatHP <= 125_000 &&
                    threat.axeIconEvidence >= 0.04)),
           threat.distance >= 250,
           threat.distance <= 360,
           recentDamageFrames == 0,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            persistentDetourFrames -= 1
            return .swipe(
                directionX: returnTowardCamp.x,
                directionY: returnTowardCamp.y,
                duration: 0.52,
                reason: "A hordozó távoli nyugati őrétől jobbra, a tábor felé tartom a visszatérő lábat"
            )
        }

        if weaponCarrierCornerTurnFrames > 0,
           persistentDetourFrames == 0,
           lastTargetWasVerifiedWeaponCarrier,
           let turn = weaponCarrierCornerTurnDirection,
           let threat = analysis.nearestThreat,
           let threatHP = threat.displayedHP,
           ((threatHP >= 900 && threatHP <= 1_500) ||
                (threatHP >= 120_000 && threatHP <= 125_000 &&
                    threat.axeIconEvidence >= 0.04)),
           threat.distance >= 250,
           threat.distance <= 360,
           recentDamageFrames == 0,
           (analysis.playerHealthFraction ?? 0) >= 0.90,
           let outward = persistentDetourDirection {
            weaponCarrierCornerTurnFrames -= 1
            let returnTowardCamp = Vector2(x: -outward.x, y: -outward.y)
            let corridorRun = Vector2(
                x: turn.x * 0.78 + returnTowardCamp.x,
                y: turn.y * 0.78 + returnTowardCamp.y
            ).normalized
            if weaponCarrierCornerTurnFrames == 0 {
                weaponCarrierCornerTurnDirection = nil
                persistentDetourDirection = returnTowardCamp
                persistentDetourFrames = 8
                lostTargetFrames = 12
            }
            return .swipe(
                directionX: corridorRun.x,
                directionY: corridorRun.y,
                duration: 0.52,
                reason: "A hordozó 1.22K-s nyugati őre még távoli; jobbra-felfelé folytatom a kerítéskerülést"
            )
        }

        if let skullDirection = analysis.island2SkullDirection {
            cachedIsland2SkullDirection = skullDirection
            cachedIsland2SkullDirectionFrames = 8
        } else if cachedIsland2SkullDirectionFrames > 0 {
            cachedIsland2SkullDirectionFrames -= 1
        } else {
            cachedIsland2SkullDirection = nil
        }
        let effectiveIsland2SkullDirection = analysis.island2SkullDirection ??
            cachedIsland2SkullDirection

        let strategicBossThreat: Target? = {
            guard effectiveIsland2SkullDirection != nil else {
                return analysis.nearestThreat
            }
            // A szívikonos kaktuszok tartós maximumot adnak: az élő Island 2
            // mérésben a 10.9K-s példány +300 HP-t, egy kisebb példány további
            // +40 HP-t adott. Ezek fejlődési értéke nagyobb, mint a pillanatnyi
            // koponyacélé, és nem ütnek vissza, ezért a látható, elérhető
            // szívkaktusz minden koponyás humanoidot megelőz.
            if let heartTree = analysis.visibleTargets.filter({ candidate in
                candidate.treeConfidence >= 0.25 &&
                    candidate.heartIconEvidence >= 0.04 &&
                    candidate.distance <= 380 &&
                    (800...30_000).contains(canonicalControlledTrialHP(candidate) ?? 0)
            }).min(by: { $0.distance < $1.distance }) {
                return heartTree
            }
            let nonTreeBosses = analysis.visibleTargets.filter { candidate in
                guard candidate.treeConfidence < 0.25,
                      let hp = canonicalControlledTrialHP(candidate) else { return false }
                return (800...30_000).contains(hp)
            }
            // A nagy térképes koponya stratégiai régiót jelöl, nem azt, hogy a
            // legnagyobb képernyőn látható HP-csík fizikailag elérhető. A
            // Dusty-udvarban a 3.06K-s őr már a karakter mellett állt, miközben
            // a 4.4K-s DOC-őr egy másik magaslati szinten látszott. Ilyenkor a
            // biztosan kontaktközeli, nem növényi ellenfelet előbb levágjuk.
            if let reachableCloseBoss = nonTreeBosses
                .filter({ $0.distance <= 155 })
                .max(by: {
                    (canonicalControlledTrialHP($0) ?? 0) <
                        (canonicalControlledTrialHP($1) ?? 0)
                }) {
                return reachableCloseBoss
            }
            // A 3.06K-s őr 3.77K saját maximum mellett mindössze kb. 60 HP
            // veszteséggel esett el. A 2.49K-s kísérők ugyanilyen fejlődési
            // célok; ne ugorjuk át őket csak azért, mert ugyanazon a képen egy
            // 18.8K-s főellenfél is látszik.
            if let farmableGuard = nonTreeBosses.filter({ candidate in
                let hp = canonicalControlledTrialHP(candidate) ?? .max
                return hp <= 5_000 && candidate.distance <= 380
            }).min(by: { $0.distance < $1.distance }) {
                return farmableGuard
            }
            // Aktív koponyaküldetésben a nagy térképes főellenfél fontosabb a
            // közelebbi 1.28K-s kaktusznál és a 2.49K-s kísérőknél. A
            // `032434-play/20` egyszerre mutatta a 18.8K-s fő célpontot, két
            // 2.49K-s őrt és egy 1.28K-s növényt; a puszta távolsági választás
            // rossz próbacélt rögzített. A legnagyobb nem növényi cél nyer.
            return nonTreeBosses.max { lhs, rhs in
                (canonicalControlledTrialHP(lhs) ?? 0) <
                    (canonicalControlledTrialHP(rhs) ?? 0)
            } ?? analysis.nearestThreat
        }()

        let nearestBossAlignedWithMap: Bool = {
            guard let threat = strategicBossThreat,
                  let mapDirection = effectiveIsland2SkullDirection ?? analysis.explorationDirection else { return false }
            let towardThreat = Vector2(
                x: threat.x - Double(analysis.width) * 0.5,
                y: threat.y - Double(analysis.height) * 0.515
            ).normalized
            return towardThreat.x * mapDirection.x + towardThreat.y * mapDirection.y >= 0.55
        }()

        if let threat = analysis.nearestThreat,
           let bossHP = canonicalControlledTrialHP(threat),
           bossHP >= 800,
           bossBandIsStillAboveProvenStrength(bossHP),
           !(threat.treeConfidence >= 0.25 && threat.heartIconEvidence >= 0.04),
           threat.distance <= (analysis.innerMapEnemyVisible ? 520 : 430) {
            // A geometriai irányhűtő egy másik célra forduláskor feloldhat;
            // ettől a visszautasított boss koponyája nem lesz újra jó úticél.
            rejectedSkullCooldownFrames = 120
            let toward = Vector2(
                x: threat.x - Double(analysis.width) * 0.5,
                y: threat.y - Double(analysis.height) * 0.515
            ).normalized
            let away = Vector2(x: -toward.x, y: -toward.y).normalized
            blockedRouteDirection = toward
            blockedRouteCooldownFrames = max(blockedRouteCooldownFrames, 600)
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
            controlledBossTrialActive = false
            // Ez ugyanolyan valódi visszavonulás, mint az általános bossőr.
            // A 122032-es futásban a régi faljárás a boss eltűnése után
            // visszahúzott a veszély irányába. Minden félbehagyott kerülőt
            // törlünk, és hat végrehajtott inputig megtartjuk a kifelé irányt.
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            minimapDetourFrames = 0
            stagnantMinimapFrames = 0
            persistentDetourFrames = 0
            persistentDetourDirection = nil
            weaponCarrierCornerTurnFrames = 0
            weaponCarrierCornerTurnDirection = nil
            blockedAreaEscapeFrames = 0
            blockedAreaEscapeDirection = nil
            lastPursuitDirection = nil
            lastTargetDistance = nil
            lastTargetDisplayedHP = nil
            bossEscapeDirection = away
            bossEscapeFrames = 5
            return .swipe(
                directionX: away.x,
                directionY: away.y,
                duration: 0.68,
                reason: "Tartós harci tudás: a \(bossHP) HP-s cél a jelenlegi erőn már súlyos vereséget okozott; fejlődésig területelhagyás"
            )
        }

        if controlledBossTrialsEnabled || smallGuardResearchTarget != nil,
           deepMinesGateBossCooldownFrames == 0,
           let threat = smallGuardResearchTarget ?? strategicBossThreat,
           (threat.bossEvidence || (threat.displayedHP ?? 0) >= 800),
           let bossHP = canonicalControlledTrialHP(threat),
           (!analysis.innerMapEnemyVisible || nearestBossAlignedWithMap ||
                (threat.treeConfidence >= 0.25 && threat.heartIconEvidence >= 0.04) ||
                (bossHP <= 5_000 && threat.distance <= 360)),
           (800...30_000).contains(bossHP),
           !(elevationSeparatedBossCooldownFrames > 0 &&
                elevationSeparatedBossBand == (bossHP / 250) * 250),
           threat.distance <= (analysis.innerMapEnemyVisible ? 520 : 420),
           (analysis.playerDisplayedHP ?? 0) >= 750,
           (analysis.playerHealthFraction ?? 0) >= 0.95,
           recentDamageFrames == 0 {
            let band = (bossHP / 250) * 250
            let passiveHeartTree = threat.treeConfidence >= 0.25 &&
                threat.heartIconEvidence >= 0.04
            // A koponyajel felderítési prioritás, nem engedély ugyanannak a
            // bizonyítottan vesztes közelharcnak az azonnali ismétlésére. A
            // 18.8K-s boss 3.77K maximumnál néhány másodperc alatt megölt;
            // fejlődésig a kísérők és a statkaktuszok kapnak elsőbbséget.
            guard !bossBandIsStillAboveProvenStrength(bossHP) ||
                    passiveHeartTree else {
                return fallbackExplorationDecision(
                    analysis,
                    reason: "A korábban vesztes (bossHP) HP-s sáv csak legalább 20% új maximum után próbálható újra"
                )
            }
            let edgeBandMatches = passiveHeartTree || !analysis.edgeObjectiveVisible ||
                edgeObjectiveTrialBand == nil ||
                edgeObjectiveTrialBand == band
            // A most feltérképezett piros peremjel a 4.4K-s páncélos erődőrt
            // mutatta. Amíg a jel aktív és még nincs rögzített sáv, egy köztes
            // 11.4K-s passzív kaktusz nem veheti át a kijelölt ellenfél helyét.
            let canPinNewEdgeBand = passiveHeartTree || !analysis.edgeObjectiveVisible ||
                edgeObjectiveTrialBand != nil ||
                threat.treeConfidence < 0.25
            if edgeBandMatches,
               canPinNewEdgeBand,
               !attemptedBossTrialBands.contains(band) {
                if analysis.edgeObjectiveVisible,
                   edgeObjectiveTrialBand == nil,
                   !passiveHeartTree {
                    edgeObjectiveTrialBand = band
                }
                attemptedBossTrialBands.insert(band)
                controlledBossTrialActive = true
                controlledBossTrialCloseNoDamageFrames = 0
                controlledBossTrialFrames = 1
                controlledBossTrialLostFrames = 0
                controlledBossTrialInitialHP = bossHP
                controlledBossTrialLowestHP = bossHP
                passiveContactLastHP = nil
                passiveContactStagnantFrames = 0
                controlledBossTrialInitialHeartEvidence = threat.heartIconEvidence
                controlledBossTrialInitialAxeEvidence = threat.axeIconEvidence
                controlledBossTrialInitialTreeConfidence = threat.treeConfidence
                controlledBossTrialOrbitSign *= -1
                controlledBossTrialLastDistance = threat.distance
                controlledBossTrialStagnantApproachFrames = 0
                controlledBossTrialDetourFrames = 0
                controlledBossTrialDetourDirection = nil
                controlledBossTrialDetourCycles = 0
                controlledBossTrialStructureDetourCount = 0
                controlledBossTrialElevatedRampFrames = 0
                controlledBossTrialElevatedRampDirection = nil
                controlledBossTrialElevatedRoutePhase = 0
                controlledBossTrialReachedCloseRange = false
                controlledBossTrialInitialNearbyRespawnTimer = analysis.nearbyRespawnTimer
                controlledBossTrialHealthReward = (bossHP > 8_000 &&
                    threat.treeConfidence >= 0.25 &&
                    threat.ocrStrings.contains(where: {
                        $0.filter(\.isNumber) == "300"
                    })) ? 300 : 0
                controlledBossTrialRewardApplied = false
                if !passiveHeartTree {
                    recentHostileBossTrialHP = bossHP
                    recentHostileBossTrialFrames = 90
                }
                let toward = Vector2(
                    x: threat.x - Double(analysis.width) * 0.5,
                    y: threat.y - Double(analysis.height) * 0.515
                ).normalized
                controlledBossTrialDirection = toward
                // A `015140`→`015257` kézi mérés végleg kizárta az itt korábban
                // indított 14 dél + 10 nyugat + 16 észak útvonalat: teljes
                // hurkot zárt és ugyanabba a házzsebbe ért vissza. A próbát most
                // a tényleges képi irány indítja; stagnáláskor a későbbi,
                // képkockából választott faljáró dönt, nem ez a vak hurok.
                return .swipe(
                    directionX: toward.x,
                    directionY: toward.y,
                    duration: threat.distance > 180 ? 0.56 : 0.38,
                    reason: "Kontrollált bosspróba indul \(bossHP) HP-ról; a tényleges sebzést és túlélhetőséget mérem"
                )
            }
        }

        if let threat = analysis.nearestThreat,
           let bossHP = canonicalControlledTrialHP(threat),
           elevationSeparatedBossBand == (bossHP / 250) * 250,
           elevationSeparatedWallFollowFrames > 0,
           recentDamageFrames == 0,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A másik magassági szinten álló boss képi közelsége nem aggró és
            // nem indokol ismételt, közvetlen ellenirányú menekülést: az a
            // külső sziklafalnak nyomta a karaktert. A fal mentén, enyhén kifelé
            // haladunk, amíg a boss eltűnik vagy valódi bejárat nyílik.
            let toward = Vector2(
                x: threat.x - Double(analysis.width) * 0.5,
                y: threat.y - Double(analysis.height) * 0.515
            ).normalized
            let tangent = Vector2(
                x: -toward.y * elevationSeparatedWallSign,
                y: toward.x * elevationSeparatedWallSign
            )
            let wallFollow = Vector2(
                x: tangent.x - toward.x * 0.28,
                y: tangent.y - toward.y * 0.28
            ).normalized
            elevationSeparatedWallFollowFrames -= 1
            if elevationSeparatedWallFollowFrames == 0 {
                // A mozgó őr és a perces körök a képi ujjlenyomatot akkor is
                // változtatják, amikor a karakter ugyanannak a külső háznak a
                // sarkán áll. Hetvenkét célzott faljáró lépés után a helyi
                // magaslati felderítés kimerült: a már bizonyított Settings /
                // Unstuck helyreállítás jogos, nem várunk további álmozgásra.
                failedStaticEscapePhases = max(failedStaticEscapePhases, 6)
            }
            return .swipe(
                directionX: wallFollow.x,
                directionY: wallFollow.y,
                duration: 0.58,
                reason: "Magaslati szintkülönbség: a külső fal mentén valódi bejáratot keresek"
            )
        }

        let elevationSeparatedThreatInCooldown: Bool = {
            guard elevationSeparatedBossCooldownFrames > 0,
                  let separatedBand = elevationSeparatedBossBand,
                  let threat = analysis.nearestThreat,
                  let hp = canonicalControlledTrialHP(threat) else { return false }
            return (hp / 250) * 250 == separatedBand
        }()

        if let threat = analysis.nearestThreat,
           (threat.bossEvidence || (threat.displayedHP ?? 0) >= 800),
           threat.distance <= 360,
           !elevationSeparatedThreatInCooldown,
           !(effectiveIsland2SkullDirection != nil && threat.treeConfidence < 0.25),
           !(threat.treeConfidence >= 0.25 &&
                recentDamageFrames == 0 &&
                ((analysis.playerHealthFraction ?? 0) >= 0.90 ||
                 (analysis.playerDisplayedHP ?? 0) >=
                    Int(Double(knownMaximumDisplayedHP) * 0.85))) {
            // A nagy térkép piros fegyverjele aktív célmegbízás. Útközben egy
            // passzív 1.28K-s kaktusz puszta képi közelsége nem szakíthatja meg
            // a küldetést és nem indíthat hatswipe-os menekülést; a tényleges
            // sérülésőr továbbra is azonnal érvényes. A nem növényi 4.4K-s őrt
            // a fenti kontrollált próba veszi át és rögzíti célként.
            // A központi +10 szívfa első oldaljárását élőben boss szakította
            // félbe. A kerülő jele már átfordult a másik oldalra, de a hibaciklus
            // megmaradt; a következő stagnálás ezért próba nélkül rögtön hosszú
            // kiszakadásnak számított. A félbeszakított kerülő nem sikertelen
            // kerülő: egyet visszalépünk, az oldalváltó jelet viszont megőrizzük.
            if persistentDetourFrames > 0 {
                failedApproachCycles = max(0, failedApproachCycles - 1)
            }
            bossEncountersWithoutProgress += 1
            if recentOrangeRockBiomeFrames > 0,
               protectedFreeExploreFrames == 0,
               bossEncountersWithoutProgress >= 3,
               bossEncountersWithoutProgress % 3 == 0 {
                // A Dusty Gulch oázisánál a piros minimapjel három teljes
                // bossköre ugyanahhoz a több tízezer HP-s növényhez vitt vissza:
                // hatswipe-os menekülés, rövid oldaljárás, majd ismét azonos cél.
                // A bosspróbákat nem tiltjuk le, de minden harmadik ilyen
                // találkozás után indítjuk az elég hosszú, helyi szabad keresést.
                // Már aktív ablakot nem töltünk újra: a `150906-play` során a
                // saját kitérései közben látott bossok 136+ döntésre nyújtották
                // a 120-as módot, így az sosem adta vissza a piros cél követését.
                protectedFreeExploreFrames = max(protectedFreeExploreFrames, 120)
                resetFallbackExploration()
            }
            let valuableHeartTreeVisible = analysis.target.map { target in
                target.distance <= 300 &&
                    target.treeConfidence >= 0.25 &&
                    target.heartIconEvidence >= 0.05 &&
                    (target.level ?? 0) >= 5
            } ?? false
            if bossEncountersWithoutProgress >= 5,
               deepMinesGateBossCooldownFrames == 0,
               recentOrangeRockBiomeFrames == 0,
               !valuableHeartTreeVisible,
               (analysis.playerHealthFraction ?? 0) >= 0.90 {
                // Az újraéledésről bizonyított, hogy nem vesz el maximumot vagy
                // felszerelést, és a Meadowlands biztonságos farmjára helyez.
                // Öt bossciklus hozam nélkül már drágább, mint ez a rövidítés.
                let toward = Vector2(
                    x: threat.x - Double(analysis.width) * 0.5,
                    y: threat.y - Double(analysis.height) * 0.515
                ).normalized
                strategicRespawnMode = true
                strategicRespawnDirection = toward
                strategicRespawnFramesRemaining = 120
                strategicRespawnSawDamage = false
                strategicRespawnSawHUDLoss = false
                strategicRespawnLastBossDistance = nil
                strategicRespawnStagnantApproachFrames = 0
                strategicRespawnDetourFrames = 0
                strategicRespawnDetourDirection = nil
                strategicRespawnDetourSign = 1
                bossEscapeFrames = 0
                bossEscapeDirection = nil
                return .swipe(
                    directionX: toward.x,
                    directionY: toward.y,
                    duration: 0.56,
                    reason: "Öt eredménytelen boss-találkozás után büntetésmentes újraéledési rövidítés"
                )
            }
            lostTargetFrames = 0
            lastPursuitDirection = nil
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            // A boss megszakítja az útvonal szándékát is. A hatswipe-os
            // menekülési memória után nem szabad folytatni a félbehagyott
            // faljárást/minimap-kerülőt, mert az visszavezethet ugyanahhoz a
            // veszélyhez; a következő irány friss képből születik.
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            minimapDetourFrames = 0
            stagnantMinimapFrames = 0
            persistentDetourFrames = 0
            persistentDetourDirection = nil
            weaponCarrierCornerTurnFrames = 0
            weaponCarrierCornerTurnDirection = nil
            blockedAreaEscapeFrames = 0
            blockedAreaEscapeDirection = nil
            let away = Vector2(
                x: Double(analysis.width) * 0.5 - threat.x,
                y: Double(analysis.height) * 0.515 - threat.y
            ).normalized
            bossEscapeDirection = away
            bossEscapeFrames = 5
            // Nemcsak a képen látható testet, hanem az odavezető legutóbbi
            // minimap-szándékot is hűtjük. A hatswipe-os távolodás után így a
            // döntő oldalirányú felderítésre vált, ahelyett hogy ugyanannak a
            // piros pontnak nekifutna. Ha még nincs minimapmérés, a boss felé
            // mutató geometriai irány lesz a lezárt vektor.
            // A lezárt irányt a boss tényleges képi iránya adja. A legutóbbi
            // magas szintű navigációs szándék lehet Island 4-határelhagyás,
            // láda vagy küldetésút is; annak hűtése a veszéllyel ellentétes,
            // hibás oldalra fordíthatná a botot.
            blockedRouteDirection = Vector2(
                x: -away.x,
                y: -away.y
            )
            blockedRouteCooldownFrames = 120
            blockedRouteBypassSign *= -1
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
            return .swipe(
                directionX: away.x,
                directionY: away.y,
                duration: 0.68,
                reason: "Többezer HP-s boss túl közel van; megelőző területelhagyás"
            )
        }

        // A 10-szíves, 174 HP-s fa 182 pixelen látszott, de a 180-as általános
        // megszakítási küszöb miatt a türkiz küldetésút két pixellel felülírta.
        // A jelenlegi sebzéssel az 5/10/20-szíves fák együtéses vagy közel
        // együtéses, kiemelt hozamcélok. A már safeTargetként kiválasztott,
        // biztosan fás és szíves példány 300 pixelen belül megszakíthatja a
        // rövid faljárást, hűtőt és quest-navigációt. A boss- és sérülésőrök
        // fentebb futnak, tehát ezt veszélyhelyzetben nem érjük el.
        let priorityHeartTreeVisible = analysis.target.map { target in
            target.distance <= 380 &&
                target.treeConfidence >= 0.25 &&
                target.heartIconEvidence >= 0.05 &&
                (analysis.playerHealthFraction ?? 0) >= 0.90
        } ?? false

        if deepMinesGateBossCooldownFrames > 0,
           analysis.deepMinesPotionQuestVisible {
            // A `192249-play` 60–62. képein a karakter a lila híd alsó oldalán,
            // a `0/1` buborék mellett állt. A felső réteg 1,92K/7,15K csíkjait
            // az OCR átmenetileg 2/20 HP-s közeli farmnak hitte, ezért két swipe
            // még visszament a bizonyítottan zárt kapuhoz. A biztos helyállapot
            // minden távoli célbecslésnél erősebb: dél felé távozunk, amíg a
            // buborék eltűnik. Egy későbbi biztos `1/1` fent már kikapcsolja ezt.
            lostTargetFrames = 0
            lastPursuitDirection = nil
            edgeObjectiveRouteAssistFrames = 0
            edgeObjectiveRouteAssistDirection = nil
            cachedQuestRouteDirection = nil
            cachedQuestRouteDirectionFrames = 0
            cachedSpecialLandmarkDirection = nil
            cachedSpecialLandmarkDirectionFrames = 0
            consecutiveStaticSceneDecisions = 0
            return .swipe(
                directionX: 0,
                directionY: 1,
                duration: 0.68,
                reason: "Deep Mines 0/1 kapuhűtés: az alsó tábor felé tartó azonnali területelhagyás"
            )
        }

        let localGrowthTargetVisible = analysis.target.map {
            $0.distance <= Double(analysis.width) * 0.62
        } ?? false
        let recentGrowthTargetMemory = lastPursuitDirection != nil && lostTargetFrames < 3
        // Mindkét feltérképezett koponyaboss valós vereségsávban van.
        // A harci tilalom már a távoli útvonalválasztást is korlátozza:
        // ne csak odaérve forduljunk vissza minden új folyamatban.
        let knownSkullBattlesCooling = [18_800, 27_700].allSatisfy {
            bossBandIsStillAboveProvenStrength($0)
        }

        if hasReachedIsland2ThisProcess,
           analysis.orangeRockCoverage >= 0.40,
           let skullDirection = effectiveIsland2SkullDirection,
           !controlledBossTrialActive,
           !priorityHeartTreeVisible,
           !localGrowthTargetVisible,
           !recentGrowthTargetMemory,
           !knownSkullBattlesCooling,
           rejectedSkullCooldownFrames == 0,
           blockedRouteCooldownFrames == 0,
           (analysis.playerHealthFraction ?? lastHealthFraction ?? 0) >= 0.75 {
            // A `024704-play` elérte Dusty Gulchot, de a közönséges piros
            // minimappontok 136–416 HP-s fák közt köröztették. A két nagy
            // térképes ellenfél koponyaikonja külön detektorral most erősebb
            // szándék minden helyi farmnál. Egy valódi, 800+ HP-s képi cél
            // viszont már fent kontrollált bosspróbát indíthat.
            lastPursuitDirection = nil
            lastTargetDistance = nil
            lastTargetDisplayedHP = nil
            engagedVerifiedTree = false
            persistentDetourFrames = 0
            persistentDetourDirection = nil
            let route: Vector2
            let reason: String
            // A korábbi 16S/6W/12S makró órás timer + narancs + NW koponya
            // kapuja a már elért alsó arénában is igaz volt (123929-play).
            // Egyedi helyazonosítás nélkül nem futtatunk ilyen nyílt hurkot.
            if island2SkullDetourFrames > 0,
               let detour = island2SkullDetourDirection {
                island2SkullDetourFrames -= 1
                route = detour
                reason = "Island 2 koponyaküldetés: fix akadály nyolclépéses oldalkerülése"
                if island2SkullDetourFrames == 0 {
                    island2SkullDetourDirection = nil
                    consecutiveStaticSceneDecisions = 0
                }
            } else if consecutiveStaticSceneDecisions >= 5 {
                let tangent = Vector2(
                    x: -skullDirection.y * island2SkullDetourSign,
                    y: skullDirection.x * island2SkullDetourSign
                ).normalized
                island2SkullDetourSign *= -1
                island2SkullDetourDirection = tangent
                island2SkullDetourFrames = 7
                route = tangent
                reason = "Island 2 koponyaküldetés: öt statikus kép után falvégi kerülő indul"
            } else {
                route = skullDirection
                reason = "Island 2 koponyaküldetés: a narancs/pink koponya közvetlen követése"
            }
            return .swipe(
                directionX: route.x,
                directionY: route.y,
                duration: 0.60,
                reason: reason
            )
        } else if effectiveIsland2SkullDirection == nil {
            island2SkullDetourFrames = 0
            island2SkullDetourDirection = nil
        }

        // A keskeny Island 4-sziklapárkányon a négy átló, az ellenirány és a
        // hűtött oldaljárás is több teljes fázison át teljesen statikus maradt.
        // A Settings/Unstuck gomb élőben biztonságosan a zöld medencéhez tett,
        // majd visszagyógyított 747 HP-ra. Ez közvetlenebb és biztosabb, mint egy
        // esetleg elérhetetlen támadóval megpróbálni a halált kikényszeríteni.
        // A `192554-play` narancssziklás, cél nélküli magaslati zsebében a hat
        // teljes fázis még 77 fölösleges döntést jelentett, miközben az eltérő
        // átlók és falirányok már három fázis után ugyanazt a statikus réteget
        // bizonyították. Magaslaton három, normál terepen továbbra is hat kell.
        let requiredStaticEscapePhases = analysis.orangeRockBiomeVisible &&
            pendingOneShotHighlandExit ? 3 : 6
        if orangeEnemyEntryRouteFrames == 0,
           orangeBoundaryGateRecoveryFrames == 0,
           alternateGreenEnemyRouteFrames == 0,
           failedStaticEscapePhases >= requiredStaticEscapePhases,
           unstuckRetryCooldownFrames == 0,
           analysis.target == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90,
           !priorityHeartTreeVisible {
            if analysis.orangeRockCoverage >= 0.75,
               analysis.centralLongRespawnTimerCount > 0 {
                persistNavigationCooldown(
                    exhaustedOneShotHighland: true,
                    oneShotHighlandExitPending: true
                )
            }
            failedStaticEscapePhases = 0
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            blockedRouteCooldownFrames = 0
            blockedRouteDirection = nil
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
            strategicRespawnMode = false
            strategicRespawnDirection = nil
            strategicRespawnFramesRemaining = 0
            unstuckRecoveryStage = 1
            unstuckRecoveryWaitFrames = 0
            return .tap(
                x: Double(analysis.width) * 0.061,
                y: Double(analysis.height) * 0.076,
                reason: analysis.orangeRockBiomeVisible
                    ? "Három magaslati statikus kiszabadítási fázis után a bizonyított Unstuck helyreállítást nyitom"
                    : "Hat statikus kiszabadítási fázis után a bizonyított Unstuck helyreállítást nyitom"
            )
        }
        if priorityHeartTreeVisible {
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            // A cél saját stagnálásából indított tartós kerülőt nem töröljük:
            // replayen a kiemelt fa minden képen lenullázta a frissen indult
            // nyolclépéses faljárást, majd ismét ugyanannak a kerítésnek ment.
            blockedRouteCooldownFrames = 0
            blockedRouteDirection = nil
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
        }

        // A Deep Mines piros peremcéljához a közvetlen térképvektor a
        // sziklapárkánynak vezethet, miközben a türkiz sín a járható kerülőt
        // rajzolja. Az ellenfél-szándék megmarad; egy igazolt stagnálás után
        // rövid ideig a sín képenként frissülő irányával vezetünk.
        if deepMinesGateBossCooldownFrames > 0 {
            // A `191302-play` a sikeres kétoldali kapupróba után is megtartotta
            // a korábban indított peremcél+sín kerülőt. Az ág nyers
            // `questRouteDirection` értéket olvasott, így megkerülte a fenti
            // effektív sínnémítást és visszafordult ugyanahhoz a kapuhoz.
            edgeObjectiveRouteAssistFrames = 0
            edgeObjectiveRouteAssistDirection = nil
        }
        if edgeObjectiveRouteAssistFrames > 0,
           analysis.edgeObjectiveVisible,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            if let currentRoute = analysis.questRouteDirection {
                edgeObjectiveRouteAssistDirection = currentRoute
            }
            if let route = edgeObjectiveRouteAssistDirection {
                edgeObjectiveRouteAssistFrames -= 1
                consecutiveStaticSceneDecisions = 0
                return .swipe(
                    directionX: route.x,
                    directionY: route.y,
                    duration: 0.52,
                    reason: "A piros peremcél közvetlen útja zárt; a türkiz sínt 12 lépéses kerülőként követem, a célzár megmarad"
                )
            }
        } else if !analysis.edgeObjectiveVisible {
            edgeObjectiveRouteAssistFrames = 0
            edgeObjectiveRouteAssistDirection = nil
        }

        if orangeEnemyEntryRouteFrames == 0,
           orangeBoundaryGateRecoveryFrames == 0,
           alternateGreenEnemyRouteFrames == 0,
           protectedFreeExploreFrames == 0,
           staticSceneEscapeFrames > 0,
           let escape = staticSceneEscapeDirection {
            if priorityHeartTreeVisible || (analysis.target?.distance ?? .infinity) <= 180 {
                // Hosszú fal mentén haladva közben új farmcél kerülhet elérhető
                // közelségbe. Ilyenkor a faljárás már elérte a célját, nem szabad
                // a teljes tartalék szakaszt vakon végigfuttatni.
                staticSceneEscapeFrames = 0
                staticSceneEscapeDirection = nil
            } else if consecutiveStaticSceneDecisions >= 3 {
                // A hosszú, ismert navigációs vektor melletti faljárás csak akkor
                // ér valamit, ha közben ténylegesen mozog a kamera. Az Island 4
                // hídsarkában ugyanazt a rossz átlót tíz swipe-ig tartottuk, noha
                // már három után bizonyított volt, hogy a karakter be van ékelődve.
                // A lentebbi indítóág rögtön a következő négyátlós fázist választja;
                // mozgó háttérnél ez az ág nem fut le, így a hosszú falak menti
                // tízlépéses haladás változatlanul megmarad.
                staticSceneEscapeFrames = 0
                staticSceneEscapeDirection = nil
                failedStaticEscapePhases += 1
                staticSceneEscapeSawMovement = false
                consecutiveStaticSceneDecisions = 6
            } else {
                staticSceneEscapeFrames -= 1
                if staticSceneEscapeFrames == 0 {
                    staticSceneEscapeDirection = nil
                    if staticSceneEscapeSawMovement && !preserveStaticFailureEvidence {
                        failedStaticEscapePhases = 0
                    } else {
                        failedStaticEscapePhases += 1
                    }
                    staticSceneEscapeSawMovement = false
                }
                return .swipe(
                    directionX: escape.x,
                    directionY: escape.y,
                    duration: 0.70,
                    reason: "A falmenti kerülőt tartom; veszély és közeli farmcél minden képen megszakíthatja"
                )
            }
        }
        let hasNoImmediateCombatTarget = !priorityHeartTreeVisible &&
            (analysis.target == nil ||
                (effectiveQuestRouteDirection != nil && (analysis.target?.distance ?? .infinity) > 110))
        if orangeEnemyEntryRouteFrames == 0,
           orangeBoundaryGateRecoveryFrames == 0,
           alternateGreenEnemyRouteFrames == 0,
           hasNoImmediateCombatTarget,
           protectedFreeExploreFrames == 0,
           blockedRouteCooldownFrames == 0,
           (analysis.playerHealthFraction ?? 0) >= 0.90,
           consecutiveStaticSceneDecisions >= 6 {
            if deepMinesGateBossCooldownFrames == 0,
               analysis.edgeObjectiveVisible,
               let route = analysis.questRouteDirection {
                edgeObjectiveRouteAssistFrames = 11
                edgeObjectiveRouteAssistDirection = route
                consecutiveStaticSceneDecisions = 0
                staticSceneEscapeFrames = 0
                staticSceneEscapeDirection = nil
                resetFallbackExploration()
                return .swipe(
                    directionX: route.x,
                    directionY: route.y,
                    duration: 0.52,
                    reason: "A piros peremcél közvetlen útja hat swipe óta zárt; 12 lépéses türkizsín-kerülő indul"
                )
            }
            let escape: Vector2
            if let blockedDirection = preferredNavigationDirection {
                let phase = staticSceneEscapeDirectionIndex % 6
                // Ha a minimap/quest-nyom iránya nem mozdítja a hátteret, az
                // akadály (tipikusan kerítés) mentén induljunk el. A következő
                // elakadásnál a másik oldalát próbáljuk, így nem ismétlünk két
                // északi átlót egy vízszintes kerítésnek nyomódva.
                if analysis.orangeRockBiomeVisible {
                    // Az Island 4 narancsszikla kiugró peremén a tiszta jobb
                    // és bal mozgás is statikus maradt, amikor a minimap már
                    // felfelé mutatott. Nemcsak a balra-zárt minimapesetben,
                    // hanem bármely látható Island 4-falnál együtt tartunk
                    // falmenti és előre mutató összetevőt: így a két oldalpróba
                    // jobbra-fel, majd balra-fel átló, nem ugyanazon vízszintes
                    // tengely végtelen váltogatása.
                    // A felfelé mutató minimapnál a konkrét szikla–kaktusz
                    // zseb nyílása balra-le volt. Négy átlót járunk be, nem
                    // ugyanannak a tengelynek két oldalát: balra-le, balra-fel,
                    // jobbra-fel, jobbra-le. Más falirányra ugyanez a sorrend
                    // az adott vektorhoz képest forgatva érvényes.
                    if phase < 4 {
                        let sideSign = [-1.0, -1.0, 1.0, 1.0][phase]
                        let forwardSign = [-1.0, 1.0, 1.0, -1.0][phase]
                        let perpendicular = Vector2(
                            x: -blockedDirection.y * sideSign,
                            y: blockedDirection.x * sideSign
                        )
                        escape = Vector2(
                            x: perpendicular.x + blockedDirection.x * 0.55 * forwardSign,
                            y: perpendicular.y + blockedDirection.y * 0.55 * forwardSign
                        ).normalized
                    } else if phase == 4 {
                        escape = Vector2(x: -blockedDirection.x, y: -blockedDirection.y).normalized
                    } else {
                        escape = blockedDirection.normalized
                    }
                } else {
                    // Zöld területen is lehet L-alakú sátor-/kerítéssarok. A
                    // puszta bal/jobb merőleges váltás ugyanabba a zsebbe
                    // vitte vissza a karaktert (`031220-play`). Ugyanazt a
                    // négy oldalsó-előre/hátra kombinációt használjuk, mint a
                    // narancssziklánál; a sorozat a blokkolt vektorhoz képest
                    // bal-hátra, bal-előre, jobb-előre, jobb-hátra. A híd–fa
                    // zseb mind a négyet körbeismételte, miközben a kijárat a
                    // blokkolt irány pontos ellentéte volt; ezért ötödik és
                    // hatodik fázisként az ellenirányt és az eredeti irányt is
                    // közvetlenül kipróbáljuk.
                    if phase < 4 {
                        let sideSign = [-1.0, -1.0, 1.0, 1.0][phase]
                        let forwardSign = [-1.0, 1.0, 1.0, -1.0][phase]
                        let perpendicular = Vector2(
                            x: -blockedDirection.y * sideSign,
                            y: blockedDirection.x * sideSign
                        )
                        escape = Vector2(
                            x: perpendicular.x + blockedDirection.x * 0.55 * forwardSign,
                            y: perpendicular.y + blockedDirection.y * 0.55 * forwardSign
                        ).normalized
                    } else if phase == 4 {
                        escape = Vector2(x: -blockedDirection.x, y: -blockedDirection.y).normalized
                    } else {
                        escape = blockedDirection.normalized
                    }
                }
                staticSceneEscapeDirectionIndex = (staticSceneEscapeDirectionIndex + 1) % 6
                if phase == 4 {
                    // A híd–fa zsebnél a közvetlen ellenirány bizonyítottan
                    // kijuttatta a karaktert a rámpáról, az ezt követő eredeti
                    // irány viszont pontosan visszavitte. Az ellenirányú szakasz
                    // alatt ezért lezárjuk a hibás navigációs vektort. Amikor a
                    // szakasz új akadálynál (például sátornál) véget ér, a lenti
                    // hűtőlogika oldalirányú-kifelé kerüléssel folytatja, nem a
                    // hatodik fázis visszafordításával.
                    blockedRouteDirection = blockedDirection
                    blockedRouteCooldownFrames = 120
                    blockedRouteBypassPhaseSteps = 0
                    blockedRouteBypassSawMovement = false
                    staticSceneEscapeDirectionIndex = 0
                }
            } else {
                let directions = [
                    Vector2(x: -1, y: -1).normalized,
                    Vector2(x: 1, y: -1).normalized,
                    Vector2(x: -1, y: 1).normalized,
                    Vector2(x: 1, y: 1).normalized
                ]
                escape = directions[staticSceneEscapeDirectionIndex % directions.count]
                staticSceneEscapeDirectionIndex = (staticSceneEscapeDirectionIndex + 1) % directions.count
            }
            staticSceneEscapeDirection = escape
            staticSceneEscapeSawMovement = false
            // Vak irányban négy tényleges swipe elég. Bizonyított minimap-/sínvektor
            // mellett hosszabb fal végét kell megtalálni: a zöld udvarban a négyes
            // szakasz két oldalváltás után is ugyanoda tért vissza. A tízes szakasz
            // most megszakítható: a visszavonulás és a hatswipe-os bossmemória e
            // blokk előtt fut, 180 px-en belüli farmcél pedig közvetlenül megszakítja.
            staticSceneEscapeFrames = preferredNavigationDirection == nil ? 3 : 9
            consecutiveStaticSceneDecisions = 0
            resetFallbackExploration()
            return .swipe(
                directionX: escape.x,
                directionY: escape.y,
                duration: 0.70,
                reason: preferredNavigationDirection != nil
                    ? "Hat végrehajtott swipe után változatlan háttér; merőleges akadálykerülés indul (sikertelen fázisok: \(failedStaticEscapePhases))"
                    : "Hat végrehajtott swipe után változatlan háttér; átlós kiszabadulás indul (sikertelen fázisok: \(failedStaticEscapePhases))"
            )
        }

        if let chestDirection = analysis.worldChestDirection,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A képen ténylegesen látható, biztonságosan azonosított láda
            // értékesebb a minimap ismeretlen piros pontjánál. Ha az út elakad,
            // a fenti statikus háttérőr ugyanezt az irányt használja faljáráshoz;
            // boss és friss sebzés továbbra is minden ládakeresést megelőz.
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastPursuitDirection = nil
            lostTargetFrames = 0
            stagnantApproachFrames = 0
            return .swipe(
                directionX: chestDirection.x,
                directionY: chestDirection.y,
                duration: 0.50,
                reason: "Látható fénylő helyszíni láda megközelítése"
            )
        }

        if analysis.target == nil {
            consecutiveNoSafeTargetDecisions += 1
        } else {
            consecutiveNoSafeTargetDecisions = 0
        }
        if !mailInspectionCompleted,
           consecutiveNoSafeTargetDecisions >= 24,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            mailInspectionMode = true
            mailInspectionStage = 1
            consecutiveNoSafeTargetDecisions = 0
            return .tap(
                x: Double(analysis.width) * 0.136,
                y: Double(analysis.height) * 0.077,
                reason: "Tartós célhiány; a piros jelzésű boríték egyszeri, csak olvasási célú megnyitása"
            )
        }
        if !equipmentInspectionCompleted,
           consecutiveNoSafeTargetDecisions >= 24,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            equipmentInspectionMode = true
            consecutiveNoSafeTargetDecisions = 0
            return .tap(
                x: Double(analysis.width) * 0.948,
                y: Double(analysis.height) * 0.585,
                reason: "Tartós célhiány; a piros jelzésű felszerelésláda egyszeri, csak olvasási célú megnyitása"
            )
        }

        // A cél rövid eltűnése vagy egy másik csík felvillanása nem szakíthatja
        // meg az akadály menti mozgást. A korábbi háromlépéses kerülőt a célzár
        // rendszeresen lenullázta, ezért a bot az Island 4 zárt kerítésénél
        // ugyanabba a megközelítés–visszacsúszás hurokba került.
        if blockedAreaEscapeFrames > 0, let escape = blockedAreaEscapeDirection {
            blockedAreaEscapeFrames -= 1
            if blockedAreaEscapeFrames == 0 {
                lastTargetBarWidth = nil
                lastTargetX = nil
                lastTargetY = nil
                lastTargetDistance = nil
                lastPursuitDirection = nil
                lostTargetFrames = 0
                lastTargetDisplayedHP = nil
                lastTargetWasVerifiedTree = false
                lastTargetWasVerifiedWeaponCarrier = false
                engagedVerifiedTree = false
                stagnantApproachFrames = 0
                failedApproachCycles = 0
                failedMinimapDetourCycles = 0
            }
            return .swipe(
                directionX: escape.x,
                directionY: escape.y,
                duration: 0.56,
                reason: "Ismételten elérhetetlen célterület; hosszú kiszakadás a kerítéstől"
            )
        }
        if persistentDetourFrames > 0, let detour = persistentDetourDirection {
            persistentDetourFrames -= 1
            let isWeaponCarrierReturnLeg = lastTargetWasVerifiedWeaponCarrier
                && weaponCarrierCornerTurnFrames == 0
            return .swipe(
                directionX: detour.x,
                directionY: detour.y,
                duration: 0.48,
                reason: isWeaponCarrierReturnLeg
                    ? "A hordozó kerítését kívülről megkerültem; jobbra visszatérek a bekerített területre"
                    : "Tartós akadálykövetés; a felvillanó célok nem szakítják meg a kerülőt"
            )
        }

        // A jobb oldali próbát tizenkét swipe-on át a torony–hordó sarok teljesen
        // statikusan blokkolta. A bal oldal ezzel szemben bizonyítottan elérte a
        // kerítés sarkát. A cél járőrözése nem bizonyít játékosmozgást, ezért a
        // bal oldali szakasz után cél-láthatóságtól függetlenül végrehajtjuk a
        // megtanult befordulást. Az élő 101003-as futásban a tizenkét lépéses
        // függőleges szakasz a Deep Mines őreihez vezetett; a 103900-as futásban
        // már a negyedik ilyen swipe előtt megjelent az 1.22K-s őr. A sarok viszont
        // 7–8 bal swipe után elérhető volt. A 104751-es futás megmutatta, hogy a
        // háromlépéses felső szakasz túl rövid: a jobbra visszatérés a függőleges
        // palánknak ment. Ezért nyolc északi lépést tartunk; a fenti szűk kivétel
        // a távoli 1.22K-s őrnél jobbra-felfelé ferdíti ezt a szakaszt. Sebzés,
        // közeli őr vagy nagyobb boss továbbra is megszakítja a rögzített utat.
        if weaponCarrierCornerTurnFrames > 0,
           let turn = weaponCarrierCornerTurnDirection {
            weaponCarrierCornerTurnFrames -= 1
            if weaponCarrierCornerTurnFrames == 0 {
                weaponCarrierCornerTurnDirection = nil
                if let outward = persistentDetourDirection {
                    persistentDetourDirection = Vector2(x: -outward.x, y: -outward.y)
                    persistentDetourFrames = 8
                }
                // Ha a hordozó a teljes befordulás alatt takarásban maradt,
                // ugyanazt az irányt ne tartsuk még extra lépésekig.
                lostTargetFrames = 12
            }
            return .swipe(
                directionX: turn.x,
                directionY: turn.y,
                duration: 0.34,
                reason: "A hordozó bal oldali kerületsarka után a kerítés külső oldalán haladok"
            )
        }

        // A 291 HP-s, alacsony hozamú fa többször ugyanahhoz az Island 4-falhoz
        // húzta vissza a botot, miután két teljes kerülő már bizonyította, hogy
        // az adott célterület elérhetetlen. A helykoordináta kameraalapú, de a
        // HP és a fás test együtt elég stabil rövid cél-aláírás. A magas hozamú
        // szívfa-prioritás nem kerülhet ide: az feljebb minden hűtést töröl.
        if unreachableTargetCooldownFrames > 0 {
            unreachableTargetCooldownFrames -= 1
            if unreachableTargetCooldownFrames == 0 {
                unreachableTargetDisplayedHP = nil
                unreachableTargetWasTree = false
                unreachableTargetSceneFingerprint = nil
            }
        }
        let sameUnreachableTargetContext: Bool
        if let blockedScene = unreachableTargetSceneFingerprint,
           blockedScene.count == analysis.sceneFingerprint.count {
            let sceneDifference = zip(blockedScene, analysis.sceneFingerprint).reduce(0) {
                $0 + abs($1.0 - $1.1)
            }
            // A fal előtti 291-es célképek 0–22 eltérésűek voltak, a hosszú
            // kiszakadás első átmeneti képei legfeljebb 42-esek. Az ugyanazon fa
            // másik, járható megközelítése 45-ös eltérést adott, majd együtéses
            // +1 fejszejutalmat. A 44-es kapu ezért a rossz falnézetet hűti, nem
            // magát az entitást tiltja globálisan.
            sameUnreachableTargetContext = sceneDifference <= 44
        } else {
            sameUnreachableTargetContext = false
        }
        let matchingUnreachableTarget = analysis.target.map { target in
            guard !priorityHeartTreeVisible,
                  unreachableTargetCooldownFrames > 0,
                  sameUnreachableTargetContext,
                  let blockedHP = unreachableTargetDisplayedHP,
                  let currentHP = target.displayedHP else { return false }
            return abs(currentHP - blockedHP) <= 20 &&
                unreachableTargetWasTree == (target.treeConfidence >= 0.25)
        } ?? false
        if unreachableTargetCooldownFrames > 0,
           !priorityHeartTreeVisible,
           effectiveQuestRouteDirection == nil,
           sameUnreachableTargetContext,
           (analysis.target == nil || matchingUnreachableTarget) {
            // A 291 HP-s, fal mögötti fa nemcsak a főképen húzta vissza a
            // karaktert: eltűnése után a hozzá tartozó piros minimappont nagyobb
            // körben újra ugyanoda vezette. Az aktív célaláírás alatt ezért a
            // piros minimapjelet is elnémítjuk. Új, másik látható cél vagy
            // küldetéssín továbbra is azonnal átveheti a prioritást; ezek hiányában
            // a növekvő négyzetspirál ténylegesen új területet fed fel.
            blockedRouteCooldownFrames = 0
            blockedRouteDirection = nil
            blockedRouteBypassPhaseSteps = 0
            blockedRouteBypassSawMovement = false
            if matchingUnreachableTarget {
                lastTargetBarWidth = nil
                lastTargetX = nil
                lastTargetY = nil
                lastTargetDistance = nil
                lastPursuitDirection = nil
                lostTargetFrames = 0
                lastTargetDisplayedHP = nil
                lastTargetWasVerifiedTree = false
                lastTargetWasVerifiedWeaponCarrier = false
                engagedVerifiedTree = false
                stagnantApproachFrames = 0
                failedApproachCycles = 0
            }
            return fallbackExplorationDecision(
                analysis,
                reason: "Elérhetetlen cél aktív hűtése; a hozzá tartozó minimapjel helyett növekvő területfelderítés"
            )
        }
        if matchingUnreachableTarget,
           blockedRouteCooldownFrames == 0,
           let target = analysis.target {
            let direction = Vector2(
                x: target.x - Double(analysis.width) * 0.5,
                y: target.y - Double(analysis.height) * 0.515
            ).normalized
            blockedRouteDirection = direction
            blockedRouteCooldownFrames = 120
            blockedRouteBypassSign *= -1
            blockedRouteBypassPhaseSteps = 1
            blockedRouteBypassSawMovement = false
            let perpendicular = Vector2(
                x: -direction.y * blockedRouteBypassSign,
                y: direction.x * blockedRouteBypassSign
            )
            let bypass = Vector2(
                x: perpendicular.x - direction.x * 0.55,
                y: perpendicular.y - direction.y * 0.55
            ).normalized
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastPursuitDirection = nil
            lostTargetFrames = 0
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            stagnantApproachFrames = 0
            failedApproachCycles = 0
            return .swipe(
                directionX: bypass.x,
                directionY: bypass.y,
                duration: 0.52,
                reason: "Korábban elérhetetlen cél-aláírás; új üldözés helyett oldalirányú felderítés"
            )
        }

        // A zöld landmark korábban elvezetett a 499 HP-s fegyverhordozóhoz, de
        // a helyi készlet kiürülése után ugyanaz a jel 16–18 órás és 15–18
        // perces cooldownkörök között tartotta a botot, jutalom nélkül. Ha már
        // 150 döntés óta nincs progressz, piros cél vagy quest-sín, ideiglenesen
        // a növekvő szabad spirál győz a zöld landmark felett. A közös cooldown
        // megakadályozza, hogy a mód lejártakor azonnal újrainduljon.
        if island4DroughtEscapeFrames == 0,
           island4DroughtEscapeCooldownFrames == 0,
           protectedFreeExploreFrames == 0,
           titanAltarExploredCooldownFrames == 0,
           decisionsSinceProgress >= 150,
           effectiveQuestRouteDirection == nil,
           effectiveExplorationDirection == nil,
           analysis.worldChestDirection == nil,
           analysis.target == nil,
           analysis.landmarkDirection != nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            protectedFreeExploreFrames = 160
            island4DroughtEscapeCooldownFrames = 360
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            minimapDetourFrames = 0
            stagnantMinimapFrames = 0
            resetFallbackExploration()
        }

        // A korábbi, erősen balra mutató piros vektorhoz kötött "Island 4
        // zárút"-területelhagyást eltávolítottuk. Az UNLOCKS felirat fegyverhely-
        // HUD, a piros jel pedig a Dusty Gulch elérhető céljaihoz is vezethet.
        // Valódi elakadást a képi statikusság és az általános faljárás kezel.
        if protectedFreeExploreFrames > 0 {
            let interrupted = analysis.target != nil ||
                effectiveQuestRouteDirection != nil ||
                analysis.worldChestDirection != nil ||
                analysis.edgeObjectiveVisible
            if interrupted {
                protectedFreeExploreFrames = 0
            } else {
                var freeExploreReason = "Védett szabad területfelderítés: a visszahúzó minimapjel helyett új helyi útvonalat keresek"
                if let special = effectiveSpecialLandmarkDirection {
                    protectedFreeExploreFrames -= 1
                    if consecutiveStaticSceneDecisions >= 3 {
                        consecutiveStaticSceneDecisions = 0
                        let bypass = Vector2(
                            x: -special.y - special.x * 0.35,
                            y: special.x - special.y * 0.35
                        ).normalized
                        return .swipe(
                            directionX: bypass.x,
                            directionY: bypass.y,
                            duration: 0.56,
                            reason: "A különleges lila minimaphely útjában akadály van; oldalról közelítem"
                        )
                    }
                    return .swipe(
                        directionX: special.x,
                        directionY: special.y,
                        duration: 0.52,
                        reason: "A vak spirál helyett a különleges lila minimaphely felderítése"
                    )
                }
                if consecutiveStaticSceneDecisions >= 3 {
                    // A védett szabad mód szándékosan nem indítja el a teljes
                    // statikus faljárást, mert az korábban visszarántotta a botot
                    // ugyanabba a zárútba. A hosszúra nőtt spirálszárat viszont
                    // nem tarthatjuk több tucat swipe-on át egy kerítésnek. Három
                    // változatlan háttér után helyben negyed fordulatot teszünk és
                    // rövid oldalszakaszt próbálunk; a védett mód ettől megmarad.
                    consecutiveStaticSceneDecisions = 0
                    exploreDirectionIndex = (exploreDirectionIndex + 1) % 4
                    exploreLegStepsRemaining = min(12, max(4, exploreLegLength / 2))
                    freeExploreReason = "Védett szabad felderítés közben három statikus swipe; negyedfordulatos oldalkitérés"
                }
                protectedFreeExploreFrames -= 1
                return fallbackExplorationDecision(
                    analysis,
                    reason: freeExploreReason
                )
            }
        }

        // A kiszakadás önmagában nem elég, ha a minimap rögtön ugyanahhoz a
        // lezárt célhoz fordít vissza. A bizonyítottan elakadt világirányt
        // ideiglenesen oldalirányú felderítéssel kerüljük. Egy legalább kb.
        // 63 fokkal eltérő új célirány azonnal feloldja a hűtést.
        if blockedRouteCooldownFrames > 0, let blocked = blockedRouteDirection {
            let proposedDirection: Vector2? = effectiveQuestRouteDirection ?? analysis.target.map { target in
                Vector2(
                    x: target.x - Double(analysis.width) * 0.5,
                    y: target.y - Double(analysis.height) * 0.515
                ).normalized
            } ?? preferredNavigationDirection
            if let proposedDirection {
                let alignment = blocked.x * proposedDirection.x + blocked.y * proposedDirection.y
                if alignment >= 0.45 {
                    blockedRouteCooldownFrames -= 1
                    let perpendicular = Vector2(
                        x: -blocked.y * blockedRouteBypassSign,
                        y: blocked.x * blockedRouteBypassSign
                    )
                    // A tisztán merőleges déli vektor 12 swipe-on át sem
                    // mozdította le a karaktert a narancs/zöld határszikláról,
                    // az északi oldal pedig bossba vitt. A fal menti komponens
                    // mellé kifelé, a lezárt iránnyal ellentétesen is lépünk:
                    // előbb lekerülünk a falról, aztán tudunk mellette haladni.
                    let bypass = Vector2(
                        x: perpendicular.x - blocked.x * 0.55,
                        y: perpendicular.y - blocked.y * 0.55
                    ).normalized
                    if consecutiveStaticSceneDecisions == 0 {
                        blockedRouteBypassSawMovement = true
                    }
                    blockedRouteBypassPhaseSteps += 1
                    if blockedRouteBypassPhaseSteps >= 12 {
                        blockedRouteBypassPhaseSteps = 0
                        if blockedRouteBypassSawMovement {
                            // A délkeleti hűtőszakasz élőben már lehozta a
                            // karaktert a szikláról és nyílt terepre vitte. Sikeres
                            // kameramozgás után ne forduljunk automatikusan vissza:
                            // oldjuk a hűtést, és a következő kép tervezzen újra.
                            blockedRouteCooldownFrames = 0
                            blockedRouteDirection = nil
                            consecutiveStaticSceneDecisions = 0
                        } else {
                            blockedRouteBypassSign *= -1
                        }
                        blockedRouteBypassSawMovement = false
                    }
                    return .swipe(
                        directionX: bypass.x,
                        directionY: bypass.y,
                        duration: 0.52,
                        reason: "Hűtőlistás lezárt minimap-irány; oldalirányú felderítés"
                    )
                }
                blockedRouteCooldownFrames = 0
                blockedRouteDirection = nil
                blockedRouteBypassPhaseSteps = 0
                blockedRouteBypassSawMovement = false
            } else {
                blockedRouteCooldownFrames -= 1
            }
        }

        // A 074813-as élő futásban egy 10-szíves, 174 HP-s fa 224→203
        // pixelre közeledett, majd egyetlen célfelismerési résnél a türkiz sín
        // azonnal törölte a célmemóriát, noha a fa még tisztán a képen volt.
        // A már igazolt, 300 pixelen belüli passzív szívfát ugyanazzal a rövid
        // háromdöntéses memóriával védjük a quest-sín ellen is. A boss- és
        // sebzésőrök e blokk előtt futnak, ezért veszélyben nem tart vissza.
        let recentPriorityHeartTreeMemory = lastTargetWasVerifiedTree &&
            (lastTargetDistance ?? .infinity) <= 300 &&
            lostTargetFrames < 3
        if let questRoute = effectiveQuestRouteDirection,
           (analysis.playerHealthFraction ?? 0) >= 0.90,
           !priorityHeartTreeVisible,
           !recentPriorityHeartTreeMemory,
           (analysis.target?.distance ?? .infinity) > 110 {
            // Távoli farmcsík nem térítheti le a játékost a képen ténylegesen
            // látható történeti útvonalról. Közeli/megkezdett harcot továbbra
            // is befejezünk, a boss- és visszavonulási őrök pedig korábban futnak.
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            lastPursuitDirection = nil
            lostTargetFrames = 0
            stagnantApproachFrames = 0
            resetFallbackExploration()
            return .swipe(
                directionX: questRoute.x,
                directionY: questRoute.y,
                duration: 0.52,
                reason: "A látható türkiz Deep Mines küldetésútvonal követése"
            )
        }

        let blockedExhaustedHighlandTarget = analysis.target.map { target in
            let direction = Vector2(
                x: target.x - Double(analysis.width) * 0.5,
                y: target.y - Double(analysis.height) * 0.515
            ).normalized
            return elevationSeparatedBossCooldownFrames > 0 &&
                direction.x < -0.45 && direction.y < -0.15
        } ?? false
        if blockedExhaustedHighlandTarget {
            closeTargetFrames = 0
            lastTargetBarWidth = nil
            lastTargetX = nil
            lastTargetY = nil
            lastTargetDistance = nil
            lastPursuitDirection = nil
            lostTargetFrames = 0
            lastTargetDisplayedHP = nil
            lastTargetWasVerifiedTree = false
            lastTargetWasVerifiedWeaponCarrier = false
            engagedVerifiedTree = false
            stagnantApproachFrames = 0
            detourFrames = 0
        }

        if let target = analysis.target, !blockedExhaustedHighlandTarget {
            resetFallbackExploration()
            let sameTargetByPosition: Bool
            if let lastX = lastTargetX, let lastY = lastTargetY {
                sameTargetByPosition = hypot(target.x - lastX, target.y - lastY) < 85
            } else {
                sameTargetByPosition = false
            }
            let sameTargetByAppearance = lastTargetDisplayedHP.flatMap { previousHP in
                target.displayedHP.map { currentHP in
                    abs(currentHP - previousHP) <= 40 &&
                        lastTargetWasVerifiedTree == (target.treeConfidence >= 0.25)
                }
            } ?? false
            let sameTarget = sameTargetByPosition || sameTargetByAppearance

            // Két egyszerre látható cél költsége a kamera mozgásával felváltva
            // lehet a legjobb. Rövid ideig mégis az előző cél irányát tartjuk:
            // ez megakadályozza, hogy az egymással ellentétes swipe-ok kioltsák
            // egymást. Azonos HP/testtípus nagy kameraelmozdulásnál is azonosító.
            if !sameTarget,
               let lockedDirection = lastPursuitDirection,
               let lockedDistance = lastTargetDistance,
               lostTargetFrames < 3 {
                lostTargetFrames += 1
                if lockedDistance <= 92 {
                    return .wait(reason: "A kiválasztott közeli cél röviden takart; másik jelöltre még nem váltok")
                }
                return .swipe(
                    directionX: lockedDirection.x,
                    directionY: lockedDirection.y,
                    duration: 0.25,
                    reason: "Célzár: a régi cél irányát tartom, a felvillanó másik jelöltet még nem veszem át"
                )
            }
            lostTargetFrames = 0
            let previousTargetDisplayedHP = lastTargetDisplayedHP
            let barDamageDetected = sameTarget &&
                (lastTargetBarWidth.map { target.bar.width <= $0 - 4 } ?? false)
            let numericDamageDetected = sameTarget &&
                (previousTargetDisplayedHP.flatMap { previousHP in
                    target.displayedHP.map { $0 <= previousHP - 5 }
                } ?? false)
            let damageDetected = barDamageDetected || numericDamageDetected
            if !sameTarget {
                closeTargetFrames = 0
                stagnantApproachFrames = 0
                detourFrames = 0
                lastTargetDistance = nil
                lastTargetDisplayedHP = nil
                lastTargetWasVerifiedTree = false
                lastTargetWasVerifiedWeaponCarrier = false
                engagedVerifiedTree = false
            }
            lastTargetBarWidth = target.bar.width
            lastTargetX = target.x
            lastTargetY = target.y
            if let displayedHP = target.displayedHP {
                lastTargetDisplayedHP = displayedHP
            }
            let targetIsVerifiedWeaponCarrier = target.weaponDropIconEvidence >= 0.006 &&
                (target.displayedHP == 499 || lastTargetWasVerifiedWeaponCarrier)
            lastTargetWasVerifiedWeaponCarrier = targetIsVerifiedWeaponCarrier
            if target.treeConfidence >= 0.25 {
                lastTargetWasVerifiedTree = true
            } else {
                lastTargetWasVerifiedTree = false
                engagedVerifiedTree = false
            }
            // A sérülés bizonyítéka a megközelítési küszöbtől független. Ha a
            // felhasználói aktivitási őr alatt 174→145 HP-ra esett a fa, a
            // következő valódi döntés ezt akkor is megőrzi, ha még 86 px-re van.
            if damageDetected, lastTargetWasVerifiedTree {
                engagedVerifiedTree = true
            }

            let direction = Vector2(
                x: target.x - Double(analysis.width) * 0.5,
                y: target.y - Double(analysis.height) * 0.515
            ).normalized
            lastPursuitDirection = direction

            if target.distance > 82 {
                closeTargetFrames = 0
                if let previousDistance = lastTargetDistance, sameTarget,
                   abs(previousDistance - target.distance) < 3.5 {
                    stagnantApproachFrames += 1
                } else if let previousDistance = lastTargetDistance,
                          target.distance < previousDistance - 3.5 {
                    stagnantApproachFrames = 0
                }
                lastTargetDistance = target.distance

                if stagnantApproachFrames >= 4 {
                    stagnantApproachFrames = 0
                    failedApproachCycles += 1
                    if failedApproachCycles >= 2 {
                        let escape = Vector2(x: -direction.x, y: -direction.y).normalized
                        if target.treeConfidence >= 0.25,
                           target.heartIconEvidence < 0.05,
                           let displayedHP = target.displayedHP {
                            unreachableTargetDisplayedHP = displayedHP
                            unreachableTargetWasTree = true
                            unreachableTargetCooldownFrames = 360
                            unreachableTargetSceneFingerprint = analysis.sceneFingerprint
                        }
                        blockedAreaEscapeDirection = escape
                        blockedRouteDirection = direction
                        blockedRouteCooldownFrames = 120
                        blockedRouteBypassSign *= -1
                        blockedRouteBypassPhaseSteps = 0
                        blockedRouteBypassSawMovement = false
                        // Az első mozdulatot most hajtjuk végre; további 17
                        // tényleges döntés elég messz visz a lezárt zónától.
                        blockedAreaEscapeFrames = 17
                        persistentDetourFrames = 0
                        persistentDetourDirection = nil
                        weaponCarrierCornerTurnFrames = 0
                        weaponCarrierCornerTurnDirection = nil
                        return .swipe(
                            directionX: escape.x,
                            directionY: escape.y,
                            duration: 0.56,
                            reason: "A célterület két kerülő után is elérhetetlen; hosszú kiszakadás indul"
                        )
                    }
                    // A 499 HP-s Bat-fegyverhordozó az Island 4 vízszintes
                    // tábori kerítése fölött áll. A bal oldali nyolclépéses
                    // kerülő élőben ugyan kijutott a sarokhoz, de közvetlenül
                    // egy 1.22K HP-s őr aggrókörébe vezetett. A hordozónál ezért
                    // A későbbi jobb oldali élő próba tizenkét swipe-on át sem
                    // mozdította a hátteret a torony–hordó sarok miatt. A bal oldal
                    // viszont bizonyítottan elérte a kerítés végét; ezért ennél a
                    // célaláírásnál nyolc bal oldali swipe után rövid, rögzített
                    // befordulási szakaszt, majd az első szakasszal ellentétes
                    // visszatérő lábat futtatunk: nyolc balra → nyolc felfelé
                    // (a távoli 1.22K-s őrnél jobbra-felfelé) → nyolc jobbra.
                    // Más céloknál megmarad az általános oldalváltás.
                    let detourSign = targetIsVerifiedWeaponCarrier ? -1.0 : nextDetourSign
                    let detour = Vector2(
                        x: -direction.y * detourSign,
                        y: direction.x * detourSign
                    ).normalized
                    if !targetIsVerifiedWeaponCarrier { nextDetourSign *= -1 }
                    persistentDetourDirection = detour
                    if targetIsVerifiedWeaponCarrier {
                        weaponCarrierCornerTurnDirection = direction
                        weaponCarrierCornerTurnFrames = 8
                    }
                    // Az első mozdulat most történik. Az általános céloknál a
                    // következő hét, a hordozónál szintén a következő hét döntés
                    // célazonosságtól függetlenül ugyanebbe az irányba tart.
                    persistentDetourFrames = 7
                    return .swipe(
                        directionX: detour.x,
                        directionY: detour.y,
                        duration: 0.48,
                        reason: targetIsVerifiedWeaponCarrier
                            ? "A 499 HP-s hordozó kerítése elzárja az utat; nyolclépéses bal oldali kerülő indul"
                            : "Elakadás észlelve; nyolclépéses tartós akadálykövetés indul"
                    )
                }
                let duration = min(0.60, max(0.22, (target.distance - 85) / 360))
                return .swipe(
                    directionX: direction.x,
                    directionY: direction.y,
                    duration: duration,
                    reason: String(format: "Legközelebbi HP-csík megközelítése (táv %.0f px)", target.distance)
                )
            }

            lastTargetDistance = target.distance
            stagnantApproachFrames = 0
            detourFrames = 0
            failedApproachCycles = 0
            failedMinimapDetourCycles = 0

            if damageDetected {
                closeTargetFrames = 0
                return .wait(reason: "Sebzés észlelve a célpont HP-csíkján; az automata támadás aktív")
            }

            closeTargetFrames += 1
            let contactObservationLimit=CloseContactPolicy.observationLimit(
                treeConfidence:target.treeConfidence,hp:target.displayedHP,
                nearbyThreats:analysis.nearbyThreatCount,health:analysis.playerHealthFraction ?? 0)
            if closeTargetFrames >= contactObservationLimit {
                closeTargetFrames = 0
                return .swipe(
                    directionX: direction.x,
                    directionY: direction.y,
                    duration: 0.18,
                    reason: "Finom közelítés: az automata támadás még nem zárta le a célpontot"
                )
            }
            return .wait(reason: "Támadási távolság: az automata harcot figyelem")
        }

        if let lastDirection = lastPursuitDirection,
           let lastDistance = lastTargetDistance {
            let lostLimit: Int
            if lastDistance <= 92, engagedVerifiedTree {
                // A játékos teste és a találati animáció hosszabb időre is
                // eltakarhatja egy nagy HP-jú fa csíkját. A fa nem üt vissza,
                // ezért itt olcsóbb kivárni a becsült hátralévő ütéseket, mint
                // félbehagyni a már megkezdett támadóerő-jutalmat.
                let estimatedHits = Int(ceil(Double(lastTargetDisplayedHP ?? 100) / 25.0))
                lostLimit = min(36, max(8, estimatedHits * 3 + 3))
            } else if lastTargetWasVerifiedWeaponCarrier {
                // A hosszú oldaljárás alatt a hordozó természetesen kicsúszik
                // a képből. A sarok után még elég ideig tartjuk a legutóbbi,
                // kerítésen át a tábor belsejébe mutató irányt ahhoz, hogy a
                // cél újra megjelenjen. A boss-őrök e blokk előtt futnak.
                lostLimit = 12
            } else {
                lostLimit = 3
            }
            if lostTargetFrames < lostLimit {
                lostTargetFrames += 1
                if lastDistance <= 92 {
                    let reason = engagedVerifiedTree
                        ? "A sebzett, passzív fa csíkja takart; az automata támadás befejezésére várok"
                        : "A közeli cél HP-csíkja eltűnt; támadás/jutalom megfigyelése"
                    return .wait(reason: reason)
                }
                return .swipe(
                    directionX: lastDirection.x,
                    directionY: lastDirection.y,
                    duration: 0.25,
                    reason: "A cél ideiglenesen eltűnt; rövid folytatás az utolsó ismert irányba"
                )
            }
        }

        closeTargetFrames = 0
        lastTargetBarWidth = nil
        lastTargetX = nil
        lastTargetY = nil
        lastTargetDistance = nil
        lastPursuitDirection = nil
        lostTargetFrames = 0
        lastTargetDisplayedHP = nil
        lastTargetWasVerifiedTree = false
        lastTargetWasVerifiedWeaponCarrier = false
        engagedVerifiedTree = false
        stagnantApproachFrames = 0
        detourFrames = 0
        if analysis.orangeRockCoverage >= 0.68 {
            // A narancssárga oldal elérése maga a bizonyíték arra, hogy a
            // határátjárót megtaláltuk. Ettől a pillanattól a képi cél- és
            // harclogika vegye át az irányítást, ne tartson tovább a belépő láb.
            orangeEnemyEntryRouteFrames = 0
            orangeBoundaryGateRecoveryFrames = 0
            island2CentralApproachRouteFrames = 0
        }
        if island2CentralApproachRouteFrames == 0,
           !island2CentralApproachRouteAttempted,
           !hasReachedIsland2ThisProcess,
           analysis.orangeRockCoverage < 0.15,
           analysis.edgeObjectiveVisible,
           let island2Target = effectiveExplorationDirection,
           island2Target.x < -0.65,
           island2Target.y < -0.35,
           let titanDirection = effectiveSpecialLandmarkDirection,
           titanDirection.x > 0.90,
           abs(titanDirection.y) < 0.22,
           analysis.target == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A `235857-play/105` és a `001339-play/106` ugyanazt a köztes
            // térképpontot adta: Island 2 északnyugatra, a Titan-jel csaknem
            // pontosan keletre. A sikeres történeti futás innen 18 NW lépéssel
            // ért a hajóroncsos koponyatáborhoz; az ottani helyben futó kitérők
            // után nyolc SW lépés vitte át a Dusty Gulch - 2 kapun. A két mért
            // lábat most közvetlen, ismételhető útvonallá vonjuk össze.
            island2CentralApproachRouteAttempted = true
            island2CentralApproachRouteFrames = 28
            orangeEnemyEntryRouteAttempted = true
            orangeEnemyEntryRouteFrames = 0
            orangeBoundaryGateRecoveryAttempted = true
            orangeBoundaryGateRecoveryFrames = 0
            resetFallbackExploration()
        }
        if island2CentralApproachRouteFrames > 0,
           analysis.orangeRockCoverage < 0.68,
           analysis.target == nil,
           effectiveQuestRouteDirection == nil,
           analysis.worldChestDirection == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            let direction: Vector2
            let phase: String
            if island2CentralApproachRouteFrames > 10 {
                direction = Vector2(x: -0.75, y: -0.66).normalized
                phase = "észanyugati menet a hajóroncsos koponyatáborhoz"
            } else {
                direction = Vector2(x: -0.71, y: 0.71).normalized
                phase = "délnyugati kapuátlépés Dusty Gulch - 2-be"
            }
            island2CentralApproachRouteFrames -= 1
            return .swipe(
                directionX: direction.x,
                directionY: direction.y,
                duration: 0.62,
                reason: "Island 2 bizonyított köztes kapu: \(phase)"
            )
        }
        if orangeEnemyEntryRouteFrames == 0,
           !orangeEnemyEntryRouteAttempted,
           !hasReachedIsland2ThisProcess,
           analysis.orangeRockCoverage < 0.68,
           (analysis.innerMapEnemyVisible || analysis.edgeObjectiveVisible),
           let orangeTarget = effectiveExplorationDirection,
           orangeTarget.x < -0.55,
           orangeTarget.y < -0.15,
           let orangeGateTitan = effectiveSpecialLandmarkDirection,
           orangeGateTitan.x > 0.75,
           abs(orangeGateTitan.y) < 0.35,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A `205232-play/283` mellől megnyitott nagy térkép szerint a
            // karakter a zöld–narancs határon állt. Az ellenfél északnyugatra
            // látszott, de a közvetlen átló fix sziklafalnak ment. A világoszöld
            // átjárójel ettől nyugat–délnyugatra volt; előbb ehhez tartunk, majd
            // rövid északnyugati lábbal fordulunk rá a narancs területre.
            orangeEnemyEntryRouteAttempted = true
            // A `211939-play` bizonyított szakasza 14 nyugat-délnyugati és
            // 12 tiszta nyugati lépés volt. Az 52-re nyújtott változat a
            // `221934-play/20–59` alatt negyven WSW mozdulattal ugyanabba a
            // fás-sziklás sarokba szorult, ezért visszaállunk a mért 26-ra.
            orangeEnemyEntryRouteFrames = 26
            resetFallbackExploration()
        }
        if orangeEnemyEntryRouteFrames > 0,
           analysis.orangeRockCoverage < 0.68,
           analysis.target == nil,
           effectiveQuestRouteDirection == nil,
           analysis.worldChestDirection == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            consecutiveStaticSceneDecisions = 0
            failedStaticEscapePhases = 0
            staticSceneEscapeFrames = 0
            staticSceneEscapeDirection = nil
            let entryDirection = orangeEnemyEntryRouteFrames > 12
                ? Vector2(x: -0.82, y: 0.57).normalized
                : Vector2(x: -1.0, y: 0.0)
            orangeEnemyEntryRouteFrames -= 1
            return .swipe(
                directionX: entryDirection.x,
                directionY: entryDirection.y,
                duration: 0.58,
                // Szándékosan nem általános "felderítés"/"útvonal" döntés:
                // ezt a nagy térkép konkrét átjárójele alapozza meg, ezért a
                // korábbi, tág képaláíráshoz kötött akadálymemória nem írhatja
                // felül egy másik zöld oldali zsákutca tapasztalatával.
                reason: orangeEnemyEntryRouteFrames >= 12
                    ? "Nagy térképes narancs kapu: nyugat-délnyugati belépőpont"
                    : "Nagy térképes narancs kapu: tiszta nyugati áthaladás Dusty Gulch - 2-be"
            )
        }
        if orangeEnemyEntryRouteFrames == 0,
           orangeEnemyEntryRouteAttempted,
           !orangeBoundaryGateRecoveryAttempted,
           !hasReachedIsland2ThisProcess,
           analysis.orangeRockCoverage < 0.68,
           (analysis.innerMapEnemyVisible || analysis.edgeObjectiveVisible),
           let orangeTarget = effectiveExplorationDirection,
           orangeTarget.x < -0.55,
           orangeTarget.y < -0.15,
           let orangeGateTitan = effectiveSpecialLandmarkDirection,
           orangeGateTitan.x > 0.75,
           abs(orangeGateTitan.y) < 0.35,
           analysis.target == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            // A `222304-play` nagy térképe szerint a játékos a függőleges
            // zöld–narancs fal jobb oldalán áll, a sárga átjárójel pedig
            // délnyugatra van. A diagonális WSW a falnak ütközve nem csúszik
            // végig annak oldalán. Előbb tisztán délre követjük a fix falat,
            // majd a jel magasságában nyugatra fordulunk a nyílásba.
            orangeBoundaryGateRecoveryAttempted = true
            // A biztonságos narancs-talaj érintési ponttal mért új futásban a
            // régi 12 déli lépés még a ferde fakerítés jobb oldalán fordult
            // nyugatra. Húsz lépéssel biztosan a kerítés alsó vége alá érünk,
            // majd húsz nyugati lépés keresztezi az Island 2 átjárót.
            orangeBoundaryGateRecoveryFrames = 40
            resetFallbackExploration()
        }
        if orangeBoundaryGateRecoveryFrames > 0,
           analysis.orangeRockCoverage < 0.68,
           analysis.target == nil,
           effectiveQuestRouteDirection == nil,
           analysis.worldChestDirection == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            let gateDirection = orangeBoundaryGateRecoveryFrames > 20
                ? Vector2(x: 0.0, y: 1.0)
                : Vector2(x: -1.0, y: 0.0)
            orangeBoundaryGateRecoveryFrames -= 1
            return .swipe(
                directionX: gateDirection.x,
                directionY: gateDirection.y,
                duration: 0.58,
                reason: orangeBoundaryGateRecoveryFrames >= 20
                    ? "Narancs határgráf: tiszta déli falvégi kapukeresés"
                    : "Narancs határgráf: nyugati belépés a sárga átjáró szintjén"
            )
        }
        // 233: removed blind 14S/10W/16N macro; terrain/timer is not a verified starting place.
        if blockedExhaustedHighlandSuppressesRed,
           !alternateGreenEnemyRouteAttempted,
           !hasSeenAnyWorldTargetThisProcess,
           titanExitFramesRemaining == 0,
           !analysis.titanGemQuestVisible,
           analysis.target == nil {
            // A kézzel megnyitott nagy térképen a játékos a zöld régió déli
            // részén, a lezárt magaslati cél északnyugatra, egy külön narancs
            // ellenféljel pedig észak-északkeletre látszott. A piros jel
            // elnémítása után ezért nem vak spirállal indulunk, hanem ehhez a
            // második, zöld oldali ellenfélhez tartó időkorlátos folyosóval.
            alternateGreenEnemyRouteAttempted = true
            alternateGreenEnemyRouteFrames = 56
            resetFallbackExploration()
        }
        if alternateGreenEnemyRouteFrames > 0,
           titanExitFramesRemaining == 0,
           (analysis.target == nil || blockedExhaustedHighlandTarget),
           effectiveQuestRouteDirection == nil,
           analysis.worldChestDirection == nil,
           (analysis.playerHealthFraction ?? 0) >= 0.90 {
            alternateGreenEnemyRouteFrames -= 1
            return .swipe(
                directionX: 0.22,
                directionY: -0.98,
                duration: 0.56,
                reason: "Nagy térképes északkeleti zöld ellenfél-útvonal"
            )
        }
        if (analysis.playerHealthFraction ?? 0) >= 0.90,
           let titanExit = effectiveTitanExitDirection {
            // A `225035-play/173-174` képen a Titan `0/7` buborék biztosan
            // jelezte az oltár elérését, miközben egy északnyugati piros
            // minimapjel továbbra is látszott. A régi feltétel csak piros jel
            // hiányában engedte a 28 lépéses oltárkijáratot, ezért a bot a
            // kerítéssel körbezárt táborban négyzetspirálozott. Az explicit,
            // frissen felépített kijárati állapot erősebb a távoli piros
            // céljelöltnél; cél, sebzés, Deep Mines-kijárat és világ-láda
            // továbbra is a kód korábbi, magasabb prioritású őrein fut át.
            titanExitFramesRemaining = max(0, titanExitFramesRemaining - 1)
            resetFallbackExploration()
            return .swipe(
                directionX: titanExit.x,
                directionY: titanExit.y,
                duration: 0.54,
                reason: analysis.specialLandmarkDirection != nil
                    ? "A felderített Titan-oltártól a lila minimapjel ellenirányában távolodom"
                    : "A pulzáló Titan-jel rövid kijárati irányát tartom"
            )
        }
        if (analysis.playerHealthFraction ?? 0) >= 0.90,
           let minimapDirection = preferredNavigationDirection {
            if minimapDetourFrames > 0 {
                minimapDetourFrames -= 1
                let detour = Vector2(
                    x: -minimapDirection.y * minimapDetourSign,
                    y: minimapDirection.x * minimapDetourSign
                ).normalized
                if minimapDetourFrames == 0 { minimapDetourSign *= -1 }
                return .swipe(
                    directionX: detour.x,
                    directionY: detour.y,
                    duration: 0.52,
                    reason: "Minimap-útvonal elakadt; merőleges kerítés-/akadálykerülő"
                )
            }
            if let previousDirection = lastMinimapDirection {
                let alignment = previousDirection.x * minimapDirection.x +
                    previousDirection.y * minimapDirection.y
                if alignment >= 0.96 {
                    stagnantMinimapFrames += 1
                } else {
                    stagnantMinimapFrames = 0
                    // Egy valóban más irányba forduló minimapút új navigációs
                    // folyamat. A kis kerülő alatti enyhe elfordulás még nem az.
                    if alignment < 0.50 { failedMinimapDetourCycles = 0 }
                }
            } else {
                stagnantMinimapFrames = 0
            }
            lastMinimapDirection = minimapDirection
            if stagnantMinimapFrames >= 24 {
                stagnantMinimapFrames = 0
                failedMinimapDetourCycles += 1
                if failedMinimapDetourCycles >= 2 || failedApproachCycles >= 1 {
                    let escape = Vector2(x: -minimapDirection.x, y: -minimapDirection.y).normalized
                    blockedAreaEscapeDirection = escape
                    blockedRouteDirection = minimapDirection
                    blockedRouteCooldownFrames = 120
                    blockedRouteBypassSign *= -1
                    blockedRouteBypassPhaseSteps = 0
                    blockedRouteBypassSawMovement = false
                    blockedAreaEscapeFrames = 17
                    minimapDetourFrames = 0
                    return .swipe(
                        directionX: escape.x,
                        directionY: escape.y,
                        duration: 0.56,
                        reason: "A minimap másodszor vezetett ugyanabba az akadályba; hosszú területelhagyás indul"
                    )
                }
                minimapDetourFrames = 7
                let detour = Vector2(
                    x: -minimapDirection.y * minimapDetourSign,
                    y: minimapDirection.x * minimapDetourSign
                ).normalized
                return .swipe(
                    directionX: detour.x,
                    directionY: detour.y,
                    duration: 0.52,
                    reason: "Minimap-útvonal 24 döntés óta azonos; nyolclépéses kerülő indul"
                )
            }
            return .swipe(
                directionX: minimapDirection.x,
                directionY: minimapDirection.y,
                duration: 0.52,
                reason: effectiveQuestRouteDirection != nil
                    ? (analysis.questRouteDirection != nil
                        ? "A látható türkiz Deep Mines küldetésútvonal követése"
                        : "A legutóbb látott türkiz Deep Mines útvonal követése")
                    : (effectiveSpecialLandmarkDirection != nil
                        ? (analysis.specialLandmarkDirection != nil
                            ? "A különleges lila minimaphely célzott felderítése"
                            : "A pulzáló lila minimaphely irányának rövid megtartása")
                        : effectiveExplorationDirection != nil
                        ? "Minimap alapján a legközelebbi piros cél felderítése"
                        : "Piros cél hiányában a minimap zöld helyszínjelzőjének felderítése")
            )
        }
        return fallbackExplorationDecision(
            analysis,
            reason: blockedExhaustedHighlandSuppressesRed
                ? "A kimerített magaslati ládaág északnyugati piros jele helyett új zöld területet derítek fel"
                : blockedDeepMinesGateSuppressesRed
                ? "A bizonyítottan zárt Deep Mines-kapu piros iránya helyett növekvő szabad felderítés"
                : "Nincs látható cél; növekvő négyzetspirál-felderítés"
        )
    }

    private func targetMatchesControlledTrial(_ target: Target, in analysis: FrameAnalysis) -> Bool {
        guard let initialHP = controlledBossTrialInitialHP else { return false }

        if canonicalControlledTrialHP(target) == initialHP {
            // A `220041/116` képen a stabil 4,4K-s őr felirata `4:4` lett,
            // amit a nyers parser 4 HP-nak adott tovább. Az explicit kanonikus
            // alak aktív próbában erősebb, mint ez a csonkolt szám.
            return true
        }

        if let displayedHP = target.displayedHP {
            var normalizedHP = displayedHP
            // A régi OCR-hibajavítás a legfeljebb 8K-s próbákhoz készült:
            // például a pont nélkül felismert 122K-ból 1220-at gyártott. Egy
            // valódi, explicit `11.4K`-ról indított nagypróbánál viszont a
            // 11.1K-re csökkent HP-t nem szabad 111-re osztani.
            while initialHP <= 8_000,
                  normalizedHP > 8_000,
                  normalizedHP % 100 == 0 {
                normalizedHP /= 100
            }
            if abs(normalizedHP - initialHP) <= 250 {
                return true
            }

            if initialHP == 1_220,
               (15...29).contains(normalizedHP),
               target.bar.width >= 45,
               target.axeIconEvidence >= 0.12 {
                // A bizonyítottan legyőzhető páncélos `1.22K` felirata a bal
                // képszélen `:22`, majd `1122` alakra csonkolódott, miközben a
                // széles, 59 px-es csík és a fejszeikon végig ugyanaz maradt.
                // Aktív 1220-as próbában a képi test és az iránymemória a hiányzó
                // K-t is áthidalhatja; ez nem általános 22 HP-s felmentés.
                let compact = target.ocrStrings.joined(separator: "").filter(\.isNumber)
                let toward = Vector2(
                    x: target.x - Double(analysis.width) * 0.5,
                    y: target.y - Double(analysis.height) * 0.515
                ).normalized
                let directionMatches = controlledBossTrialDirection.map {
                    $0.x * toward.x + $0.y * toward.y >= 0.50
                } ?? false
                if compact.contains("122") || target.bossEvidence || directionMatches {
                    return true
                }
            }

            // A nagy cél felirata harc közben ténylegesen csökkenhet. A 4.31K-s
            // óriásfa két közelítő swipe után már 2.18K-t mutatott. Csökkenő
            // értéket csak erős test-/statikon-azonossággal, az előző iránnyal
            // egy oldalon és harci közelségben fogadunk el; így egy szomszédos,
            // másik HP-sávú boss nem veheti át a próbát.
            let heartSignatureMatches = controlledBossTrialInitialHeartEvidence < 0.04
                ? target.heartIconEvidence < 0.12
                : target.heartIconEvidence >= 0.03
            let axeSignatureMatches = controlledBossTrialInitialAxeEvidence < 0.03
                ? target.axeIconEvidence < 0.12
                : target.axeIconEvidence >= 0.02
            let treeSignatureMatches = controlledBossTrialInitialTreeConfidence < 0.25
                ? target.treeConfidence < 0.18
                : target.treeConfidence >= 0.18
            let toward = Vector2(
                x: target.x - Double(analysis.width) * 0.5,
                y: target.y - Double(analysis.height) * 0.515
            ).normalized
            let directionMatches = controlledBossTrialDirection.map {
                $0.x * toward.x + $0.y * toward.y >= 0.55
            } ?? false
            if normalizedHP < initialHP - 250,
               normalizedHP >= max(250, initialHP / 8),
               target.bossEvidence,
               target.distance <= 180,
               heartSignatureMatches,
               axeSignatureMatches,
               treeSignatureMatches,
               (directionMatches || target.distance <= 112) {
                // Valódi közelharcban az ellenfél egyetlen automata ütés alatt
                // átkerülhet a karakter másik oldalára. A `183754/117–120`
                // 3.06K-s őrénél ez 490 kiosztott és csak 60 kapott sebzés után
                // törte meg az egyébként nyerhető próbát. 112 px-en belül a
                // csökkenő HP, a boss- és ikon-aláírás erősebb azonosság, mint
                // a korábbi irány félsíkja, ezért ott engedjük az oldalváltást.
                return true
            }

            // Ha az aktuális célhoz már van konkrét, de apró HP-érték, ne a
            // szomszéd bossból a ROI-ba lógó `1.92K` OCR-szöveg döntse el az
            // azonosságot. A havas kapunál egy 20 HP-s, szint 3-as cél így lett
            // hamis `1920→20` bossfolytatás. A valódi leütött boss csökkenő
            // tartományát a fenti, bossbizonyítékos harci ág kezeli.
            if normalizedHP < max(250, initialHP / 8) {
                return false
            }
        }

        // Az ezres HP-felirat gyakran toldalékot kap (`31.92K`) vagy elveszti az
        // első számjegyét (`22K`). A kezdő cél teljes háromjegyű ezred-aláírása,
        // illetve a két tizedesjegy + K még így is megkülönbözteti az 1.92K-t a
        // mellette álló 7.15K-tól.
        guard target.bossEvidence || (target.displayedHP ?? 0) >= 800 else {
            return false
        }
        let compactOCR = target.ocrStrings
            .joined(separator: "")
            .lowercased()
            .filter { $0.isNumber || $0 == "k" }
        let thousandDigits = String(initialHP / 10)
        let suffix = String(format: "%02d", (initialHP / 10) % 100)
        return compactOCR.contains(thousandDigits) || compactOCR.contains("\(suffix)k")
    }

    private func canonicalControlledTrialHP(_ target: Target) -> Int? {
        guard let displayedHP = target.displayedHP else { return nil }
        let normalizedOCR = target.ocrStrings.map {
            $0.lowercased()
                .replacingOccurrences(of: ":", with: ".")
                .replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: " ", with: "")
        }
        if normalizedOCR.contains(where: { $0.contains("4.4k") }) {
            return 4_400
        }
        if displayedHP <= 49,
           target.bar.width >= 55,
           normalizedOCR.contains(where: { $0 == "4.4" || $0.contains("4.4") }) {
            return 4_400
        }
        if normalizedOCR.contains(where: { $0.contains("18.8k") }) {
            return 18_800
        }
        let compactDigits = target.ocrStrings.joined(separator: "").filter(\.isNumber)
        let knownTruncatedFangSignature = target.bar.width >= 45 &&
            target.axeIconEvidence >= 0.15 &&
            target.bossEvidence &&
            (compactDigits.contains("122") || compactDigits.contains("1122"))
        if knownTruncatedFangSignature,
           ((15...29).contains(displayedHP) ||
                (1_100...1_250).contains(displayedHP) ||
                displayedHP == 122_000) {
            return 1_220
        }

        // A pont nélküli K-alak nem mondja meg, hogy melyik tizedeshely veszett
        // el. A Dusty Gulch 11.4K-s kaktuszát a Vision előbb `114K`-nak olvasta;
        // a régi ismételt /100 normalizálás ebből veszélyes, hamis 1140 HP-s
        // próbát indított. Ugyanez a `272K` képszéli alaknál 2720-at gyártott.
        // Csak a már külön bizonyított Fang-aláírás kap fenti kivételt; minden
        // más 8K fölötti érték megvár egy explicit pontot/kettőspontot vagy egy
        // későbbi, biztosabb OCR-képet.
        if displayedHP > 8_000 {
            // A játékos kérésére a már bizonyított 3.06K-s győzelem után az
            // egyértelműen kiírt nagy ellenfeleket is egyszer megpróbáljuk. A
            // tizedespont és a K együttes jelenléte kizárja a veszélyes `114K`
            // félreolvasást. A 18.8K-s, 25-ös statikonú páncélos élő megtalálása
            // után a 30K plafon és a próba meglévő sebzés-/visszavonulás-őrei
            // kontrollálják a kísérletet; a halál büntetésmentes. A
            // `004826-play/45` ugyanezen a járható Island 2-síkon egy explicit
            // 27.7K-s páncélost is mutatott, ezért az is egyszeri mérhető próba.
            let explicitDecimalThousands = target.ocrStrings.contains { text in
                let normalized = text.lowercased()
                let hasDecimalSeparator = normalized.contains(".") ||
                    normalized.contains(":") ||
                    normalized.contains(",")
                return hasDecimalSeparator && normalized.contains("k")
            }
            return explicitDecimalThousands && displayedHP <= 30_000
                ? displayedHP
                : nil
        }

        return displayedHP
    }

    private func explicitPlayerKHP(_ strings: [String]) -> Int? {
        for raw in strings {
            let lower = raw.lowercased()
            guard lower.contains("k"),
                  !lower.contains("m"),
                  !lower.contains("s"),
                  !lower.contains("h") else { continue }

            let normalized = lower
                .replacingOccurrences(of: ":", with: ".")
                .replacingOccurrences(of: ",", with: ".")
            let groups = normalized.split { !$0.isNumber }.map(String.init)
            if groups.count >= 2,
               let whole = Int(groups[0]),
               whole >= 1, whole <= 9 {
                let fractionDigits = String(groups[1].prefix(2))
                if let fraction = Int(fractionDigits) {
                    let scale = fractionDigits.count == 1 ? 100 : 10
                    return whole * 1_000 + fraction * scale
                }
            }

            var digits = String(lower.filter(\.isNumber))
            // A zöld csík bal széle gyakran külön vezető `1`-ként tapad a
            // valódi `1.64K`/`1.94K` elé: `1164K`, illetve `1194K` lesz.
            if digits.count == 4, digits.hasPrefix("1") {
                digits.removeFirst()
            }
            if digits.count == 3, digits.hasPrefix("1"),
               let fraction = Int(digits.dropFirst()) {
                return 1_000 + fraction * 10
            }
            if digits.count == 2, digits.hasPrefix("1"),
               let fraction = Int(digits.suffix(1)) {
                return 1_000 + fraction * 100
            }
        }
        return nil
    }

    private func fallbackExplorationDecision(
        _ analysis: FrameAnalysis,
        reason: String
    ) -> ActionDecision {
        // A korábbi 4×4 irányú négyzetjárőr minden 16 döntés után pontosan
        // visszatért a kiindulópontra. A két-két azonos hosszú oldal után növekvő
        // négyzetspirál egyre nagyobb területet fed le. Ugyanezt a döntőt használjuk
        // aktív elérhetetlen-cél aláírásnál is, amikor a piros minimapjel maga a
        // bizonyított útvonalhurok forrása.
        if exploreLegStepsRemaining == 0 {
            exploreDirectionIndex = (exploreDirectionIndex + 1) % 4
            exploreCompletedLegsAtLength += 1
            if exploreCompletedLegsAtLength >= 2 {
                exploreCompletedLegsAtLength = 0
                exploreLegLength = min(48, exploreLegLength + 4)
            }
            exploreLegStepsRemaining = exploreLegLength
        }
        let patrol: Vector2
        switch exploreDirectionIndex {
        case 0: patrol = Vector2(x: 0, y: 1)
        case 1: patrol = Vector2(x: 1, y: 0)
        case 2: patrol = Vector2(x: 0, y: -1)
        default: patrol = Vector2(x: -1, y: 0)
        }
        exploreLegStepsRemaining -= 1
        if let threat = analysis.nearestThreat {
            let away = Vector2(
                x: Double(analysis.width) * 0.5 - threat.x,
                y: Double(analysis.height) * 0.515 - threat.y
            ).normalized
            let label = threat.level.map { "\($0). szint" } ?? "ismeretlen szint"
            let returnDirection = Vector2(
                x: patrol.x + away.x * 0.65,
                y: patrol.y + away.y * 0.65
            ).normalized
            return .swipe(
                directionX: returnDirection.x,
                directionY: returnDirection.y,
                duration: 0.44,
                reason: "Nem értékelhető cél (\(label)); négyirányú biztonságos felderítés"
            )
        }
        return .swipe(
            directionX: patrol.x,
            directionY: patrol.y,
            duration: 0.42,
            reason: reason
        )
    }

    private func resetFallbackExploration() {
        exploreDirectionIndex = 0
        exploreLegLength = 4
        exploreLegStepsRemaining = 4
        exploreCompletedLegsAtLength = 0
    }
}

// A pálya tereptárgyai rögzítettek, a kamera és az ellenfelek viszont mozognak.
// Emiatt egy hamis abszolút koordinátarendszernél megbízhatóbb a képi helyhez
// kötött topologikus térkép: ugyanazon háttéraláírásnál irányonként megjegyzi,
// hogy a végrehajtott swipe valódi kameramozgást vagy statikus akadályt adott-e.
// A tudás újraindítások között is megmarad a docs/world-map.json fájlban.
private final class PersistentObstacleMap {
    private struct Node: Codable {
        var signature: [Int]
        var attempts: [Int]
        var blocked: [Int]
        var successful: [Int]
        var collectedChestDirections: [Int]?
        var retiredDirections: [Int]?
        var visits: Int
        var lastSeen: Date
    }

    private struct State: Codable {
        var version: Int
        var nodes: [Node]
        var totalAttempts: Int
        var totalBlocked: Int
        var totalReroutes: Int
    }

    // Az egyszeri jutalomhelyek nem gyorsítótár-adatok. Külön, kicsi szemantikus
    // állományban is megmaradnak, így a sok változó képi csomópont nem szoríthatja
    // ki őket a 400 elemű geometriai LRU-térképből.
    private struct SemanticChest: Codable {
        var signature: [Int]
        var collectedDirections: [Int]
        var lastConfirmed: Date?
    }

    private struct SemanticState: Codable {
        var version: Int
        var collectedChests: [SemanticChest]
    }

    private struct PendingAttempt {
        let signature: [Int]
        let directionBin: Int
    }

    private let url: URL
    private let semanticURL: URL
    private let readOnly: Bool
    private var state: State
    private var semanticState: SemanticState
    private var pendingAttempt: PendingAttempt?
    private var pendingChest: PendingAttempt?
    private var pendingChestFrames = 0
    private var persistentRerouteDirection: Vector2?
    private var persistentRerouteFrames = 0
    private var persistentRerouteWasCollectedChest = false

    init(readOnly: Bool) {
        self.readOnly = readOnly
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        url = root.appendingPathComponent("docs/world-map.json")
        semanticURL = root.appendingPathComponent("docs/semantic-map.json")
        if let data = try? Data(contentsOf: url),
           var decoded = try? JSONDecoder().decode(State.self, from: data),
           decoded.version == 1 {
            for index in decoded.nodes.indices {
                decoded.nodes[index].attempts = Self.normalizedBins(decoded.nodes[index].attempts)
                decoded.nodes[index].blocked = Self.normalizedBins(decoded.nodes[index].blocked)
                decoded.nodes[index].successful = Self.normalizedBins(decoded.nodes[index].successful)
            }
            state = decoded
        } else {
            state = State(version: 1, nodes: [], totalAttempts: 0, totalBlocked: 0, totalReroutes: 0)
        }
        if let data = try? Data(contentsOf: semanticURL),
           let decoded = try? JSONDecoder().decode(SemanticState.self, from: data),
           decoded.version == 1 {
            semanticState = decoded
        } else {
            semanticState = SemanticState(version: 1, collectedChests: [])
        }
    }

    private static func normalizedBins(_ values: [Int]) -> [Int] {
        Array((values + Array(repeating: 0, count: 8)).prefix(8))
    }

    private func signatureDifference(_ lhs: [Int], _ rhs: [Int]) -> Int {
        guard lhs.count == rhs.count else { return .max }
        return zip(lhs, rhs).reduce(0) { $0 + abs($1.0 - $1.1) }
    }

    private func nearestNodeIndex(for signature: [Int], maximumDifference: Int = 14) -> Int? {
        let best = state.nodes.indices.min {
            signatureDifference(state.nodes[$0].signature, signature) <
                signatureDifference(state.nodes[$1].signature, signature)
        }
        guard let best,
              signatureDifference(state.nodes[best].signature, signature) <= maximumDifference else {
            return nil
        }
        return best
    }

    private func ensureNode(for signature: [Int]) -> Int {
        if let existing = nearestNodeIndex(for: signature) { return existing }
        if state.nodes.count >= 400 {
            // A már kifosztott láda helyi csomópontja végleges tudás. Csak
            // hétköznapi geometriai csomópontot szabad LRU-alapon kidobni.
            let disposable = state.nodes.indices.filter { index in
                let localCollected = Self.normalizedBins(
                    state.nodes[index].collectedChestDirections ?? []
                ).contains(1)
                let durableCollected = semanticChestDirections(
                    for: state.nodes[index].signature
                ) != nil
                return !localCollected && !durableCollected
            }
            if let oldest = disposable.min(by: {
               state.nodes[$0].lastSeen < state.nodes[$1].lastSeen
            }) {
                state.nodes.remove(at: oldest)
            }
        }
        state.nodes.append(Node(
            signature: signature,
            attempts: Array(repeating: 0, count: 8),
            blocked: Array(repeating: 0, count: 8),
            successful: Array(repeating: 0, count: 8),
            collectedChestDirections: nil,
            retiredDirections: nil,
            visits: 0,
            lastSeen: Date()
        ))
        return state.nodes.count - 1
    }

    private func persist() {
        guard !readOnly else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(state) else { return }
        try? data.write(to: url, options: .atomic)
        if let semanticData = try? encoder.encode(semanticState) {
            try? semanticData.write(to: semanticURL, options: .atomic)
        }
    }

    private func semanticChestDirections(for signature: [Int]) -> [Int]? {
        let best = semanticState.collectedChests.min {
            signatureDifference($0.signature, signature) <
                signatureDifference($1.signature, signature)
        }
        guard let best,
              signatureDifference(best.signature, signature) <= 14 else { return nil }
        return Self.normalizedBins(best.collectedDirections)
    }

    private func recordSemanticChest(_ pending: PendingAttempt) {
        if let existing = semanticState.collectedChests.indices.min(by: {
            signatureDifference(semanticState.collectedChests[$0].signature, pending.signature) <
                signatureDifference(semanticState.collectedChests[$1].signature, pending.signature)
        }), signatureDifference(
            semanticState.collectedChests[existing].signature,
            pending.signature
        ) <= 14 {
            var directions = Self.normalizedBins(
                semanticState.collectedChests[existing].collectedDirections
            )
            directions[pending.directionBin] = 1
            semanticState.collectedChests[existing].collectedDirections = directions
            semanticState.collectedChests[existing].lastConfirmed = Date()
            return
        }
        var directions = Array(repeating: 0, count: 8)
        directions[pending.directionBin] = 1
        semanticState.collectedChests.append(SemanticChest(
            signature: pending.signature,
            collectedDirections: directions,
            lastConfirmed: Date()
        ))
    }

    func observe(_ analysis: FrameAnalysis, allowLearning: Bool) {
        if allowLearning, let chestDirection = analysis.worldChestDirection {
            pendingChest = PendingAttempt(
                signature: analysis.sceneFingerprint,
                directionBin: directionBin(x: chestDirection.x, y: chestDirection.y)
            )
            pendingChestFrames = 24
        } else if pendingChestFrames > 0 {
            pendingChestFrames -= 1
        }
        if allowLearning,
           pendingChestFrames > 0,
           (analysis.claimRewardVisible || analysis.continueButtonVisible || analysis.recentRewardValue != nil),
           let chest = pendingChest {
            let nodeIndex = ensureNode(for: chest.signature)
            var directions = Self.normalizedBins(state.nodes[nodeIndex].collectedChestDirections ?? [])
            directions[chest.directionBin] = 1
            state.nodes[nodeIndex].collectedChestDirections = directions
            state.nodes[nodeIndex].lastSeen = Date()
            recordSemanticChest(chest)
            pendingChest = nil
            pendingChestFrames = 0
            persist()
        } else if pendingChestFrames == 0 {
            pendingChest = nil
        }

        guard let pending = pendingAttempt else { return }
        pendingAttempt = nil
        guard allowLearning else { return }

        let difference = signatureDifference(pending.signature, analysis.sceneFingerprint)
        let nodeIndex = ensureNode(for: pending.signature)
        state.nodes[nodeIndex].attempts[pending.directionBin] += 1
        state.nodes[nodeIndex].visits += 1
        state.nodes[nodeIndex].lastSeen = Date()
        state.totalAttempts += 1
        if difference <= 12 {
            state.nodes[nodeIndex].blocked[pending.directionBin] += 1
            state.totalBlocked += 1
            if state.nodes[nodeIndex].blocked[pending.directionBin] >= 4,
               state.nodes[nodeIndex].successful[pending.directionBin] == 0 {
                var retired = Self.normalizedBins(state.nodes[nodeIndex].retiredDirections ?? [])
                retired[pending.directionBin] = 1
                state.nodes[nodeIndex].retiredDirections = retired
            }
        } else {
            state.nodes[nodeIndex].successful[pending.directionBin] += 1
            if var retired = state.nodes[nodeIndex].retiredDirections {
                retired = Self.normalizedBins(retired)
                retired[pending.directionBin] = 0
                state.nodes[nodeIndex].retiredDirections = retired
            }
        }
        persist()
    }

    private func directionBin(x: Double, y: Double) -> Int {
        let raw = Int(round(atan2(y, x) / (.pi / 4.0)))
        return (raw % 8 + 8) % 8
    }

    private func vector(for bin: Int) -> Vector2 {
        let angle = Double((bin % 8 + 8) % 8) * (.pi / 4.0)
        return Vector2(x: cos(angle), y: sin(angle))
    }

    private func isSafetyRetreat(_ reason: String) -> Bool {
        ["visszavonul", "menekülési", "Tartós harci tudás", "Többezer HP-s boss"]
            .contains { reason.localizedCaseInsensitiveContains($0) }
    }

    private func isNavigational(_ reason: String) -> Bool {
        if isSafetyRetreat(reason) { return false }
        if reason.localizedCaseInsensitiveContains("Kontrollált bosspróba") ||
           reason.localizedCaseInsensitiveContains("DOC kapupont") ||
           reason.localizedCaseInsensitiveContains("18,8K-s magaslati őr") ||
           reason.localizedCaseInsensitiveContains("Island 2 bizonyított köztes kapu") ||
           reason.localizedCaseInsensitiveContains("Island 2 narancs koponya") ||
           reason.localizedCaseInsensitiveContains("felderített Titan-oltártól") ||
           reason.localizedCaseInsensitiveContains("pulzáló Titan-jel rövid kijárati") ||
           reason.localizedCaseInsensitiveContains("Nagy térképes nyugati cél") ||
           reason.localizedCaseInsensitiveContains("Nagy térképes északkeleti zöld ellenfél-útvonal") {
            // A harci kísérlet saját, visszacsatolt célzára és a nagy térképről
            // levezetett fix rétegútvonal pontosabb az általános képaláírásos
            // kerülőnél; az utóbbi a `220041/99–106` sorban felülírta a 4,4K-s
            // kapupróbát és kifordította a karaktert.
            return false
        }
        let markers = [
            "felderítés", "Minimap", "minimap", "útvonal", "megközelítése",
            "akadálykerül", "falmenti", "Hűtőlistás", "kiszabadulás",
            "területelhagyás", "kerülő", "szintkülönbség"
        ]
        return markers.contains { reason.localizedCaseInsensitiveContains($0) }
    }

    func adapt(_ decision: ActionDecision, analysis: FrameAnalysis) -> ActionDecision {
        guard case .swipe(let x, let y, let duration, let reason) = decision else {
            return decision
        }
        if isSafetyRetreat(reason) || reason.hasPrefix("Vizuális útvonalgráf:") {
            // A harci döntő már törölte a saját kerülőjét; a külön térképréteg
            // sem írhatja felül a kifelé inputot, és nem tarthat régi kerülőt.
            persistentRerouteFrames = 0
            persistentRerouteDirection = nil
            persistentRerouteWasCollectedChest = false
            return decision
        }
        guard isNavigational(reason) else { return decision }

        if persistentRerouteFrames > 0,
           let reroute = persistentRerouteDirection,
           (analysis.target?.distance ?? .infinity) > 110 {
            persistentRerouteFrames -= 1
            if persistentRerouteFrames == 0 {
                persistentRerouteDirection = nil
                persistentRerouteWasCollectedChest = false
            }
            return .swipe(
                directionX: reroute.x,
                directionY: reroute.y,
                duration: max(0.48, duration),
                reason: persistentRerouteWasCollectedChest
                    ? "Szemantikus térkép: a begyűjtött egyszeri helytől tartós eltávolodás"
                    : "Tartós akadálytérkép: nyolclépéses falvégi kerülő folytatása"
            )
        }
        if (analysis.target?.distance ?? .infinity) <= 110 {
            persistentRerouteFrames = 0
            persistentRerouteDirection = nil
            persistentRerouteWasCollectedChest = false
        }

        var nodeIndex = nearestNodeIndex(for: analysis.sceneFingerprint)
        let durableCollectedDirections = semanticChestDirections(
            for: analysis.sceneFingerprint
        )
        if nodeIndex == nil, durableCollectedDirections != nil {
            nodeIndex = ensureNode(for: analysis.sceneFingerprint)
        }
        guard let nodeIndex else { return decision }

        if reason.localizedCaseInsensitiveContains("szintkülönbség"),
           let threat = analysis.nearestThreat {
            let towardThreat = Vector2(
                x: threat.x - Double(analysis.width) * 0.5,
                y: threat.y - Double(analysis.height) * 0.515
            ).normalized
            let separatedBin = directionBin(x: towardThreat.x, y: towardThreat.y)
            var retired = Self.normalizedBins(state.nodes[nodeIndex].retiredDirections ?? [])
            retired[separatedBin] = 1
            state.nodes[nodeIndex].retiredDirections = retired
            state.nodes[nodeIndex].lastSeen = Date()
            persist()
        }

        let proposedBin = directionBin(x: x, y: y)
        var collectedChestDirections = Self.normalizedBins(
            state.nodes[nodeIndex].collectedChestDirections ?? []
        )
        if let durableCollectedDirections {
            for bin in 0..<8 {
                collectedChestDirections[bin] = max(
                    collectedChestDirections[bin],
                    durableCollectedDirections[bin]
                )
            }
            state.nodes[nodeIndex].collectedChestDirections = collectedChestDirections
        }
        let returnsToCollectedChest = collectedChestDirections[proposedBin] > 0 &&
            analysis.worldChestDirection == nil && analysis.target == nil
        let retiredDirections = Self.normalizedBins(state.nodes[nodeIndex].retiredDirections ?? [])
        let returnsToRetiredDirection = retiredDirections[proposedBin] > 0 && analysis.target == nil
        let proposedFailures = state.nodes[nodeIndex].blocked[proposedBin] -
            state.nodes[nodeIndex].successful[proposedBin]
        guard returnsToCollectedChest || returnsToRetiredDirection ||
                (state.nodes[nodeIndex].attempts[proposedBin] >= 2 && proposedFailures >= 2) else {
            return decision
        }

        let proposed = Vector2(x: x, y: y).normalized
        // A korábbi legfeljebb 90 fokos jelöltek hosszú külső falnál jók voltak,
        // de a `194735-play` konkáv szikla–ház zsebében a cél bal-fent volt,
        // miközben az egyetlen kijárat lefelé/jobbra nyílt. Bal, bal-fel,
        // fel és jobb-fel sorban mind statikus maradt; a térkép mégsem
        // mérlegelhette a cél átmeneti feladását jelentő 135–180 fokos fordulót.
        // Két bizonyított blokkolás után mind a hét másik bin versenyezhet. A
        // célirányhoz való igazodási pontszám továbbra is a kis kerülőt választja,
        // amíg az valóban járhatónak látszik, de egy zsákból már ki tud fordulni.
        let candidates = (0..<8).filter { $0 != proposedBin }
        let best = candidates.max { lhs, rhs in
            score(bin: lhs, proposed: proposed, node: state.nodes[nodeIndex]) <
                score(bin: rhs, proposed: proposed, node: state.nodes[nodeIndex])
        }
        guard let best,
              score(bin: best, proposed: proposed, node: state.nodes[nodeIndex]) >
                score(bin: proposedBin, proposed: proposed, node: state.nodes[nodeIndex]) + 0.35 else {
            return decision
        }

        state.totalReroutes += 1
        state.nodes[nodeIndex].lastSeen = Date()
        persist()
        let alternative = vector(for: best)
        persistentRerouteDirection = alternative
        persistentRerouteFrames = 7
        persistentRerouteWasCollectedChest = returnsToCollectedChest
        return .swipe(
            directionX: alternative.x,
            directionY: alternative.y,
            duration: max(0.44, duration),
            reason: returnsToCollectedChest
                ? "Szemantikus térkép: a már begyűjtött egyszeri láda iránya helyett új terület"
                : returnsToRetiredDirection
                ? "Tartós térkép: a négyszer bizonyított zsákutca helyett hosszú kerülő"
                : "Tartós akadálytérkép: a korábban blokkolt irány helyett megtanult oldalsó út"
        )
    }

    private func score(bin: Int, proposed: Vector2, node: Node) -> Double {
        let candidate = vector(for: bin)
        let alignment = candidate.x * proposed.x + candidate.y * proposed.y
        let failures = max(0, node.blocked[bin] - node.successful[bin])
        let collectedPenalty = Self.normalizedBins(node.collectedChestDirections ?? [])[bin] > 0
            ? 4.0 : 0.0
        let retiredPenalty = Self.normalizedBins(node.retiredDirections ?? [])[bin] > 0
            ? 6.0 : 0.0
        return alignment * 3.0 + Double(node.successful[bin]) * 0.45 -
            Double(failures) * 1.55 - Double(node.attempts[bin]) * 0.03 -
            collectedPenalty - retiredPenalty
    }

    func recordExecuted(_ decision: ActionDecision, analysis: FrameAnalysis) {
        guard case .swipe(let x, let y, _, let reason) = decision,
              isNavigational(reason) else { return }
        pendingAttempt = PendingAttempt(
            signature: analysis.sceneFingerprint,
            directionBin: directionBin(x: x, y: y)
        )
    }
}

@MainActor
private final class SwipeController {
    // A CGEventSource a bot saját warp/down/drag/up eseményeit is felhasználói
    // aktivitásnak számolja. Emiatt a korábbi ciklus minden swipe után legalább
    // egyszer tévesen várakozott. Megőrizzük a szintetikus input előtti valódi
    // inaktivitást, és csak addig korrigáljuk a rendszerórát, amíg bizonyíthatóan
    // a bot utolsó eseménye a legfrissebb. Egy későbbi emberi input rövidebb nyers
    // idle-időt ad, ezért azonnal visszakapja az elsőbbséget.
    private var syntheticInputEndedAt: Date?
    private var idleBeforeSyntheticInput = 0.0

    func focus(processID: pid_t) -> NSRunningApplication? {
        guard processID > 0, let app = NSRunningApplication(processIdentifier: processID) else { return nil }
        let previous = NSWorkspace.shared.frontmostApplication
        app.activate()
        Thread.sleep(forTimeInterval: 0.080)
        return previous?.processIdentifier == processID ? nil : previous
    }

    func restoreFocus(_ application: NSRunningApplication?) {
        application?.activate()
    }

    private func rawUserIdleSeconds() -> Double {
        guard let anyInput = CGEventType(rawValue: UInt32.max) else { return 0 }
        return CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyInput)
    }

    func userIdleSeconds() -> Double {
        let rawIdle = rawUserIdleSeconds()
        guard let syntheticInputEndedAt else { return rawIdle }
        let elapsedSinceSyntheticInput = Date().timeIntervalSince(syntheticInputEndedAt)

        // Ha a nyers rendszeróra együtt fut a legutóbbi botsaját eseménnyel,
        // az ember előző idle-idejét folytatjuk. Ha rövidebb, azóta valódi input
        // érkezett, ezért azt változtatás nélkül tiszteletben tartjuk.
        if rawIdle + 0.035 >= elapsedSinceSyntheticInput {
            return idleBeforeSyntheticInput + elapsedSinceSyntheticInput
        }
        return rawIdle
    }

    private func beginSyntheticInput() {
        idleBeforeSyntheticInput = userIdleSeconds()
        syntheticInputEndedAt = nil
    }

    private func endSyntheticInput() {
        syntheticInputEndedAt = Date()
    }

    func tap(processID: pid_t, windowID: CGWindowID, windowFrame: CGRect, imageWidth: Int, imageHeight: Int, x: Double, y: Double, globalInput: Bool) throws {
        guard AXIsProcessTrusted() else { throw BotError.inputPermissionMissing }
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            throw BotError.captureFailed("Nem hozható létre koppintási esemény.")
        }
        let localPoint = CGPoint(
            x: x * windowFrame.width / Double(imageWidth),
            y: y * windowFrame.height / Double(imageHeight)
        )
        let point = globalInput ? CGPoint(x: windowFrame.minX + localPoint.x, y: windowFrame.minY + localPoint.y) : localPoint
        guard let down = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left),
              let up = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
            throw BotError.captureFailed("Nem hozható létre koppintási esemény.")
        }
        beginSyntheticInput()
        defer { endSyntheticInput() }
        if globalInput {
            // A Catalyst-játék aktiválása után az első azonnali down esemény
            // időnként csak az ablakot hozza előre, magát a játékbeli gombot
            // nem éri el. A `202055-play` Settings-próbája ezt mutatta, miközben
            // ugyanaz a koordináta kézi, friss állapot utáni kattintással működött.
            // A rövid aktiválódási ablak csak ritka koppintásoknál kell; a
            // folyamatos swipe-ok tempóját nem lassítja.
            Thread.sleep(forTimeInterval: 0.160)
            let savedCursor = CGEvent(source: nil)?.location
            CGWarpMouseCursorPosition(point)
            down.post(tap: .cghidEventTap)
            Thread.sleep(forTimeInterval: 0.070)
            up.post(tap: .cghidEventTap)
            if let savedCursor { CGWarpMouseCursorPosition(savedCursor) }
        } else {
            for event in [down, up] {
                event.setIntegerValueField(.mouseEventWindowUnderMousePointer, value: Int64(windowID))
                event.setIntegerValueField(.mouseEventWindowUnderMousePointerThatCanHandleThisEvent, value: Int64(windowID))
            }
            down.postToPid(processID)
            Thread.sleep(forTimeInterval: 0.070)
            up.postToPid(processID)
        }
    }

    func swipe(
        processID: pid_t,
        windowID: CGWindowID,
        windowFrame: CGRect,
        imageWidth: Int,
        imageHeight: Int,
        anchorX: Double,
        anchorY: Double,
        directionX: Double,
        directionY: Double,
        duration: Double,
        globalInput: Bool,
        dragDistanceFraction: Double? = nil
    ) throws {
        guard AXIsProcessTrusted() else { throw BotError.inputPermissionMissing }

        let normalized = Vector2(x: directionX, y: directionY).normalized
        let scaleX = windowFrame.width / Double(imageWidth)
        let scaleY = windowFrame.height / Double(imageHeight)
        let touchAnchor = CGPoint(
            x: windowFrame.minX + Double(imageWidth) * anchorX * scaleX,
            y: windowFrame.minY + Double(imageHeight) * anchorY * scaleY
        )
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            throw BotError.captureFailed("Nem hozható létre egéresemény.")
        }
        beginSyntheticInput()
        defer { endSyntheticInput() }

        if globalInput {
            let radius = dragDistanceFraction.map { windowFrame.height * $0 } ??
                (min(windowFrame.width, windowFrame.height) * 0.072)
            let endpoint = CGPoint(
                x: touchAnchor.x + normalized.x * radius,
                y: touchAnchor.y + normalized.y * radius
            )
            let savedCursor = CGEvent(source: nil)?.location
            let cancellation = RunCancellation.shared
            guard !cancellation.requested else { return }
            CGWarpMouseCursorPosition(touchAnchor)
            cancellation.wait(0.060)
            guard !cancellation.requested else {
                if let savedCursor { CGWarpMouseCursorPosition(savedCursor) }
                return
            }
            guard let down = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: touchAnchor, mouseButton: .left) else {
                throw BotError.captureFailed("Nem hozható létre érintéskezdet.")
            }
            down.post(tap: .cghidEventTap)
            defer {
                CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: endpoint, mouseButton: .left)?.post(tap: .cghidEventTap)
                if let savedCursor { CGWarpMouseCursorPosition(savedCursor) }
            }
            let dragSteps = dragDistanceFraction == nil ? 8 : 18
            for step in 1...dragSteps {
                if cancellation.requested { break }
                let progress = Double(step) / Double(dragSteps)
                let point = CGPoint(
                    x: touchAnchor.x + (endpoint.x - touchAnchor.x) * progress,
                    y: touchAnchor.y + (endpoint.y - touchAnchor.y) * progress
                )
                CGEvent(mouseEventSource: source, mouseType: .leftMouseDragged, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)
                cancellation.wait(0.025)
            }
            cancellation.wait(duration)
            return
        }

        // Az Apple „Érintési alternatívák” módban a görgetés a mutató helyéről
        // induló érintéses húzássá alakul. Az eseményt közvetlenül a játék PID-jének
        // küldjük, így sem a rendszer egerét, sem a felhasználó fókuszát nem vesszük el.
        let verticalDelta: Int32 = normalized.y < -0.15 ? 1 : (normalized.y > 0.15 ? -1 : 0)
        let horizontalDelta: Int32 = normalized.x < -0.15 ? 1 : (normalized.x > 0.15 ? -1 : 0)
        let steps = max(5, Int(duration * 18))
        for _ in 0..<steps {
            if let scroll = CGEvent(
                scrollWheelEvent2Source: source,
                units: .line,
                wheelCount: 2,
                wheel1: verticalDelta,
                wheel2: horizontalDelta,
                wheel3: 0
            ) {
                scroll.setIntegerValueField(.mouseEventWindowUnderMousePointer, value: Int64(windowID))
                scroll.setIntegerValueField(.mouseEventWindowUnderMousePointerThatCanHandleThisEvent, value: Int64(windowID))
                scroll.location = touchAnchor
                scroll.postToPid(processID)
            }
            Thread.sleep(forTimeInterval: 1.0 / 18.0)
        }
    }
}

private final class RunLogger {
    private let directory: URL
    private let logURL: URL
    private let encoder: JSONEncoder
    private var handle: FileHandle?

    init(mode: Options.Mode) throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        // Több gyors replay ugyanabba a másodpercbe eshet. A puszta időbélyeg
        // ilyenkor felülírta az előző bizonyítékot; minden futás saját névteret kap.
        let stamp = formatter.string(from: Date()) + "-" + UUID().uuidString.prefix(8).lowercased()
        directory = root.appendingPathComponent("docs/runs/\(stamp)-\(mode.rawValue)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        logURL = directory.appendingPathComponent("events.jsonl")
        FileManager.default.createFile(atPath: logURL.path, contents: nil)
        handle = try FileHandle(forWritingTo: logURL)
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        print("Napló: \(directory.path)")
    }

    deinit { try? handle?.close() }

    struct Event: Encodable {
        let timestamp: String
        let frame: Int
        let analysis: FrameAnalysis
        let decision: ActionDecision
        let mapping: LocalWorldMap.Snapshot?
        let navigation: NavigationV2.Snapshot?
    }

    func append(frame: Int, analysis: FrameAnalysis, decision: ActionDecision, mapping: LocalWorldMap.Snapshot? = nil, navigation:NavigationV2.Snapshot?=nil) {
        let event = Event(
            timestamp: ISO8601DateFormatter().string(from: Date()),
            frame: frame,
            analysis: analysis,
            decision: decision,
            mapping: mapping,
            navigation:navigation
        )
        guard let data = try? encoder.encode(event) else { return }
        try? handle?.write(contentsOf: data + Data([0x0A]))
    }

    func appendRecording(frame:Int,width:Int,height:Int) {
        let event:[String:Any]=["frame":frame,"timestamp":Date().timeIntervalSince1970,
            "width":width,"height":height,"mode":"passive-human-demonstration","inputExecuted":false]
        guard let data=try? JSONSerialization.data(withJSONObject:event,options:[.sortedKeys]) else{return}
        try? handle?.write(contentsOf:data+Data([0x0A]))
    }

    func save(_ image: CGImage, frame: Int) {
        let url = directory.appendingPathComponent(String(format: "frame-%05d.png", frame))
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else { return }
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }

    func evidence(frame:Int)->String {directory.lastPathComponent+String(format:"/frame-%05d.png",frame)}
}

@MainActor
private final class Bot {
    private let options: Options
    private let capture = GameCapture()
    private let analyzer: Analyzer
    private let strategy: Strategy
    private let obstacleMap: PersistentObstacleMap
    private let localMap: LocalWorldMap
    private let navigationV2: NavigationV2
    private let mapObjectives: MapObjectivePlanner
    private var navigatedObjectiveID:String?
    private let landmarkGoal: LandmarkGoalNavigator
    private let progressWatchdog = ProgressWatchdog()
    private let westCourtyardExit = LandmarkCorridorPlanner(path:"docs/west-courtyard-exit.json")
    private let targetQuarantine = MinimapTargetQuarantine()
    private let farmGateway = MinimapFarmTracker()
    private let controller = SwipeController()
    private let logger: RunLogger

    init(options: Options) throws {
        self.options = options
        analyzer = Analyzer(readOnlyKnowledge: options.mode == .replay || options.mode == .observe || options.mode == .mapPan,
                            playerFixturePath: options.replayPlayerPath)
        strategy = Strategy(
            controlledBossTrialsEnabled: options.controlledBossTrials,
            readOnlyKnowledge: options.mode == .replay || options.mode == .observe,
            loadNavigationKnowledge: options.mode != .replay || options.replayNavigationPath != nil,
            navigationFixturePath: options.replayNavigationPath,
            playerFixturePath: options.replayPlayerPath
        )
        strategy.shopOnly = options.shopOnly
        strategy.kitingTrialEnabled = options.kitingTrial
        obstacleMap = PersistentObstacleMap(readOnly: options.mode == .replay || options.mode == .observe)
        localMap = LocalWorldMap(readOnly: options.mode != .play)
        navigationV2 = NavigationV2(readOnly:options.mode != .play)
        mapObjectives = MapObjectivePlanner(readOnly:options.mode != .play)
        landmarkGoal = LandmarkGoalNavigator(readOnly: options.mode != .play)
        logger = try RunLogger(mode: options.mode)
    }

    func run() async throws {
        // Két élő képrögzítő 20260919-130413-ban válasz nélkül maradt.
        // Replay párhuzamosítható, élő megfigyelés/input ugyanitt csak egy lehet.
        var captureLockFD: Int32 = -1
        if options.mode != .replay {
            captureLockFD = open("docs/runs/.live-capture.lock", O_CREAT | O_RDWR, mode_t(0o600))
            guard captureLockFD >= 0 else {
                throw BotError.captureFailed("Nem hozható létre az élő képrögzítés zárja.")
            }
            guard flock(captureLockFD, LOCK_EX | LOCK_NB) == 0 else {
                close(captureLockFD)
                throw BotError.captureFailed("Már fut élő bot/megfigyelés. Előbb azt állítsd le; replay közben is engedett.")
            }
        }
        defer {
            if captureLockFD >= 0 {
                flock(captureLockFD, LOCK_UN)
                close(captureLockFD)
            }
        }
        switch options.mode {
        case .observe: try await observe()
        case .play: try await play()
        case .replay: try replay()
        case .nudge: try await nudge()
        case .tap: try await tap()
        case .scroll: try await scroll()
        case .mapPan: try await mapPan()
        case .record: try await recordDemonstration()
        }
    }

    private func recordDemonstration() async throws {
        // Deliberately no analyzer, strategy, controller, focus or mouse calls.
        // High-cadence capture avoids OCR latency while the human demonstrates.
        let started=Date(),cancellation=RunCancellation.shared
        var index=0
        while Date().timeIntervalSince(started)<options.seconds && !cancellation.requested {
            let frame=try await capture.capture()
            logger.save(frame.cgImage,frame:index)
            logger.appendRecording(frame:index,width:frame.cgImage.width,height:frame.cgImage.height)
            index+=1
            if index%20==0 {print("Passzív felvétel: \(index) kép; input nincs")}
            await pause(options.interval)
        }
        print("Passzív felvétel kész: \(index) kép; inputot nem adtam")
    }

    private func tap() async throws {
        guard AXIsProcessTrusted() else { throw BotError.inputPermissionMissing }
        guard options.foreground else {
            throw BotError.badArguments("A tap módhoz add meg a --foreground kapcsolót.")
        }
        guard let rawX = options.tapX, let rawY = options.tapY else {
            throw BotError.badArguments("A tap módhoz --x és --y is kell.")
        }
        let frame = try await capture.capture()
        let analysis = analyzer.analyze(frame.pixelImage, cgImage: frame.cgImage)
        logger.save(frame.cgImage, frame: 0)
        // 0...1 között ablakarányt, nagyobb értéknél képpixelt fogadunk. Így a
        // ritka, kézzel felügyelt UI-felderítés felbontástól független marad.
        let x = rawX <= 1 ? rawX * Double(analysis.width) : rawX
        let y = rawY <= 1 ? rawY * Double(analysis.height) : rawY
        let previous = controller.focus(processID: frame.processID)
        defer { controller.restoreFocus(previous) }
        try controller.tap(
            processID: frame.processID,
            windowID: frame.windowID,
            windowFrame: frame.windowFrame,
            imageWidth: analysis.width,
            imageHeight: analysis.height,
            x: x,
            y: y,
            globalInput: true
        )
        print(String(format: "Tap: (%.1f, %.1f)", x, y))
    }

    private func mapPan() async throws {
        guard AXIsProcessTrusted(),options.foreground else{throw BotError.inputPermissionMissing}
        guard hypot(options.nudgeX,options.nudgeY)>0.01 else{throw BotError.badArguments("A map-pan iránya nem lehet nulla")}
        for index in 0..<options.nudgeSteps {
            let frame=try await capture.capture()
            let analysis=analyzer.analyze(frame.pixelImage,cgImage:frame.cgImage)
            logger.save(frame.cgImage,frame:index)
            guard analysis.expandedMapVisible==true else{throw BotError.badArguments("Térképhúzás csak igazolt nagy térképen")}
            guard controller.userIdleSeconds()>=options.minUserIdle else{print("A felhasználó aktív; térképhúzás kihagyva");return}
            let previous=controller.focus(processID:frame.processID)
            do {
                defer{controller.restoreFocus(previous)}
                try controller.swipe(processID:frame.processID,windowID:frame.windowID,windowFrame:frame.windowFrame,
                    imageWidth:analysis.width,imageHeight:analysis.height,anchorX:0.70,anchorY:0.27,
                    directionX:options.nudgeX,directionY:options.nudgeY,duration:0.18,
                    globalInput:true,dragDistanceFraction:0.17)
            }
            print("Nagy térkép húzása: \(options.nudgeX),\(options.nudgeY)")
            await pause(0.35)
        }
    }

    private func scroll() async throws {
        guard AXIsProcessTrusted(),options.foreground else{throw BotError.inputPermissionMissing}
        for index in 0..<options.nudgeSteps {
            let frame=try await capture.capture()
            let analysis=analyzer.analyze(frame.pixelImage,cgImage:frame.cgImage)
            logger.save(frame.cgImage,frame:index)
            guard analysis.shop?.visible==true else{throw BotError.badArguments("Görgetés csak igazolt SHOP-panelen")}
            guard controller.userIdleSeconds()>=options.minUserIdle else{print("A felhasználó aktív; görgetés kihagyva");return}
            let up=options.nudgeY<0
            let previous=controller.focus(processID:frame.processID)
            do {
                defer{controller.restoreFocus(previous)}
                try controller.swipe(processID:frame.processID,windowID:frame.windowID,windowFrame:frame.windowFrame,
                    imageWidth:analysis.width,imageHeight:analysis.height,anchorX:0.395,anchorY:up ? 0.78:0.30,
                    directionX:0,directionY:up ? -1:1,duration:0.12,globalInput:true,dragDistanceFraction:0.43)
            }
            await pause(0.7)
        }
    }

    private func nudge() async throws {
        guard AXIsProcessTrusted() else { throw BotError.inputPermissionMissing }
        guard options.foreground else {
            throw BotError.badArguments("A nudge módhoz add meg a --foreground kapcsolót.")
        }
        guard abs(options.nudgeX) + abs(options.nudgeY) > 0.01 else {
            throw BotError.badArguments("A nudge módhoz nem nulla --dx vagy --dy kell.")
        }
        for step in 0..<options.nudgeSteps {
            let frame = try await capture.capture()
            let analysis = analyzer.analyze(frame.pixelImage, cgImage: frame.cgImage)
            logger.save(frame.cgImage, frame: step)
            let previous = controller.focus(processID: frame.processID)
            do {
                defer { controller.restoreFocus(previous) }
                try controller.swipe(
                    processID: frame.processID,
                    windowID: frame.windowID,
                    windowFrame: frame.windowFrame,
                    imageWidth: analysis.width,
                    imageHeight: analysis.height,
                    anchorX: analysis.touchAnchor.x,
                    anchorY: analysis.touchAnchor.y,
                    directionX: options.nudgeX,
                    directionY: options.nudgeY,
                    duration: options.nudgeDuration,
                    globalInput: true
                )
            }
            print("Nudge \(step + 1)/\(options.nudgeSteps): (\(options.nudgeX), \(options.nudgeY))")
            await pause(options.interval)
        }
    }

    private func replay() throws {
        guard let path = options.replayPath else {
            throw BotError.badArguments("A replay módhoz adj meg egy PNG-fájlt vagy egy futási mappát.")
        }
        let inputURL = URL(fileURLWithPath: path, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)).standardizedFileURL
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: inputURL.path, isDirectory: &isDirectory) else {
            throw BotError.badArguments("Nem található visszajátszási útvonal: \(inputURL.path)")
        }
        let files: [URL]
        if isDirectory.boolValue {
            files = try FileManager.default.contentsOfDirectory(
                at: inputURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ).filter { $0.pathExtension.lowercased() == "png" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        } else {
            files = [inputURL]
        }
        guard !files.isEmpty else {
            throw BotError.badArguments("A visszajátszási útvonalon nincs PNG-képkocka.")
        }

        for (frameIndex, url) in files.enumerated() {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                print("Kihagyva, nem olvasható: \(url.path)")
                continue
            }
            let analysis = analyzer.analyze(try PixelImage(image), cgImage: image)
            let decision = strategy.decide(analysis)
            analyzer.adoptProvenMaximumDisplayedHP(strategy.provenMaximumDisplayedHP)
            logger.append(frame: frameIndex, analysis: analysis, decision: decision)
            print("\(url.lastPathComponent):", terminator: " ")
            printSummary(frame: frameIndex, analysis: analysis, decision: decision)
        }
    }

    private func observe() async throws {
        for frameIndex in 0..<options.frames {
            let frame = try await capture.capture()
            let analysis = analyzer.analyze(frame.pixelImage, cgImage: frame.cgImage)
            let decision = strategy.decide(analysis)
            analyzer.adoptProvenMaximumDisplayedHP(strategy.provenMaximumDisplayedHP)
            logger.append(frame: frameIndex, analysis: analysis, decision: decision)
            logger.save(frame.cgImage, frame: frameIndex)
            printSummary(frame: frameIndex, analysis: analysis, decision: decision)
            if options.debug {
                print("  piros komponensek: \(analysis.redBars)")
                print("  zöld komponensek:  \(analysis.greenBars)")
            }
            if frameIndex + 1 < options.frames { await pause(options.interval) }
        }
    }

    private func play() async throws {
        guard AXIsProcessTrusted() else { throw BotError.inputPermissionMissing }
        guard options.foreground else {
            throw BotError.badArguments("A fókuszmentes iPad-bemenet még nem bizonyított. Játékhoz jelenleg add meg a --foreground kapcsolót; az observe mód teljesen háttérbarát.")
        }
        let started = Date()
        let cancellation = RunCancellation.shared
        var frameIndex = 0
        var consecutiveCaptureFailures = 0

        while !cancellation.requested && Date().timeIntervalSince(started) < options.seconds {
            let frame: GameCapture.Frame
            do {
                frame = try await capture.capture()
                if consecutiveCaptureFailures > 0 {
                    print("A képrögzítés helyreállt \(consecutiveCaptureFailures) átmeneti hiba után.")
                    consecutiveCaptureFailures = 0
                }
            } catch {
                consecutiveCaptureFailures += 1
                print("Képrögzítési hiba #\(consecutiveCaptureFailures); újrapróbálom, a botfolyamat életben marad: \(error)")
                await pause(min(5.0, max(0.75, Double(consecutiveCaptureFailures) * 0.5)))
                continue
            }
            let analysis = analyzer.analyze(frame.pixelImage, cgImage: frame.cgImage)
            // A stratégia számlálói (célmemória, stagnálás, kerülőlépések) csak
            // akkor haladhatnak, ha az ebből következő input ténylegesen végre is
            // hajtható. Korábban aktív felhasználónál a swipe kimaradt, de például
            // a háromlépéses kerülő mindhárom belső lépése elfogyott mozgás nélkül.
            let userIsActive = controller.userIdleSeconds() < options.minUserIdle
            if analysis.shop?.visible != true && analysis.expandedMapVisible != true {
                landmarkGoal.observeVictory(pose:analysis.minimapPose,texts:analysis.titanQuestOCRStrings,evidence:logger.evidence(frame:frameIndex))
            }
            let settingsPanelVisible = analysis.settingsClose != nil &&
                analysis.titanQuestOCRStrings.contains { $0.uppercased().contains("SETTINGS") || $0.uppercased().contains("UNSTUCK") }
            let mappingEligible = !userIsActive && analysis.hudConfidence >= 0.8 &&
                analysis.expandedMapVisible != true && analysis.shop?.visible != true &&
                (analysis.popupClose == nil || analysis.playerHealthSource == "ocr-current") && !settingsPanelVisible &&
                (analysis.playerHealthFraction ?? 0) > 0.85
            _ = localMap.observe(frame.cgImage, eligible: mappingEligible, evidence: logger.evidence(frame:frameIndex),orangeCoverage:analysis.orangeRockCoverage,anchorPose:analysis.minimapPose)
            if mappingEligible {
                for target in analysis.visibleTargets {
                    if let hp=target.displayedHP {
                        localMap.recordEnemy(screenX:target.x,screenY:target.y,width:Double(analysis.width),
                            height:Double(analysis.height),hp:hp,evidence:logger.evidence(frame:frameIndex))
                    }
                }
            }
            obstacleMap.observe(analysis, allowLearning: !userIsActive && analysis.expandedMapVisible != true && analysis.shop?.visible != true)
            let mapSnapshot=localMap.snapshot()
            if mappingEligible {
                let anchor:NavigationV2.Point? = analysis.minimapPose.flatMap {
                    $0.anchor=="dusty-gulch-orange-skull" && $0.error<18
                        ? .init(x:$0.x,y:$0.y):nil
                }
                let motion:NavigationV2.Point? = mapSnapshot.motion.flatMap {
                    $0.valid && hypot($0.dx,$0.dy)<160 ? .init(x:-$0.dx,y:-$0.dy):nil
                }
                let terrain=mapSnapshot.chart.map {
                    NavigationV2.TerrainPose(chart:$0,x:mapSnapshot.position.x,y:mapSnapshot.position.y)
                }
                navigationV2.observe(anchor:anchor,motion:motion,evidence:logger.evidence(frame:frameIndex),
                    scene:analysis.sceneFingerprint,terrain:terrain)
            } else {navigationV2.suspend()}
            let watchdogLandmark:(Double,Double)? = analysis.minimapPose.flatMap { pose in
                switch pose.anchor {
                case "dusty-gulch-venom-guard": return (pose.x,pose.y)
                case "dusty-gulch-orange-skull": return (pose.x-4.5,pose.y-65.5)
                default:return nil
                }
            }
            let stalledNavigation=progressWatchdog.observe(chart:mapSnapshot.chart,
                x:mapSnapshot.position.x,y:mapSnapshot.position.y,
                eligible:mappingEligible && analysis.nearbyThreatCount==0 &&
                    (analysis.target?.distance ?? .infinity)>180 &&
                    (analysis.playerHealthFraction ?? 0)>=0.95,landmark:watchdogLandmark)
            let strategicDecision: ActionDecision = userIsActive
                ? .wait(reason: "A felhasználó aktív; elemzek, de a stratégia állapota és az input vár")
                : strategy.decide(analysis)
            analyzer.adoptProvenMaximumDisplayedHP(strategy.provenMaximumDisplayedHP)
            let experimentalSafetyAction: Bool
            switch strategicDecision {
            case .swipe(_, _, _, let reason), .wait(let reason):
                experimentalSafetyAction = reason.hasPrefix("Kitérős")
            default: experimentalSafetyAction = false
            }
            // Normal play has one navigation owner, including short approaches.
            // The old signature-based detour must not survive outside the
            // experimental branch and override V2 between its routing frames.
            var decision = strategicDecision
            if !options.kitingTrial,case .swipe(_,_,_,let reason)=strategicDecision,
               reason.hasPrefix("HP-t takaró időzítő:") {
                let probe=navigationV2.observationProbe()
                decision = .swipe(directionX:probe.x,directionY:probe.y,
                    duration:probe.duration,reason:probe.reason)
            }
            if options.kitingTrial && !userIsActive && !experimentalSafetyAction {
                decision = obstacleMap.adapt(strategicDecision, analysis: analysis)
            }
            func generalNavigation(_ reason:String)->Bool {
                NavigationIntentPolicy.owns(reason,targetDistance:analysis.target?.distance)
            }
            var v2Command:NavigationV2.Command?
            var usingMapObjective=false
            var freshMapObjectives=false
            if !options.kitingTrial,mappingEligible,analysis.expandedMapVisible != true,
               let marker=analysis.mapPlayerPosition,let here=navigationV2.snapshot().position {
                mapObjectives.observe(analysis.mapObjectives.map {
                    .init(kind:$0.kind,dx:$0.x-marker.x,dy:$0.y-marker.y)
                },space:navigationV2.snapshot().space,x:here.x,y:here.y)
                freshMapObjectives=true
            }
            // Legacy experimental navigation is isolated. Normal play has one owner.
            if options.kitingTrial {
            // Do not stack the old colour-signature detour and the measured
            // position controller: conflicting turns caused repeated loops.
            if mappingEligible,localMap.snapshot().motion?.valid==true,
               case .swipe(_,_,_,let reason)=strategicDecision,generalNavigation(reason) {
                decision=strategicDecision
            }
            var localFarmNavigation = false
            if mappingEligible, !options.kitingTrial, analysis.nearbyThreatCount==0,
               (analysis.target?.distance ?? .infinity)>400,
               case .swipe(_,_,_,let reason)=decision, generalNavigation(reason),
               let farm=analysis.localFarmDirection {
                localFarmNavigation = true
                decision = .swipe(directionX:farm.x,directionY:farm.y,duration:0.62,
                    reason:"Minimap alapján: tartott helyi piros farmcél; szigetmakró nem írhatja felül")
                if let gateway=farmGateway.gatewayDirection(pose:analysis.minimapPose,
                    toward:.init(x:farm.x,y:farm.y),orangeCoverage:analysis.orangeRockCoverage) {
                    decision = .swipe(directionX:gateway.x,directionY:gateway.y,duration:0.62,
                        reason:"Minimap alapján: helyi piros farmcél a szikla túloldalán; előbb a mért északi kapu")
                }
            }
            if !localFarmNavigation,mappingEligible,analysis.nearbyThreatCount==0,(analysis.target?.distance ?? .infinity)>180,
               case .swipe(let x,let y,_,let reason)=decision,generalNavigation(reason),
               let pose=analysis.minimapPose,let replacement=targetQuarantine.steer(pose:pose,x:x,y:y) {
                decision = .swipe(directionX:replacement.x,directionY:replacement.y,duration:0.62,reason:replacement.reason)
            }
            if !localFarmNavigation,mappingEligible,analysis.nearbyThreatCount==0,(analysis.target?.distance ?? .infinity)>180,
               case .swipe(_,_,_,let reason)=decision,generalNavigation(reason),
               let pose=analysis.minimapPose,let goal=landmarkGoal.direction(pose) {
                decision = .swipe(directionX:goal.x,directionY:goal.y,duration:0.62,reason:goal.reason)
            }
            if options.kitingTrial,!strategy.kitingTrialFinished,mappingEligible,
               case .swipe(_,_,_,let reason)=decision,generalNavigation(reason),let pose=analysis.minimapPose {
                let dx = -pose.x-(pose.anchor=="dusty-gulch-venom-guard" ? 4.5:0)
                let dy = -pose.y-(pose.anchor=="dusty-gulch-venom-guard" ? 65.5:0)
                let d=hypot(dx,dy)
                if d>5 {decision = .swipe(directionX:dx/d,directionY:dy/d,duration:0.55,
                    reason:"Térképi farmcél: kijelölt rövid kitérős bosskísérlet megközelítése")}
            }
            if !localFarmNavigation,mappingEligible,analysis.nearbyThreatCount==0,(analysis.target?.distance ?? .infinity)>180,
               case .swipe(_,_,_,let reason)=decision,generalNavigation(reason),
               let pose=analysis.minimapPose,let exit=westCourtyardExit.direction(pose) {
                decision = .swipe(directionX:exit.x,directionY:exit.y,duration:0.62,reason:exit.reason)
            }
            if mappingEligible,analysis.nearbyThreatCount==0,
               case .swipe(let x,let y,let duration,let reason)=decision,generalNavigation(reason),
               let steering=localMap.steer(x:x,y:y,duration:duration,allowGoalReplacement:!localFarmNavigation) {
                decision = .swipe(directionX:steering.x,directionY:steering.y,duration:steering.duration,reason:steering.reason)
            }
            } else if mappingEligible,analysis.nearbyThreatCount==0,
                      case .swipe(_,_,_,let reason)=strategicDecision,generalNavigation(reason) {
                let worldTarget=analysis.target.map {
                    navigationV2.screenOffset(x:$0.x-Double(analysis.width)*0.5,y:$0.y-Double(analysis.height)*0.515)
                }
                let objective=freshMapObjectives ? mapObjectives.choose():nil
                usingMapObjective=worldTarget==nil && analysis.localFarmOffset==nil && objective != nil
                let changedObjective=usingMapObjective && objective?.id != navigatedObjectiveID
                navigatedObjectiveID=usingMapObjective ? objective?.id:nil
                // Active weapon objectives replace indiscriminate skull chasing.
                // Red heads are progression bosses; orange goals need individual
                // combat evidence. Close world combat still owns its decisions.
                v2Command=navigationV2.decide(targetOffset:worldTarget ?? analysis.localFarmOffset.map{.init(x:$0.x,y:$0.y)} ?? objective.map{.init(x:$0.dx,y:$0.dy)},preferCurrentTarget:worldTarget != nil || changedObjective)
                if let command=v2Command {
                    let label=usingMapObjective ? " [aktív \(objective!.kind)]":""
                    decision = .swipe(directionX:command.x,directionY:command.y,duration:command.duration,reason:command.reason+label)
                } else {
                    decision = .wait(reason:"Navigáció V2: nincs igazolt pozíció vagy követhető helyi cél; nincs vak szigetmakró")
                }
            } else if !options.kitingTrial,case .swipe(_,_,_,let reason)=strategicDecision,generalNavigation(reason) {
                decision = .wait(reason:"Navigáció V2: a harci vagy helyzetbizonytalanság feloldásáig nincs régi szigetmakró")
            }
            if let stalledNavigation {decision = .stop(reason:stalledNavigation)}
            logger.append(frame: frameIndex, analysis: analysis, decision: decision,mapping:localMap.snapshot(),navigation:navigationV2.snapshot())
            if options.saveEvery > 0 && frameIndex % options.saveEvery == 0 {
                logger.save(frame.cgImage, frame: frameIndex)
            }
            printSummary(frame: frameIndex, analysis: analysis, decision: decision)

            if cancellation.requested { break }
            switch decision {
            case .scrollShop(let up, _):
                guard analysis.shop?.visible == true else { break }
                if controller.userIdleSeconds() < options.minUserIdle { break }
                let previous = controller.focus(processID: frame.processID)
                do {
                    defer { controller.restoreFocus(previous) }
                    try controller.swipe(processID:frame.processID,windowID:frame.windowID,
                        windowFrame:frame.windowFrame,imageWidth:analysis.width,imageHeight:analysis.height,
                        anchorX:0.395,anchorY:up ? 0.78 : 0.30,directionX:0,directionY:up ? -1 : 1,
                        duration:0.12,globalInput:options.foreground,dragDistanceFraction:0.43)
                }
                await pause(0.65)
            case .wait:
                await pause(options.interval)
            case .stop(let reason):
                print("Biztonsági leállás: \(reason)")
                return
            case .tap(let x, let y, _):
                if controller.userIdleSeconds() < options.minUserIdle {
                    print("  A felhasználó aktív; a bot nem veszi át az egeret, vár.")
                    await pause(max(0.5, options.interval))
                    break
                }
                let previous = controller.focus(processID: frame.processID)
                do {
                    defer { controller.restoreFocus(previous) }
                    try controller.tap(
                        processID: frame.processID,
                        windowID: frame.windowID,
                        windowFrame: frame.windowFrame,
                        imageWidth: analysis.width,
                        imageHeight: analysis.height,
                        x: x,
                        y: y,
                        globalInput: options.foreground
                    )
                }
                await pause(max(0.55, options.interval))
            case .swipe(let x, let y, let duration, let reason):
                if controller.userIdleSeconds() < options.minUserIdle {
                    print("  A felhasználó aktív; a bot nem veszi át az egeret, vár.")
                    await pause(max(0.5, options.interval))
                    break
                }
                let previous = controller.focus(processID: frame.processID)
                do {
                    defer { controller.restoreFocus(previous) }
                    try controller.swipe(
                        processID: frame.processID,
                        windowID: frame.windowID,
                        windowFrame: frame.windowFrame,
                        imageWidth: analysis.width,
                        imageHeight: analysis.height,
                        anchorX: analysis.touchAnchor.x,
                        anchorY: analysis.touchAnchor.y,
                        directionX: x,
                        directionY: y,
                        duration: duration,
                        globalInput: options.foreground
                    )
                    obstacleMap.recordExecuted(decision, analysis: analysis)
                    if let command=v2Command {navigationV2.recordExecuted(command)}
                    else if reason.hasPrefix("HP-t takaró időzítő:") {navigationV2.finishObservationProbe()}
                    else {navigationV2.handoffMovement()}
                    if usingMapObjective {mapObjectives.recordExecuted()}
                    localMap.recordExecuted(x:x,y:y,duration:duration,
                        learnObstacle:mappingEligible && analysis.nearbyThreatCount==0 &&
                        (generalNavigation(reason) || reason.hasPrefix("Saját helyi térkép:")))
                    if v2Command != nil || generalNavigation(reason) || reason.hasPrefix("Saját helyi térkép:") {
                        progressWatchdog.recordMovement()
                    }
                }
                await pause(options.interval)
            }
            frameIndex += 1
        }
        print(cancellation.requested ? "Megszakítás teljesítve: az input felengedve, a bot szabályosan leállt."
              : String(format: "Az időkorlát lejárt (%.1f másodperc), a bot szabályosan leállt.", options.seconds))
    }

    private func printSummary(frame: Int, analysis: FrameAnalysis, decision: ActionDecision) {
        let health: String
        if let displayed = analysis.playerDisplayedHP, let fraction = analysis.playerHealthFraction {
            let source = analysis.playerHealthSource == "ocr-current" ? "OCR" :
                (analysis.playerHealthSource == "pixel-fallback" ? "csík" : "memória")
            health = String(format: "%d / %.0f%% [%@]", displayed, fraction * 100, source)
        } else if let fraction = analysis.playerHealthFraction {
            health = String(format: "%.0f%% [%@]", fraction * 100, analysis.playerHealthSource)
        } else {
            health = "?"
        }
        let target = analysis.target.map {
            let level = $0.level.map(String.init) ?? "?"
            let hp = $0.displayedHP.map(String.init) ?? "?"
            return String(format: "%.0f px / szint %@ / HP %@", $0.distance, level, hp)
        } ?? "nincs biztonságos"
        let reward = analysis.recentRewardValue.map { " | jutalom +\($0)" } ?? ""
        print("[#\(frame)] HUD \(Int(analysis.hudConfidence * 100))% | HP \(health) | cél \(target)\(reward) | \(decision)")
        if options.debug {
            print("  játékos OCR: \(analysis.playerOCRStrings)")
            let biomeName = analysis.orangeRockBiomeVisible ? "narancsszikla" : "nem narancsszikla"
            print("  biom: \(biomeName)")
        }
    }

    private func pause(_ seconds: Double) async {
        let nanos = UInt64(max(0, seconds) * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanos)
    }
}

private func printUsageAndExit() -> Never {
    print("""
    ButcherHeroBot

      ButcherHeroBot observe [--frames 3] [--interval 0.3] [--debug]
      ButcherHeroBot record [--seconds 180] [--interval 0.15]
      ButcherHeroBot replay <frame.png|run-directory> [--debug] [--replay-navigation-state fixture.json]
                           [--replay-player-state player-fixture.json]
      ButcherHeroBot nudge --foreground --dx 1 --dy 0 [--steps 10] [--duration 0.62]
      ButcherHeroBot tap --foreground --x 0.061 --y 0.076
      ButcherHeroBot map-pan --foreground --dx 1 --dy 0 [--steps 1]
      ButcherHeroBot play --foreground [--seconds 60] [--interval 0.3] [--controlled-boss-trials]
                            [--save-every 10] [--min-user-idle 1.5] [--debug]

    Az observe csak élő képeket elemez, a replay korábbi képeket tesztel.
    A play időkorlátosan, a lenti virtuális karon végzett kitartott swipe-okkal játszik.
    Azonnali leállítás: Ctrl+C.
    """)
    Foundation.exit(0)
}

@main
private struct ButcherHeroBotMain {
    @MainActor
    static func main() async {
        _ = NSApplication.shared
        NSApplication.shared.setActivationPolicy(.prohibited)

        do {
            let options = try Options.parse(Array(CommandLine.arguments.dropFirst()))
            let bot = try Bot(options: options)
            try await bot.run()
        } catch {
            fputs("HIBA: \(error.localizedDescription)\n", stderr)
            Foundation.exit(1)
        }
    }
}
