import Foundation

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
