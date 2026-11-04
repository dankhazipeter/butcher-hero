import Charts
import SwiftUI

struct OverviewView:View {
    @ObservedObject var model:AppModel
    @ObservedObject var stats:StatsStore
    @State private var hidden=Set<String>()
    var body:some View {
        ScrollView {
            VStack(alignment:.leading,spacing:0) {
                StatusBand(model:model,stats:stats)
                VStack(alignment:.leading,spacing:30) {
                    if !model.accessibilityGranted || !model.screenCaptureGranted {PermissionNotice(model:model)}
                    if model.legacyRunning {
                        Notice(icon:"exclamationmark.triangle.fill",tone:.warn,
                               text:L("A régi parancssoros gyűjtő (ButcherHeroAutomation) még fut. Amíg fut, ez az app nem kattint.","The old command-line collector (ButcherHeroAutomation) is still running. This app won't click while it runs."))
                    }
                    if stats.range == .custom {CustomRange(stats:stats)}
                    if stats.summary.unknownConfirmed>0 {
                        Notice(icon:"questionmark.circle",tone:.warn,
                               text:L("\(stats.summary.unknownConfirmed) átvétel típusa vagy mennyisége bizonytalan, ezek nincsenek az összegekben.",
                                      "\(stats.summary.unknownConfirmed) claims have an uncertain kind or amount and are left out of the totals."))
                    }
                    VStack(alignment:.leading,spacing:14) {
                        SectionTitle(title:L("Mit fogtunk","What we caught"),note:L("\(stats.summary.confirmed) igazolt átvétel típusonként","\(stats.summary.confirmed) confirmed claims by kind"))
                        ShareBar(summary:stats.summary,hidden:$hidden)
                    }
                    VStack(alignment:.leading,spacing:10) {
                        SectionTitle(title:L("Statok","Stats"),note:L("a kiválasztott időszakban","in the selected period"))
                        StatLedger(summary:stats.summary)
                    }
                    VStack(alignment:.leading,spacing:14) {
                        SectionTitle(title:L("Alakulás","Over time"),note:L("halmozott átvételek, vidd az egeret a görbére","cumulative claims, hover a line"))
                        FrequencyLines(summary:stats.summary,hidden:hidden).frame(height:240)
                    }
                    Text(L("A napló a játékban látott értékeket rögzíti, nem a karakter szorzókkal módosított statváltozását.","Values are as shown in the game, not the character's multiplied stat change."))
                        .font(.footnote).foregroundStyle(Theme.steel)
                }
                .padding(.horizontal,28).padding(.top,26).padding(.bottom,28)
                .frame(maxWidth:1400,alignment:.leading)
            }
        }
        .background(Theme.paper)
    }
}

// MARK: - Status band (the one loud element)

private struct StatusBand:View {
    @ObservedObject var model:AppModel
    @ObservedObject var stats:StatsStore
    var body:some View {
        let collector=model.collectorStatus,game=model.gameStatus,s=stats.summary
        let latest=s.recent.first{$0.confirmed}
        HStack(alignment:.top,spacing:28) {
            VStack(alignment:.leading,spacing:6) {
                Text(collector.title)
                    .font(Theme.display(52)).foregroundStyle(collector.tone == .bad ? Theme.blood:Theme.ink)
                    .lineLimit(1).minimumScaleFactor(0.6)
                    .contentTransition(.opacity)
                Text(collector.detail).font(.callout).foregroundStyle(Theme.ink.opacity(0.8))
                    .fixedSize(horizontal:false,vertical:true).frame(maxWidth:420,alignment:.leading)
                HStack(spacing:8) {
                    Image(systemName:game.tone == .good ? "gamecontroller.fill":"gamecontroller")
                    Text(game.title).font(.callout.weight(.semibold))
                    if model.game.state == .notRunning {
                        Button(L("Játék indítása","Launch game")){model.game.launch()}.controlSize(.small)
                    }
                }
                .foregroundStyle(game.tone == .bad ? Theme.blood:Theme.ink)
                .padding(.top,8)
                .help(game.detail)
                if model.engine.isRunning {LastCapture(engine:model.engine).padding(.top,2)}
            }
            Spacer(minLength:12)
            VStack(alignment:.leading,spacing:2) {
                Text("\(s.confirmed)")
                    .font(Theme.display(64)).foregroundStyle(Theme.ink)
                    .contentTransition(.numericText(value:Double(s.confirmed))).animation(.default,value:s.confirmed)
                Text(L("átvétel – \(stats.range.label.lowercased())","claims – \(stats.range.label.lowercased())"))
                    .font(.callout.weight(.semibold)).foregroundStyle(Theme.ink)
                Group {
                    if stats.range == .custom {
                        Text(Format.duration(s.to.timeIntervalSince(s.from)))
                    } else {
                        // Live elapsed time without re-rendering the page.
                        Text(timerInterval:s.from...Date.distantFuture,countsDown:false)
                    }
                }
                .font(.callout.monospacedDigit()).foregroundStyle(Theme.ink.opacity(0.7))
                Text(L("kezdete: ","since ")+Format.dateTime(s.from)).font(.caption).foregroundStyle(Theme.ink.opacity(0.6))
                if s.pending>0 {
                    Text(L("\(s.pending) függőben","\(s.pending) pending")).font(.caption).foregroundStyle(Theme.ink.opacity(0.6))
                }
            }
            .padding(.top,6)
            PriceTag(row:latest).padding(.top,-2)
        }
        .padding(.leading,28).padding(.trailing,44).padding(.top,22).padding(.bottom,26)
        .frame(maxWidth:.infinity,alignment:.leading)
        .background(Theme.band(collector.tone))
        .overlay(alignment:.bottom){Rectangle().fill(Theme.ink).frame(height:3)}
        .animation(.smooth,value:collector.title)
    }
}

/// Re-renders only itself once a second; the rest of the page stays untouched.
private struct LastCapture:View {
    let engine:CollectorEngine
    var body:some View {
        TimelineView(.periodic(from:.now,by:1)) {_ in
            if let at=engine.status.lastCheckedAt {
                Text(L("Utoljára nézett rá: ","Last looked: ")+Format.time(at)).font(.caption.monospacedDigit()).foregroundStyle(Theme.ink.opacity(0.6))
            }
        }
    }
}

// MARK: - Quiet building blocks

struct Notice:View {
    let icon:String,tone:Tone,text:String
    var body:some View {
        HStack(alignment:.firstTextBaseline,spacing:10) {
            Image(systemName:icon).foregroundStyle(tone == .bad ? Theme.blood:Theme.ink)
            Text(text).font(.callout).fixedSize(horizontal:false,vertical:true)
        }
        .padding(.leading,12).padding(.vertical,4)
        .overlay(alignment:.leading){Rectangle().fill(tone == .bad ? Theme.blood:Theme.butcherYellow).frame(width:3)}
    }
}

struct PermissionNotice:View {
    @ObservedObject var model:AppModel
    var body:some View {
        VStack(alignment:.leading,spacing:10) {
            Text(L("Két engedély kell a gyűjtéshez","Collecting needs two permissions")).font(.headline)
            Text(L("Képernyőfelvétel a játékablak lefotózásához, Kisegítő lehetőségek a háttérkattintáshoz. Egyszer kell megadni.",
                   "Screen Recording to capture the game window, Accessibility for background clicks. Grant them once."))
                .font(.callout).foregroundStyle(Theme.steel)
            HStack(spacing:16) {
                PermissionLabel(name:L("Kisegítő lehetőségek","Accessibility"),granted:model.accessibilityGranted)
                PermissionLabel(name:L("Képernyőfelvétel","Screen Recording"),granted:model.screenCaptureGranted)
                Spacer()
                Button(L("Engedélyek kérése","Request access")){model.requestPermissions()}.buttonStyle(.borderedProminent)
            }
        }
        .padding(.leading,12)
        .overlay(alignment:.leading){Rectangle().fill(Theme.blood).frame(width:3)}
    }
}

struct PermissionLabel:View {
    let name:String,granted:Bool
    var body:some View {
        Label(name,systemImage:granted ? "checkmark.circle.fill":"xmark.circle").foregroundStyle(granted ? Color.green:Theme.blood)
    }
}

private struct CustomRange:View {
    @ObservedObject var stats:StatsStore
    var body:some View {
        HStack(spacing:14) {
            DatePicker(L("Kezdet","From"),selection:$stats.customFrom)
            DatePicker(L("Vége","To"),selection:$stats.customTo)
            Button(L("Szűrés","Apply")){stats.recompute()}
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
