import Foundation

@MainActor
protocol TasteUpdateStatusRepositoryProtocol {
    func markTasteUpdateStatus(logID: UUID, status: TasteUpdateStatus, errorMessage: String?) async throws
    func fetchPendingTasteUpdateLogIDs(limit: Int) async throws -> [UUID]
    func fetchFailedTasteUpdateLogIDs(limit: Int) async throws -> [UUID]
    func fetchTasteUpdateAttemptCount(logID: UUID) async throws -> Int?
    func fetchTasteUpdateStatusSummary() async throws -> TasteUpdateStatusSummary
}

struct UnimplementedTasteUpdateStatusRepository: TasteUpdateStatusRepositoryProtocol {
    func markTasteUpdateStatus(logID: UUID, status: TasteUpdateStatus, errorMessage: String?) async throws {}
    func fetchPendingTasteUpdateLogIDs(limit: Int) async throws -> [UUID] { [] }
    func fetchFailedTasteUpdateLogIDs(limit: Int) async throws -> [UUID] { [] }
    func fetchTasteUpdateAttemptCount(logID: UUID) async throws -> Int? { nil }
    func fetchTasteUpdateStatusSummary() async throws -> TasteUpdateStatusSummary { .empty }
}
