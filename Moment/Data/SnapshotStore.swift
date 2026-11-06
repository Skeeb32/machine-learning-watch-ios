import Foundation
import SwiftData
import MomentShared

@Model final class StoredSnapshot {
    @Attribute(.unique) var key: String
    var payload: Data
    init(key: String, payload: Data) { self.key = key; self.payload = payload }
}
@MainActor protocol SnapshotStoring {
    func load(source: DataSource) throws -> DashboardSnapshot?
    func save(_ snapshot: DashboardSnapshot) throws
}
@MainActor final class SnapshotStore: SnapshotStoring {
    let context: ModelContext
    init(context: ModelContext) { self.context = context }
    func load(source: DataSource) throws -> DashboardSnapshot? {
        let key = source.rawValue
        let records = try context.fetch(FetchDescriptor<StoredSnapshot>(predicate: #Predicate { $0.key == key }))
        guard let payload = records.first?.payload else { return nil }
        let snapshot = try JSONDecoder().decode(DashboardSnapshot.self, from: payload)
        return snapshot.version == 1 && snapshot.source == source ? snapshot : nil
    }
    func save(_ snapshot: DashboardSnapshot) throws {
        let key = snapshot.source.rawValue
        let payload = try JSONEncoder().encode(snapshot)
        let records = try context.fetch(FetchDescriptor<StoredSnapshot>(predicate: #Predicate { $0.key == key }))
        if let record = records.first { record.payload = payload }
        else { context.insert(StoredSnapshot(key: key, payload: payload)) }
        try context.save()
    }
}
