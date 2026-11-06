import XCTest
import SwiftData
import MomentShared
@testable import Moment

@MainActor final class MomentTests: XCTestCase {
    func testSnapshotRoundTripAndOrdering() throws {
        let date = Date(timeIntervalSince1970: 10000)
        let snapshot = SampleData.snapshot(now: date)
        let restored = try JSONDecoder().decode(DashboardSnapshot.self, from: JSONEncoder().encode(snapshot))
        XCTAssertEqual(snapshot, restored)
        XCTAssertFalse(SampleData.snapshot(now: date.addingTimeInterval(-1)).canReplace(snapshot))
        XCTAssertTrue(snapshot.isStale(now: date.addingTimeInterval(3601)))
        let unsupported = DashboardSnapshot(generatedAt: date, source: .sample, metrics: [], insight: snapshot.insight, version: 2)
        XCTAssertFalse(unsupported.canReplace(nil))
    }
    func testMissingStepValueIsNotZero() {
        let missing = HealthMetric(type: .steps, value: nil, unit: "steps", recordedAt: .now, source: .healthKit)
        let zero = HealthMetric(type: .steps, value: 0, unit: "steps", recordedAt: .now, source: .healthKit)
        XCTAssertEqual(missing.displayValue, "—")
        XCTAssertEqual(zero.displayValue, "0")
    }
    func testPersistenceSeparatesSourcesAndUpdatesExistingRecord() throws {
        let container = try ModelContainer(for: StoredSnapshot.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let store = SnapshotStore(context: container.mainContext)
        let first = SampleData.snapshot(now: Date(timeIntervalSince1970: 100))
        let second = SampleData.snapshot(now: Date(timeIntervalSince1970: 200))
        try store.save(first)
        try store.save(second)
        let reloaded = SnapshotStore(context: ModelContext(container))
        XCTAssertEqual(try reloaded.load(source: .sample), second)
        XCTAssertNil(try reloaded.load(source: .healthKit))
        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<StoredSnapshot>()), 1)
    }
    func testModeSwitchDoesNotLeakSampleMetricsWhenLiveFetchFails() async {
        let suite = "moment.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let model = DashboardViewModel(store: MemoryStore(), health: FailingHealth(), defaults: defaults)
        await model.refresh()
        XCTAssertEqual(model.snapshot?.source, .sample)
        await model.setSampleMode(false)
        XCTAssertNil(model.snapshot)
        XCTAssertNotNil(model.error)
        XCTAssertFalse(model.sampleMode)
        XCTAssertFalse(model.isLoading)
    }
    func testEmptyChatDoesNotSubmitAndSuccessfulResponseIsLabeled() async {
        let model = ChatViewModel(service: SampleAIService())
        model.input = "   "
        await model.send()
        XCTAssertTrue(model.messages.isEmpty)
        model.input = "How was my sleep?"
        await model.send()
        XCTAssertEqual(model.messages.count, 2)
        XCTAssertTrue(model.messages[1].text.contains("sample response"))
        XCTAssertFalse(model.isSending)
    }
}
@MainActor private final class MemoryStore: SnapshotStoring {
    var value: DashboardSnapshot?
    func load(source: DataSource) throws -> DashboardSnapshot? { value?.source == source ? value : nil }
    func save(_ snapshot: DashboardSnapshot) throws { value = snapshot }
}
@MainActor private struct FailingHealth: HealthRepository {
    var isAvailable: Bool { true }
    func requestAccess() async throws {}
    func snapshot(now: Date) async throws -> DashboardSnapshot { throw CocoaError(.fileReadUnknown) }
}
