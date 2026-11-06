import Foundation
import Combine
import WatchConnectivity

@MainActor
public final class ConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published public private(set) var snapshot: DashboardSnapshot?
    @Published public private(set) var status = "Waiting for connection"
    private let defaults: UserDefaults
    private let cacheKey = "moment.watch.snapshot.v1"
    private var pending: DashboardSnapshot?
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
        if let data = defaults.data(forKey: cacheKey), let value = try? JSONDecoder().decode(DashboardSnapshot.self, from: data), value.version == 1 { snapshot = value }
        if WCSession.isSupported() { WCSession.default.delegate = self; WCSession.default.activate() }
        else { status = "Connectivity unavailable" }
    }
    public func publish(_ value: DashboardSnapshot) {
        pending = value
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }
        #if os(iOS)
        guard WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else { status = "Pair a Watch and install MOMENT"; return }
        #endif
        do {
            try WCSession.default.updateApplicationContext(["snapshot": JSONEncoder().encode(value)])
            status = "Latest summary queued for Watch"
        } catch { status = "Sync unavailable. Try refreshing later." }
    }
    private func receive(_ data: Data) {
        guard let value = try? JSONDecoder().decode(DashboardSnapshot.self, from: data), value.canReplace(snapshot) else { return }
        snapshot = value
        defaults.set(data, forKey: cacheKey)
        status = "Summary received from iPhone"
    }
    nonisolated public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let data = session.receivedApplicationContext["snapshot"] as? Data
        let ready = activationState == .activated && error == nil
        Task { @MainActor in
            self.status = ready ? "Ready to sync" : "Connection unavailable"
            if let data { self.receive(data) }
            if ready, let pending = self.pending { self.publish(pending) }
        }
    }
    nonisolated public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["snapshot"] as? Data else { return }
        Task { @MainActor in self.receive(data) }
    }
    #if os(iOS)
    nonisolated public func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated public func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    nonisolated public func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in if let pending = self.pending { self.publish(pending) } }
    }
    #endif
}
