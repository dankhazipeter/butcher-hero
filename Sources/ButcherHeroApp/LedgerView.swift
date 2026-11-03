import SwiftUI

/// "Mikor, mit, mennyit?" as a native table with fixed column widths, so a status change
/// never shifts the layout.
struct LedgerView:View {
    @ObservedObject var stats:StatsStore
    var body:some View {
        VStack(alignment:.leading,spacing:0) {
            Table(stats.summary.recent) {
                TableColumn(L("Kattintás ideje","Click time")) {row in
                    Text(Format.shortDateTime(row.at)).monospacedDigit()
                }
                .width(min:140,ideal:150,max:170)
                TableColumn(L("Jutalom","Reward")) {row in
                    Label {Text(StatsStore.Kind.label(row.kind))} icon:{KindIcon(kind:row.kind,size:16)}
                }
                .width(min:160,ideal:200)
                TableColumn(L("Mennyiség","Amount")) {row in
                    Text(row.amount.map{"+\(Format.compact($0))"} ?? "?").monospacedDigit()
                        .frame(maxWidth:.infinity,alignment:.trailing)
                        .help(row.amount.map(Format.exact) ?? "")
                }
                .width(90)
                TableColumn(L("Állapot","Status")) {row in StateBadge(confirmed:row.confirmed)}
                    .width(120)
            }
            .tableStyle(.inset(alternatesRowBackgrounds:true))
            .overlay {
                if stats.summary.recent.isEmpty {
                    ContentUnavailableView(L("Nincs átvétel","No claims"),systemImage:"tray",
                                           description:Text(L("Ebben az időszakban még nincs átvétel.","No claims in this period yet.")))
                }
            }
            Divider()
            Text(L("\(stats.summary.recent.count) legutóbbi tétel · a kattintás időpontja szerint","\(stats.summary.recent.count) latest items · by click time"))
                .font(.caption).foregroundStyle(.secondary).padding(8)
        }
    }
}

/// Fixed-size capsule so "Átvéve" and "Nem igazolt" occupy the same width.
private struct StateBadge:View {
    let confirmed:Bool
    var body:some View {
        Label(confirmed ? L("Átvéve","Claimed"):L("Nem igazolt","Unconfirmed"),
              systemImage:confirmed ? "checkmark.circle.fill":"clock.badge.questionmark")
            .font(.caption.weight(.medium))
            .foregroundStyle(confirmed ? .green:.orange)
            .lineLimit(1)
            .frame(width:104,alignment:.leading)
            .contentTransition(.opacity)
            .animation(.default,value:confirmed)
    }
}
