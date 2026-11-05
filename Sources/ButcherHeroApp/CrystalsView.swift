import SwiftUI
import RewardAutomationCore

/// Opened crystals from `crystal-rewards/results.jsonl`. New result frames are read on a
/// background utility queue, away from the collector: a failure here only leaves a crystal
/// unread, it never pauses or changes collecting.
@MainActor final class CrystalStore:ObservableObject {
    @Published private(set) var entries:[CrystalResultEntry]=[]
    private let queue=DispatchQueue(label:"crystal-results",qos:.utility)
    private var scheduled:DispatchWorkItem?
    private var results:URL {AppPaths.crystal.appendingPathComponent("results.jsonl")}

    init() {
        entries=CrystalResultLog.load(results)
        refresh(after:5)
    }

    /// Debounced: the result frame is written before its journal line, and the crystal flow
    /// is still clicking Continue right after it, so wait a few seconds.
    func refresh(after delay:TimeInterval=5) {
        scheduled?.cancel()
        let root=AppPaths.crystal,results=results
        let work=DispatchWorkItem {
            _=try? CrystalResultLog.update(root:root,results:results,source:"app")
            let loaded=CrystalResultLog.load(results)
            Task{@MainActor [weak self] in self?.entries=loaded}
        }
        scheduled=work
        queue.asyncAfter(deadline:.now()+delay,execute:work)
    }

    struct Row:Identifiable {
        let id:String,at:Date,result:CrystalResult,missing:Bool
    }
    func rows(from:Date,to:Date)->[Row] {
        entries.compactMap {e in
            guard let at=Stamp.date(e.openedAt),at>=from,at<to else{return nil}
            return Row(id:"\(e.source)/\(e.evidence)",at:at,result:e.result,missing:e.evidenceMissing==true)
        }.sorted{$0.at>$1.at}
    }
}

enum CrystalStyle {
    static let rarities=["grey","green","blue","purple","orange","red"]
    static let gems=["blue","green","red"]
    static func rarityColor(_ name:String?)->Color {
        switch name {
        case "grey":Color(light:"#8C99A3",dark:"#9AA6AF")
        case "green":Color(light:"#22B84A",dark:"#3DD068")
        case "blue":Color(light:"#1C97F5",dark:"#46ABFF")
        case "purple":Color(light:"#9450F0",dark:"#AC74FF")
        case "orange":Color(light:"#F2A007",dark:"#FFB833")
        case "red":Color(light:"#E03A3E",dark:"#FF5C60")
        default:Theme.rule
        }
    }
    static func gemColor(_ name:String?)->Color {
        switch name {
        case "blue":Color(light:"#4A86F0",dark:"#6E9FFF")
        case "green":Color(light:"#7DC424",dark:"#98DC45")
        case "red":Color(light:"#DC2160",dark:"#FF4D85")
        default:Theme.rule
        }
    }
    static func name(_ colour:String?)->String {
        switch colour {
        case "grey":L("Szürke","Grey");case "green":L("Zöld","Green");case "blue":L("Kék","Blue")
        case "purple":L("Lila","Purple");case "orange":L("Narancs","Orange");case "red":L("Piros","Red")
        default:L("Ismeretlen","Unknown")
        }
    }
    static func gemGroup(_ colour:String)->String {
        switch colour {
        case "blue":L("védelem","defence");case "green":L("élet","health");default:L("sebzés","damage")
        }
    }
}

struct CrystalsView:View {
    @ObservedObject var crystals:CrystalStore
    @ObservedObject var stats:StatsStore
    var body:some View {
        let s=stats.summary,rows=crystals.rows(from:s.from,to:s.to)
        ScrollView {
            VStack(alignment:.leading,spacing:30) {
                VStack(alignment:.leading,spacing:14) {
                    SectionTitle(title:L("Kristályok","Crystals"),note:L("\(rows.count) nyitott kristály a kiválasztott időszakban","\(rows.count) crystals opened in the selected period"),
                                 warning:rows.contains{$0.missing} ? L("van, amelynek a képe már törlődött: fajtája ismeretlen","some frames were already pruned: kind unknown"):nil)
                    HStack(alignment:.top,spacing:36) {
                        Tally(title:L("Ritkaság (háttér)","Rarity (tile)"),keys:CrystalStyle.rarities,values:rows.map(\.result.rarity),
                              color:CrystalStyle.rarityColor,label:CrystalStyle.name)
                        Tally(title:L("Kristály színe","Crystal colour"),keys:CrystalStyle.gems,values:rows.map(\.result.gem),
                              color:CrystalStyle.gemColor,label:{"\(CrystalStyle.name($0)) · \(CrystalStyle.gemGroup($0 ?? ""))"})
                        LevelTally(levels:rows.map(\.result.level))
                    }
                }
                VStack(alignment:.leading,spacing:10) {
                    SectionTitle(title:L("Statok","Stats"),note:L("amit a kristályok adtak","what the crystals gave"))
                    CrystalStatLedger(rows:rows)
                }
                VStack(alignment:.leading,spacing:10) {
                    SectionTitle(title:L("Mikor, mit","When, what"),note:L("legfrissebb elöl","newest first"))
                    CrystalList(rows:rows)
                }
                Text(L("A kristály adatait a mentett eredményképről olvassuk le utólag; amit nem lehet biztosan kiolvasni, az üresen marad.",
                       "Crystal details are read afterwards from the saved result frame; anything not read with certainty stays empty."))
                    .font(.footnote).foregroundStyle(Theme.steel)
            }
            .padding(.horizontal,28).padding(.top,22).padding(.bottom,28)
            .frame(maxWidth:1400,alignment:.leading)
        }
        .background(Theme.paper)
    }
}

/// A stacked bar plus a fixed-width legend; unknown values are counted separately.
private struct Tally:View {
    let title:String,keys:[String],values:[String?]
    let color:(String?)->Color,label:(String?)->String
    var body:some View {
        let total=max(1,values.count)
        let counts=Dictionary(grouping:values.compactMap{$0},by:{$0}).mapValues(\.count)
        let unknown=values.filter{$0==nil}.count
        VStack(alignment:.leading,spacing:10) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(Theme.steel).textCase(.uppercase)
            GeometryReader {geo in
                HStack(spacing:2) {
                    ForEach(keys.filter{(counts[$0] ?? 0)>0},id:\.self) {key in
                        Rectangle().fill(color(key))
                            .frame(width:max(3,(geo.size.width-12)*Double(counts[key] ?? 0)/Double(total)))
                            .help("\(label(key)): \(counts[key] ?? 0)")
                    }
                }
            }
            .frame(width:250,height:14)
            .background(Theme.rule.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius:3,style:.continuous))
            VStack(alignment:.leading,spacing:5) {
                ForEach(keys.filter{(counts[$0] ?? 0)>0},id:\.self) {key in
                    legend(color(key),label(key),counts[key] ?? 0,total)
                }
                if unknown>0 {legend(Theme.rule,L("Ismeretlen","Unknown"),unknown,total)}
                if values.isEmpty {Text("–").font(.callout).foregroundStyle(Theme.steel)}
            }
        }
        .frame(width:250,alignment:.leading)
    }
    private func legend(_ c:Color,_ text:String,_ n:Int,_ total:Int)->some View {
        HStack(spacing:7) {
            RoundedRectangle(cornerRadius:2).fill(c).frame(width:12,height:12)
            Text(text).font(.callout).foregroundStyle(Theme.ink).lineLimit(1).frame(width:140,alignment:.leading)
            Text("\(n)").font(.callout.monospacedDigit()).foregroundStyle(Theme.steel).frame(width:34,alignment:.trailing)
            Text(Format.percent(Double(n)/Double(total))).font(.caption.monospacedDigit()).foregroundStyle(Theme.steel).frame(width:48,alignment:.trailing)
        }
    }
}

private struct LevelTally:View {
    let levels:[Int?]
    var body:some View {
        let counts=Dictionary(grouping:levels.compactMap{$0},by:{$0}).mapValues(\.count)
        VStack(alignment:.leading,spacing:10) {
            Text(L("Szint","Level")).font(.caption.weight(.semibold)).foregroundStyle(Theme.steel).textCase(.uppercase)
            if counts.isEmpty {Text("–").font(.callout).foregroundStyle(Theme.steel)}
            ForEach(counts.keys.sorted(),id:\.self) {level in
                HStack(alignment:.firstTextBaseline,spacing:8) {
                    Text("\(level)").font(Theme.display(26)).foregroundStyle(Theme.ink).frame(width:44,alignment:.leading)
                    Text(L("\(counts[level] ?? 0) db","\(counts[level] ?? 0)×")).font(.callout.monospacedDigit()).foregroundStyle(Theme.steel)
                }
            }
            let unknown=levels.filter{$0==nil}.count
            if unknown>0 {Text(L("\(unknown) ismeretlen","\(unknown) unknown")).font(.caption).foregroundStyle(Theme.steel)}
        }
        .frame(width:140,alignment:.leading)
    }
}

/// One ruled row per stat with fixed column widths, like the Free stats ledger.
private struct CrystalStatLedger:View {
    let rows:[CrystalStore.Row]
    private enum W {static let stat:CGFloat=170,count:CGFloat=56,total:CGFloat=116,avg:CGFloat=96,gap:CGFloat=18}
    var body:some View {
        VStack(alignment:.leading,spacing:0) {
            HStack(spacing:W.gap) {
                Text(L("Stat","Stat")).frame(width:W.stat,alignment:.leading)
                Text(L("Darab","Count")).frame(width:W.count,alignment:.trailing)
                Text(L("Összesen","Total")).frame(width:W.total,alignment:.trailing)
                Text(L("Átlag","Average")).frame(width:W.avg,alignment:.trailing)
                Text(L("Ritkaság","Rarity")).frame(maxWidth:.infinity,alignment:.leading)
            }
            .font(.caption).foregroundStyle(Theme.steel).lineLimit(1)
            .padding(.bottom,6)
            ForEach(CrystalResultReader.stats,id:\.self) {stat in
                let mine=rows.filter{$0.result.stat==stat}
                if !mine.isEmpty {Divider();row(stat,mine)}
            }
            let unread=rows.filter{$0.result.stat==nil}.count
            if unread>0 {
                Divider()
                Text(L("\(unread) kristály statja nem olvasható","\(unread) crystals with an unreadable stat"))
                    .font(.callout).foregroundStyle(Theme.steel).padding(.vertical,9)
            }
            if rows.isEmpty {Text(L("Ebben az időszakban még nem nyitottunk kristályt.","No crystal opened in this period yet.")).font(.callout).foregroundStyle(Theme.steel).padding(.vertical,9)}
        }
    }
    private func row(_ stat:String,_ mine:[CrystalStore.Row])->some View {
        let amounts=mine.compactMap{$0.result.amount.flatMap{Decimal(string:$0,locale:Locale(identifier:"en_US_POSIX"))}}
        let total=amounts.reduce(0,+),color=CrystalStyle.gemColor(CrystalResultReader.gemColour(forStat:stat))
        let missing=mine.count-amounts.count
        return HStack(spacing:W.gap) {
            HStack(spacing:9) {
                Circle().fill(color).frame(width:10,height:10)
                Text(stat).font(.body.weight(.medium)).lineLimit(1)
            }
            .frame(width:W.stat,alignment:.leading)
            Text("\(mine.count)").font(.body.monospacedDigit()).foregroundStyle(Theme.steel).frame(width:W.count,alignment:.trailing)
            Text(amounts.isEmpty ? "–":"+\(Format.compact(total))").font(Theme.display(22)).foregroundStyle(amounts.isEmpty ? Theme.steel:color)
                .lineLimit(1).minimumScaleFactor(0.7).frame(width:W.total,alignment:.trailing)
                .help(missing>0 ? L("\(missing) összeg nem olvasható, kimarad","\(missing) amounts unreadable, left out"):Format.exact(total))
            Text(amounts.isEmpty ? "–":Format.compact(total/Decimal(amounts.count))).font(.callout.monospacedDigit()).foregroundStyle(Theme.steel)
                .lineLimit(1).frame(width:W.avg,alignment:.trailing)
            HStack(spacing:3) {
                ForEach(CrystalStyle.rarities,id:\.self) {r in
                    let n=mine.filter{$0.result.rarity==r}.count
                    if n>0 {
                        Text("\(n)").font(.caption.weight(.bold).monospacedDigit()).foregroundStyle(.white)
                            .frame(minWidth:22).padding(.vertical,2).padding(.horizontal,3)
                            .background(CrystalStyle.rarityColor(r),in:RoundedRectangle(cornerRadius:4))
                            .help("\(CrystalStyle.name(r)): \(n)")
                    }
                }
            }
            .frame(maxWidth:.infinity,alignment:.leading)
        }
        .frame(height:28).padding(.vertical,7)
    }
}

private struct CrystalList:View {
    let rows:[CrystalStore.Row]
    var body:some View {
        VStack(alignment:.leading,spacing:0) {
            HStack(spacing:16) {
                Text(L("Nyitás ideje","Opened")).frame(width:130,alignment:.leading)
                Text(L("Ritkaság","Rarity")).frame(width:110,alignment:.leading)
                Text(L("Kristály","Crystal")).frame(width:90,alignment:.leading)
                Text(L("Szint","Level")).frame(width:44,alignment:.trailing)
                Text(L("Stat","Stat")).frame(width:150,alignment:.leading)
                Text(L("Mennyiség","Amount")).frame(width:90,alignment:.trailing)
            }
            .font(.caption).foregroundStyle(Theme.steel).lineLimit(1).padding(.bottom,6)
            ForEach(rows.prefix(200)) {row in
                Divider()
                HStack(spacing:16) {
                    Text(Format.shortDateTime(row.at)).monospacedDigit().frame(width:130,alignment:.leading)
                    swatch(CrystalStyle.rarityColor(row.result.rarity),CrystalStyle.name(row.result.rarity)).frame(width:110,alignment:.leading)
                    swatch(CrystalStyle.gemColor(row.result.gem),CrystalStyle.name(row.result.gem),round:true).frame(width:90,alignment:.leading)
                    Text(row.result.level.map(String.init) ?? "–").monospacedDigit().frame(width:44,alignment:.trailing)
                    Text(row.result.stat ?? "–").lineLimit(1).frame(width:150,alignment:.leading)
                    Text(row.result.amount.flatMap{Decimal(string:$0,locale:Locale(identifier:"en_US_POSIX"))}.map{"+\(Format.compact($0))"} ?? "?")
                        .monospacedDigit().frame(width:90,alignment:.trailing)
                        .help(row.missing ? L("A kép már törlődött","Frame already pruned"):(row.result.rawAmount ?? ""))
                }
                .font(.callout).lineLimit(1).frame(height:26)
            }
        }
    }
    private func swatch(_ c:Color,_ text:String,round:Bool=false)->some View {
        HStack(spacing:6) {
            (round ? AnyShape(Circle()):AnyShape(RoundedRectangle(cornerRadius:3))).fill(c).frame(width:12,height:12)
            Text(text).lineLimit(1)
        }
    }
}
