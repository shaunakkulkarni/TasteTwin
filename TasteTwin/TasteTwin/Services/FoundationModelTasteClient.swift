import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

protocol FoundationModelTasteClientProtocol {
    func extract(input: TasteExtractionInput) async throws -> TasteExtractionOutput
}

enum FoundationModelTasteClientError: Error, LocalizedError {
    case unavailable
    case invalidResponse
    case emptySignals

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Apple Foundation Models are unavailable on this device."
        case .invalidResponse:
            return "Unable to parse model output for taste extraction."
        case .emptySignals:
            return "Model output did not contain any valid taste signals."
        }
    }
}

final class AppleFoundationModelTasteClient: FoundationModelTasteClientProtocol {
    func extract(input: TasteExtractionInput) async throws -> TasteExtractionOutput {
#if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, *) {
            let model = SystemLanguageModel.default
            guard model.isAvailable else {
                throw FoundationModelTasteClientError.unavailable
            }

            let session = LanguageModelSession(model: model)
            let response = try await session.respond(to: prompt(for: input))
            return try parse(response.content, logEntryID: input.logEntryID)
        }
#endif
        throw FoundationModelTasteClientError.unavailable
    }

    private func prompt(for input: TasteExtractionInput) -> String {
        let review = input.reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let reviewText = review.isEmpty ? "(none)" : review
        let tags = input.tags.isEmpty ? "(none)" : input.tags.joined(separator: ", ")
        let genre = input.genreName ?? "(unknown)"
        let year = input.releaseYear.map(String.init) ?? "(unknown)"

        let dimensions = TasteDimensionKey.allCases.map(\.rawValue).joined(separator: ", ")

        return """
        You are extracting structured taste signals from a single music log.
        Only use evidence provided below. Do not invent preferences.
        Evidence snippets must be copied verbatim from reviewText or tags.
        Output strict JSON only, with no markdown fences.

        Allowed dimensions: [\(dimensions)]
        Allowed evidenceType values: [reviewSnippet, ratingSignal, tagSignal]

        Input:
        - albumTitle: \(input.albumTitle)
        - artistName: \(input.artistName)
        - genreName: \(genre)
        - releaseYear: \(year)
        - rating: \(input.rating)
        - reviewText: \(reviewText)
        - tags: \(tags)

        Return JSON with this shape:
        {
          "signals": [
            {
              "dimension": "one of allowed dimensions",
              "label": "short preference label",
              "direction": "positive",
              "confidence": 0.0,
              "evidenceSnippet": "exact text copied from review or tag",
              "evidenceType": "reviewSnippet or tagSignal or ratingSignal"
            }
          ],
          "summary": "one sentence summary"
        }
        """
    }

    private func parse(_ rawContent: String, logEntryID: UUID) throws -> TasteExtractionOutput {
        guard
            let start = rawContent.firstIndex(of: "{"),
            let end = rawContent.lastIndex(of: "}")
        else {
            throw FoundationModelTasteClientError.invalidResponse
        }

        let jsonString = String(rawContent[start...end])
        let data = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let decoded = try decoder.decode(RawExtractionResponse.self, from: data)
        let signals = decoded.signals.compactMap { rawSignal -> TasteSignalDTO? in
            guard let dimension = TasteDimensionKey(normalized: rawSignal.dimension)?.rawValue else {
                return nil
            }

            let confidence = min(1.0, max(0.0, rawSignal.confidence))
            let evidenceType = rawSignal.evidenceType.flatMap(EvidenceType.init(rawValue:)) ?? .reviewSnippet

            return TasteSignalDTO(
                dimension: dimension,
                label: rawSignal.label,
                direction: rawSignal.direction,
                confidence: confidence,
                evidenceSnippet: rawSignal.evidenceSnippet,
                evidenceType: evidenceType
            )
        }

        guard !signals.isEmpty else {
            throw FoundationModelTasteClientError.emptySignals
        }

        let summary = decoded.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        return TasteExtractionOutput(
            logEntryID: logEntryID,
            signals: signals,
            summary: summary.isEmpty ? "Taste signals extracted from this log." : summary
        )
    }
}

private struct RawExtractionResponse: Decodable {
    let signals: [RawExtractionSignal]
    let summary: String
}

private struct RawExtractionSignal: Decodable {
    let dimension: String
    let label: String
    let direction: String
    let confidence: Double
    let evidenceSnippet: String
    let evidenceType: String?
}
