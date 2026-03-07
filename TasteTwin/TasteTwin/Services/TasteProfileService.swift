import Foundation

@MainActor
protocol TasteProfileServiceProtocol {
    func updateTasteProfile(with output: TasteExtractionOutput) async throws
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension]
}

@MainActor
final class TasteProfileService: TasteProfileServiceProtocol {
    private let tasteRepository: TasteRepositoryProtocol

    init(tasteRepository: TasteRepositoryProtocol) {
        self.tasteRepository = tasteRepository
    }

    func updateTasteProfile(with output: TasteExtractionOutput) async throws {
        for signal in output.signals {
            guard
                let key = TasteDimensionKey(normalized: signal.dimension),
                !signal.evidenceSnippet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                continue
            }

            let canonicalName = key.rawValue
            let existing = try await tasteRepository.fetchDimension(named: canonicalName)
            let sampleCount = try await existingEvidenceCount(for: existing)
            let denominator = max(1, sampleCount + 1)

            let incomingWeight = signal.direction.lowercased() == "negative"
                ? clamp(1.0 - signal.confidence)
                : clamp(signal.confidence)
            let incomingConfidence = clamp(signal.confidence)

            let mergedWeight = merge(existingValue: existing?.weight, incomingValue: incomingWeight, denominator: denominator)
            let mergedConfidence = merge(existingValue: existing?.confidence, incomingValue: incomingConfidence, denominator: denominator)

            let dimension = TasteDimension(
                id: existing?.id ?? UUID(),
                name: canonicalName,
                weight: mergedWeight,
                confidence: mergedConfidence,
                summary: summary(for: signal, key: key, existing: existing),
                updatedAt: .now
            )

            let persistedDimension = try await tasteRepository.upsertDimension(dimension)
            let evidence = TasteEvidence(
                id: UUID(),
                tasteDimensionID: persistedDimension.id,
                logEntryID: output.logEntryID,
                snippet: signal.evidenceSnippet,
                evidenceType: signal.evidenceType,
                strength: incomingConfidence
            )
            _ = try await tasteRepository.saveEvidence(evidence)
        }
    }

    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension] {
        try await tasteRepository.fetchTopDimensions(limit: limit)
    }

    private func existingEvidenceCount(for dimension: TasteDimension?) async throws -> Int {
        guard let dimension else { return 0 }
        return try await tasteRepository.fetchEvidence(forDimensionID: dimension.id).count
    }

    private func merge(existingValue: Double?, incomingValue: Double, denominator: Int) -> Double {
        guard let existingValue else {
            return clamp(incomingValue)
        }

        let numerator = (existingValue * Double(denominator - 1)) + incomingValue
        return clamp(numerator / Double(denominator))
    }

    private func summary(for signal: TasteSignalDTO, key: TasteDimensionKey, existing: TasteDimension?) -> String {
        let label = signal.label.trimmingCharacters(in: .whitespacesAndNewlines)
        if !label.isEmpty {
            if signal.direction.lowercased() == "negative" {
                return "Lower affinity for \(label)."
            }
            return "Consistent preference for \(label)."
        }

        if let existing {
            return existing.summary
        }
        return "Signal mapped to \(key.displayName)."
    }

    private func clamp(_ value: Double) -> Double {
        min(1.0, max(0.0, value))
    }
}

@MainActor
struct UnimplementedTasteProfileService: TasteProfileServiceProtocol {
    func updateTasteProfile(with output: TasteExtractionOutput) async throws {}
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension] { [] }
}
