import Charts
import SwiftUI

struct OverviewView:View {
    @ObservedObject var model:AppModel
    @ObservedObject var stats:StatsStore
    @State private var hidden=Set<String>()
    var body:some View {
        ScrollView {
            VStack(alignment:.leading,spacing:16) {
                if !model.accessibilityGranted || !model.screenCaptureGranted {PermissionBanner(model:model)}
                if model.legacyRunning {
                    Banner(icon:"exclamationmark.triangle.fill",tone:.warn,
                           text:L("A régi parancssoros gyűjtő (ButcherHeroAutomation) még fut. Amíg fut, ez az app nem kattint.","The old command-line collector (ButcherHeroAutomation) is still running. This app won't click while it runs."))
                }
                HStack(alignment:.top,spacing:16) {
                    StatusCard(eyebrow:L("Játék","Game"),status:model.gameStatus) {
                        if model.game.state == .notRunning {
                            Button(L("Játék indítása","Launch game")){model.game.launch()}.buttonStyle(.borderedProminent).padding(.top,2)
                        }
                    }
                    StatusCard(eyebrow:L("Gyűjtő","Collector"),status:model.collectorStatus) {
                        if model.engine.isRunning {LastCapture(engine:model.engine)}
                    }
                }
                SummaryRow(stats:stats)
                Card {
                    VStack(alignment:.leading,spacing:14) {
                        CardHeader(title:L("Mit kaptunk gyakrabban?","What did we get most?"),
                                   subtitle:L("Halmozott, igazolt átvételek típusonként · vidd az egeret a görbére","Cumulative confirmed claims per kind · hover the lines"))
                        HStack(alignment:.center,spacing:24) {
                            DistributionDonut(summary:stats.summary).frame(width:170,height:170)
                            FrequencyLines(summary:stats.summary,hidden:hidden).frame(minHeight:230)
                        }
                        KindChips(summary:stats.summary,hidden:$hidden)
                    }
                }
                Text(L("Növekedés, statonként","Growth per stat")).font(.title3.weight(.semibold)).padding(.top,4)
                LazyVGrid(columns:[GridItem(.adaptive(minimum:300),spacing:16)],spacing:16) {
                    ForEach(StatsStore.Kind.cardOrder,id:\.self){StatKPI(kind:$0,summary:stats.summary)}
                }
                Text(L("A napló rögzített értékeit mutatjuk, nem a karakter szorzózott statváltozását.","Values are as logged, not the character's multiplied stat change."))
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(20)
        }
    }
}

// MARK: - Building blocks

struct Banner:View {
    let icon:String,tone:Tone,text:String
    var body:some View {
        Label {Text(text)} icon:{Image(systemName:icon).foregroundStyle(tone.color)}
            .font(.callout).padding(12).frame(maxWidth:.infinity,alignment:.leading)
            .background(tone.color.opacity(0.1),in:RoundedRectangle(cornerRadius:10,style:.continuous))
    }
}

private struct StatusCard<Accessory:View>:View {
    let eyebrow:String,status:StatusText
    @ViewBuilder var accessory:Accessory
    var body:some View {
        Card {
            HStack(alignment:.top,spacing:12) {
                Image(systemName:status.tone == .good ? "checkmark.circle.fill":status.tone == .warn ? "exclamationmark.circle.fill":"xmark.circle.fill")
                    .font(.title2).foregroundStyle(status.tone.color)
                    .contentTransition(.symbolEffect(.replace))
                VStack(alignment:.leading,spacing:4) {
                    Text(eyebrow.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text(status.title).font(.title3.weight(.semibold))
                    Text(status.detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
                    accessory
                }
            }
        }
        .animation(.smooth,value:status.title)
    }
}

/// Re-renders only itself once a second; the rest of the page stays untouched.
private struct LastCapture:View {
    let engine:CollectorEngine
    var body:some View {
        TimelineView(.periodic(from:.now,by:1)) {_ in
            if let at=engine.status.lastCheckedAt {
                Text(L("Legutóbbi képrögzítés: ","Last capture: ")+Format.time(at)).font(.caption).foregroundStyle(.secondary).monospacedDigit()
            }
        }
    }
}

struct PermissionBanner:View {
    @ObservedObject var model:AppModel
    var body:some View {
        Card {
            VStack(alignment:.leading,spacing:10) {
                Label(L("Engedélyek szükségesek","Permissions needed"),systemImage:"lock.shield").font(.headline)
                Text(L("A gyűjtéshez képernyőfelvételi (a játékablak lefotózásához) és Kisegítő lehetőségek (a háttérkattintáshoz) engedély kell. Egyszer kell megadni.",
                       "Collecting needs Screen Recording (to capture the game window) and Accessibility (for background clicks). Grant them once."))
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    PermissionLabel(name:L("Kisegítő lehetőségek","Accessibility"),granted:model.accessibilityGranted)
                    PermissionLabel(name:L("Képernyőfelvétel","Screen Recording"),granted:model.screenCaptureGranted)
                    Spacer()
                    Button(L("Engedélykérés","Request access")){model.requestPermissions()}.buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct PermissionLabel:View {
    let name:String,granted:Bool
    var body:some View {
        Label(name,systemImage:granted ? "checkmark.circle.fill":"xmark.circle").foregroundStyle(granted ? .green:.red)
    }
}

/// Period and headline numbers in one row of compact tiles.
private struct SummaryRow:View {
    @ObservedObject var stats:StatsStore
    var body:some View {
        let s=stats.summary
        VStack(alignment:.leading,spacing:10) {
            if stats.range == .custom {
                HStack {
                    DatePicker(L("Kezdet","From"),selection:$stats.customFrom)
                    DatePicker(L("Vége","To"),selection:$stats.customTo)
                    Button(L("Szűrés","Apply")){stats.recompute()}
                }
            }
            HStack(spacing:16) {
                Tile(label:stats.range.label,note:L("Kezdet: ","From: ")+Format.dateTime(s.from)) {
                    // Live elapsed time without re-rendering the page.
                    if stats.range == .custom {
                        Text(Format.duration(s.to.timeIntervalSince(s.from)))
                    } else {
                        Text(timerInterval:s.from...Date.distantFuture,countsDown:false)
                    }
                }
                Tile(label:L("Igazolt átvétel","Confirmed claims"),note:L("Kártyaeltűnéssel visszaigazolva","Confirmed by the card disappearing")) {
                    Text("\(s.confirmed)").contentTransition(.numericText(value:Double(s.confirmed))).animation(.default,value:s.confirmed)
                }
                Tile(label:L("Függő","Pending"),note:L("Nem része az összegeknek","Not part of the totals")) {
                    Text("\(s.pending)").contentTransition(.numericText(value:Double(s.pending))).animation(.default,value:s.pending)
                }
                Tile(label:L("Legutóbbi átvétel","Last claim"),note:L("\(s.attempts) kattintási próbálkozás","\(s.attempts) click attempts")) {
                    Text(s.lastConfirmedAt.map(Format.time) ?? "–")
                }
            }
            if s.unknownConfirmed>0 {
                Banner(icon:"questionmark.circle",tone:.warn,text:L("\(s.unknownConfirmed) igazolt átvétel típusa vagy mennyisége bizonytalan; nincs beleszámolva a statösszegekbe.",
                                                                   "\(s.unknownConfirmed) confirmed claims have an uncertain kind or amount; not included in the totals."))
            }
        }
    }
}

private struct Tile<Value:View>:View {
    let label:String,note:String
    @ViewBuilder var value:Value
    var body:some View {
        Card(padding:14) {
            VStack(alignment:.leading,spacing:4) {
                Text(label.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary).lineLimit(1)
                value.font(.system(size:26,weight:.bold,design:.rounded).monospacedDigit()).lineLimit(1).minimumScaleFactor(0.7)
                Text(note).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
        }
    }
}

struct KindIcon:View {
    let kind:String,size:CGFloat
    var body:some View {
        if let image=KindStyle.icon(kind) {Image(nsImage:image).resizable().interpolation(.high).frame(width:size,height:size)}
        else {Image(systemName:"questionmark.circle").frame(width:size,height:size)}
    }
}
