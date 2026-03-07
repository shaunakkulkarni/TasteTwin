import Foundation

@MainActor
protocol TasteRepositoryProtocol {
    func upsertDimension(_ dimension: TasteDimension) async throws -> TasteDimension
    func saveEvidence(_ evidence: TasteEvidence) async throws -> TasteEvidence
    func fetchDimension(named name: String) async throws -> TasteDimension?
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension]
    func fetchEvidence(forDimensionID id: UUID) async throws -> [TasteEvidence]
    func fetchDimensionIDs(forLogEntryID id: UUID) async throws -> [UUID]
    func deleteEvidence(forLogEntryID id: UUID) async throws
    func recomputeDimensionAggregate(dimensionID: UUID) async throws -> TasteDimension?
}

struct UnimplementedTasteRepository: TasteRepositoryProtocol {
    func upsertDimension(_ dimension: TasteDimension) async throws -> TasteDimension { dimension }
    func saveEvidence(_ evidence: TasteEvidence) async throws -> TasteEvidence { evidence }
    func fetchDimension(named name: String) async throws -> TasteDimension? { nil }
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension] { [] }
    func fetchEvidence(forDimensionID id: UUID) async throws -> [TasteEvidence] { [] }
    func fetchDimensionIDs(forLogEntryID id: UUID) async throws -> [UUID] { [] }
    func deleteEvidence(forLogEntryID id: UUID) async throws {}
    func recomputeDimensionAggregate(dimensionID: UUID) async throws -> TasteDimension? { nil }
}
