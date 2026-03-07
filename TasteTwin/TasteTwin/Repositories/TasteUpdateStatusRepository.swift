import Foundation

@MainActor
protocol TasteUpdateStatusRepositoryProtocol {
    func markTasteUpdateStatus(logID: UUID, status: TasteUpdateStatus, errorMessage: String?) async throws
    func fetchPendingTasteUpdateLogIDs(limit: Int) async throws -> [UUID]
}

struct UnimplementedTasteUpdateStatusRepository: TasteUpdateStatusRepositoryProtocol {
    func markTasteUpdateStatus(logID: UUID, status: TasteUpdateStatus, errorMessage: String?) async throws {}
    func fetchPendingTasteUpdateLogIDs(limit: Int) async throws -> [UUID] { [] }
}
