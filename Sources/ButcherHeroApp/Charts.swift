import Charts
import SwiftUI

private func value(of series:[StatsStore.Point],at date:Date)->Double {
    series.last{$0.at<=date}?.value ?? 0
}

/// Section heading in the display face, sentence case, with an optional quiet note.
/// Notes stay on one line, so a changing count never makes the heading taller.
struct SectionTitle:View {
    let title:String
    var note:String?=nil
    /// Data caveat shown inline instead of as a block that would push the page down.
    var warning:String?=nil
    var body:some View {
        HStack(alignment:.firstTextBaseline,spacing:10) {
            Text(title).font(Theme.display(24)).foregroundStyle(Theme.ink).lineLimit(1).fixedSize()
            if let note {Text(note).font(.callout).foregroundStyle(Theme.steel).lineLimit(1).help(note)}
            if let warning {
                Label {Text(warning).lineLimit(1)} icon:{Image(systemName:"questionmark.circle").foregroundStyle(Theme.blood)}
                    .font(.callout).foregroundStyle(Theme.ink).help(warning)
            }
            Spacer(minLength:0)
        }
    }
}

// MARK: - The price tag: latest catch

/// A butcher's price tag hanging from a string; swings once when a new claim lands.
struct PriceTag:View {
    let row:StatsStore.Row?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var swing=0.0
    var body:some View {
        VStack(spacing:0) {
            Rectangle().fill(Theme.ink.opacity(0.75)).frame(width:1.5,height:18)
            ZStack(alignment:.top) {
                TagShape()
                    .fill(Color(nsColor:.controlBackgroundColor))
                    .overlay(TagShape().stroke(Theme.ink,lineWidth:2.5))
                    .shadow(color:.black.opacity(0.18),radius:0,x:3,y:4)
                Circle().strokeBorder(Theme.ink,lineWidth:2).frame(width:12,height:12).padding(.top,9)
                content.padding(.top,28).padding(.horizontal,16).padding(.bottom,14)
            }
            .frame(width:176,height:156)
        }
        .rotationEffect(.degrees(-4+swing),anchor:.top)
        .onChange(of:row?.id) {
            guard !reduceMotion else{return}
            swing=9
            withAnimation(.interpolatingSpring(stiffness:90,damping:5)) {swing=0}
        }
        .accessibilityElement(children:.combine)
    }
    @ViewBuilder private var content:some View {
        if let row {
            VStack(spacing:4) {
                Text(L("Legutóbbi zsákmány","Latest catch")).font(.caption).foregroundStyle(Theme.steel)
                HStack(spacing:6) {
                    KindIcon(kind:row.kind,size:20)
                    Text(StatsStore.Kind.label(row.kind)).font(.callout.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.8)
                }
                Text(row.amount.map{"+\(Format.compact($0))"} ?? "?")
                    .font(Theme.display(40)).foregroundStyle(KindStyle.color(row.kind))
                    .contentTransition(.numericText()).lineLimit(1).minimumScaleFactor(0.6)
                Text(Format.time(row.at)).font(.caption.monospacedDigit()).foregroundStyle(Theme.steel)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
        } else {
            VStack(spacing:6) {
                Text(L("Még nincs zsákmány","Nothing caught yet")).font(.callout.weight(.semibold))
                Text(L("Az első átvétel ide kerül.","The first claim lands here.")).font(.caption).foregroundStyle(Theme.steel)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity)
        }
    }
}

/// Tag outline: a card with clipped top corners, like a paper price tag.
private struct TagShape:Shape {
    func path(in r:CGRect)->Path {
        let cut:CGFloat=26,radius:CGFloat=6
        var p=Path()
        p.move(to:.init(x:r.minX+cut,y:r.minY))
        p.addLine(to:.init(x:r.maxX-cut,y:r.minY))
        p.addLine(to:.init(x:r.maxX,y:r.minY+cut))
        p.addLine(to:.init(x:r.maxX,y:r.maxY-radius))
        p.addQuadCurve(to:.init(x:r.maxX-radius,y:r.maxY),control:.init(x:r.maxX,y:r.maxY))
        p.addLine(to:.init(x:r.minX+radius,y:r.maxY))
        p.addQuadCurve(to:.init(x:r.minX,y:r.maxY-radius),control:.init(x:r.minX,y:r.maxY))
        p.addLine(to:.init(x:r.minX,y:r.minY+cut))
        p.closeSubpath()
        return p
    }
}

// MARK: - Share of claims as one bar of "cuts"

struct ShareBar:View {
    let summary:StatsStore.Summary
    @Binding var hidden:Set<String>
    var body:some View {
        let kinds=StatsStore.Kind.all
        let total=max(1,summary.counts.values.reduce(0,+))
        VStack(alignment:.leading,spacing:12) {
            GeometryReader {geo in
                HStack(spacing:2) {
                    ForEach(kinds.filter{(summary.counts[$0.id] ?? 0)>0}) {kind in
                        let share=Double(summary.counts[kind.id] ?? 0)/Double(total)
                        Rectangle().fill(KindStyle.color(kind.id))
                            .opacity(hidden.contains(kind.id) ? 0.25:1)
                            .frame(width:max(3,(geo.size.width-2*7)*share))
                            .help("\(kind.label): \(summary.counts[kind.id] ?? 0)")
                    }
                }
            }
            .frame(height:18)
            .background(Theme.rule.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius:3,style:.continuous))
            .animation(.smooth,value:summary.counts)
            // Legend doubles as the series toggle for the trend chart below.
            LazyVGrid(columns:[GridItem(.adaptive(minimum:220),spacing:18,alignment:.leading)],alignment:.leading,spacing:8) {
                ForEach(kinds) {kind in
                    let count=summary.counts[kind.id] ?? 0,off=hidden.contains(kind.id)
                    Button {
                        withAnimation(.smooth) {if off {hidden.remove(kind.id)} else {hidden.insert(kind.id)}}
                    } label:{
                        HStack(spacing:7) {
                            RoundedRectangle(cornerRadius:2).fill(KindStyle.color(kind.id)).frame(width:12,height:12)
                            Text(kind.label).font(.callout).foregroundStyle(Theme.ink).lineLimit(1)
                                .frame(width:100,alignment:.leading)
                            Text("\(count)").font(.callout.monospacedDigit()).foregroundStyle(Theme.steel).lineLimit(1)
                                .contentTransition(.numericText(value:Double(count))).animation(.default,value:count)
                                .frame(width:34,alignment:.leading)
                            Text(Format.percent(Double(count)/Double(total))).font(.caption.monospacedDigit()).foregroundStyle(Theme.steel).lineLimit(1)
                                .frame(width:48,alignment:.leading)
                        }
                        .opacity(off ? 0.4:1)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(off ? L("Görbe megjelenítése","Show line"):L("Görbe elrejtése","Hide line"))
                }
            }
        }
    }
}

// MARK: - Per-stat ledger

/// One ruled row per stat: what was caught, how much, how fast, and its curve.
/// Every column has a fixed width (the trend takes the rest), so values never resize the table.
struct StatLedger:View {
    let summary:StatsStore.Summary
    private enum W {static let stat:CGFloat=170,count:CGFloat=56,total:CGFloat=116,rate:CGFloat=84,gap:CGFloat=18,row:CGFloat=30}
    var body:some View {
        VStack(alignment:.leading,spacing:0) {
            HStack(spacing:W.gap) {
                Text(L("Stat","Stat")).frame(width:W.stat,alignment:.leading)
                Text(L("Átvétel","Claims")).frame(width:W.count,alignment:.trailing)
                Text(L("Összesen","Total")).frame(width:W.total,alignment:.trailing)
                Text(L("Percenként","Per minute")).frame(width:W.rate,alignment:.trailing)
                Text(L("Alakulás","Trend")).frame(maxWidth:.infinity,alignment:.leading)
            }
            .font(.caption).foregroundStyle(Theme.steel).lineLimit(1)
            .padding(.bottom,6)
            ForEach(StatsStore.Kind.cardOrder,id:\.self) {kind in
                Divider()
                row(kind)
            }
        }
    }
    private func row(_ kind:String)->some View {
        let total=summary.totals[kind] ?? 0,count=summary.counts[kind] ?? 0
        let numeric=NSDecimalNumber(decimal:total).doubleValue
        let color=KindStyle.color(kind)
        return HStack(spacing:W.gap) {
            HStack(spacing:9) {
                KindIcon(kind:kind,size:20)
                Text(StatsStore.Kind.label(kind)).font(.body.weight(.medium)).lineLimit(1)
            }
            .frame(width:W.stat,alignment:.leading)
            Text("\(count)").font(.body.monospacedDigit()).foregroundStyle(Theme.steel).lineLimit(1)
                .contentTransition(.numericText(value:Double(count))).animation(.default,value:count)
                .frame(width:W.count,alignment:.trailing)
            Text("+\(Format.compact(total))").font(Theme.display(24)).foregroundStyle(count>0 ? color:Theme.steel)
                .lineLimit(1).minimumScaleFactor(0.7)
                .contentTransition(.numericText(value:numeric)).animation(.default,value:numeric)
                .frame(width:W.total,alignment:.trailing)
                .help(Format.exact(total))
            Text(Format.rate(total,from:summary.from,to:summary.to)).font(.callout.monospacedDigit()).foregroundStyle(Theme.steel)
                .lineLimit(1).frame(width:W.rate,alignment:.trailing)
            Chart(summary.series[kind] ?? []) {p in
                AreaMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Érték","Value"),p.value))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(color.opacity(0.14))
                LineMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Érték","Value"),p.value))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth:1.8,lineCap:.round,lineJoin:.round))
            }
            .chartXAxis(.hidden).chartYAxis(.hidden).chartLegend(.hidden)
            .chartXScale(domain:summary.from...max(summary.to,summary.from.addingTimeInterval(60)))
            .frame(maxWidth:.infinity)
        }
        .frame(height:W.row)
        .padding(.vertical,9)
    }
}

// MARK: - Cumulative claims, one smooth line per kind, hover tooltip

struct FrequencyLines:View {
    let summary:StatsStore.Summary
    let hidden:Set<String>
    @State private var selection:Date?

    var body:some View {
        let kinds=StatsStore.Kind.all.filter{!hidden.contains($0.id)}
        Chart {
            ForEach(kinds) {kind in
                ForEach(summary.countSeries[kind.id] ?? []) {p in
                    LineMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Darab","Count"),p.value),series:.value("Kind",kind.label))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(KindStyle.color(kind.id))
                        .lineStyle(StrokeStyle(lineWidth:2.4,lineCap:.round,lineJoin:.round))
                }
            }
            if let selection {
                RuleMark(x:.value(L("Idő","Time"),selection))
                    .foregroundStyle(Theme.ink.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth:1))
                    .annotation(position:.trailing,alignment:.top,spacing:10,
                                overflowResolution:.init(x:.fit(to:.chart),y:.fit(to:.chart))) {
                        Tooltip(date:selection,rows:kinds.map{($0,value(of:summary.countSeries[$0.id] ?? [],at:selection))})
                    }
                ForEach(kinds) {kind in
                    PointMark(x:.value(L("Idő","Time"),selection),y:.value(L("Darab","Count"),value(of:summary.countSeries[kind.id] ?? [],at:selection)))
                        .symbol {
                            Circle().strokeBorder(KindStyle.color(kind.id),lineWidth:2)
                                .background(Circle().fill(Theme.paper))
                                .frame(width:9,height:9)
                        }
                }
            }
        }
        .chartXSelection(value:$selection)
        .chartXScale(domain:summary.from...max(summary.to,summary.from.addingTimeInterval(60)))
        .chartYAxis {
            AxisMarks(position:.leading,values:.automatic(desiredCount:4)) {value in
                AxisGridLine(stroke:StrokeStyle(lineWidth:0.5)).foregroundStyle(Theme.rule)
                AxisValueLabel {
                    if let v=value.as(Double.self) {
                        Text(v,format:.number.precision(.fractionLength(0...1))).lineLimit(1).frame(width:40,alignment:.trailing)
                    }
                }
                .foregroundStyle(Theme.steel)
            }
        }
        .chartXAxis {
            AxisMarks(values:.automatic(desiredCount:6)) {_ in
                AxisValueLabel(format:summary.to.timeIntervalSince(summary.from)>86400 ? .dateTime.month(.twoDigits).day(.twoDigits):.dateTime.hour().minute())
                    .foregroundStyle(Theme.steel)
            }
        }
        .chartLegend(.hidden)
    }
}

private struct Tooltip:View {
    let date:Date
    let rows:[(StatsStore.Kind,Double)]
    var body:some View {
        VStack(alignment:.leading,spacing:5) {
            Text(Format.shortDateTime(date)).font(.caption.weight(.semibold)).foregroundStyle(Theme.steel)
            ForEach(rows.sorted{$0.1>$1.1},id:\.0.id) {kind,count in
                HStack(spacing:6) {
                    RoundedRectangle(cornerRadius:2).fill(KindStyle.color(kind.id)).frame(width:10,height:10)
                    Text(kind.label).font(.caption)
                    Spacer(minLength:12)
                    Text("\(Int(count))").font(.caption.weight(.semibold).monospacedDigit())
                }
            }
        }
        .padding(10)
        .frame(width:190)
        .background(RoundedRectangle(cornerRadius:6,style:.continuous).fill(Theme.paper))
        .overlay(RoundedRectangle(cornerRadius:6,style:.continuous).strokeBorder(Theme.ink,lineWidth:1.5))
        .shadow(color:.black.opacity(0.15),radius:0,x:2,y:3)
    }
}
