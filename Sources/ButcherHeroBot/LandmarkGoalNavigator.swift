import Foundation

/// Global coarse bearing toward a known repeatable spawn. LocalWorldMap still
/// owns obstacles; a minimap bearing is not a claim that a straight line is open.
final class LandmarkGoalNavigator {
    struct State:Codable {
        var nextCheckAt=Date.distantPast;var lastResult="not checked"
        var lastVictoryAt:Date?;var lastEvidence:String?
    }
    struct Direction {let x:Double;let y:Double;let reason:String}
    private let url=URL(fileURLWithPath:"docs/landmark-goals.json")
    private let readOnly:Bool
    private let corridor=LandmarkCorridorPlanner()
    private var state:State
    init(readOnly:Bool) {
        self.readOnly=readOnly
        state=(try? Data(contentsOf:url)).flatMap{try? JSONDecoder().decode(State.self,from:$0)} ?? State()
    }
    func observeVictory(pose:MinimapPose?,texts:[String],evidence:String) {
        guard let pose,texts.contains(where:{$0.uppercased().contains("LEVEL UP")}),
              Date().timeIntervalSince(state.lastVictoryAt ?? .distantPast)>60 else{return}
        let dx=pose.x-(pose.anchor=="dusty-gulch-orange-skull" ? 4.5:0)
        let dy=pose.y-(pose.anchor=="dusty-gulch-orange-skull" ? 65.5:0)
        guard hypot(dx,dy)<14 else{return}
        let pattern=#"^(\d{1,2})m\s*(\d{1,2})s$"#
        let regex=try! NSRegularExpression(pattern:pattern,options:.caseInsensitive)
        for text in texts {
            let raw=text.trimmingCharacters(in:.whitespacesAndNewlines)
            guard let m=regex.firstMatch(in:raw,range:NSRange(raw.startIndex...,in:raw)),
                  let mr=Range(m.range(at:1),in:raw),let sr=Range(m.range(at:2),in:raw),
                  let minutes=Int(raw[mr]),let seconds=Int(raw[sr]),(20...30).contains(minutes),seconds<60 else{continue}
            state.nextCheckAt=Date().addingTimeInterval(Double(minutes*60+seconds))
            state.lastVictoryAt=Date();state.lastEvidence=evidence
            state.lastResult="Venom vicinity: LEVEL UP + \(raw); next farm only after measured timer"
            if !readOnly,let data=try? JSONEncoder().encode(state){try? data.write(to:url,options:.atomic)}
            break
        }
    }
    func direction(_ pose:MinimapPose)->Direction? {
        guard Date()>=state.nextCheckAt else{return nil}
        if let next=corridor.direction(pose) {
            return .init(x:next.x,y:next.y,reason:next.reason)
        }
        let targetX:Double,targetY:Double
        switch pose.anchor {
        case "dusty-gulch-venom-guard": targetX=0;targetY=0
        // 140122/21: Venom icon (544.5,139), orange skull (540,73.5).
        case "dusty-gulch-orange-skull": targetX=4.5;targetY=65.5
        default:return nil
        }
        let dx=targetX-pose.x,dy=targetY-pose.y,d=hypot(dx,dy)
        if d<6 {
            state.nextCheckAt=Date().addingTimeInterval(180)
            state.lastResult="Venom spawn vicinity reached; not proof of kill or availability"
            if !readOnly,let data=try? JSONEncoder().encode(state){try? data.write(to:url,options:.atomic)}
            return nil
        }
        return .init(x:dx/d,y:dy/d,reason:"Térképi farmcél: a 3,06K Venom-őr helye; friss minimaptámpont, helyi akadálykerüléssel")
    }
}
