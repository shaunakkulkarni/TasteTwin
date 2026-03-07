import Foundation

enum TasteDimensionKey: String, Codable, CaseIterable, Sendable {
    case mood
    case energy
    case productionStyle
    case vocalFocus
    case lyricFocus
    case experimentation
    case instrumentalRichness
    case genreOpenness
    case eraAffinity
    case replayability

    init?(normalized rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let direct = Self(rawValue: trimmed) {
            self = direct
            return
        }

        let snakeNormalized = trimmed
            .replacingOccurrences(of: "-", with: "_")
            .lowercased()
            .split(separator: "_")
            .enumerated()
            .map { index, piece in
                let text = String(piece)
                return index == 0 ? text : text.prefix(1).uppercased() + text.dropFirst()
            }
            .joined()

        if let snakeMapped = Self(rawValue: snakeNormalized) {
            self = snakeMapped
            return
        }

        let compact = trimmed.replacingOccurrences(of: " ", with: "").lowercased()
        if let lowerMatch = Self.allCases.first(where: { $0.rawValue.lowercased() == compact }) {
            self = lowerMatch
            return
        }

        return nil
    }

    var displayName: String {
        switch self {
        case .mood:
            return "Mood"
        case .energy:
            return "Energy"
        case .productionStyle:
            return "Production Style"
        case .vocalFocus:
            return "Vocal Focus"
        case .lyricFocus:
            return "Lyric Focus"
        case .experimentation:
            return "Experimentation"
        case .instrumentalRichness:
            return "Instrumental Richness"
        case .genreOpenness:
            return "Genre Openness"
        case .eraAffinity:
            return "Era Affinity"
        case .replayability:
            return "Replayability"
        }
    }
}

enum RecommendationStatus: String, Codable, CaseIterable, Sendable {
    case active
    case dismissed
    case saved
    case accepted
}

enum RecommendationFeedbackType: String, Codable, CaseIterable, Sendable {
    case liked
    case dismissed
    case savedForLater
    case listened
}

enum EvidenceType: String, Codable, CaseIterable, Sendable {
    case reviewSnippet
    case ratingSignal
    case tagSignal
}

struct Album: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let appleMusicID: String
    let title: String
    let artistName: String
    let releaseYear: Int?
    let genreName: String?
    let artworkURL: String?
    let trackCount: Int?
    let cachedAt: Date
}

struct LogEntry: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let albumID: UUID
    let rating: Double
    let reviewText: String
    let tags: [String]
    let loggedAt: Date
    let updatedAt: Date
}

struct TasteDimension: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let name: String
    let weight: Double
    let confidence: Double
    let summary: String
    let updatedAt: Date

    var key: TasteDimensionKey? {
        TasteDimensionKey(normalized: name)
    }
}

struct TasteEvidence: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let tasteDimensionID: UUID
    let logEntryID: UUID
    let snippet: String
    let evidenceType: EvidenceType
    let strength: Double
}

struct Recommendation: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let albumID: UUID
    let score: Double
    let confidence: Double
    let status: RecommendationStatus
    let explanationText: String
    let createdAt: Date
}

struct RecommendationReceipt: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let recommendationID: UUID
    let logEntryID: UUID
    let snippet: String
    let linkedDimension: String
}

struct ClarifyingQuestion: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let recommendationID: UUID
    let questionText: String
    let questionType: String
    let answerValue: String?
    let createdAt: Date
    let answeredAt: Date?
}

struct RecommendationFeedback: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let recommendationID: UUID
    let feedbackType: RecommendationFeedbackType
    let createdAt: Date
}
