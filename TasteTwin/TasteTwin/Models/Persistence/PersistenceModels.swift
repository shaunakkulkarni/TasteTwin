import Foundation
import SwiftData

@Model
final class AlbumRecord {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var appleMusicID: String
    var title: String
    var artistName: String
    var releaseYear: Int?
    var genreName: String?
    var artworkURL: String?
    var trackCount: Int?
    var cachedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \LogEntryRecord.album)
    var logs: [LogEntryRecord]

    init(
        id: UUID = UUID(),
        appleMusicID: String,
        title: String,
        artistName: String,
        releaseYear: Int? = nil,
        genreName: String? = nil,
        artworkURL: String? = nil,
        trackCount: Int? = nil,
        cachedAt: Date = .now,
        logs: [LogEntryRecord] = []
    ) {
        self.id = id
        self.appleMusicID = appleMusicID
        self.title = title
        self.artistName = artistName
        self.releaseYear = releaseYear
        self.genreName = genreName
        self.artworkURL = artworkURL
        self.trackCount = trackCount
        self.cachedAt = cachedAt
        self.logs = logs
    }
}

@Model
final class LogEntryRecord {
    @Attribute(.unique) var id: UUID
    var rating: Double
    var reviewText: String
    var tags: [String]
    var loggedAt: Date
    var updatedAt: Date

    var album: AlbumRecord?

    @Relationship(deleteRule: .cascade, inverse: \TasteEvidenceRecord.logEntry)
    var tasteEvidence: [TasteEvidenceRecord]

    @Relationship(deleteRule: .cascade, inverse: \RecommendationReceiptRecord.logEntry)
    var recommendationReceipts: [RecommendationReceiptRecord]

    init(
        id: UUID = UUID(),
        album: AlbumRecord? = nil,
        rating: Double,
        reviewText: String,
        tags: [String],
        loggedAt: Date = .now,
        updatedAt: Date = .now,
        tasteEvidence: [TasteEvidenceRecord] = [],
        recommendationReceipts: [RecommendationReceiptRecord] = []
    ) {
        self.id = id
        self.album = album
        self.rating = rating
        self.reviewText = reviewText
        self.tags = tags
        self.loggedAt = loggedAt
        self.updatedAt = updatedAt
        self.tasteEvidence = tasteEvidence
        self.recommendationReceipts = recommendationReceipts
    }
}

@Model
final class TasteDimensionRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var weight: Double
    var confidence: Double
    var summary: String
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TasteEvidenceRecord.tasteDimension)
    var evidenceItems: [TasteEvidenceRecord]

    init(
        id: UUID = UUID(),
        name: String,
        weight: Double,
        confidence: Double,
        summary: String,
        updatedAt: Date = .now,
        evidenceItems: [TasteEvidenceRecord] = []
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.confidence = confidence
        self.summary = summary
        self.updatedAt = updatedAt
        self.evidenceItems = evidenceItems
    }
}

@Model
final class TasteEvidenceRecord {
    @Attribute(.unique) var id: UUID
    var snippet: String
    var evidenceTypeRaw: String
    var strength: Double

    var tasteDimension: TasteDimensionRecord?
    var logEntry: LogEntryRecord?

    init(
        id: UUID = UUID(),
        tasteDimension: TasteDimensionRecord? = nil,
        logEntry: LogEntryRecord? = nil,
        snippet: String,
        evidenceType: EvidenceType,
        strength: Double
    ) {
        self.id = id
        self.tasteDimension = tasteDimension
        self.logEntry = logEntry
        self.snippet = snippet
        self.evidenceTypeRaw = evidenceType.rawValue
        self.strength = strength
    }

    var evidenceType: EvidenceType {
        get { EvidenceType(rawValue: evidenceTypeRaw) ?? .reviewSnippet }
        set { evidenceTypeRaw = newValue.rawValue }
    }
}

@Model
final class RecommendationRecord {
    @Attribute(.unique) var id: UUID
    var score: Double
    var confidence: Double
    var statusRaw: String
    var explanationText: String
    var createdAt: Date

    var album: AlbumRecord?

    @Relationship(deleteRule: .cascade, inverse: \RecommendationReceiptRecord.recommendation)
    var receipts: [RecommendationReceiptRecord]

    @Relationship(deleteRule: .cascade, inverse: \RecommendationFeedbackRecord.recommendation)
    var feedbackItems: [RecommendationFeedbackRecord]

    @Relationship(deleteRule: .cascade, inverse: \ClarifyingQuestionRecord.recommendation)
    var clarifyingQuestion: ClarifyingQuestionRecord?

    init(
        id: UUID = UUID(),
        album: AlbumRecord? = nil,
        score: Double,
        confidence: Double,
        status: RecommendationStatus,
        explanationText: String,
        createdAt: Date = .now,
        receipts: [RecommendationReceiptRecord] = [],
        feedbackItems: [RecommendationFeedbackRecord] = [],
        clarifyingQuestion: ClarifyingQuestionRecord? = nil
    ) {
        self.id = id
        self.album = album
        self.score = score
        self.confidence = confidence
        self.statusRaw = status.rawValue
        self.explanationText = explanationText
        self.createdAt = createdAt
        self.receipts = receipts
        self.feedbackItems = feedbackItems
        self.clarifyingQuestion = clarifyingQuestion
    }

    var status: RecommendationStatus {
        get { RecommendationStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }
}

@Model
final class RecommendationReceiptRecord {
    @Attribute(.unique) var id: UUID
    var snippet: String
    var linkedDimension: String

    var recommendation: RecommendationRecord?
    var logEntry: LogEntryRecord?

    init(
        id: UUID = UUID(),
        recommendation: RecommendationRecord? = nil,
        logEntry: LogEntryRecord? = nil,
        snippet: String,
        linkedDimension: String
    ) {
        self.id = id
        self.recommendation = recommendation
        self.logEntry = logEntry
        self.snippet = snippet
        self.linkedDimension = linkedDimension
    }
}

@Model
final class ClarifyingQuestionRecord {
    @Attribute(.unique) var id: UUID
    var questionText: String
    var questionType: String
    var answerValue: String?
    var createdAt: Date
    var answeredAt: Date?

    var recommendation: RecommendationRecord?

    init(
        id: UUID = UUID(),
        recommendation: RecommendationRecord? = nil,
        questionText: String,
        questionType: String,
        answerValue: String? = nil,
        createdAt: Date = .now,
        answeredAt: Date? = nil
    ) {
        self.id = id
        self.recommendation = recommendation
        self.questionText = questionText
        self.questionType = questionType
        self.answerValue = answerValue
        self.createdAt = createdAt
        self.answeredAt = answeredAt
    }
}

@Model
final class RecommendationFeedbackRecord {
    @Attribute(.unique) var id: UUID
    var feedbackTypeRaw: String
    var createdAt: Date

    var recommendation: RecommendationRecord?

    init(
        id: UUID = UUID(),
        recommendation: RecommendationRecord? = nil,
        feedbackType: RecommendationFeedbackType,
        createdAt: Date = .now
    ) {
        self.id = id
        self.recommendation = recommendation
        self.feedbackTypeRaw = feedbackType.rawValue
        self.createdAt = createdAt
    }

    var feedbackType: RecommendationFeedbackType {
        get { RecommendationFeedbackType(rawValue: feedbackTypeRaw) ?? .liked }
        set { feedbackTypeRaw = newValue.rawValue }
    }
}
