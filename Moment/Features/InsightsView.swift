import SwiftUI
import Charts
import MomentShared
struct InsightsView: View {
    @EnvironmentObject private var model: DashboardViewModel
    @State private var days = 7
    var body: some View {
        Page("Insights") {
            Text("See the bigger picture.").font(.system(.largeTitle, design: .serif))
            Picker("Time period", selection: $days) { Text("7 days").tag(7); Text("30 days").tag(30) }.pickerStyle(.segmented)
            if model.sampleMode {
                SourceBadge(.sample)
                MomentCard {
                    Text("Daily movement").font(.headline)
                    Text("An illustrative look at your last \(days) days.").font(.subheadline).foregroundStyle(.secondary)
                    Chart(Array(SampleData.steps(days: days).enumerated()), id: \.offset) { entry in
                        BarMark(x: .value("Day", entry.offset + 1), y: .value("Steps", entry.element)).foregroundStyle(Midnight.mint.gradient).cornerRadius(3)
                    }.frame(height: 190).chartXAxisLabel("Day in sample period").chartYAxisLabel("Steps")
                    Text("Sample daily average: \(Int(SampleData.steps(days: days).reduce(0, +) / Double(days)).formatted()) steps").font(.subheadline)
                }
                MomentCard {
                    Text("Consistency over intensity.").font(.title3.weight(.semibold))
                    Text("This example shows how a daily briefing will connect your activity with a useful reflection. It is not a finding about you.").foregroundStyle(.secondary)
                }
            } else {
                ContentUnavailableView("History is growing", systemImage: "chart.xyaxis.line", description: Text("This build reads today's steps. Historical metrics and generated insights are not connected yet."))
            }
        }
    }
}
struct PatternsView: View {
    @EnvironmentObject private var model: DashboardViewModel
    var body: some View {
        Page("Patterns") {
            Text("Small things,\nover time.").font(.system(.largeTitle, design: .serif))
            if model.sampleMode {
                SourceBadge(.sample)
                MomentCard {
                    Image(systemName: "figure.walk").font(.title).foregroundStyle(Midnight.mint)
                    Text("Finding your pace").font(.title2)
                    Text("In the illustrative week, activity varied from day to day. A longer history will help MOMENT describe your personal baseline.").foregroundStyle(.secondary)
                    Text("Illustration only · no personal analysis").font(.caption).foregroundStyle(Midnight.mint)
                }
            }
            MomentCard {
                Label("More history, more perspective", systemImage: "circle.dotted").font(.headline)
                Text("Personal pattern detection is coming in a later milestone. MOMENT will show the observations behind each pattern and explain when there is not enough data.").foregroundStyle(.secondary)
            }
        }
    }
}
