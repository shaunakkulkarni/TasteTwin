import Foundation
import SwiftData

@MainActor
final class SwiftDataLogRepository: LogRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createLog(_ entry: LogEntry) async throws -> LogEntry {
        guard let albumRecord = try await fetchAlbumRecord(by: entry.albumID) else {
            throw SwiftDataLogRepositoryError.albumNotFound
        }

        let record = LogEntryRecord(
            id: entry.id,
            album: albumRecord,
            rating: entry.rating,
            reviewText: entry.reviewText,
            tags: entry.tags,
            loggedAt: entry.loggedAt,
            updatedAt: entry.updatedAt
        )

        modelContext.insert(record)
        try modelContext.save()
        guard let mapped = record.asDomain() else {
            throw SwiftDataLogRepositoryError.albumNotFound
        }
        return mapped
    }

    func updateLog(_ entry: LogEntry) async throws -> LogEntry {
        guard let existing = try await fetchLogRecord(by: entry.id) else {
            throw SwiftDataLogRepositoryError.logNotFound
        }

        existing.rating = entry.rating
        existing.reviewText = entry.reviewText
        existing.tags = entry.tags
        existing.updatedAt = .now
        try modelContext.save()

        guard let mapped = existing.asDomain() else {
            throw SwiftDataLogRepositoryError.albumNotFound
        }
        return mapped
    }

    func deleteLog(id: UUID) async throws {
        guard let existing = try await fetchLogRecord(by: id) else {
            return
        }

        modelContext.delete(existing)
        try modelContext.save()
    }

    func fetchRecentLogs(limit: Int) async throws -> [LogEntry] {
        let descriptor = FetchDescriptor<LogEntryRecord>(sortBy: [SortDescriptor(\LogEntryRecord.loggedAt, order: .reverse)])
        let logs = try modelContext.fetch(descriptor)
        return Array(logs.prefix(limit)).compactMap { $0.asDomain() }
    }

    func fetchAllLogs() async throws -> [LogEntry] {
        let descriptor = FetchDescriptor<LogEntryRecord>(sortBy: [SortDescriptor(\LogEntryRecord.loggedAt, order: .reverse)])
        return try modelContext.fetch(descriptor).compactMap { $0.asDomain() }
    }

    func fetchLog(byID id: UUID) async throws -> LogEntry? {
        try await fetchLogRecord(by: id)?.asDomain()
    }

    func fetchLog(forAlbumID id: UUID) async throws -> LogEntry? {
        let descriptor = FetchDescriptor<LogEntryRecord>(sortBy: [SortDescriptor(\LogEntryRecord.loggedAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
            .first(where: { $0.album?.id == id })?
            .asDomain()
    }

    private func fetchLogRecord(by id: UUID) async throws -> LogEntryRecord? {
        let descriptor = FetchDescriptor<LogEntryRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }

    private func fetchAlbumRecord(by id: UUID) async throws -> AlbumRecord? {
        let descriptor = FetchDescriptor<AlbumRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first
    }
}

enum SwiftDataLogRepositoryError: Error {
    case albumNotFound
    case logNotFound
}

private extension LogEntryRecord {
    func asDomain() -> LogEntry? {
        guard let albumID = album?.id else {
            return nil
        }

        return LogEntry(
            id: id,
            albumID: albumID,
            rating: rating,
            reviewText: reviewText,
            tags: tags,
            loggedAt: loggedAt,
            updatedAt: updatedAt
        )
    }
}
