import Foundation
import CoreGraphics

public enum CrystalScreen: String, Codable {
    case hud, inventoryReady, inventoryEmpty, inventoryUnavailable, geode, result, unknown
}

public struct CrystalObservation: Codable {
    public let screen: CrystalScreen
    public let notification: Bool
    public let texts: [String]
    public let closePoint:CGPoint?
    public let openPoint:CGPoint?
    public init(screen: CrystalScreen, notification: Bool = false, texts: [String] = [],closePoint:CGPoint?=nil,openPoint:CGPoint?=nil) {
        self.screen=screen; self.notification=notification; self.texts=texts
        self.closePoint=closePoint;self.openPoint=openPoint
    }
}

public enum CrystalInputPolicy {
    public static func isManualPanel(screen:CrystalScreen,active:Bool)->Bool {
        !active && [.inventoryReady,.inventoryEmpty,.inventoryUnavailable,.geode,.result].contains(screen)
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
        // Anchor the known inventory to its actual close button. Its vertical
        // position changes with window aspect; do not mistake it for the HUD.
        if let layout=CrystalInventoryLayout.locate(p) {
            let title=try words(layout.rect(.init(x:0.38,y:0.353,width:0.25,height:0.033)),white:false)
            var grid=try words(layout.rect(.init(x:0.37,y:0.616,width:0.26,height:0.029)))
            // Shorter windows compress the header gap independently of the X
            // anchor. Retry only two bounded upward crops; text stays exact.
            if compact(title)=="CRYSTALSTATS",compact(grid) != "CRYSTALS" {
                for dy in [-0.008,-0.016] {
                    let candidate=try words(layout.rect(.init(x:0.37,y:0.616+dy,width:0.26,height:0.029)))
                    if compact(candidate)=="CRYSTALS" {grid=candidate;break}
                }
            }
            diagnostics += ["inventory",title,grid,"layout=\(layout)"]
            if compact(title)=="CRYSTALSTATS",compact(grid)=="CRYSTALS" {
                for box in layout.goldButtons(p) {
                    let label=try words(.init(x:box.minX,y:box.minY,width:box.width,height:box.height*0.55))
                    if compact(label)=="X1" {
                        return .init(screen:.inventoryReady,texts:[title,grid,label,"layout=\(layout)"],
                            closePoint:layout.close,openPoint:.init(x:box.midX,y:box.midY))
                    }
                }
                let button=try words(layout.rect(.init(x:0.39,y:0.566,width:0.20,height:0.023)))
                let emptyButton=try words(layout.rect(.init(x:0.39,y:0.571,width:0.20,height:0.030)))
                let active=fraction(layout.rect(.init(x:0.39,y:0.565,width:0.20,height:0.043)),yellow)>0.35
                let grey=fraction(layout.rect(.init(x:0.40,y:0.57,width:0.18,height:0.03)),{r,g,b in
                    r>120 && r<210 && abs(r-g)<15 && abs(r-b)<15})>0.30
                let screen:CrystalScreen = !active && grey && compact(emptyButton)=="OPEN" ? .inventoryEmpty:.inventoryUnavailable
                return .init(screen:screen,texts:[title,grid,button,emptyButton,"layout=\(layout)"],
                    closePoint:layout.close,openPoint:layout.point(.init(x:0.49,y:0.585)))
            }
        }
        if hudVisible {
            // The red notification must have its white ring AND blue crystals
            // immediately below it. A red enemy/map marker alone is insufficient.
            let blue=CGRect(x:0.905,y:0.482,width:0.090,height:0.060)
            let crystal=fraction(blue,{r,g,b in b>170 && b>r+35 && g>90})
            let dot=CrystalNotificationMatcher.match(p)
            return .init(screen:.hud,notification:dot != nil && crystal>0.12,
                         texts:["ringDot=\(dot ?? "absent");blue=\(crystal)"])
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
            var header=try words(.init(x:0.34,y:0.562,width:0.33,height:0.037),white:false)
            if compact(button)=="CONTINUE",compact(header) != "CRYSTALSTATS" {
                // Exclude the bevel's decorative marks, not arbitrary words.
                header=try words(.init(x:0.365,y:0.562,width:0.275,height:0.037),white:false)
            }
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
        return .init(screen:.unknown,texts:diagnostics)
    }
}

struct CrystalInventoryLayout {
    let close:CGPoint
    let yScale:Double
    let xScale:Double
    let buttonWidth:Double
    func point(_ p:CGPoint)->CGPoint {.init(x:close.x+(p.x-0.74)*xScale,y:close.y+(p.y-0.144)*yScale)}
    func rect(_ r:CGRect)->CGRect {.init(origin:point(r.origin),size:.init(width:r.width*xScale,height:r.height*yScale))}
    func goldButtons(_ p:Pixels)->[CGRect] {
        let roi=rect(.init(x:0.33,y:0.55,width:0.34,height:0.065))
        let x0=max(0,Int(roi.minX*Double(p.w))),x1=min(p.w,Int(roi.maxX*Double(p.w)))
        let y0=max(0,Int(roi.minY*Double(p.h))),y1=min(p.h,Int(roi.maxY*Double(p.h)))
        let w=x1-x0,h=y1-y0;guard w>0,h>0 else{return []}
        var mask=[Bool](repeating:false,count:w*h),boxes:[CGRect]=[]
        for y in 0..<h {for x in 0..<w {let i=((y+y0)*p.w+x+x0)*4
            mask[y*w+x]=p.data[i]>200 && p.data[i+1]>120 && p.data[i+2]<70
        }}
        for start in mask.indices where mask[start] {
            var q=[start],head=0,l=w,r=0,t=h,b=0;mask[start]=false
            while head<q.count {
                let i=q[head],x=i%w,y=i/w;head+=1;l=min(l,x);r=max(r,x);t=min(t,y);b=max(b,y)
                for (nx,ny) in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)] where nx>=0 && nx<w && ny>=0 && ny<h {
                    let j=ny*w+nx;if mask[j] {mask[j]=false;q.append(j)}
                }
            }
            let bw=Double(r-l+1),bh=Double(b-t+1)
            if bw>Double(p.w)*0.06,bh>Double(p.h)*0.018,bw/bh>1.2,bw/bh<5,Double(q.count)>bw*bh*0.4 {
                boxes.append(.init(x:Double(x0+l)/Double(p.w),y:Double(y0+t)/Double(p.h),width:bw/Double(p.w),height:bh/Double(p.h)))
            }
        }
        return boxes.sorted{$0.minX<$1.minX}
    }
    static func locate(_ p:Pixels)->Self? {
        let x0=Int(Double(p.w)*0.66),x1=Int(Double(p.w)*0.83),y0=Int(Double(p.h)*0.045),y1=Int(Double(p.h)*0.23)
        let w=x1-x0,h=y1-y0
        guard w>0,h>0 else{return nil}
        var mask=[Bool](repeating:false,count:w*h)
        for y in 0..<h {for x in 0..<w {
            let i=((y+y0)*p.w+x+x0)*4,r=Int(p.data[i]),g=Int(p.data[i+1]),b=Int(p.data[i+2])
            mask[y*w+x]=r>185 && g<100 && b>55 && b<180
        }}
        for start in mask.indices where mask[start] {
            var q=[start],head=0,l=w,r=0,t=h,b=0;mask[start]=false
            while head<q.count {
                let i=q[head],x=i%w,y=i/w;head+=1;l=min(l,x);r=max(r,x);t=min(t,y);b=max(b,y)
                for (nx,ny) in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)] where nx>=0 && nx<w && ny>=0 && ny<h {
                    let j=ny*w+nx;if mask[j] {mask[j]=false;q.append(j)}
                }
            }
            let bw=Double(r-l+1),bh=Double(b-t+1),cx=Double(x0+l)+bw/2,cy=Double(y0+t)+bh/2
            guard bw>=Double(p.w)*0.09,bw<=Double(p.w)*0.15,bh>=Double(p.w)*0.025,bh<=Double(p.w)*0.08,
                  bw/bh>=1.5,bw/bh<=4,Double(q.count)>bw*bh*0.45,
                  cx/Double(p.w)>0.71,cx/Double(p.w)<0.78 else{continue}
            let center=CGRect(x:(cx-bw*0.22)/Double(p.w),y:(cy-bh*0.38)/Double(p.h),
                              width:bw*0.44/Double(p.w),height:bh*0.76/Double(p.h))
            let white=p.count(in:center){r,g,b in min(r,min(g,b))>200 && max(r,max(g,b))-min(r,min(g,b))<40}
            guard Double(white)>bw*bh*0.025 else{continue}
            // The panel can shrink independently of the entire window (e.g. x1+x2).
            // Reviewed642x951 reference has a78px pink-button component.
            let scale=bw/78.0
            return .init(close:.init(x:cx/Double(p.w),y:cy/Double(p.h)),
                yScale:951.0*scale/Double(p.h),xScale:642.0*scale/Double(p.w),buttonWidth:bw)
        }
        return nil
    }
}

/// A single compact red disk with a spatially surrounding white ring and dark
/// outline. Independent regional red/white counts also matched confetti.
enum CrystalNotificationMatcher {
    static func match(_ p:Pixels)->String? {
        let x0=Int(Double(p.w)*0.945),x1=min(p.w,Int(Double(p.w)*0.998))
        let y0=Int(Double(p.h)*0.45),y1=min(p.h,Int(Double(p.h)*0.505))
        let w=x1-x0,h=y1-y0
        guard w>0,h>0 else{return nil}
        func rgb(_ x:Int,_ y:Int)->(Int,Int,Int) {
            let i=(max(0,min(p.h-1,y))*p.w+max(0,min(p.w-1,x)))*4
            return (Int(p.data[i]),Int(p.data[i+1]),Int(p.data[i+2]))
        }
        var mask=[Bool](repeating:false,count:w*h)
        for y in 0..<h {for x in 0..<w {
            let (r,g,b)=rgb(x+x0,y+y0)
            mask[y*w+x]=r>185 && g<100 && b>55 && b<180
        }}
        for start in mask.indices where mask[start] {
            var queue=[start],head=0,minX=w,maxX=0,minY=h,maxY=0
            mask[start]=false
            while head<queue.count {
                let i=queue[head],x=i%w,y=i/w;head+=1
                minX=min(minX,x);maxX=max(maxX,x);minY=min(minY,y);maxY=max(maxY,y)
                for (nx,ny) in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)] where nx>=0 && nx<w && ny>=0 && ny<h {
                    let next=ny*w+nx
                    if mask[next] {mask[next]=false;queue.append(next)}
                }
            }
            let bw=Double(maxX-minX+1),bh=Double(maxY-minY+1),diameter=max(bw,bh)
            guard bw/bh>=0.70,bw/bh<=1.40,diameter>=Double(p.w)*0.009,
                  diameter<=Double(p.w)*0.029,Double(queue.count)/(bw*bh)>=0.55,
                  minX>0,maxX<w-1,minY>0,maxY<h-1 else{continue}
            let cx=Double(x0+minX)+((bw-1)/2),cy=Double(y0+minY)+((bh-1)/2),radius=diameter/2
            func ring(_ x:Double,_ y:Double,_ rad:Double)->(white:Int,neutral:Int,dark:Int,sectors:Int) {
                var white=0,neutral=0,dark=0,sectors=Set<Int>()
                for n in 0..<24 {
                    let a=Double(n)*2*Double.pi/24
                    func at(_ scales:[Double],_ predicate:(Int,Int,Int)->Bool)->Bool {
                        scales.contains {scale in
                            let (r,g,b)=rgb(Int((x+cos(a)*rad*scale).rounded()),Int((y+sin(a)*rad*scale).rounded()))
                            return predicate(r,g,b)
                        }
                    }
                    if at([1.10,1.30,1.50],{r,g,b in min(r,min(g,b))>205 && max(r,max(g,b))-min(r,min(g,b))<45}) {white+=1;sectors.insert(n/6)}
                    if at([1.10,1.30,1.50],{r,g,b in min(r,min(g,b))>150 && max(r,max(g,b))-min(r,min(g,b))<45}) {neutral+=1}
                    if at([1.65,1.90,2.15],{r,g,b in max(r,max(g,b))<105}) {dark+=1}
                }
                return (white,neutral,dark,sectors.count)
            }
            let original=ring(cx,cy,radius)
            if original.white>=18 && original.dark>=16 {
                return "center=\(cx),\(cy);diameter=\(diameter);whiteAngles=\(original.white)/24;darkAngles=\(original.dark)/24;mode=white-ring"
            }
            // At <=12px the thin white stroke is antialiased grey and the red
            // bounding box does not give an exact subpixel circle centre.
            // Require a solid circular red core, bright anchors in 3 quadrants,
            // and more complete neutral/dark rings on the SAME bounded fit.
            var coreRed=0
            for dy in -1...1 {for dx in -1...1 {
                let(r,g,b)=rgb(Int(cx.rounded())+dx,Int(cy.rounded())+dy)
                if r>185 && g<100 && b>55 && b<180 {coreRed+=1}
            }}
            guard diameter<=12,min(bw,bh)/diameter>=0.85,
                  Double(queue.count)/(bw*bh)>=0.70,coreRed>=8 else{continue}
            for oy in [0.0,-0.5,0.5,-1,1] {for ox in [0.0,-0.5,0.5,-1,1] {for dr in [0.0,-0.5,0.5] {
                let score=ring(cx+ox,cy+oy,radius+dr)
                if score.white>=4,score.sectors>=3,score.neutral>=20,score.dark>=20 {
                    return "center=\(cx),\(cy);diameter=\(diameter);whiteAngles=\(score.white)/24;whiteQuadrants=\(score.sectors)/4;neutralAngles=\(score.neutral)/24;darkAngles=\(score.dark)/24;offset=\(ox),\(oy);radiusShift=\(dr);coreRed=\(coreRed)/9;mode=antialiased-small-ring"
                }
            }}}
        }
        return nil
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
        if self == .closeInventory {return [.inventoryEmpty,.inventoryReady,.inventoryUnavailable].contains(observation.screen)}
        return observation.screen==expectedScreen && (self != .openInventory || observation.notification)
    }
    public func point(in observation:CrystalObservation)->CGPoint {
        if self == .closeInventory {return observation.closePoint ?? point}
        if self == .openOne {return observation.openPoint ?? point}
        return point
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
    private var continuePending=false
    private var emptyCleanupStarted:Double?
    public init() {}
    /// Explicit operator recovery only, from the unfinished transaction's own
    /// journal. It retains sent-attempt limits; no assumed success or UI clicks.
    public init(recovering actions:[CrystalAction],now:Double) {
        self.init()
        guard let last=actions.last else{return}
        started=now;lastSent=now
        for action in actions {attempts[action,default:0]+=1}
        strikes=attempts[.strike,default:0]
        resultSeen=last == .proceed || last == .closeInventory
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
            phase = .opening; started=now; attempts=[:]; strikes=0; failure=nil;resultSeen=false;continuePending=false;emptyCleanupStarted=nil
        }
        let unavailable=[CrystalScreen.inventoryEmpty,.inventoryUnavailable].contains(observation.screen)
        let owned=attempts[.openInventory,default:0]>0
        if phase == .opening,observation.screen == .hud,!observation.notification,stable>=2 {
            phase = .idle;cooldownUntil=now+60;return nil
        }
        if phase == .blocked {
            // One bounded cleanup of our OWN known inventory, never an unknown
            // modal, never another open/strike and never a fabricated result.
            if owned,unavailable,stable>=2,emptyCleanupStarted==nil,attempts[.closeInventory,default:0]<3 {
                emptyCleanupStarted=now;phase = .closing;failure=nil
            } else {
            // No auto-closing an unrecognised modal. Human return to HUD recovers.
            if observation.screen == .hud,stable>=2 {phase = .idle;cooldownUntil=now+60}
            return nil
            }
        }
        if let cleanup=emptyCleanupStarted {
            if now-cleanup>10 {phase = .blocked;failure="empty_cleanup_timeout";return nil}
        } else if now-started>90 {phase = .blocked;failure="transaction_timeout";return nil}
        if phase == .opening,attempts[.openInventory,default:0]>0,observation.screen == .inventoryReady {phase = .ready}
        if [.opening,.ready].contains(phase),owned,unavailable,
           observation.screen == .inventoryEmpty || stable>=2 {phase = .closing}
        if phase == .ready,attempts[.openOne,default:0]>0,observation.screen == .geode {phase = .breaking}
        if phase == .breaking,attempts[.strike,default:0]>0,observation.screen == .result {phase = .continuing;resultSeen=true;continuePending=true}
        // With multiple queued geodes, the game's own Continue may immediately
        // show the next stone. Never send another Open; retain TOTAL budgets.
        if phase == .continuing,!continuePending,attempts[.proceed,default:0]>0,observation.screen == .geode,stable>=2 {
            phase = .breaking;resultSeen=false
        }
        if phase == .continuing,!continuePending,attempts[.proceed,default:0]>0,unavailable {phase = .closing}
        // Available inventory after Continue is also closed; do not spend more
        // geodes from one notification without a fresh HUD notification.
        if phase == .continuing,!continuePending,attempts[.proceed,default:0]>0,observation.screen == .inventoryReady {phase = .closing}
        if phase == .closing,attempts[.closeInventory,default:0]>0,observation.screen == .hud,stable>=2 {
            let confirmed=resultSeen && !continuePending && attempts[.proceed,default:0]>0
            if confirmed {completed+=1}
            phase = .idle;cooldownUntil=now+(confirmed ? 5:60);return nil
        }
        let action:CrystalAction?
        switch phase {
        case .opening: action = observation.screen == .hud && observation.notification ? .openInventory:nil
        case .ready: action = observation.screen == .inventoryReady ? .openOne:nil
        case .breaking: action = observation.screen == .geode ? .strike:nil
        case .continuing: action = observation.screen == .result ? .proceed:nil
        case .closing: action = [.inventoryEmpty,.inventoryReady,.inventoryUnavailable].contains(observation.screen) ? .closeInventory:nil
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
        if action == .proceed {continuePending=false}
    }
    /// The initial notification may disappear after activation. No inventory
    /// click was sent, so don't monopolise collection for the full90s timeout.
    @discardableResult public mutating func abandonUnsentOpening(now:Double)->Bool {
        guard phase == .opening,attempts[.openInventory,default:0]==0 else{return false}
        phase = .idle;cooldownUntil=now+60
        return true
    }
}
