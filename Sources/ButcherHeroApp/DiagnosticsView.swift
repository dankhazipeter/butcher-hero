import SwiftUI

/// Shows why the collector does (or doesn't do) something: current wait reason,
/// key-holding availability, and the recent journal events of all three flows.
struct DiagnosticsView:View {
    @ObservedObject var model:AppModel
    @ObservedObject var diagnostics:DiagnosticsStore
    @State private var onlyIssues=false
    @State private var domain:JournalDomain?
    @State private var selection=Set<DiagnosticsStore.Entry.ID>()

    private var rows:[DiagnosticsStore.Entry] {
        diagnostics.entries.filter{(!onlyIssues || $0.severity>DiagnosticsStore.Severity.info) && (domain==nil || $0.domain==domain)}
    }

    var body:some View {
        VStack(alignment:.leading,spacing:14) {
            SectionTitle(title:L("Most","Right now"),note:L("mit csinál a gyűjtő, és miért","what the collector is doing, and why"))
            Grid(alignment:.leading,horizontalSpacing:16,verticalSpacing:6) {
                    GridRow {
                        Text(L("Gyűjtő","Collector")).foregroundStyle(Theme.steel)
                        Text("\(model.collectorStatus.title). \(model.collectorStatus.detail)").lineLimit(1).help(model.collectorStatus.detail)
                    }
                    GridRow {
                        Text(L("Várakozás oka","Wait reason")).foregroundStyle(Theme.steel)
                        Text(model.engine.status.waitReason ?? L("nincs","none")).lineLimit(1).help(model.engine.status.waitReason ?? "")
                    }
                    GridRow {
                        Text(L("Kattintási mód","Click mode")).foregroundStyle(Theme.steel)
                        Text(L("háttérkattintás fókuszváltás nélkül: az aktív app, a kurzor és a gépelés érintetlen","background click without focus change: active app, cursor and typing untouched"))
                    }
                    GridRow {
                        Text(L("Fázisok","Phases")).foregroundStyle(Theme.steel)
                        Text(L("képernyő: ","screen: ")+model.engine.status.screenState+L(", kristály: ",", crystal: ")+model.engine.status.crystalPhase+L(", esemény: ",", event: ")+model.engine.status.eventEndPhase).lineLimit(1)
                    }
                }
                .font(.callout)
                .frame(maxWidth:.infinity,alignment:.leading)
                .padding(.leading,12)
                .overlay(alignment:.leading){Rectangle().fill(Theme.band(model.collectorStatus.tone)).frame(width:3)}
            SectionTitle(title:L("Események","Events"),note:L("a legutóbbi 500, legfrissebb elöl","the latest 500, newest first")).padding(.top,6)

            HStack {
                Picker(L("Terület","Area"),selection:$domain) {
                    Text(L("Minden","All")).tag(JournalDomain?.none)
                    ForEach(JournalDomain.allCases,id:\.self){Text($0.label).tag(JournalDomain?.some($0))}
                }
                .pickerStyle(.segmented).frame(maxWidth:320)
                Toggle(L("Csak várakozás és hiba","Only waits and problems"),isOn:$onlyIssues).toggleStyle(.checkbox)
                Spacer()
                Button {NSWorkspace.shared.open(AppPaths.root)} label:{Label(L("Adatmappa","Data folder"),systemImage:"folder")}
            }

            Table(rows,selection:$selection) {
                TableColumn(L("Idő","Time")) {e in Text(Format.time(e.at)).monospacedDigit()}
                    .width(80)
                TableColumn(L("Terület","Area")) {e in Text(e.domain.label)}
                    .width(70)
                TableColumn(L("Esemény","Event")) {e in
                    Label {Text(e.label)} icon:{
                        Image(systemName:e.severity == .problem ? "exclamationmark.triangle.fill":e.severity == .wait ? "hourglass":"circle.fill")
                            .foregroundStyle(e.severity == .problem ? .orange:e.severity == .wait ? .yellow:.secondary)
                            .imageScale(.small)
                    }
                }
                .width(min:170,ideal:210)
                TableColumn(L("Részletek","Details")) {e in
                    Text(e.detail).lineLimit(1).truncationMode(.middle).help(e.detail).textSelection(.enabled)
                }
            }
            .tableStyle(.inset(alternatesRowBackgrounds:true))
            .contextMenu(forSelectionType:DiagnosticsStore.Entry.ID.self) {ids in
                Button(L("Másolás","Copy")) {
                    let text=rows.filter{ids.contains($0.id)}.map{"\(Stamp.string($0.at))\t\($0.domain.rawValue)\t\($0.event)\t\($0.detail)"}.joined(separator:"\n")
                    NSPasteboard.general.clearContents();NSPasteboard.general.setString(text,forType:.string)
                }
            }
        }
        .padding(.horizontal,28).padding(.vertical,24)
        .background(Theme.paper)
    }
}
