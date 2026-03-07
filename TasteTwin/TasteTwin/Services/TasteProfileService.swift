import Foundation

@MainActor
protocol TasteProfileServiceProtocol {
    func updateTasteProfile(with output: TasteExtractionOutput) async throws
    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension]
}

enum TasteProfileServiceError: Error, LocalizedError {
    case noValidSignals

    var errorDescription: String? {
        switch self {
        case .noValidSignals:
            return "No valid taste signals were available to persist."
        }
    }
}

@MainActor
final class TasteProfileService: TasteProfileServiceProtocol {
    private let tasteRepository: TasteRepositoryProtocol

    init(tasteRepository: TasteRepositoryProtocol) {
        self.tasteRepository = tasteRepository
    }

    func updateTasteProfile(with output: TasteExtractionOutput) async throws {
        let sanitizedSignals = sanitizeSignals(output.signals)
        guard !sanitizedSignals.isEmpty else {
            throw TasteProfileServiceError.noValidSignals
        }

        var affectedDimensionIDs = Set(try await tasteRepository.fetchDimensionIDs(forLogEntryID: output.logEntryID))
        try await tasteRepository.deleteEvidence(forLogEntryID: output.logEntryID)

        for signal in sanitizedSignals {
            guard let key = TasteDimensionKey(normalized: signal.dimension) else {
                continue
            }

            let canonicalName = key.rawValue
            let existing = try await tasteRepository.fetchDimension(named: canonicalName)
            let incomingWeight = signal.direction.lowercased() == "negative"
                ? clamp(1.0 - signal.confidence)
                : clamp(signal.confidence)
            let incomingConfidence = clamp(signal.confidence)

            let dimension = TasteDimension(
                id: existing?.id ?? UUID(),
                name: canonicalName,
                weight: incomingWeight,
                confidence: incomingConfidence,
                summary: summary(for: signal, key: key, existing: existing),
                updatedAt: .now
            )

            let persistedDimension = try await tasteRepository.upsertDimension(dimension)
            affectedDimensionIDs.insert(persistedDimension.id)

            let evidence = TasteEvidence(
                id: UUID(),
                tasteDimensionID: persistedDimension.id,
                logEntryID: output.logEntryID,
                snippet: signal.evidenceSnippet,
                evidenceType: signal.evidenceType,
                weightContribution: incomingWeight,
                strength: incomingConfidence
            )
            _ = try await tasteRepository.saveEvidence(evidence)
        }

        for dimensionID in affectedDimensionIDs {
            _ = try await tasteRepository.recomputeDimensionAggregate(dimensionID: dimensionID)
        }
    }

    func fetchTopDimensions(limit: Int) async throws -> [TasteDimension] {
        try await tasteRepository.fetchTopDimensions(limit: limit)
    }

    private func sanitizeSignals(_ signals: [TasteSignalDTO]) -> [TasteSignalDTO] {
        var seen = Set<String>()
        var deduped: [TasteSignalDTO] = []

        for signal in signals {
            guard
                let key = TasteDimensionKey(normalized: signal.dimension)?.rawValue,
                !signal.evidenceSnippet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                continue
            }

            let evidenceSnippet = signal.evidenceSnippet.trimmingCharacters(in: .whitespacesAndNewlines)
            let dedupeKey = "\(key.lowercased())|\(evidenceSnippet.lowercased())"
            guard seen.insert(dedupeKey).inserted else {
                continue
            }

            deduped.append(
                TasteSignalDTO(
                    dimension: key,
                    label: signal.label,
                    direction: signal.direction,
                    confidence: clamp(signal.confidence),
                    evidenceSnippet: evidenceSnippet,
                    evidenceType: signal.evidenceType
                )
            )
        }

        return deduped
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
