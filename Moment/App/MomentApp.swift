import SwiftUI
import SwiftData
import MomentShared

@main struct MomentApp: App {
    private let container: ModelContainer?
    @StateObject private var dashboard: DashboardViewModel
    init() {
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            UserDefaults.standard.removeObject(forKey: "hasOnboarded")
            UserDefaults.standard.set(true, forKey: "sampleMode")
        }
        do {
            let container = try ModelContainer(for: StoredSnapshot.self)
            self.container = container
            _dashboard = StateObject(wrappedValue: DashboardViewModel(store: SnapshotStore(context: container.mainContext)))
        } catch {
            container = nil
            _dashboard = StateObject(wrappedValue: DashboardViewModel(store: UnavailableStore()))
        }
    }
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(dashboard)
                .preferredColorScheme(.dark).tint(Midnight.mint)
        }
    }
}
@MainActor private struct UnavailableStore: SnapshotStoring {
    func load(source: DataSource) throws -> DashboardSnapshot? { throw CocoaError(.fileReadUnknown) }
    func save(_ snapshot: DashboardSnapshot) throws { throw CocoaError(.fileWriteUnknown) }
}
struct RootView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @EnvironmentObject private var model: DashboardViewModel
    var body: some View {
        Group {
            if hasOnboarded {
                TabView {
                    TodayView().tabItem { Label("Today", systemImage: "sun.max") }.accessibilityIdentifier("todayTab")
                    AskView().tabItem { Label("Ask", systemImage: "sparkles") }
                    InsightsView().tabItem { Label("Insights", systemImage: "chart.xyaxis.line") }
                    PatternsView().tabItem { Label("Patterns", systemImage: "circle.grid.cross") }
                    ProfileView().tabItem { Label("Profile", systemImage: "person.crop.circle") }
                }.task { await model.refresh() }
            } else {
                OnboardingView { hasOnboarded = true }
            }
        }
    }
}
struct OnboardingView: View {
    let finish: () -> Void
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("moment.").font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(Midnight.mint)
                Text("A little clarity.\nEvery day.").font(.system(.largeTitle, design: .serif).weight(.medium))
                Text("Make sense of your day.").font(.title3).foregroundStyle(.secondary)
                MomentCard {
                    Image(systemName: "sparkle").font(.largeTitle).foregroundStyle(Midnight.mint)
                    Text("Your day, thoughtfully connected.").font(.title2.weight(.semibold))
                    Text("Explore activity, daily insights, and a companion for your wrist. Start with clearly labeled sample data.").foregroundStyle(.secondary)
                }
                Label("Your health data stays on your devices in this build.", systemImage: "lock.shield").font(.subheadline)
                Text("Connect Apple Health later in Profile. Only steps are supported initially. Ask uses sample responses, with no AI server connection.").font(.footnote).foregroundStyle(.secondary)
                Button(action: finish) { Text("Explore MOMENT").fontWeight(.semibold).frame(maxWidth: .infinity).padding(10) }
                    .buttonStyle(.borderedProminent).accessibilityIdentifier("exploreMoment")
                Text("MIDNIGHT · BUILD 0.1").font(.caption2).tracking(3).foregroundStyle(.secondary)
            }.padding(28)
        }.background(Midnight.background)
    }
}
