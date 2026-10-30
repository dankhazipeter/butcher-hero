import Foundation
import CoreGraphics

public struct RewardText: Codable {
    public let text: String
    public let confidence: Float
    public let x: Double, y: Double, width: Double, height: Double
    public init(_ text: String, confidence: Float = 1, rect: CGRect) {
        self.text=text; self.confidence=confidence
        x=rect.minX; y=rect.minY; width=rect.width; height=rect.height
    }
    public var rect: CGRect { CGRect(x:x,y:y,width:width,height:height) }
}

public enum RewardAmount {
    /// Decimal strings preserve large M/B rewards without floating-point rounding.
    public static func parse(_ text: String) -> String? {
        let s=text.trimmingCharacters(in:.whitespacesAndNewlines).uppercased()
        guard s.range(of:#"^\+?\d+(?:[.,]\d+)?\s*[KMBT]?$"#,options:.regularExpression) != nil else{return nil}
        let suffix=s.last!, power: Int
        switch suffix {case "K":power=3; case "M":power=6; case "B":power=9; case "T":power=12; default:power=0}
        let number=(power>0 ? String(s.dropLast()):s).replacingOccurrences(of:",",with:".").trimmingCharacters(in:.whitespaces)
        guard var amount=Decimal(string:number,locale:Locale(identifier:"en_US_POSIX")),amount>0 else{return nil}
        for _ in 0..<power {amount *= 10}
        return NSDecimalNumber(decimal:amount).stringValue
    }
}

public struct FreeReward: Codable {
    public let kind: String
    public let amount: String?
    public let rawAmount: String?
    public let classification: String
    public let texts: [RewardText]
    public let tapX: Double, tapY: Double
    public let badgeX: Double, badgeY: Double
    public let iconFeatures: [String:Int]
    // Icon uncertainty must not turn one unchanged offer into two clickable offers.
    public var fingerprint: String { "left-event|\(amount ?? rawAmount ?? "unknown")" }
}

/// Legacy/dry-run deduplication only. Live claims use RewardClaimVerification:
/// a sent but ineffective click must be retryable, not permanently reserved.
public struct RewardGate {
    public private(set) var blockedFingerprint: String?
    private var absentFrames=0
    public init(blockedFingerprint:String?=nil){self.blockedFingerprint=blockedFingerprint}
    public mutating func observe(_ reward:FreeReward?) {
        if reward == nil {absentFrames+=1; if absentFrames>=3 {blockedFingerprint=nil}}
        else {absentFrames=0}
    }
    public func permits(_ reward:FreeReward)->Bool {blockedFingerprint != reward.fingerprint}
    public mutating func reserve(_ reward:FreeReward){blockedFingerprint=reward.fingerprint;absentFrames=0}
    /// Only call after a failure BEFORE mouse-down. A sent click stays reserved.
    public mutating func releaseUnsent(_ reward:FreeReward){
        if blockedFingerprint==reward.fingerprint {blockedFingerprint=nil;absentFrames=0}
    }
}
