import SwiftUI
import MomentShared
struct ProfileView: View {
    @EnvironmentObject private var model: DashboardViewModel
    @AppStorage("gentleSuggestions") private var suggestions = true
    var body: some View {
        Page("Profile") {
            Text("Your MOMENT.").font(.system(.largeTitle, design: .serif))
            MomentCard {
                Label("Experience", systemImage: "slider.horizontal.3").font(.headline)
                Toggle("Explore sample data", isOn: Binding(get: { model.sampleMode }, set: { enabled in Task { await model.setSampleMode(enabled) } })).disabled(model.isLoading)
                Text("Sample mode uses illustrative metrics. Live mode currently supports daily steps only.").font(.caption).foregroundStyle(.secondary)
                Toggle("Show daily suggestions", isOn: $suggestions)
            }
            MomentCard {
                Label("Apple Health", systemImage: "heart.fill").font(.headline)
                Text("Connect your step count. Your summary stays on this iPhone and can sync to your paired Watch.").foregroundStyle(.secondary)
                Button("Connect Apple Health") { Task { await model.connectHealth() } }.buttonStyle(.borderedProminent).disabled(model.isLoading)
                Text("No available records can mean no data or restricted access. Manage access in Apple Health.").font(.caption).foregroundStyle(.secondary)
                if let error = model.error { Text(error).font(.caption).foregroundStyle(.orange) }
            }
            ConnectionCard(manager: model.connectivity)
            MomentCard {
                Label("Private by design", systemImage: "lock.shield").font(.headline)
                Text("No account, analytics, or AI server is connected in Build 0.1. Health summaries stay on your devices. Chat is temporary and clears when the app closes.").foregroundStyle(.secondary)
                Text("Notifications, subscriptions, and account controls will arrive with their supporting services.").font(.caption).foregroundStyle(.secondary)
            }
            Text("MOMENT 0.1 · MIDNIGHT").font(.caption).tracking(2).foregroundStyle(Midnight.mint)
        }
    }
}
private struct ConnectionCard: View {
    @ObservedObject var manager: ConnectivityManager
    var body: some View { MomentCard { Label("Apple Watch", systemImage: "applewatch").font(.headline); Text(manager.status).foregroundStyle(.secondary) } }
}
