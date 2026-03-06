import Foundation

@MainActor
protocol LogRepositoryProtocol {
    func createLog(_ entry: LogEntry) async throws -> LogEntry
    func updateLog(_ entry: LogEntry) async throws -> LogEntry
    func deleteLog(id: UUID) async throws
    func fetchRecentLogs(limit: Int) async throws -> [LogEntry]
    func fetchAllLogs() async throws -> [LogEntry]
    func fetchLog(byID id: UUID) async throws -> LogEntry?
    func fetchLog(forAlbumID id: UUID) async throws -> LogEntry?
}

struct UnimplementedLogRepository: LogRepositoryProtocol {
    func createLog(_ entry: LogEntry) async throws -> LogEntry { entry }
    func updateLog(_ entry: LogEntry) async throws -> LogEntry { entry }
    func deleteLog(id: UUID) async throws {}
    func fetchRecentLogs(limit: Int) async throws -> [LogEntry] { [] }
    func fetchAllLogs() async throws -> [LogEntry] { [] }
    func fetchLog(byID id: UUID) async throws -> LogEntry? { nil }
    func fetchLog(forAlbumID id: UUID) async throws -> LogEntry? { nil }
}
