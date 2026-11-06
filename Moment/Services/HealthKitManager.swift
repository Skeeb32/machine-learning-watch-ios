import Foundation
import HealthKit
import MomentShared

@MainActor protocol HealthRepository {
    var isAvailable: Bool { get }
    func requestAccess() async throws
    func snapshot(now: Date) async throws -> DashboardSnapshot
}
@MainActor final class HealthKitManager: HealthRepository {
    private let store = HKHealthStore()
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    func requestAccess() async throws {
        guard isAvailable, let steps = HKObjectType.quantityType(forIdentifier: .stepCount) else { throw HealthError.unavailable }
        // Request only the data this milestone actually reads.
        try await store.requestAuthorization(toShare: [], read: [steps])
    }
    func snapshot(now: Date) async throws -> DashboardSnapshot {
        guard isAvailable, let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { throw HealthError.unavailable }
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        let count: Double? = try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: .count())) }
            }
            store.execute(query)
        }
        let metrics = [
            HealthMetric(type: .sleep, value: nil, unit: "min", recordedAt: now, source: .healthKit),
            HealthMetric(type: .steps, value: count, unit: "steps", recordedAt: now, source: .healthKit),
            HealthMetric(type: .restingHeartRate, value: nil, unit: "bpm", recordedAt: now, source: .healthKit),
            HealthMetric(type: .activeEnergy, value: nil, unit: "kcal", recordedAt: now, source: .healthKit)
        ]
        return DashboardSnapshot(generatedAt: now, source: .healthKit, metrics: metrics, insight: DailyInsight(title: count == nil ? "Your day, at your pace." : "A little movement adds up.", explanation: count == nil ? "No step data is available. You can review MOMENT's access in Apple Health. Other metrics are coming in a later build." : "Your step total comes from Apple Health. Personal insights need more history; other metrics are not connected yet.", source: .healthKit, generatedAt: now))
    }
    enum HealthError: LocalizedError {
        case unavailable
        var errorDescription: String? { "Apple Health is unavailable on this device." }
    }
}
