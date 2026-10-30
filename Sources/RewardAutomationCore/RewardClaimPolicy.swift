import Foundation

/// Shared by the live mouse checks and deterministic tests. Cursor movement alone
/// is not a drag; wait briefly after a button event before taking over the mouse.
public enum RewardInputPolicy {
    public static func permitsClick(anyButtonDown:Bool,secondsSinceButtonActivity:TimeInterval)->Bool {
        !anyButtonDown && secondsSinceButtonActivity>=0.25
    }
}

public enum RewardClaimDecision:Equatable {case wait,retry,confirm}

/// Only explicit card disappearance on two game-HUD frames confirms a claim.
/// A visible, readable unchanged Free card permits a retry after one second.
/// An obscured HUD or unreadable card is neither success nor permission to click.
public struct RewardClaimVerification {
    public let sentAt:TimeInterval
    private var absentFrames=0
    public init(sentAt:TimeInterval){self.sentAt=sentAt}
    public mutating func observe(gameHUDVisible:Bool,cardVisible:Bool,matchingOfferVisible:Bool,now:TimeInterval)->RewardClaimDecision {
        guard gameHUDVisible else{absentFrames=0;return .wait}
        if cardVisible || matchingOfferVisible {
            absentFrames=0
            return matchingOfferVisible && now-sentAt>=1 ? .retry:.wait
        }
        absentFrames+=1
        return absentFrames>=2 ? .confirm:.wait
    }
}
