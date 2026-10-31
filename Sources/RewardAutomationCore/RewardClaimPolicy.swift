import Foundation

/// Shared by the live mouse checks and deterministic tests. Cursor movement alone
/// is not a drag; wait briefly after a button event before taking over the mouse.
public enum RewardInputPolicy {
    public static func permitsClick(anyButtonDown:Bool,secondsSinceButtonActivity:TimeInterval)->Bool {
        !anyButtonDown && secondsSinceButtonActivity>=0.25
    }
}

public enum RewardClaimDecision:Equatable {case wait,retry,confirm}

public enum RewardPreclickDecision:Equatable {case accept,retry,reject}

/// A failed read permits another fresh screenshot, never a click from old data.
/// Changed offers/windows, cancellation and expired validation fail closed.
public struct RewardPreclickValidation {
    private let expected:String
    private var attempts=0,finished=false
    public init(expectedFingerprint:String){expected=expectedFingerprint}
    public mutating func observe(fingerprint:String?,sameWindow:Bool,cancelled:Bool,elapsed:TimeInterval)->RewardPreclickDecision {
        guard !finished else{return .reject}
        attempts+=1
        guard sameWindow,!cancelled,elapsed>=0,elapsed<=1.2 else{finished=true;return .reject}
        if fingerprint==expected {finished=true;return .accept}
        if fingerprint != nil || attempts>=3 {finished=true;return .reject}
        return .retry
    }
}

public enum RewardStabilityPolicy {
    /// Bridge one short text-reading gap only while the HUD AND card persist.
    /// The caller still requires a readable current frame plus preclick validation.
    public static func bridgeUnreadable(gameHUDVisible:Bool,cardVisible:Bool,lastReadableAt:TimeInterval?,now:TimeInterval)->Bool {
        guard gameHUDVisible,cardVisible,let lastReadableAt else{return false}
        return now>=lastReadableAt && now-lastReadableAt<=2.5
    }
}

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
