import Charts
import SwiftUI

/// Rounded card used for every section of the white content area.
struct Card<Content:View>:View {
    var padding:CGFloat=16
    @ViewBuilder var content:Content
    var body:some View {
        content
            .padding(padding)
            .frame(maxWidth:.infinity,alignment:.leading)
            .background(RoundedRectangle(cornerRadius:14,style:.continuous).fill(Color(nsColor:.controlBackgroundColor)))
            .overlay(RoundedRectangle(cornerRadius:14,style:.continuous).strokeBorder(Color(nsColor:.separatorColor).opacity(0.6)))
            .shadow(color:.black.opacity(0.04),radius:6,y:2)
    }
}

struct CardHeader:View {
    let title:String
    var subtitle:String?=nil
    var body:some View {
        VStack(alignment:.leading,spacing:2) {
            Text(title).font(.headline)
            if let subtitle {Text(subtitle).font(.caption).foregroundStyle(.secondary)}
        }
    }
}

private func value(of series:[StatsStore.Point],at date:Date)->Double {
    series.last{$0.at<=date}?.value ?? 0
}

// MARK: - Distribution donut

/// Share of confirmed claims per kind, total in the middle.
struct DistributionDonut:View {
    let summary:StatsStore.Summary
    var body:some View {
        let kinds=StatsStore.Kind.all.filter{(summary.counts[$0.id] ?? 0)>0}
        let total=summary.counts.values.reduce(0,+)
        Chart(kinds) {kind in
            SectorMark(angle:.value(L("Darab","Count"),summary.counts[kind.id] ?? 0),innerRadius:.ratio(0.64),angularInset:1.5)
                .cornerRadius(4)
                .foregroundStyle(KindStyle.color(kind.id))
        }
        .chartBackground {proxy in
            GeometryReader {geo in
                if let anchor=proxy.plotFrame {
                    let frame=geo[anchor]
                    VStack(spacing:0) {
                        Text("\(total)").font(.system(size:28,weight:.bold).monospacedDigit())
                            .contentTransition(.numericText(value:Double(total))).animation(.default,value:total)
                        Text(L("átvétel","claims")).font(.caption).foregroundStyle(.secondary)
                    }
                    .position(x:frame.midX,y:frame.midY)
                }
            }
        }
        .overlay {
            if total==0 {Circle().strokeBorder(Color(nsColor:.separatorColor),lineWidth:18).padding(8)}
        }
        .animation(.smooth,value:total)
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
                        .lineStyle(StrokeStyle(lineWidth:2.2,lineCap:.round,lineJoin:.round))
                }
            }
            if let selection {
                RuleMark(x:.value(L("Idő","Time"),selection))
                    .foregroundStyle(Color.secondary.opacity(0.25))
                    .lineStyle(StrokeStyle(lineWidth:1))
                    .annotation(position:.trailing,alignment:.top,spacing:10,
                                overflowResolution:.init(x:.fit(to:.chart),y:.fit(to:.chart))) {
                        Tooltip(date:selection,rows:kinds.map{($0,value(of:summary.countSeries[$0.id] ?? [],at:selection))})
                    }
                ForEach(kinds) {kind in
                    PointMark(x:.value(L("Idő","Time"),selection),y:.value(L("Darab","Count"),value(of:summary.countSeries[kind.id] ?? [],at:selection)))
                        .symbol {
                            Circle().strokeBorder(KindStyle.color(kind.id),lineWidth:2)
                                .background(Circle().fill(Color(nsColor:.controlBackgroundColor)))
                                .frame(width:9,height:9)
                        }
                }
            }
        }
        .chartXSelection(value:$selection)
        .chartXScale(domain:summary.from...max(summary.to,summary.from.addingTimeInterval(60)))
        .chartYAxis {
            AxisMarks(position:.leading,values:.automatic(desiredCount:4)) {_ in
                AxisGridLine(stroke:StrokeStyle(lineWidth:0.6,dash:[3,4])).foregroundStyle(Color.secondary.opacity(0.35))
                AxisValueLabel().foregroundStyle(.secondary)
            }
        }
        .chartXAxis {
            AxisMarks(values:.automatic(desiredCount:6)) {_ in
                AxisValueLabel(format:summary.to.timeIntervalSince(summary.from)>86400 ? .dateTime.month(.twoDigits).day(.twoDigits):.dateTime.hour().minute())
                    .foregroundStyle(.secondary)
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
            Text(Format.shortDateTime(date)).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            ForEach(rows.sorted{$0.1>$1.1},id:\.0.id) {kind,count in
                HStack(spacing:6) {
                    Capsule().fill(KindStyle.color(kind.id)).frame(width:10,height:3)
                    Text(kind.label).font(.caption)
                    Spacer(minLength:12)
                    Text("\(Int(count))").font(.caption.weight(.semibold).monospacedDigit())
                }
            }
        }
        .padding(10)
        .frame(width:190)
        .background(RoundedRectangle(cornerRadius:10,style:.continuous).fill(Color(nsColor:.controlBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius:10,style:.continuous).strokeBorder(Color(nsColor:.separatorColor).opacity(0.7)))
        .shadow(color:.black.opacity(0.12),radius:10,y:4)
    }
}

/// Legend chips that toggle a series; also show count and share.
struct KindChips:View {
    let summary:StatsStore.Summary
    @Binding var hidden:Set<String>
    var body:some View {
        let total=max(1,summary.counts.values.reduce(0,+))
        LazyVGrid(columns:[GridItem(.adaptive(minimum:190),spacing:8,alignment:.leading)],alignment:.leading,spacing:8) {
            ForEach(StatsStore.Kind.all) {kind in
                let count=summary.counts[kind.id] ?? 0,off=hidden.contains(kind.id)
                Button {
                    withAnimation(.smooth) {if off {hidden.remove(kind.id)} else {hidden.insert(kind.id)}}
                } label:{
                    HStack(spacing:7) {
                        Circle().fill(KindStyle.color(kind.id)).frame(width:8,height:8)
                        KindIcon(kind:kind.id,size:15)
                        Text(kind.label).font(.callout)
                        Spacer(minLength:4)
                        Text("\(count) · \(Format.percent(Double(count)/Double(total)))")
                            .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                            .contentTransition(.numericText(value:Double(count))).animation(.default,value:count)
                    }
                    .padding(.horizontal,10).padding(.vertical,6)
                    .background(Capsule().fill(KindStyle.color(kind.id).opacity(off ? 0.04:0.12)))
                    .opacity(off ? 0.45:1)
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .help(off ? L("Megjelenítés","Show"):L("Elrejtés","Hide"))
            }
        }
    }
}

// MARK: - KPI card per stat

struct StatKPI:View {
    let kind:String,summary:StatsStore.Summary
    var body:some View {
        let total=summary.totals[kind] ?? 0
        let numeric=NSDecimalNumber(decimal:total).doubleValue
        let color=KindStyle.color(kind)
        let count=summary.counts[kind] ?? 0
        Card(padding:14) {
            VStack(alignment:.leading,spacing:8) {
                HStack(spacing:8) {
                    KindIcon(kind:kind,size:20)
                    Text(StatsStore.Kind.label(kind)).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(L("\(count) átvétel","\(count) claims")).font(.caption).foregroundStyle(.secondary)
                        .contentTransition(.numericText(value:Double(count))).animation(.default,value:count)
                }
                HStack(alignment:.firstTextBaseline,spacing:8) {
                    Text("+\(Format.compact(total))")
                        .font(.system(size:28,weight:.bold,design:.rounded).monospacedDigit())
                        .contentTransition(.numericText(value:numeric))
                        .animation(.default,value:numeric)
                        .help(Format.exact(total))
                    Text(L("\(Format.rate(total,from:summary.from,to:summary.to))/perc","\(Format.rate(total,from:summary.from,to:summary.to))/min"))
                        .font(.caption.weight(.semibold)).foregroundStyle(color)
                        .padding(.horizontal,7).padding(.vertical,3)
                        .background(Capsule().fill(color.opacity(0.12)))
                }
                Chart(summary.series[kind] ?? []) {p in
                    AreaMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Érték","Value"),p.value))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(LinearGradient(colors:[color.opacity(0.32),color.opacity(0.02)],startPoint:.top,endPoint:.bottom))
                    LineMark(x:.value(L("Idő","Time"),p.at),y:.value(L("Érték","Value"),p.value))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(color)
                        .lineStyle(StrokeStyle(lineWidth:2,lineCap:.round,lineJoin:.round))
                }
                .chartXAxis(.hidden).chartYAxis(.hidden)
                .chartXScale(domain:summary.from...max(summary.to,summary.from.addingTimeInterval(60)))
                .frame(height:64)
            }
        }
    }
}
