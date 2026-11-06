import Foundation

public enum DataSource: String, Codable, Sendable { case sample, healthKit, userEntered }
public enum MetricType: String, Codable, CaseIterable, Identifiable, Sendable {
    case steps, sleep, restingHeartRate, activeEnergy, heartRate, workouts
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .steps: return "Steps"
        case .sleep: return "Sleep"
        case .restingHeartRate: return "Resting heart rate"
        case .activeEnergy: return "Active energy"
        case .heartRate: return "Heart rate"
        case .workouts: return "Workouts"
        }
    }
    public var symbol: String {
        switch self {
        case .steps: return "figure.walk"
        case .sleep: return "moon.zzz.fill"
        case .restingHeartRate, .heartRate: return "heart.fill"
        case .activeEnergy: return "flame.fill"
        case .workouts: return "figure.run"
        }
    }
}
public struct HealthMetric: Identifiable, Codable, Equatable, Sendable {
    public var id: String { type.rawValue }
    public let type: MetricType
    public let value: Double?
    public let unit: String
    public let recordedAt: Date
    public let source: DataSource
    public init(type: MetricType, value: Double?, unit: String, recordedAt: Date, source: DataSource) {
        self.type = type; self.value = value; self.unit = unit; self.recordedAt = recordedAt; self.source = source
    }
    public var displayValue: String {
        guard let value else { return "—" }
        if type == .sleep { return "\(Int(value) / 60)h \(Int(value) % 60)m" }
        return value.formatted(.number.precision(.fractionLength(0)))
    }
}
public struct DailyInsight: Codable, Equatable, Sendable {
    public let title: String
    public let explanation: String
    public let source: DataSource
    public let generatedAt: Date
    public init(title: String, explanation: String, source: DataSource, generatedAt: Date) {
        self.title = title; self.explanation = explanation; self.source = source; self.generatedAt = generatedAt
    }
}
public struct DashboardSnapshot: Codable, Equatable, Sendable {
    public let version: Int
    public let generatedAt: Date
    public let source: DataSource
    public let metrics: [HealthMetric]
    public let insight: DailyInsight
    public init(generatedAt: Date, source: DataSource, metrics: [HealthMetric], insight: DailyInsight, version: Int = 1) {
        self.version = version; self.generatedAt = generatedAt; self.source = source; self.metrics = metrics; self.insight = insight
    }
    public func isStale(now: Date = .now) -> Bool { now.timeIntervalSince(generatedAt) > 3600 }
    public func canReplace(_ previous: DashboardSnapshot?) -> Bool {
        version == 1 && (previous == nil || generatedAt >= previous!.generatedAt)
    }
}
public enum SampleData {
    public static func snapshot(now: Date = .now) -> DashboardSnapshot {
        DashboardSnapshot(generatedAt: now, source: .sample, metrics: [
            HealthMetric(type: .sleep, value: 432, unit: "min", recordedAt: now, source: .sample),
            HealthMetric(type: .steps, value: 8420, unit: "steps", recordedAt: now, source: .sample),
            HealthMetric(type: .restingHeartRate, value: 62, unit: "bpm", recordedAt: now, source: .sample),
            HealthMetric(type: .activeEnergy, value: 380, unit: "kcal", recordedAt: now, source: .sample)
        ], insight: DailyInsight(title: "You're finding your rhythm.", explanation: "Your recent activity has been more consistent. Keep building on the routines that work for you.", source: .sample, generatedAt: now))
    }
    public static func steps(days: Int) -> [Double] {
        let week: [Double] = [5300, 7200, 6400, 9100, 7800, 6800, 8420]
        return (0..<days).map { week[$0 % week.count] + Double($0 / 7) * 120 }
    }
}
