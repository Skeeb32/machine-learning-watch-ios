import SwiftUI
import MomentShared
@main struct MomentWatchApp: App {
    @StateObject private var connectivity = ConnectivityManager()
    var body: some Scene {
        WindowGroup { WatchHomeView().environmentObject(connectivity).preferredColorScheme(.dark).tint(Midnight.mint) }
    }
}
struct WatchHomeView: View {
    @EnvironmentObject private var connectivity: ConnectivityManager
    @State private var sampleMode = false
    private var snapshot: DashboardSnapshot? { sampleMode ? SampleData.snapshot() : connectivity.snapshot }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("moment.").font(.title2.bold()).foregroundStyle(Midnight.mint)
                    Text("Your day.").font(.system(.title2, design: .serif))
                    if let snapshot {
                        SourceBadge(snapshot.source)
                        NavigationLink { WatchInsightView(snapshot: snapshot) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Image(systemName: "sparkles").foregroundStyle(Midnight.mint)
                                Text(snapshot.insight.title).font(.headline)
                                Text("Explore insight").font(.caption).foregroundStyle(.secondary)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if let steps = snapshot.metrics.first(where: { $0.type == .steps }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Activity", systemImage: "figure.walk").foregroundStyle(Midnight.mint)
                                Text("\(steps.displayValue) steps").font(.title3.bold())
                                Text(steps.value == nil ? "Not available" : snapshot.source == .sample ? "Illustrative data" : "Apple Health").font(.caption2).foregroundStyle(.secondary)
                            }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Midnight.surface, in: RoundedRectangle(cornerRadius: 16))
                        }
                        Text("\(snapshot.isStale() ? "Cached" : "Updated") \(snapshot.generatedAt.formatted(date: .abbreviated, time: .shortened))").font(.caption2).foregroundStyle(.secondary)
                    } else {
                        Text("Your summary starts on iPhone.").font(.headline)
                        Text("Open MOMENT on your paired iPhone and refresh Today. Your latest summary will stay available here offline.").font(.caption).foregroundStyle(.secondary)
                    }
                    NavigationLink("Quick prompts") { WatchPromptsView() }
                    Toggle("Preview sample", isOn: $sampleMode).font(.caption)
                    Text(connectivity.status).font(.caption2).foregroundStyle(.secondary)
                }.padding(.horizontal, 4)
            }.containerBackground(Midnight.background, for: .navigation)
        }
    }
}
struct WatchInsightView: View {
    let snapshot: DashboardSnapshot
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 12) { SourceBadge(snapshot.source); Text(snapshot.insight.title).font(.headline); Text(snapshot.insight.explanation).font(.caption) } }.navigationTitle("Your MOMENT")
    }
}
struct WatchPromptsView: View {
    var body: some View {
        List(["How was my sleep?", "How active was I?"], id: \.self) { prompt in
            NavigationLink(prompt) { ScrollView { VStack(alignment: .leading, spacing: 12) { Text(prompt).font(.headline); Text("Open Ask on your iPhone to explore this sample conversation. Live AI and Watch requests are not connected yet.").font(.caption).foregroundStyle(.secondary) } } }
        }.navigationTitle("Quick prompts")
    }
}
