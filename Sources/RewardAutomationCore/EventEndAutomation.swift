import Foundation
import CoreGraphics

public enum EventEndScreen:String,Codable {case offer,summary,hud,unknown}

public struct EventEndObservation:Codable {
    public let screen:EventEndScreen
    public let texts:[String]
    public init(screen:EventEndScreen,texts:[String]=[]) {self.screen=screen;self.texts=texts}
}

/// Only the demonstrated Diamond League expiry screens. A similarly coloured
/// purchase button or an unrelated CONTINUE is never a permitted target.
public final class EventEndVision {
    private let reader=RewardVision()
    public init() {}
    public func observe(_ image:CGImage,hudVisible:Bool)throws->EventEndObservation {
        // The offer's pink button + green progress bar can fool the legacy HUD
        // colour heuristic. Check this specific overlay BEFORE trusting HUD.
        let pixels=try Pixels(image)
        func fraction(_ r:CGRect,_ test:(Int,Int,Int)->Bool)->Double {
            Double(pixels.count(in:r,matching:test))/max(1,r.width*r.height*Double(pixels.w*pixels.h))
        }
        func text(_ r:CGRect,white:Bool=true)throws->String {
            try reader.recognize(image,roi:r,highContrast:white).map(\.text).joined(separator:" ").uppercased()
        }
        func compact(_ s:String)->String {s.filter{$0.isLetter || $0.isNumber}}
        let button=CGRect(x:0.315,y:0.898,width:0.37,height:0.049)
        let pink=fraction(button,{r,g,b in r>185 && g<100 && b>55 && b<180})
        let gold=fraction(button,{r,g,b in r>200 && g>120 && b<70})
        var words:[String]=[]
        if pink>0.40 {
            let label=try text(.init(x:0.40,y:0.906,width:0.20,height:0.033))
            let title=try text(.init(x:0.34,y:0.122,width:0.33,height:0.039),white:false)
            let ended=try text(.init(x:0.425,y:0.168,width:0.20,height:0.035))
            let progress=try text(.init(x:0.39,y:0.224,width:0.24,height:0.029),white:false)
            words=[label,title,ended,progress]
            if compact(label)=="NOTHANKS",compact(title)=="DIAMONDLEAGUE",
               compact(ended)=="TIMEISOVER",compact(progress)=="LEAGUEPROGRESS" {
                return .init(screen:.offer,texts:words)
            }
        }
        if gold>0.40 {
            let label=try text(.init(x:0.40,y:0.906,width:0.20,height:0.033))
            let ended=try text(.init(x:0.33,y:0.14,width:0.34,height:0.047))
            let league=try text(.init(x:0.40,y:0.184,width:0.21,height:0.029),white:false)
            let rewards=try text(.init(x:0.38,y:0.667,width:0.25,height:0.037),white:false)
            words=[label,ended,league,rewards]
            if compact(label)=="CONTINUE",compact(ended)=="EVENTENDS",
               compact(league)=="DIAMONDLEAGUE",compact(rewards)=="CRYSTALREWARDS" {
                return .init(screen:.summary,texts:words)
            }
        }
        // An obvious modal-shaped button with unreadable context isn't proof
        // of a returned HUD, even if the old HUD colour heuristic says true.
        return .init(screen:hudVisible && pink<=0.40 && gold<=0.40 ? .hud:.unknown,texts:words)
    }
}

public enum EventEndAction:String,Codable {
    case decline,proceed
    public var expectedScreen:EventEndScreen {self == .decline ? .offer:.summary}
    public var point:CGPoint {.init(x:0.50,y:0.922)}
    public func permits(_ observation:EventEndObservation,sameWindow:Bool=true,cancelled:Bool=false,elapsed:Double=0)->Bool {
        sameWindow && !cancelled && elapsed>=0 && elapsed<=3 && observation.screen==expectedScreen
    }
}

public enum EventEndInputPolicy {
    /// Reserve the FIRST recognised frame, including while a human is dragging.
    /// Any interrupted pending Free claim is discarded rather than inferred.
    public static func reservesInput(screen:EventEndScreen,active:Bool,wasActive:Bool)->Bool {
        active || wasActive || [.offer,.summary].contains(screen)
    }
}

public struct EventEndFlow {
    public enum Phase:String {case idle,declining,continuing,blocked}
    public private(set) var phase:Phase = .idle
    public private(set) var completed=0
    public private(set) var failure:String?
    private var previous:EventEndScreen?,stable=0
    private var attempts:[EventEndAction:Int]=[:]
    private var started:Double=0,lastSent = -Double.infinity
    public init() {}
    public var active:Bool {phase != .idle}
    public mutating func observe(_ observation:EventEndObservation,now:Double,inputReady:Bool)->EventEndAction? {
        if observation.screen==previous {stable+=1} else {previous=observation.screen;stable=1}
        if phase == .idle {
            guard [.offer,.summary].contains(observation.screen),stable>=2,inputReady else{return nil}
            phase = observation.screen == .offer ? .declining:.continuing
            started=now;attempts=[:];lastSent = -Double.infinity;failure=nil
        }
        if phase == .blocked {
            if observation.screen == .hud,stable>=2 {phase = .idle}
            return nil
        }
        if now-started>60 {phase = .blocked;failure="event_timeout";return nil}
        // A human may have dismissed the offer while the mouse guard waited.
        // The independently recognised summary is still authorised to continue.
        if phase == .declining,observation.screen == .summary {
            phase = .continuing
        }
        if [.declining,.continuing].contains(phase),observation.screen == .hud,stable>=2 {
            if attempts[.proceed,default:0]>0 {completed+=1}
            phase = .idle;return nil
        }
        let action:EventEndAction?
        switch phase {
        case .declining: action = observation.screen == .offer ? .decline:nil
        case .continuing: action = observation.screen == .summary ? .proceed:nil
        default: action=nil
        }
        guard let action,inputReady,now-lastSent>=1 else{return nil}
        guard attempts[action,default:0]<3 else {phase = .blocked;failure="event_attempt_limit_\(action.rawValue)";return nil}
        return action
    }
    public mutating func sent(_ action:EventEndAction,now:Double) {
        attempts[action,default:0]+=1;lastSent=now
    }
}
