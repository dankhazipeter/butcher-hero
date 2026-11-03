import Foundation
import RewardAutomationCore

/// In-memory index of the Free journal, and the same aggregation the web dashboard did.
@MainActor final class StatsStore:ObservableObject {
    enum Range:String,CaseIterable,Identifiable {
        case run,today,hour,day,all,custom
        var id:String {rawValue}
        var label:String {
            switch self {
            case .run:"Mostani futás";case .today:"Ma";case .hour:"Utolsó óra"
            case .day:"24 óra";case .all:"Minden";case .custom:"Egyéni"
            }
        }
    }
    struct Kind:Identifiable,Hashable {
        let id:String,label:String
        static let all:[Kind]=[
            .init(id:"hp",label:"Health"),.init(id:"regeneration",label:"Health Regen"),
            .init(id:"piercing_damage",label:"Pierce Damage"),.init(id:"cutting_damage",label:"Cut Damage"),
            .init(id:"smash_damage",label:"Smash Damage"),.init(id:"piercing_defense",label:"Pierce Defense"),
            .init(id:"cutting_defense",label:"Cut Defense"),.init(id:"smash_defense",label:"Smash Defense")]
        /// Order of the stat cards.
        static let cardOrder=["hp","regeneration","piercing_damage","cutting_defense","cutting_damage","smash_defense","smash_damage","piercing_defense"]
        static func label(_ id:String)->String {all.first{$0.id==id}?.label ?? "Ismeretlen típus"}
    }
    struct Point:Identifiable {
        let id=UUID()
        let at:Date,value:Double
    }
    struct Row:Identifiable {let id:String,at:Date,kind:String,amount:Decimal?,confirmed:Bool}
    struct Summary {
        var from=Date(),to=Date(),bucketSeconds=60
        var confirmed=0,pending=0,unknownConfirmed=0,unclassified=0,attempts=0
        var lastConfirmedAt:Date?
        var totals:[String:Decimal]=[:]
        var counts:[String:Int]=[:]
        var series:[String:[Point]]=[:]          // cumulative stat amount
        var countSeries:[String:[Point]]=[:]     // cumulative number of claims
        var recent:[Row]=[]
    }
    struct Session:Codable {
        var schemaVersion=1
        var id:String
        var previousID:String?
        var startedAt:String
    }

    @Published var range:Range = .run {didSet{recompute()}}
    @Published var customFrom=Date().addingTimeInterval(-3600)
    @Published var customTo=Date()
    @Published private(set) var summary=Summary()
    @Published private(set) var malformedLines=0
    @Published private(set) var sessionStart:Date?

    private var clicks:[String:JournalEvent]=[:]       // last click_sent per claim
    private var clickTimes:[Date]=[]                    // every click_sent, for attempts
    private var confirmed=Set<String>(),corrected:[String:FreeReward]=[:]
    private var firstEventAt:Date?,watcherStartedAt:Date?
    private var dashboardSession:Session?

    init() {
        let (events,malformed)=Journal.read(AppPaths.free.appendingPathComponent("events.jsonl"))
        malformedLines=malformed
        for e in events {ingest(e)}
        dashboardSession=(try? Data(contentsOf:AppPaths.statSession)).flatMap{try? JSONDecoder().decode(Session.self,from:$0)}
        recompute()
    }

    func append(_ e:JournalEvent) {ingest(e);recompute()}

    private func ingest(_ e:JournalEvent) {
        guard let at=Stamp.date(e.timestamp) else{return}
        if firstEventAt==nil {firstEventAt=at}
        if e.event=="watcher_started" {watcherStartedAt=at}
        guard let id=e.claimID else{return}
        switch e.event {
        case "click_sent":clicks[id]=e;clickTimes.append(at)
        case "claim_confirmed_ui":confirmed.insert(id)
        case "reward_corrected":if let reward=e.reward {corrected[id]=reward}
        default:break
        }
    }

    /// "Mostani futás" starts at the last collector start, or a later manual marker.
    var currentSessionStart:Date {
        let watcher=watcherStartedAt ?? firstEventAt ?? Date()
        if let s=dashboardSession,let at=Stamp.date(s.startedAt),at>=watcher {return at}
        return watcher
    }

    /// Starts a new statistics period now; the collector keeps running.
    func startNewSession() {
        let id=UUID().uuidString.replacingOccurrences(of:"-",with:"").lowercased()
        let session=Session(id:id,previousID:dashboardSession?.id,startedAt:Stamp.string())
        try? FileManager.default.createDirectory(at:AppPaths.root,withIntermediateDirectories:true)
        if let data=try? JSONEncoder().encode(session) {try? data.write(to:AppPaths.statSession,options:.atomic)}
        dashboardSession=session
        range = .run
        recompute()
    }

    func recompute(now:Date=Date()) {
        let end=range == .custom ? customTo:now
        let start:Date
        switch range {
        case .run:start=currentSessionStart
        case .today:start=Calendar.current.startOfDay(for:now)
        case .hour:start=now.addingTimeInterval(-3600)
        case .day:start=now.addingTimeInterval(-86400)
        case .all:start=firstEventAt ?? now
        case .custom:start=customFrom
        }
        sessionStart=currentSessionStart
        var s=Summary()
        s.from=min(start,end);s.to=end
        let span=max(1,s.to.timeIntervalSince(s.from))
        s.bucketSeconds=[60,300,900,1800,3600,21600,86400,604800].first{span/Double($0)<=96} ?? Int((span/96).rounded(.up))
        s.attempts=clickTimes.filter{$0>=s.from && $0<s.to}.count

        var selected:[(id:String,at:Date,reward:FreeReward?)]=[]
        for (id,e) in clicks {
            guard let at=Stamp.date(e.timestamp),at>=s.from,at<s.to else{continue}
            selected.append((id,at,corrected[id] ?? e.reward))
        }
        selected.sort{$0.at<$1.at}
        var running:[String:Decimal]=[:],runningCount:[String:Int]=[:]
        for k in Kind.all {s.series[k.id]=[.init(at:s.from,value:0)];s.countSeries[k.id]=[.init(at:s.from,value:0)]}
        for claim in selected {
            let isConfirmed=confirmed.contains(claim.id)
            let kind=claim.reward?.kind ?? "unknown"
            let amount=claim.reward?.amount.flatMap{Decimal(string:$0,locale:Locale(identifier:"en_US_POSIX"))}.flatMap{$0>0 ? $0:nil}
            s.recent.append(.init(id:claim.id,at:claim.at,kind:kind,amount:amount,confirmed:isConfirmed))
            guard isConfirmed else{s.pending+=1;continue}
            s.confirmed+=1
            s.lastConfirmedAt=max(s.lastConfirmedAt ?? claim.at,claim.at)
            guard Kind.all.contains(where:{$0.id==kind}) else{s.unclassified+=1;s.unknownConfirmed+=1;continue}
            runningCount[kind,default:0]+=1
            s.countSeries[kind]?.append(.init(at:claim.at,value:Double(runningCount[kind]!)))
            guard let amount else{s.unknownConfirmed+=1;continue}
            running[kind,default:0]+=amount
            s.series[kind]?.append(.init(at:claim.at,value:NSDecimalNumber(decimal:running[kind]!).doubleValue))
        }
        for k in Kind.all {
            s.totals[k.id]=running[k.id] ?? 0
            s.counts[k.id]=runningCount[k.id] ?? 0
            s.series[k.id]?.append(.init(at:s.to,value:NSDecimalNumber(decimal:running[k.id] ?? 0).doubleValue))
            s.countSeries[k.id]?.append(.init(at:s.to,value:Double(runningCount[k.id] ?? 0)))
        }
        s.recent=Array(s.recent.reversed().prefix(100))
        summary=s
    }
}
