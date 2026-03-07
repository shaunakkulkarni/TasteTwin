import Foundation

@MainActor
protocol TasteRepositoryProtocol {
    func upsertDimension(_ dimension: TasteDimension) async throws -> TasteDimension
    func saveEvidence(_ evidence: TasteEvidence) async throws -> TasteEvidence
    func fetchDimension(named name: String) async throws -> TasteDimension?
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension]
    func fetchEvidence(forDimensionID id: UUID) async throws -> [TasteEvidence]
}

struct UnimplementedTasteRepository: TasteRepositoryProtocol {
    func upsertDimension(_ dimension: TasteDimension) async throws -> TasteDimension { dimension }
    func saveEvidence(_ evidence: TasteEvidence) async throws -> TasteEvidence { evidence }
    func fetchDimension(named name: String) async throws -> TasteDimension? { nil }
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension] { [] }
    func fetchEvidence(forDimensionID id: UUID) async throws -> [TasteEvidence] { [] }
}
