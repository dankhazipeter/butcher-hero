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
        VStack(alignment:.leading,spacing:12) {
            GroupBox {
                Grid(alignment:.leading,horizontalSpacing:16,verticalSpacing:6) {
                    GridRow {
                        Text(L("Gyűjtő","Collector")).foregroundStyle(.secondary)
                        Text("\(model.collectorStatus.title) — \(model.collectorStatus.detail)")
                    }
                    GridRow {
                        Text(L("Várakozás oka","Wait reason")).foregroundStyle(.secondary)
                        Text(model.engine.status.waitReason ?? L("nincs","none"))
                    }
                    GridRow {
                        Text(L("Billentyű-visszatartás","Key holding")).foregroundStyle(.secondary)
                        Text(KeyboardShield.shared.available
                             ? L("elérhető — gépelés közben is kattint, a leütések nem vesznek el","available — clicks while you type, no keystroke is lost")
                             : L("nem elérhető — gépelési szünetre vár","unavailable — waits for typing pauses"))
                    }
                    GridRow {
                        Text(L("Fázisok","Phases")).foregroundStyle(.secondary)
                        Text(L("képernyő: ","screen: ")+model.engine.status.screenState+L(" · kristály: "," · crystal: ")+model.engine.status.crystalPhase+L(" · esemény: "," · event: ")+model.engine.status.eventEndPhase)
                    }
                }
                .font(.callout)
                .frame(maxWidth:.infinity,alignment:.leading).padding(6)
            } label:{Label(L("Most","Now"),systemImage:"waveform.path.ecg")}

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
        .padding(20)
    }
}
