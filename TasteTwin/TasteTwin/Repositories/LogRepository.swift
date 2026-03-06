import Foundation

@MainActor
protocol LogRepositoryProtocol {
    func createLog(_ entry: LogEntry) async throws -> LogEntry
    func updateLog(_ entry: LogEntry) async throws -> LogEntry
    func deleteLog(id: UUID) async throws
    func fetchRecentLogs(limit: Int) async throws -> [LogEntry]
}

struct UnimplementedLogRepository: LogRepositoryProtocol {
    func createLog(_ entry: LogEntry) async throws -> LogEntry { entry }
    func updateLog(_ entry: LogEntry) async throws -> LogEntry { entry }
    func deleteLog(id: UUID) async throws {}
    func fetchRecentLogs(limit: Int) async throws -> [LogEntry] { [] }
}
