import Foundation
import Combine
import MomentShared

@MainActor final class DashboardViewModel: ObservableObject {
    @Published private(set) var snapshot: DashboardSnapshot?
    @Published private(set) var isLoading = false
    @Published var error: String?
    @Published private(set) var sampleMode: Bool
    private let store: any SnapshotStoring
    private let health: any HealthRepository
    private let defaults: UserDefaults
    private let now: () -> Date
    let connectivity: ConnectivityManager
    init(store: any SnapshotStoring, health: (any HealthRepository)? = nil, defaults: UserDefaults = .standard, connectivity: ConnectivityManager? = nil, now: @escaping () -> Date = Date.init) {
        self.store = store; self.health = health ?? HealthKitManager(); self.defaults = defaults; self.connectivity = connectivity ?? ConnectivityManager(); self.now = now
        sampleMode = defaults.object(forKey: "sampleMode") as? Bool ?? true
        do { snapshot = try store.load(source: sampleMode ? .sample : .healthKit) }
        catch { self.error = "Saved summary could not be read. Refresh to try again." }
    }
    func setSampleMode(_ enabled: Bool) async {
        guard !isLoading else { return }
        sampleMode = enabled
        defaults.set(enabled, forKey: "sampleMode")
        snapshot = nil
        await refresh()
    }
    func connectHealth() async {
        guard !isLoading else { return }
        isLoading = true; error = nil
        do {
            try await health.requestAccess()
            sampleMode = false; defaults.set(false, forKey: "sampleMode"); snapshot = nil
        } catch { self.error = error.localizedDescription; isLoading = false; return }
        isLoading = false
        await refresh()
    }
    func refresh() async {
        guard !isLoading else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            let result = sampleMode ? SampleData.snapshot(now: now()) : try await health.snapshot(now: now())
            snapshot = result
            try store.save(result)
            connectivity.publish(result)
        } catch { self.error = "Could not refresh or save your summary. \(error.localizedDescription)" }
    }
}
