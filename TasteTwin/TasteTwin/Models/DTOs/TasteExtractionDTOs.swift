import Foundation

struct TasteExtractionInput: Sendable {
    let logEntryID: UUID
    let albumTitle: String
    let artistName: String
    let genreName: String?
    let releaseYear: Int?
    let rating: Double
    let reviewText: String
    let tags: [String]
}

struct TasteSignalDTO: Codable, Hashable, Sendable {
    let dimension: String
    let label: String
    let direction: String
    let confidence: Double
    let evidenceSnippet: String
    let evidenceType: EvidenceType
}

struct TasteExtractionOutput: Sendable {
    let logEntryID: UUID
    let signals: [TasteSignalDTO]
    let summary: String
}
