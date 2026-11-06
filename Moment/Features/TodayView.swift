import SwiftUI
import MomentShared
struct Page<Content: View>: View {
    let title: String
    let content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    var body: some View {
        NavigationStack {
            ScrollView { VStack(alignment: .leading, spacing: 24) { content }.padding(22) }
                .background(Midnight.background).navigationTitle(title)
                .toolbarBackground(Midnight.background, for: .navigationBar)
        }
    }
}
struct TodayView: View {
    @EnvironmentObject private var model: DashboardViewModel
    @AppStorage("gentleSuggestions") private var suggestions = true
    @Environment(\.dynamicTypeSize) private var typeSize
    var body: some View {
        Page("moment.") {
            Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased())
                .font(.caption.weight(.medium)).tracking(2).foregroundStyle(Midnight.mint)
            VStack(alignment: .leading, spacing: 8) {
                Text("A moment for you.").font(.system(.largeTitle, design: .serif))
                Text("Here's what your day is telling you.").foregroundStyle(.secondary)
            }
            if let error = model.error {
                MomentCard { Label(error, systemImage: "exclamationmark.circle").font(.subheadline); Button("Try again") { Task { await model.refresh() } }.disabled(model.isLoading) }
            }
            if let snapshot = model.snapshot {
                MomentCard {
                    SourceBadge(snapshot.source)
                    Text(snapshot.insight.title).font(.system(.title, design: .serif))
                    Text(snapshot.insight.explanation).foregroundStyle(.secondary)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: typeSize.isAccessibilitySize ? 1 : 2), spacing: 14) {
                    ForEach(snapshot.metrics) { metric in
                        MomentCard {
                            Image(systemName: metric.type.symbol).foregroundStyle(Midnight.mint)
                            Text(metric.type.title).font(.subheadline).foregroundStyle(.secondary)
                            Text(metric.displayValue).font(.system(.title, design: .rounded).weight(.semibold)).minimumScaleFactor(0.7)
                            Text(metric.value == nil ? "Not available" : metric.source == .sample ? "Sample · \(metric.unit)" : metric.unit).font(.caption).foregroundStyle(.secondary)
                        }.accessibilityElement(children: .combine)
                    }
                }
                if suggestions { MomentCard {
                    Label("ONE THING TO TRY", systemImage: "leaf").font(.caption.weight(.semibold)).foregroundStyle(Midnight.mint)
                    Text("Make room for a short walk.").font(.title3.weight(.medium))
                    Text("A break between tasks can be a good moment to move. Start small, at your own pace.").foregroundStyle(.secondary)
                    Text("General wellbeing suggestion").font(.caption).foregroundStyle(.secondary)
                } }
                Text("\(snapshot.isStale() ? "Cached summary" : "Updated") · \(snapshot.generatedAt.formatted(date: .abbreviated, time: .shortened))").font(.caption).foregroundStyle(.secondary)
            } else if !model.isLoading {
                ContentUnavailableView("Your summary awaits", systemImage: "sun.max", description: Text("Refresh or explore sample mode in Profile."))
            }
            if model.isLoading { ProgressView("Refreshing your day…").frame(maxWidth: .infinity) }
        }.refreshable { await model.refresh() }
    }
}
