import SwiftUI

enum Page:String,CaseIterable,Identifiable {
    case overview,ledger,crystals,diagnostics
    var id:String {rawValue}
    var title:String {
        switch self {
        case .overview:L("Áttekintés","Overview")
        case .ledger:L("Napló","Ledger")
        case .crystals:L("Kristályok","Crystals")
        case .diagnostics:L("Diagnosztika","Diagnostics")
        }
    }
    var icon:String {
        switch self {case .overview:"chart.xyaxis.line";case .ledger:"list.bullet.rectangle";case .crystals:"diamond";case .diagnostics:"stethoscope"}
    }
}

struct RootView:View {
    @ObservedObject var model:AppModel
    @AppStorage(AppLanguage.defaultsKey) private var language=AppLanguage.hu.rawValue
    @State private var page:Page = .overview
    @State private var confirmNewSession=false

    var body:some View {
        NavigationSplitView {
            List(selection:$page) {
                Section("Butcher Hero Autoplayer") {
                    ForEach(Page.allCases){Label($0.title,systemImage:$0.icon).tag($0)}
                }
                Section(L("Állapot","Status")) {
                    SidebarStatus(title:L("Játék","Game"),icon:"gamecontroller.fill",status:model.gameStatus)
                        .listRowInsets(EdgeInsets(top:5,leading:2,bottom:5,trailing:6))
                    SidebarStatus(title:L("Gyűjtő","Collector"),icon:"tray.and.arrow.down.fill",status:model.collectorStatus)
                        .listRowInsets(EdgeInsets(top:5,leading:2,bottom:5,trailing:6))
                }
            }
            .navigationSplitViewColumnWidth(min:190,ideal:210)
        } detail:{
            Group {
                switch page {
                case .overview:OverviewView(model:model,stats:model.stats)
                case .ledger:LedgerView(stats:model.stats)
                case .crystals:CrystalsView(crystals:model.crystals,stats:model.stats)
                case .diagnostics:DiagnosticsView(model:model,diagnostics:model.diagnostics)
                }
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            // White content area (dark in Dark Mode); the sidebar keeps its system grey.
            .background(Color(nsColor:.textBackgroundColor))
        }
        .navigationTitle(page.title)
        .toolbar {
            if page != .diagnostics {
                ToolbarItem {RangeMenu(stats:model.stats)}
                ToolbarItem {
                    Button {confirmNewSession=true} label:{Label(L("Új munkamenet","New session"),systemImage:"arrow.counterclockwise")}
                        .help(L("A „Mostani futás” statisztikát innentől újrakezdi; a gyűjtés nem áll le.","Restarts the “Current run” statistics from now; collecting continues."))
                }
            }
            ToolbarItem {
                Toggle(isOn:Binding(get:{model.collectorEnabled},set:{model.setCollecting($0)})) {
                    Label(L("Gyűjtés","Collecting"),systemImage:"play.circle")
                }
                .toggleStyle(.switch)
                .help(model.collectorEnabled ? L("Gyűjtés leállítása (⌘R)","Stop collecting (⌘R)"):L("Gyűjtés indítása (⌘R)","Start collecting (⌘R)"))
            }
        }
        .confirmationDialog(L("Új statisztikai munkamenet indítása?","Start a new statistics session?"),isPresented:$confirmNewSession) {
            Button(L("Igen, új munkamenet","Yes, new session")){model.stats.startNewSession()}
            Button(L("Mégse","Cancel"),role:.cancel){}
        } message:{
            Text(L("A „Mostani futás” nézet mostantól számol. A korábbi átvételek a többi időszakban továbbra is látszanak.","“Current run” counts from now. Earlier claims stay visible in the other periods."))
        }
        .frame(minWidth:900,minHeight:620)
        // Content that fits the window stays put: no rubber-band drag on the overview,
        // the tables or the sidebar. Scrolling still works once something overflows.
        .scrollBounceBehavior(.basedOnSize,axes:[.vertical,.horizontal])
        .environment(\.locale,AppLanguage.current.locale)
        .id(language)
    }
}

/// A small shop sign per status, in the status band's colours: yellow while working,
/// pale while waiting, steel when stopped. Ink outline and hard shadow like the price tag.
private struct SidebarStatus:View {
    let title:String,icon:String,status:StatusText
    var body:some View {
        let shape=RoundedRectangle(cornerRadius:6,style:.continuous)
        HStack(spacing:6) {
            VStack(alignment:.leading,spacing:1) {
                HStack(spacing:4) {
                    Image(systemName:icon).font(.system(size:9,weight:.bold))
                    Text(title.uppercased()).font(.system(size:9.5,weight:.heavy)).tracking(0.9).lineLimit(1)
                }
                .foregroundStyle(Theme.ink.opacity(0.65))
                Text(status.title).font(Theme.display(17))
                    .foregroundStyle(status.tone == .bad ? Theme.blood:Theme.ink)
                    .lineLimit(1).minimumScaleFactor(0.65)
                    .contentTransition(.opacity)
            }
            Spacer(minLength:2)
            StatusMark(tone:status.tone)
        }
        .padding(.leading,10).padding(.trailing,8)
        .frame(height:46)
        // Shadow on the card shape only, so the lettering stays crisp.
        .background(shape.fill(Theme.band(status.tone)).shadow(color:.black.opacity(0.22),radius:0,x:2,y:3))
        .overlay(shape.strokeBorder(Theme.ink,lineWidth:2))
        .animation(.smooth,value:status.title)
        .help(status.detail)
        .accessibilityElement(children:.combine)
    }
}

/// Right-hand mark: a live pulse while working, an hourglass while waiting, a cross when stopped.
private struct StatusMark:View {
    let tone:Tone
    var body:some View {
        Group {
            switch tone {
            case .good:LivePulse()
            case .warn:Image(systemName:"hourglass").font(.system(size:11,weight:.bold)).foregroundStyle(Theme.ink)
            case .bad:Image(systemName:"xmark").font(.system(size:10,weight:.heavy)).foregroundStyle(Theme.blood)
            }
        }
        .frame(width:16,height:16)
    }
}

/// Ink dot with a ring that keeps expanding outward; still when Reduce Motion is on.
/// The ring is computed from the clock (TimelineView), not a repeatForever animation: such an
/// animation leaked into the sign's title change and kept cross-fading the old and new title
/// forever (2026-11-07: "A játék fut" / "A játék nem fut" flickering while the game was closed).
private struct LivePulse:View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body:some View {
        ZStack {
            if !reduceMotion {
                TimelineView(.animation(minimumInterval:1/30)) {context in
                    let t=context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy:1.6)/1.6
                    let eased=1-pow(1-t,2)
                    Circle().stroke(Theme.ink,lineWidth:1.5).frame(width:8,height:8)
                        .scaleEffect(1+1.2*eased).opacity(0.7*(1-eased))
                }
            }
            Circle().fill(Theme.ink).frame(width:8,height:8)
        }
    }
}

/// Observes only the statistics range, so the toolbar label updates without the whole window.
private struct RangeMenu:View {
    @ObservedObject var stats:StatsStore
    var body:some View {
        Menu {
            Picker(L("Időszak","Period"),selection:$stats.range) {
                ForEach(StatsStore.Range.allCases){Text($0.label).tag($0)}
            }
            .pickerStyle(.inline).labelsHidden()
        } label:{Label(stats.range.label,systemImage:"calendar").labelStyle(.titleAndIcon)}
        .help(L("Statisztikai időszak","Statistics period"))
    }
}
