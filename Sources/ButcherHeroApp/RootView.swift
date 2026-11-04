import SwiftUI

enum Page:String,CaseIterable,Identifiable {
    case overview,ledger,diagnostics
    var id:String {rawValue}
    var title:String {
        switch self {
        case .overview:L("Áttekintés","Overview")
        case .ledger:L("Napló","Ledger")
        case .diagnostics:L("Diagnosztika","Diagnostics")
        }
    }
    var icon:String {
        switch self {case .overview:"chart.xyaxis.line";case .ledger:"list.bullet.rectangle";case .diagnostics:"stethoscope"}
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
                Section(L("Butcher Hero","Butcher Hero")) {
                    ForEach(Page.allCases){Label($0.title,systemImage:$0.icon).tag($0)}
                }
                Section(L("Állapot","Status")) {
                    SidebarStatus(title:L("Játék","Game"),status:model.gameStatus)
                    SidebarStatus(title:L("Gyűjtő","Collector"),status:model.collectorStatus)
                }
            }
            .navigationSplitViewColumnWidth(min:190,ideal:210)
        } detail:{
            Group {
                switch page {
                case .overview:OverviewView(model:model,stats:model.stats)
                case .ledger:LedgerView(stats:model.stats)
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
        .environment(\.locale,AppLanguage.current.locale)
        .id(language)
    }
}

private struct SidebarStatus:View {
    let title:String,status:StatusText
    var body:some View {
        HStack(spacing:8) {
            Circle().fill(status.tone.color).frame(width:8,height:8)
            VStack(alignment:.leading,spacing:1) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(status.title).font(.callout.weight(.medium))
            }
        }
        .help(status.detail)
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
