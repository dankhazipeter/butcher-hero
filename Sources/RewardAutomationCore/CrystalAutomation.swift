import Foundation
import CoreGraphics

public enum CrystalScreen: String, Codable {
    case hud, inventoryReady, inventoryEmpty, geode, result, unknown
}

public struct CrystalObservation: Codable {
    public let screen: CrystalScreen
    public let notification: Bool
    public let texts: [String]
    public init(screen: CrystalScreen, notification: Bool = false, texts: [String] = []) {
        self.screen=screen; self.notification=notification; self.texts=texts
    }
}

/// Restricted to the four user-demonstrated screens. No sell/upgrade actions.
public final class CrystalVision {
    private let reader=RewardVision()
    public init() {}
    public func observe(_ image: CGImage, hudVisible: Bool) throws -> CrystalObservation {
        let p=try Pixels(image)
        var diagnostics:[String]=[]
        func fraction(_ r: CGRect, _ predicate: (Int,Int,Int)->Bool)->Double {
            Double(p.count(in:r,matching:predicate))/max(1,r.width*r.height*Double(p.w*p.h))
        }
        let pink: (Int,Int,Int)->Bool = {r,g,b in r>185 && g<100 && b>55 && b<180}
        let yellow: (Int,Int,Int)->Bool = {r,g,b in r>200 && g>120 && b<70}
        func words(_ r: CGRect, white:Bool=true) throws -> String {
            try reader.recognize(image,roi:r,highContrast:white).map(\.text).joined(separator:" ").uppercased()
        }
        func compact(_ s:String)->String {s.filter{$0.isLetter || $0.isNumber}}
        if hudVisible {
            // The red notification must have its white ring AND blue crystals
            // immediately below it. A red enemy/map marker alone is insufficient.
            let badge=CGRect(x:0.955,y:0.455,width:0.041,height:0.045)
            let blue=CGRect(x:0.905,y:0.482,width:0.090,height:0.060)
            let red=fraction(badge,pink)
            let white=fraction(badge,{r,g,b in min(r,min(g,b))>210})
            let crystal=fraction(blue,{r,g,b in b>170 && b>r+35 && g>90})
            return .init(screen:.hud,notification:red>0.035 && white>0.025 && crystal>0.12,
                         texts:["dotRed=\(red);dotWhite=\(white);blue=\(crystal)"])
        }
        // After the first strike the brown card and its close button disappear.
        // Only the cracked purple stone and the explicit TAP hint remain.
        let purple=fraction(.init(x:0.355,y:0.31,width:0.30,height:0.215),{r,g,b in
            b>120 && b>r+15 && b>g+10 && r>45})
        if purple>0.28 {
            let hint=try words(.init(x:0.32,y:0.837,width:0.37,height:0.039))
            if compact(hint)=="TAPTOOPENGEODE" {return .init(screen:.geode,texts:[hint,"purpleStone=\(purple)"])}
        }
        // Result is a different overlay, with a bottom yellow CONTINUE button.
        if fraction(.init(x:0.33,y:0.89,width:0.34,height:0.05),yellow)>0.28 {
            let button=try words(.init(x:0.335,y:0.898,width:0.33,height:0.030))
            let header=try words(.init(x:0.34,y:0.562,width:0.33,height:0.037),white:false)
            diagnostics += ["result",button,header]
            if compact(button)=="CONTINUE", compact(header)=="CRYSTALSTATS" {
                return .init(screen:.result,texts:[header,button])
            }
        }
        // The geode's own close button is NEVER the inventory close target.
        if fraction(.init(x:0.68,y:0.24,width:0.12,height:0.035),pink)>0.35 {
            let title=try words(.init(x:0.32,y:0.25,width:0.355,height:0.032),white:false)
            let hint=try words(.init(x:0.32,y:0.837,width:0.37,height:0.039))
            diagnostics += ["geode",title,hint]
            if compact(title).hasPrefix("BLACKSMITHING"),compact(hint)=="TAPTOOPENGEODE" {
                return .init(screen:.geode,texts:[title,hint])
            }
        }
        if fraction(.init(x:0.68,y:0.125,width:0.12,height:0.034),pink)>0.35 {
            let title=try words(.init(x:0.38,y:0.353,width:0.25,height:0.033),white:false)
            let grid=try words(.init(x:0.37,y:0.616,width:0.26,height:0.029))
            diagnostics += ["inventory",title,grid]
            if compact(title)=="CRYSTALSTATS",compact(grid)=="CRYSTALS" {
                let button=try words(.init(x:0.39,y:0.566,width:0.20,height:0.023))
                let emptyButton=try words(.init(x:0.39,y:0.571,width:0.20,height:0.030))
                let counter=try words(.init(x:0.20,y:0.596,width:0.072,height:0.027),white:false)
                diagnostics += [button,emptyButton,counter]
                let active=fraction(.init(x:0.39,y:0.565,width:0.20,height:0.043),yellow)>0.35
                if compact(button)=="X1",active {
                    return .init(screen:.inventoryReady,texts:[title,grid,button,counter])
                }
                // A grey, disabled OPEN is distinct from the active gold x1.
                // The stylised counter is kept as raw evidence, not a made-up count.
                let grey=fraction(.init(x:0.40,y:0.57,width:0.18,height:0.03),{r,g,b in
                    r>120 && r<210 && abs(r-g)<15 && abs(r-b)<15})>0.30
                if compact(emptyButton)=="OPEN",grey,!active {
                    return .init(screen:.inventoryEmpty,texts:[title,grid,button,counter])
                }
            }
        }
        return .init(screen:.unknown,texts:diagnostics)
    }
}

public enum CrystalAction: String, Codable {
    case openInventory, openOne, strike, proceed, closeInventory
    public var expectedScreen: CrystalScreen {
        switch self {
        case .openInventory: return .hud
        case .openOne: return .inventoryReady
        case .strike: return .geode
        case .proceed: return .result
        case .closeInventory: return .inventoryEmpty
        }
    }
    public var point: CGPoint {
        switch self {
        case .openInventory: return .init(x:0.945,y:0.510)
        case .openOne: return .init(x:0.49,y:0.585)
        case .strike: return .init(x:0.50,y:0.425)
        case .proceed: return .init(x:0.50,y:0.916)
        case .closeInventory: return .init(x:0.74,y:0.144)
        }
    }
    public func permits(_ observation: CrystalObservation)->Bool {
        if self == .closeInventory {return observation.screen == .inventoryEmpty || observation.screen == .inventoryReady}
        return observation.screen==expectedScreen && (self != .openInventory || observation.notification)
    }
}

/// One x1 per notification transaction, bounded strikes/retries, no blind input.
/// Sent actions advance only when their expected NEXT screen is actually seen.
public struct CrystalFlow {
    public enum Phase: String {case idle, opening, ready, breaking, continuing, closing, blocked}
    public private(set) var phase: Phase = .idle
    public private(set) var strikes=0
    public private(set) var completed=0
    public private(set) var failure: String?
    private var started: Double=0, lastSent = -Double.infinity
    private var attempts: [CrystalAction:Int]=[:]
    private var stable=0, previous:CrystalScreen?
    private var previousNotification=false
    private var cooldownUntil: Double=0
    private var resultSeen=false
    public init() {}
    /// Explicit operator recovery only, from the unfinished transaction's own
    /// journal. It retains sent-attempt limits; no assumed success or UI clicks.
    public init(recovering actions:[CrystalAction],now:Double) {
        self.init()
        guard let last=actions.last else{return}
        started=now;lastSent=now
        for action in actions {attempts[action,default:0]+=1}
        strikes=attempts[.strike,default:0];resultSeen=attempts[.proceed,default:0]>0
        switch last {
        case .openInventory:phase = .opening
        case .openOne:phase = .ready
        case .strike:phase = .breaking
        case .proceed:phase = .continuing
        case .closeInventory:phase = .closing
        }
    }
    public var active: Bool {phase != .idle}
    public mutating func observe(_ observation:CrystalObservation, now:Double, inputReady:Bool, mayStart:Bool=true)->CrystalAction? {
        if observation.screen==previous && observation.notification==previousNotification {stable+=1}
        else {previous=observation.screen;previousNotification=observation.notification;stable=1}
        if phase == .idle {
            guard mayStart,inputReady,now>=cooldownUntil,observation.screen == .hud,observation.notification,stable>=2 else{return nil}
            phase = .opening; started=now; attempts=[:]; strikes=0; failure=nil;resultSeen=false
        }
        if phase == .blocked {
            // No auto-closing an unrecognised modal. Human return to HUD recovers.
            if observation.screen == .hud,stable>=2 {phase = .idle;cooldownUntil=now+60}
            return nil
        }
        if now-started>90 {phase = .blocked;failure="transaction_timeout";return nil}
        if phase == .opening,attempts[.openInventory,default:0]>0,observation.screen == .inventoryReady {phase = .ready}
        if phase == .opening,attempts[.openInventory,default:0]>0,observation.screen == .inventoryEmpty {phase = .closing}
        if phase == .ready,attempts[.openOne,default:0]>0,observation.screen == .geode {phase = .breaking}
        if phase == .breaking,attempts[.strike,default:0]>0,observation.screen == .result {phase = .continuing;resultSeen=true}
        if phase == .continuing,attempts[.proceed,default:0]>0,observation.screen == .inventoryEmpty {phase = .closing}
        // Available inventory after Continue is also closed; do not spend more
        // geodes from one notification without a fresh HUD notification.
        if phase == .continuing,attempts[.proceed,default:0]>0,observation.screen == .inventoryReady {phase = .closing}
        if phase == .closing,attempts[.closeInventory,default:0]>0,observation.screen == .hud,stable>=2 {
            if resultSeen {completed+=1}
            phase = .idle;cooldownUntil=now+(resultSeen ? 5:60);return nil
        }
        let action:CrystalAction?
        switch phase {
        case .opening: action = observation.screen == .hud ? .openInventory:nil
        case .ready: action = observation.screen == .inventoryReady ? .openOne:nil
        case .breaking: action = observation.screen == .geode ? .strike:nil
        case .continuing: action = observation.screen == .result ? .proceed:nil
        case .closing: action = [.inventoryEmpty,.inventoryReady].contains(observation.screen) ? .closeInventory:nil
        default: action=nil
        }
        guard let action,inputReady,now-lastSent>=1 else{return nil}
        let limit=action == .strike ? 16:3
        if attempts[action,default:0]>=limit {phase = .blocked;failure="attempt_limit_\(action.rawValue)";return nil}
        return action
    }
    public mutating func sent(_ action:CrystalAction,now:Double) {
        lastSent=now;attempts[action,default:0]+=1
        if action == .strike {strikes+=1}
    }
    /// The initial notification may disappear after activation. No inventory
    /// click was sent, so don't monopolise collection for the full90s timeout.
    @discardableResult public mutating func abandonUnsentOpening(now:Double)->Bool {
        guard phase == .opening,attempts[.openInventory,default:0]==0 else{return false}
        phase = .idle;cooldownUntil=now+60
        return true
    }
}
