import Foundation

protocol TasteExtractionServiceProtocol {
    func extractSignals(from input: TasteExtractionInput) async throws -> TasteExtractionOutput
}

enum TasteExtractionServiceError: Error, LocalizedError {
    case forcedFailure
    case noValidSignals

    var errorDescription: String? {
        switch self {
        case .forcedFailure:
            return "Mock taste extraction failed."
        case .noValidSignals:
            return "No valid taste signals could be extracted."
        }
    }
}

final class AppleTasteExtractionService: TasteExtractionServiceProtocol {
    private let client: FoundationModelTasteClientProtocol

    init(client: FoundationModelTasteClientProtocol) {
        self.client = client
    }

    func extractSignals(from input: TasteExtractionInput) async throws -> TasteExtractionOutput {
        let output = try await client.extract(input: input)
        let sanitizedSignals = output.signals.compactMap { signal -> TasteSignalDTO? in
            guard let dimension = TasteDimensionKey(normalized: signal.dimension)?.rawValue else {
                return nil
            }

            let evidenceSnippet = normalizedEvidenceSnippet(
                rawSnippet: signal.evidenceSnippet,
                evidenceType: signal.evidenceType,
                input: input
            )

            return TasteSignalDTO(
                dimension: dimension,
                label: signal.label,
                direction: signal.direction,
                confidence: min(1.0, max(0.0, signal.confidence)),
                evidenceSnippet: evidenceSnippet,
                evidenceType: signal.evidenceType
            )
        }

        guard !sanitizedSignals.isEmpty else {
            throw TasteExtractionServiceError.noValidSignals
        }

        return TasteExtractionOutput(
            logEntryID: input.logEntryID,
            signals: sanitizedSignals,
            summary: output.summary
        )
    }

    private func normalizedEvidenceSnippet(
        rawSnippet: String,
        evidenceType: EvidenceType,
        input: TasteExtractionInput
    ) -> String {
        let trimmedSnippet = rawSnippet.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReview = input.reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let tags = input.tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        switch evidenceType {
        case .reviewSnippet:
            if !trimmedReview.isEmpty {
                if !trimmedSnippet.isEmpty,
                   trimmedReview.range(of: trimmedSnippet, options: .caseInsensitive) != nil {
                    return String(trimmedSnippet.prefix(160))
                }
                return String(trimmedReview.prefix(160))
            }
            if let firstTag = tags.first {
                return "Tag: \(firstTag)"
            }
            return ratingFallbackSnippet(for: input.rating)
        case .tagSignal:
            if let matchedTag = matchedTag(for: trimmedSnippet, tags: tags) {
                return "Tag: \(matchedTag)"
            }
            if let firstTag = tags.first {
                return "Tag: \(firstTag)"
            }
            if !trimmedReview.isEmpty {
                return String(trimmedReview.prefix(160))
            }
            return ratingFallbackSnippet(for: input.rating)
        case .ratingSignal:
            if !trimmedReview.isEmpty {
                return String(trimmedReview.prefix(160))
            }
            if let firstTag = tags.first {
                return "Tag: \(firstTag)"
            }
            return ratingFallbackSnippet(for: input.rating)
        }
    }

    private func matchedTag(for snippet: String, tags: [String]) -> String? {
        guard !snippet.isEmpty else { return nil }
        return tags.first {
            $0.range(of: snippet, options: .caseInsensitive) != nil ||
            snippet.range(of: $0, options: .caseInsensitive) != nil
        }
    }

    private func ratingFallbackSnippet(for rating: Double) -> String {
        let rounded = (rating * 10).rounded() / 10
        let valueText: String
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            valueText = String(Int(rounded))
        } else {
            valueText = String(format: "%.1f", rounded)
        }
        return "Rating: \(valueText)/5"
    }
}

struct MockTasteExtractionService: TasteExtractionServiceProtocol {
    func extractSignals(from input: TasteExtractionInput) async throws -> TasteExtractionOutput {
        try await Task.sleep(for: .milliseconds(180))

        let normalizedReview = input.reviewText.lowercased()
        let normalizedTags = input.tags.map { $0.lowercased() }

        if normalizedReview.contains("extractfail") || normalizedTags.contains("extractfail") {
            throw TasteExtractionServiceError.forcedFailure
        }

        var signals: [TasteSignalDTO] = []
        let direction = input.rating >= 3 ? "positive" : "negative"

        if containsAny(in: normalizedReview, keywords: ["production", "mix", "texture", "polish", "glossy", "analog"]) ||
            normalizedTags.contains(where: { $0.contains("production") || $0.contains("detailed") }) {
            signals.append(
                TasteSignalDTO(
                    dimension: "production_style",
                    label: "production detail",
                    direction: direction,
                    confidence: confidence(base: 0.72, rating: input.rating),
                    evidenceSnippet: bestSnippet(from: input, fallback: "Mentions production detail."),
                    evidenceType: .reviewSnippet
                )
            )
        }

        if containsAny(in: normalizedReview, keywords: ["vocal", "voice", "singing"]) ||
            normalizedTags.contains(where: { $0.contains("vocal") || $0.contains("voice") }) {
            signals.append(
                TasteSignalDTO(
                    dimension: TasteDimensionKey.vocalFocus.rawValue,
                    label: "vocal presence",
                    direction: direction,
                    confidence: confidence(base: 0.7, rating: input.rating),
                    evidenceSnippet: bestSnippet(from: input, fallback: "Highlights vocal-focused moments."),
                    evidenceType: .reviewSnippet
                )
            )
        }

        if containsAny(in: normalizedReview, keywords: ["lyric", "songwriting", "writing"]) ||
            normalizedTags.contains(where: { $0.contains("lyric") || $0.contains("writing") }) {
            signals.append(
                TasteSignalDTO(
                    dimension: TasteDimensionKey.lyricFocus.rawValue,
                    label: "lyrical depth",
                    direction: direction,
                    confidence: confidence(base: 0.68, rating: input.rating),
                    evidenceSnippet: bestSnippet(from: input, fallback: "Calls out lyrical qualities."),
                    evidenceType: .reviewSnippet
                )
            )
        }

        if containsAny(in: normalizedReview, keywords: ["energy", "intense", "hype", "drive"]) ||
            normalizedTags.contains(where: { $0.contains("energetic") || $0.contains("groovy") }) {
            signals.append(
                TasteSignalDTO(
                    dimension: TasteDimensionKey.energy.rawValue,
                    label: "energy preference",
                    direction: direction,
                    confidence: confidence(base: 0.66, rating: input.rating),
                    evidenceSnippet: bestSnippet(from: input, fallback: "Signals an energy preference."),
                    evidenceType: .tagSignal
                )
            )
        }

        if input.rating >= 4.5 || normalizedTags.contains(where: { $0.contains("replay") || $0.contains("repeat") }) {
            signals.append(
                TasteSignalDTO(
                    dimension: TasteDimensionKey.replayability.rawValue,
                    label: "replay value",
                    direction: "positive",
                    confidence: confidence(base: 0.75, rating: input.rating),
                    evidenceSnippet: bestSnippet(from: input, fallback: "Strong rating suggests replayability."),
                    evidenceType: input.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .ratingSignal : .reviewSnippet
                )
            )
        }

        if signals.isEmpty {
            signals = [
                TasteSignalDTO(
                    dimension: TasteDimensionKey.mood.rawValue,
                    label: input.rating >= 3 ? "positive mood response" : "muted mood response",
                    direction: direction,
                    confidence: confidence(base: 0.58, rating: input.rating),
                    evidenceSnippet: bestSnippet(from: input, fallback: "Rating signal from this log."),
                    evidenceType: input.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .ratingSignal : .reviewSnippet
                )
            ]
        }

        return TasteExtractionOutput(
            logEntryID: input.logEntryID,
            signals: signals,
            summary: "Extracted \(signals.count) taste signal\(signals.count == 1 ? "" : "s") from this log."
        )
    }

    private func containsAny(in text: String, keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    private func confidence(base: Double, rating: Double) -> Double {
        let ratingBoost = abs(rating - 3.0) * 0.06
        return min(0.95, max(0.45, base + ratingBoost))
    }

    private func bestSnippet(from input: TasteExtractionInput, fallback: String) -> String {
        let trimmedReview = input.reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedReview.isEmpty {
            return String(trimmedReview.prefix(160))
        }
        if let firstTag = input.tags.first {
            return "Tag: \(firstTag)"
        }
        return fallback
    }
}

final class FallbackTasteExtractionService: TasteExtractionServiceProtocol {
    private let primary: TasteExtractionServiceProtocol
    private let fallback: TasteExtractionServiceProtocol
    private let emitFallbackNotification: Bool

    init(
        primary: TasteExtractionServiceProtocol,
        fallback: TasteExtractionServiceProtocol,
        emitFallbackNotification: Bool = false
    ) {
        self.primary = primary
        self.fallback = fallback
        self.emitFallbackNotification = emitFallbackNotification
    }

    func extractSignals(from input: TasteExtractionInput) async throws -> TasteExtractionOutput {
        do {
            return try await primary.extractSignals(from: input)
        } catch {
            if error is CancellationError {
                throw error
            }

            let fallbackOutput = try await fallback.extractSignals(from: input)
            if emitFallbackNotification {
                Task { @MainActor in
                    NotificationCenter.default.post(name: .didUseMockExtractionFallback, object: nil)
                }
            }
            return fallbackOutput
        }
    }
}

struct UnimplementedTasteExtractionService: TasteExtractionServiceProtocol {
    func extractSignals(from input: TasteExtractionInput) async throws -> TasteExtractionOutput {
        TasteExtractionOutput(logEntryID: input.logEntryID, signals: [], summary: "")
    }
}
