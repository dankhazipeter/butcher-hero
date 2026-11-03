import Charts
import SwiftUI

struct DashboardView:View {
    @ObservedObject var model:AppModel
    var body:some View {
        ScrollView {
            VStack(alignment:.leading,spacing:18) {
                Header(model:model)
                if !model.accessibilityGranted || !model.screenCaptureGranted {PermissionBanner(model:model)}
                if model.legacyRunning {
                    Notice(text:"A régi parancssoros gyűjtő (ButcherHeroAutomation) még fut. Amíg fut, ez az app nem kattint, hogy a kettő ne zavarja egymást.",tone:.warn)
                }
                HStack(alignment:.top,spacing:14) {
                    GamePanel(model:model)
                    CollectorPanel(model:model)
                }
                Divider()
                RangeBar(stats:model.stats)
                PeriodSummary(stats:model.stats)
                OverviewRow(summary:model.stats.summary)
                FrequencyChart(summary:model.stats.summary)
                StatCards(summary:model.stats.summary)
                Ledger(summary:model.stats.summary)
                Text("A napló rögzített értékeit mutatjuk, nem a karakter szorzózott statváltozását. Adatok: ~/Library/Application Support/Butcher Hero")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .frame(minWidth:760,minHeight:600)
    }
}

// MARK: - Header and status

private struct Header:View {
    @ObservedObject var model:AppModel
    var body:some View {
        HStack(alignment:.top) {
            VStack(alignment:.leading,spacing:6) {
                Text("BUTCHER HERO / JUTALOMNAPLÓ").font(.caption.weight(.bold)).tracking(1.2).foregroundStyle(.green)
                Text("Amit összegyűjtöttünk.").font(.system(size:30,weight:.bold))
                Text("Naplózott átvételek. Nyolc stat. Minden gyűjtésnek nyoma van.").foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment:.trailing,spacing:10) {
                Toggle(isOn:Binding(get:{model.collectorEnabled},set:{model.setCollecting($0)})) {
                    Text(model.collectorEnabled ? "Gyűjtés bekapcsolva":"Gyűjtés kikapcsolva").font(.headline)
                }
                .toggleStyle(.switch).controlSize(.large)
                Text("Frissítve \(Format.time(model.now))").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private enum Tone {case good,warn,bad
    var color:Color {switch self {case .good:.green;case .warn:.orange;case .bad:.red}}
}

private struct StatusCard<Accessory:View>:View {
    let eyebrow:String,title:String,detail:String,tone:Tone
    @ViewBuilder var accessory:Accessory
    var body:some View {
        HStack(alignment:.top,spacing:12) {
            Circle().fill(tone.color).frame(width:10,height:10).padding(.top,26)
            VStack(alignment:.leading,spacing:4) {
                Text(eyebrow).font(.caption2.weight(.semibold)).tracking(1).foregroundStyle(.secondary)
                Text(title).font(.title2.weight(.bold)).foregroundStyle(tone.color)
                Text(detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal:false,vertical:true)
                accessory
            }
            Spacer(minLength:0)
        }
        .padding(16)
        .frame(maxWidth:.infinity,alignment:.leading)
        .background(RoundedRectangle(cornerRadius:12).fill(.background.secondary))
        .overlay(alignment:.leading){RoundedRectangle(cornerRadius:2).fill(tone.color).frame(width:4).padding(.vertical,8)}
    }
}

private struct GamePanel:View {
    @ObservedObject var model:AppModel
    var body:some View {
        let (title,detail,tone):(String,String,Tone)={
            switch model.game.state {
            case .running:return ("A játék fut",model.game.hidden ? "A játék fut, de el van rejtve; a gyűjtéshez látható ablak kell.":"A Butcher Hero fut, a játékablak elérhető. Takarhatod nyugodtan.",model.game.hidden ? .warn:.good)
            case .launching:return ("Indul…","A játék indítását kértem; az ablakra várok.",.warn)
            case .windowUnavailable:return ("Nincs játékablak","A játék fut, de nincs használható ablaka (kicsinyítve vagy másik Spaces-en?).",.warn)
            case .notRunning:return ("A játék nem fut","Indítsd el a játékot; a gyűjtő megvárja.",.bad)
            case .notInstalled:return ("Nincs telepítve","A Butcher Hero nem található ezen a gépen.",.bad)
            }
        }()
        StatusCard(eyebrow:"JÁTÉK ÁLLAPOTA",title:title,detail:detail,tone:tone) {
            if model.game.state == .notRunning {
                Button("Játék indítása"){model.game.launch()}.padding(.top,6)
            }
        }
    }
}

private struct CollectorPanel:View {
    @ObservedObject var model:AppModel
    var body:some View {
        let (title,detail,tone):(String,String,Tone)={
            switch model.collectorState {
            case .stopped:return ("Leállítva","A gyűjtés ki van kapcsolva. Kapcsold be fent.",.bad)
            case .blocked(let reason):return ("Nem tud elindulni",reason,.bad)
            case .waitingGame:return ("A játékra vár","A gyűjtő fut, és megvárja, hogy a játék elinduljon.",.warn)
            case .waitingWindow:return ("Az ablakra vár","A játéknak nincs használható ablaka.",.warn)
            case .starting:return ("Indul","Az első képrögzítésre várok.",.warn)
            case .stale(let seconds):return ("Elakadt?","\(seconds) másodperce nem volt új képrögzítés.",.warn)
            case .captureError(let message):return ("Képrögzítési hiba",message,.warn)
            case .crystalBlocked:return ("Megakadt egy folyamat","Egy kristály- vagy eseményablak nem a várt módon viselkedett; kézi beavatkozás kellhet.",.warn)
            case .manualPanel:return ("Kézi panel nyitva","Egy kézzel megnyitott kristálypanel látszik; amíg nyitva van, nem kattintok.",.warn)
            case .unrecognized:return ("Ismeretlen képernyő","A játékban nem a megszokott képernyő látszik; várok.",.warn)
            case .waitingInput:return ("Rád vár","Épp egeret vagy billentyűzetet használsz; szünetben kattintok.",.warn)
            case .processing(let text):return ("Dolgozik",text,.good)
            case .running:return ("Fut","Felismert játékképernyő; az elérhető Free-jutalmakat a háttérben veszi át.",.good)
            }
        }()
        StatusCard(eyebrow:"GYŰJTŐ ÁLLAPOTA",title:title,detail:detail,tone:tone) {
            if let at=model.engine.status.lastCheckedAt,model.engine.isRunning {
                Text("Legutóbbi képrögzítés: \(Format.time(at))").font(.caption).foregroundStyle(.secondary).padding(.top,4)
            }
        }
    }
}

private struct PermissionBanner:View {
    @ObservedObject var model:AppModel
    var body:some View {
        VStack(alignment:.leading,spacing:8) {
            Text("Engedélyek szükségesek").font(.headline)
            Text("A gyűjtéshez az appnak képernyőfelvételi (a játékablak lefotózásához) és Kisegítő lehetőségek (a háttérkattintáshoz) engedély kell. Egyszer kell megadni.")
                .font(.callout).foregroundStyle(.secondary)
            HStack {
                Label("Kisegítő lehetőségek",systemImage:model.accessibilityGranted ? "checkmark.circle.fill":"xmark.circle")
                    .foregroundStyle(model.accessibilityGranted ? .green:.red)
                Label("Képernyőfelvétel",systemImage:model.screenCaptureGranted ? "checkmark.circle.fill":"xmark.circle")
                    .foregroundStyle(model.screenCaptureGranted ? .green:.red)
                Spacer()
                Button("Engedélykérés"){model.requestPermissions()}
                Button("Kisegítő lehetőségek…"){model.openPrivacySettings("Privacy_Accessibility")}
                Button("Képernyőfelvétel…"){model.openPrivacySettings("Privacy_ScreenCapture")}
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius:12).fill(Color.orange.opacity(0.12)))
    }
}

private struct Notice:View {
    let text:String,tone:Tone
    var body:some View {
        Text(text).font(.callout).padding(12).frame(maxWidth:.infinity,alignment:.leading)
            .background(RoundedRectangle(cornerRadius:10).fill(tone.color.opacity(0.12)))
    }
}

// MARK: - Range and period

private struct RangeBar:View {
    @ObservedObject var stats:StatsStore
    @State private var confirmNewSession=false
    var body:some View {
        HStack(alignment:.bottom,spacing:12) {
            Picker("Időszak",selection:$stats.range) {
                ForEach(StatsStore.Range.allCases){Text($0.label).tag($0)}
            }
            .pickerStyle(.segmented).labelsHidden().frame(maxWidth:460)
            if stats.range == .custom {
                DatePicker("Kezdet",selection:$stats.customFrom).labelsHidden()
                DatePicker("Vége",selection:$stats.customTo).labelsHidden()
                Button("Szűrés"){stats.recompute()}
            }
            Spacer()
            Button("Új munkamenet…"){confirmNewSession=true}
                .help("A „Mostani futás” statisztikát innentől újrakezdi; a gyűjtés nem áll le, a régi adatok megmaradnak.")
                .confirmationDialog("Új statisztikai munkamenet indítása?",isPresented:$confirmNewSession) {
                    Button("Igen, új munkamenet"){stats.startNewSession()}
                    Button("Mégse",role:.cancel){}
                } message:{Text("A „Mostani futás” nézet mostantól számol. A korábbi átvételek a többi időszakban továbbra is látszanak.")}
        }
    }
}

private struct PeriodSummary:View {
    @ObservedObject var stats:StatsStore
    var body:some View {
        let s=stats.summary
        VStack(alignment:.leading,spacing:10) {
            HStack(spacing:10) {
                Text("KIVÁLASZTOTT IDŐSZAK").font(.caption2.weight(.semibold)).tracking(1).foregroundStyle(.secondary)
                Text(stats.range.label).font(.title3.weight(.semibold))
            }
            HStack(spacing:40) {
                LabeledValue(label:"Kezdet",value:Format.dateTime(s.from))
                LabeledValue(label:"Vége",value:Format.dateTime(s.to))
                LabeledValue(label:"Időintervallum hossza",value:Format.duration(s.to.timeIntervalSince(s.from)))
            }
            Text("\(TimeZone.current.identifier) · \(max(1,s.bucketSeconds/60)) perces diagrambontás").font(.caption).foregroundStyle(.secondary)
        }
        .padding(16).frame(maxWidth:.infinity,alignment:.leading)
        .background(RoundedRectangle(cornerRadius:12).fill(.background.secondary))
    }
}

private struct LabeledValue:View {
    let label:String,value:String
    var body:some View {
        VStack(alignment:.leading,spacing:4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline.monospacedDigit())
        }
    }
}

private struct OverviewRow:View {
    let summary:StatsStore.Summary
    var body:some View {
        HStack(spacing:14) {
            Tile(label:"IGAZOLT ÁTVÉTEL",value:"\(summary.confirmed)",note:"Kártyaeltűnéssel visszaigazolva")
            Tile(label:"NEM IGAZOLT / FÜGGŐ",value:"\(summary.pending)",note:"Nem része a jutalomösszegeknek")
            Tile(label:"LEGUTÓBBI ÁTVÉTEL",value:summary.lastConfirmedAt.map(Format.time) ?? "–",note:"\(summary.attempts) kattintási próbálkozás")
        }
        if summary.unknownConfirmed>0 {
            Text("\(summary.unknownConfirmed) igazolt átvétel típusa vagy mennyisége bizonytalan; nincs beleszámolva a statösszegekbe.")
                .font(.callout).foregroundStyle(.orange)
        }
    }
}

private struct Tile:View {
    let label:String,value:String,note:String
    var body:some View {
        VStack(alignment:.leading,spacing:6) {
            Text(label).font(.caption2.weight(.semibold)).tracking(1).foregroundStyle(.secondary)
            Text(value).font(.system(size:30,weight:.bold).monospacedDigit())
            Text(note).font(.caption).foregroundStyle(.secondary)
        }
        .padding(16).frame(maxWidth:.infinity,alignment:.leading)
        .background(RoundedRectangle(cornerRadius:12).fill(.background.secondary))
    }
}

// MARK: - Charts

private struct FrequencyChart:View {
    let summary:StatsStore.Summary
    @State private var hidden=Set<String>()
    var body:some View {
        let total=max(1,summary.counts.values.reduce(0,+))
        VStack(alignment:.leading,spacing:10) {
            Text("Mit kaptunk gyakrabban?").font(.title3.weight(.semibold))
            Text("Halmozott, igazolt gyűjtések · darab").font(.caption).foregroundStyle(.secondary)
            Chart {
                ForEach(StatsStore.Kind.all.filter{!hidden.contains($0.id)}) {kind in
                    ForEach(summary.countSeries[kind.id] ?? []) {p in
                        LineMark(x:.value("Idő",p.at),y:.value("Darab",p.value),series:.value("Típus",kind.label))
                            .interpolationMethod(.stepEnd)
                            .foregroundStyle(KindStyle.color(kind.id))
                            .lineStyle(StrokeStyle(lineWidth:2,dash:KindStyle.dash(kind.id)))
                    }
                }
            }
            .chartLegend(.hidden)
            .frame(height:240)
            LazyVGrid(columns:[GridItem(.adaptive(minimum:190),alignment:.leading)],alignment:.leading,spacing:8) {
                ForEach(StatsStore.Kind.all) {kind in
                    let count=summary.counts[kind.id] ?? 0
                    Button {
                        if hidden.contains(kind.id) {hidden.remove(kind.id)} else {hidden.insert(kind.id)}
                    } label:{
                        HStack(spacing:6) {
                            KindIcon(kind:kind.id,size:18)
                            Text(kind.label).font(.callout.weight(.medium))
                            Text("\(count) db · \(String(format:"%.1f",Double(count)*100/Double(total)).replacingOccurrences(of:".",with:","))%")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        .opacity(hidden.contains(kind.id) ? 0.35:1)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius:12).fill(.background.secondary))
    }
}

private struct StatCards:View {
    let summary:StatsStore.Summary
    var body:some View {
        VStack(alignment:.leading,spacing:10) {
            Text("Növekedés, statonként").font(.title3.weight(.semibold))
            Text("Halmozott érték a kiválasztott időszakban").font(.caption).foregroundStyle(.secondary)
            LazyVGrid(columns:[GridItem(.flexible(),spacing:14),GridItem(.flexible(),spacing:14)],spacing:14) {
                ForEach(StatsStore.Kind.cardOrder,id:\.self){StatCard(kind:$0,summary:summary)}
            }
        }
    }
}

private struct StatCard:View {
    let kind:String,summary:StatsStore.Summary
    var body:some View {
        let total=summary.totals[kind] ?? 0
        VStack(alignment:.leading,spacing:6) {
            HStack(spacing:8) {
                KindIcon(kind:kind,size:22)
                Text(StatsStore.Kind.label(kind)).font(.headline)
                Spacer()
                Text("\(summary.counts[kind] ?? 0) igazolt átvétel").font(.caption).foregroundStyle(.secondary)
            }
            Text("+\(Format.compact(total))").font(.system(size:26,weight:.bold).monospacedDigit())
                .foregroundStyle(KindStyle.color(kind)).help(Format.exact(total))
            Text("Átlag: \(Format.rate(total,from:summary.from,to:summary.to))/perc").font(.caption).foregroundStyle(.secondary)
            Chart(summary.series[kind] ?? []) {p in
                AreaMark(x:.value("Idő",p.at),y:.value("Érték",p.value)).interpolationMethod(.stepEnd)
                    .foregroundStyle(KindStyle.color(kind).opacity(0.15))
                LineMark(x:.value("Idő",p.at),y:.value("Érték",p.value)).interpolationMethod(.stepEnd)
                    .foregroundStyle(KindStyle.color(kind))
            }
            .chartXAxis(.hidden)
            .frame(height:90)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius:12).fill(.background.secondary))
    }
}

private struct KindIcon:View {
    let kind:String,size:CGFloat
    var body:some View {
        if let image=KindStyle.icon(kind) {Image(nsImage:image).resizable().interpolation(.high).frame(width:size,height:size)}
        else {Image(systemName:"questionmark.circle").frame(width:size,height:size)}
    }
}

// MARK: - Ledger

private struct Ledger:View {
    let summary:StatsStore.Summary
    var body:some View {
        VStack(alignment:.leading,spacing:10) {
            Text("Mikor, mit, mennyit?").font(.title3.weight(.semibold))
            Text("\(summary.recent.count) legutóbbi tétel · a kattintás időpontja szerint").font(.caption).foregroundStyle(.secondary)
            if summary.recent.isEmpty {
                Text("Ebben az időszakban még nincs átvétel.").foregroundStyle(.secondary).padding(.vertical,8)
            } else {
                Grid(alignment:.leading,horizontalSpacing:24,verticalSpacing:6) {
                    GridRow {
                        Text("Kattintás ideje");Text("Jutalom");Text("Mennyiség");Text("Állapot")
                    }.font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Divider()
                    ForEach(summary.recent) {row in
                        GridRow {
                            Text(Format.shortDateTime(row.at)).monospacedDigit()
                            HStack(spacing:6){KindIcon(kind:row.kind,size:16);Text(StatsStore.Kind.label(row.kind))}
                            Text(row.amount.map{"+\(Format.compact($0))"} ?? "?").monospacedDigit()
                            Text(row.confirmed ? "Átvéve":"Nem igazolt").foregroundStyle(row.confirmed ? .green:.orange)
                        }.font(.callout)
                    }
                }
            }
        }
        .padding(16).frame(maxWidth:.infinity,alignment:.leading)
        .background(RoundedRectangle(cornerRadius:12).fill(.background.secondary))
    }
}
