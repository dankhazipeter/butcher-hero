import Charts
import SwiftUI

struct OverviewView:View {
    @ObservedObject var model:AppModel
    @ObservedObject var stats:StatsStore
    var body:some View {
        ScrollView {
            VStack(alignment:.leading,spacing:16) {
                if !model.accessibilityGranted || !model.screenCaptureGranted {PermissionBanner(model:model)}
                if model.legacyRunning {
                    Banner(icon:"exclamationmark.triangle.fill",tone:.warn,
                           text:L("A régi parancssoros gyűjtő (ButcherHeroAutomation) még fut. Amíg fut, ez az app nem kattint.","The old command-line collector (ButcherHeroAutomation) is still running. This app won't click while it runs."))
                }
                HStack(alignment:.top,spacing:16) {
                    StatusBox(eyebrow:L("Játék","Game"),status:model.gameStatus) {
                        if model.game.state == .notRunning {
                            Button(L("Játék indítása","Launch game")){model.game.launch()}.padding(.top,4)
                        }
                    }
                    StatusBox(eyebrow:L("Gyűjtő","Collector"),status:model.collectorStatus) {
                        if let at=model.engine.status.lastCheckedAt,model.engine.isRunning {
                            Text(L("Legutóbbi képrögzítés: ","Last capture: ")+Format.time(at)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                PeriodBox(stats:stats)
                SummaryTiles(summary:stats.summary)
                FrequencyChart(summary:stats.summary)
                Text(L("Növekedés, statonként","Growth per stat")).font(.title3.weight(.semibold)).padding(.top,4)
                LazyVGrid(columns:[GridItem(.flexible(),spacing:16),GridItem(.flexible(),spacing:16)],spacing:16) {
                    ForEach(StatsStore.Kind.cardOrder,id:\.self){StatCard(kind:$0,summary:stats.summary)}
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
            .background(tone.color.opacity(0.1),in:RoundedRectangle(cornerRadius:8))
    }
}

private struct StatusBox<Accessory:View>:View {
    let eyebrow:String,status:StatusText
    @ViewBuilder var accessory:Accessory
    var body:some View {
        GroupBox {
            VStack(alignment:.leading,spacing:6) {
                Label {
                    Text(status.title).font(.title2.weight(.semibold))
                } icon:{
                    Image(systemName:status.tone == .good ? "checkmark.circle.fill":status.tone == .warn ? "exclamationmark.circle.fill":"xmark.circle.fill")
                        .foregroundStyle(status.tone.color)
                }
                .contentTransition(.opacity)
                Text(status.detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
                accessory
            }
            .frame(maxWidth:.infinity,alignment:.leading)
            .padding(6)
        } label:{
            Text(eyebrow.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        }
        .animation(.default,value:status.title)
    }
}

struct PermissionBanner:View {
    @ObservedObject var model:AppModel
    var body:some View {
        GroupBox {
            VStack(alignment:.leading,spacing:10) {
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
            .padding(6)
        } label:{Label(L("Engedélyek szükségesek","Permissions needed"),systemImage:"lock.shield")}
    }
}

struct PermissionLabel:View {
    let name:String,granted:Bool
    var body:some View {
        Label(name,systemImage:granted ? "checkmark.circle.fill":"xmark.circle").foregroundStyle(granted ? .green:.red)
    }
}

private struct PeriodBox:View {
    @ObservedObject var stats:StatsStore
    var body:some View {
        let s=stats.summary
        GroupBox {
            VStack(alignment:.leading,spacing:10) {
                if stats.range == .custom {
                    HStack {
                        DatePicker(L("Kezdet","From"),selection:$stats.customFrom)
                        DatePicker(L("Vége","To"),selection:$stats.customTo)
                        Button(L("Szűrés","Apply")){stats.recompute()}
                    }
                }
                Grid(alignment:.leading,horizontalSpacing:40,verticalSpacing:4) {
                    GridRow {
                        Text(L("Kezdet","From"));Text(L("Vége","To"));Text(L("Időintervallum hossza","Length"))
                    }.font(.caption).foregroundStyle(.secondary)
                    GridRow {
                        Text(Format.dateTime(s.from));Text(Format.dateTime(s.to))
                        Text(Format.duration(s.to.timeIntervalSince(s.from)))
                    }.font(.headline.monospacedDigit())
                }
                Text("\(TimeZone.current.identifier) · "+L("\(max(1,s.bucketSeconds/60)) perces diagrambontás","\(max(1,s.bucketSeconds/60))-minute chart buckets"))
                    .font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth:.infinity,alignment:.leading).padding(6)
        } label:{
            Text(L("Kiválasztott időszak: ","Selected period: ")+stats.range.label).font(.headline)
        }
    }
}

private struct SummaryTiles:View {
    let summary:StatsStore.Summary
    var body:some View {
        HStack(spacing:16) {
            Tile(label:L("Igazolt átvétel","Confirmed claims"),value:Double(summary.confirmed),text:"\(summary.confirmed)",note:L("Kártyaeltűnéssel visszaigazolva","Confirmed by the card disappearing"))
            Tile(label:L("Nem igazolt / függő","Unconfirmed / pending"),value:Double(summary.pending),text:"\(summary.pending)",note:L("Nem része a jutalomösszegeknek","Not part of the totals"))
            Tile(label:L("Legutóbbi átvétel","Last claim"),value:summary.lastConfirmedAt?.timeIntervalSince1970 ?? 0,
                 text:summary.lastConfirmedAt.map(Format.time) ?? "–",note:L("\(summary.attempts) kattintási próbálkozás","\(summary.attempts) click attempts"))
        }
        if summary.unknownConfirmed>0 {
            Banner(icon:"questionmark.circle",tone:.warn,text:L("\(summary.unknownConfirmed) igazolt átvétel típusa vagy mennyisége bizonytalan; nincs beleszámolva a statösszegekbe.",
                                                                 "\(summary.unknownConfirmed) confirmed claims have an uncertain kind or amount; not included in the totals."))
        }
    }
}

private struct Tile:View {
    let label:String,value:Double,text:String,note:String
    var body:some View {
        GroupBox {
            VStack(alignment:.leading,spacing:4) {
                Text(text).font(.system(size:30,weight:.bold).monospacedDigit())
                    .contentTransition(.numericText(value:value))
                    .animation(.default,value:value)
                Text(note).font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth:.infinity,alignment:.leading).padding(6)
        } label:{Text(label.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(.secondary)}
    }
}

private struct FrequencyChart:View {
    let summary:StatsStore.Summary
    @State private var hidden=Set<String>()
    var body:some View {
        let total=max(1,summary.counts.values.reduce(0,+))
        GroupBox {
            VStack(alignment:.leading,spacing:12) {
                Chart {
                    ForEach(StatsStore.Kind.all.filter{!hidden.contains($0.id)}) {kind in
                        ForEach(summary.countSeries[kind.id] ?? []) {p in
                            LineMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Darab","Count"),p.value),series:.value("Kind",kind.label))
                                .interpolationMethod(.stepEnd)
                                .foregroundStyle(KindStyle.color(kind.id))
                                .lineStyle(StrokeStyle(lineWidth:2,dash:KindStyle.dash(kind.id)))
                        }
                    }
                }
                .chartLegend(.hidden)
                .frame(height:220)
                LazyVGrid(columns:[GridItem(.adaptive(minimum:200),alignment:.leading)],alignment:.leading,spacing:6) {
                    ForEach(StatsStore.Kind.all) {kind in
                        let count=summary.counts[kind.id] ?? 0
                        Toggle(isOn:Binding(get:{!hidden.contains(kind.id)},set:{on in if on {hidden.remove(kind.id)} else {hidden.insert(kind.id)}})) {
                            HStack(spacing:6) {
                                KindIcon(kind:kind.id,size:16)
                                Text(kind.label)
                                Text("\(count) db · \(Format.percent(Double(count)/Double(total)))").foregroundStyle(.secondary)
                                    .contentTransition(.numericText(value:Double(count))).animation(.default,value:count)
                            }
                        }
                        .toggleStyle(.checkbox)
                        .tint(KindStyle.color(kind.id))
                    }
                }
            }
            .padding(6)
        } label:{
            VStack(alignment:.leading,spacing:2) {
                Text(L("Mit kaptunk gyakrabban?","What did we get most?")).font(.headline)
                Text(L("Halmozott, igazolt gyűjtések · darab","Cumulative confirmed claims · count")).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct StatCard:View {
    let kind:String,summary:StatsStore.Summary
    var body:some View {
        let total=summary.totals[kind] ?? 0
        let numeric=NSDecimalNumber(decimal:total).doubleValue
        GroupBox {
            VStack(alignment:.leading,spacing:6) {
                Text("+\(Format.compact(total))")
                    .font(.system(size:26,weight:.bold).monospacedDigit())
                    .foregroundStyle(KindStyle.color(kind))
                    .contentTransition(.numericText(value:numeric))
                    .animation(.default,value:numeric)
                    .help(Format.exact(total))
                HStack {
                    Text(L("Átlag: \(Format.rate(total,from:summary.from,to:summary.to))/perc","Average: \(Format.rate(total,from:summary.from,to:summary.to))/min"))
                    Spacer()
                    Text(L("\(summary.counts[kind] ?? 0) igazolt átvétel","\(summary.counts[kind] ?? 0) confirmed claims"))
                        .contentTransition(.numericText(value:Double(summary.counts[kind] ?? 0)))
                        .animation(.default,value:summary.counts[kind] ?? 0)
                }
                .font(.caption).foregroundStyle(.secondary)
                Chart(summary.series[kind] ?? []) {p in
                    AreaMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Érték","Value"),p.value)).interpolationMethod(.stepEnd)
                        .foregroundStyle(KindStyle.color(kind).opacity(0.15))
                    LineMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Érték","Value"),p.value)).interpolationMethod(.stepEnd)
                        .foregroundStyle(KindStyle.color(kind))
                }
                .chartXAxis(.hidden)
                .frame(height:80)
            }
            .padding(6)
        } label:{
            Label {Text(StatsStore.Kind.label(kind)).font(.headline)} icon:{KindIcon(kind:kind,size:18)}
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
