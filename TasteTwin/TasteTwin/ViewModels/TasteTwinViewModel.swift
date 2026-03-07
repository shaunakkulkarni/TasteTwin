import Foundation
import Observation

@MainActor
@Observable
final class TasteTwinViewModel {
    var dimensions: [TasteDimension] = []
    var evidenceByDimensionID: [UUID: [TasteEvidence]] = [:]
    var expandedDimensionIDs: Set<UUID> = []
    var isLoading = false
    var errorMessage: String?

    private var tasteProfileService: TasteProfileServiceProtocol
    private var tasteRepository: TasteRepositoryProtocol

    init(tasteProfileService: TasteProfileServiceProtocol, tasteRepository: TasteRepositoryProtocol) {
        self.tasteProfileService = tasteProfileService
        self.tasteRepository = tasteRepository
    }

    func configure(tasteProfileService: TasteProfileServiceProtocol, tasteRepository: TasteRepositoryProtocol) {
        self.tasteProfileService = tasteProfileService
        self.tasteRepository = tasteRepository
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched = try await tasteProfileService.fetchTopDimensions(limit: Constants.tasteTwinMaxDimensionCount)
            let visible = fetched
                .filter { $0.confidence >= Constants.tasteTwinLowConfidenceThreshold }
                .sorted { lhs, rhs in
                    if lhs.weight == rhs.weight {
                        return lhs.updatedAt > rhs.updatedAt
                    }
                    return lhs.weight > rhs.weight
                }

            dimensions = visible
            evidenceByDimensionID.removeAll(keepingCapacity: true)

            for dimension in visible {
                let evidence = try await tasteRepository.fetchEvidence(forDimensionID: dimension.id)
                evidenceByDimensionID[dimension.id] = Array(evidence.prefix(Constants.tasteTwinMaxEvidencePerDimension))
            }
        } catch {
            errorMessage = error.localizedDescription
            dimensions = []
            evidenceByDimensionID = [:]
        }
    }

    func toggleExpanded(for dimensionID: UUID) {
        if expandedDimensionIDs.contains(dimensionID) {
            expandedDimensionIDs.remove(dimensionID)
        } else {
            expandedDimensionIDs.insert(dimensionID)
        }
    }

    func isExpanded(_ dimensionID: UUID) -> Bool {
        expandedDimensionIDs.contains(dimensionID)
    }

    func evidence(for dimensionID: UUID) -> [TasteEvidence] {
        evidenceByDimensionID[dimensionID] ?? []
    }

    func displayName(for dimension: TasteDimension) -> String {
        if let key = dimension.key {
            return key.displayName
        }
        return dimension.name
    }

    func confidenceText(for dimension: TasteDimension) -> String {
        "\(Int((dimension.confidence * 100).rounded()))% confidence"
    }
}
