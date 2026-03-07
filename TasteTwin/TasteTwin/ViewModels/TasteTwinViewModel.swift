import Foundation
import Observation

@MainActor
@Observable
final class TasteTwinViewModel {
    var dimensions: [TasteDimension] = []
    var evidenceByDimensionID: [UUID: [TasteEvidence]] = [:]
    var expandedDimensionIDs: Set<UUID> = []
    var statusSummary: TasteUpdateStatusSummary = .empty
    var isExtractionInFlight = false
    var shouldShowExtractionProgressBar = false
    var extractionProgressValue = 0.0
    var shouldShowExtractionFallbackPill = false
    var isLoading = false
    var errorMessage: String?

    private var tasteProfileService: TasteProfileServiceProtocol
    private var tasteRepository: TasteRepositoryProtocol
    private var statusRepository: TasteUpdateStatusRepositoryProtocol
    private var progressSessionTask: Task<Void, Never>?
    private var fallbackPillTask: Task<Void, Never>?
    private let userDefaults: UserDefaults

    init(
        tasteProfileService: TasteProfileServiceProtocol,
        tasteRepository: TasteRepositoryProtocol,
        statusRepository: TasteUpdateStatusRepositoryProtocol,
        userDefaults: UserDefaults = .standard
    ) {
        self.tasteProfileService = tasteProfileService
        self.tasteRepository = tasteRepository
        self.statusRepository = statusRepository
        self.userDefaults = userDefaults
    }

    func configure(
        tasteProfileService: TasteProfileServiceProtocol,
        tasteRepository: TasteRepositoryProtocol,
        statusRepository: TasteUpdateStatusRepositoryProtocol
    ) {
        self.tasteProfileService = tasteProfileService
        self.tasteRepository = tasteRepository
        self.statusRepository = statusRepository
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await refreshDimensions()
        await refreshStatusSummary()
    }

    func beginExtractionProgressSession() {
        progressSessionTask?.cancel()
        progressSessionTask = Task { @MainActor in
            let startedAt = Date()
            shouldShowExtractionProgressBar = true
            extractionProgressValue = max(extractionProgressValue, 0.08)

            await refreshStatusSummary()
            var baselineInFlight = max(1, statusSummary.pendingCount + statusSummary.processingCount)

            while !Task.isCancelled {
                await refreshStatusSummary()
                let currentInFlight = statusSummary.pendingCount + statusSummary.processingCount
                baselineInFlight = max(baselineInFlight, currentInFlight)

                if currentInFlight > 0 {
                    let completed = Double(baselineInFlight - currentInFlight) / Double(max(1, baselineInFlight))
                    extractionProgressValue = min(0.92, max(0.08, completed))
                } else {
                    extractionProgressValue = 1.0
                    let elapsed = Date().timeIntervalSince(startedAt)
                    if elapsed >= Constants.tasteTwinProgressMinVisibleSeconds {
                        await refreshDimensions()
                        shouldShowExtractionProgressBar = false
                        extractionProgressValue = 0
                        break
                    }
                    try? await Task.sleep(for: .milliseconds(100))
                }

                try? await Task.sleep(for: .milliseconds(Constants.tasteTwinProgressPollMilliseconds))
            }
        }
    }

    func showMockExtractionFallbackIndicator() {
        fallbackPillTask?.cancel()
        shouldShowExtractionFallbackPill = true
        fallbackPillTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(Constants.tasteTwinFallbackPillVisibleSeconds))
            guard !Task.isCancelled else { return }
            shouldShowExtractionFallbackPill = false
        }
    }

    private func refreshDimensions() async {
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

    private func refreshStatusSummary() async {
        do {
            statusSummary = try await statusRepository.fetchTasteUpdateStatusSummary()
        } catch {
            statusSummary = .empty
        }

        isExtractionInFlight = (statusSummary.pendingCount + statusSummary.processingCount) > 0
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

    func consumeRecentLogSaveSignal() -> Bool {
        let now = Date().timeIntervalSince1970
        let savedAt = userDefaults.double(forKey: Constants.lastLogSaveTimestampDefaultsKey)
        guard savedAt > 0, (now - savedAt) <= Constants.tasteTwinRecentSaveSignalWindowSeconds else {
            return false
        }

        userDefaults.set(0, forKey: Constants.lastLogSaveTimestampDefaultsKey)
        return true
    }
}
