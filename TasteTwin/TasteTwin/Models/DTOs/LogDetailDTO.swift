import Foundation

struct LogDisplayItem: Identifiable, Hashable, Sendable {
    let id: UUID
    let albumID: UUID
    let appleMusicID: String
    let albumTitle: String
    let artistName: String
    let releaseYear: Int?
    let genreName: String?
    let trackCount: Int?
    let artworkURL: String?
    let rating: Double
    let reviewText: String
    let tags: [String]
    let loggedAt: Date
    let updatedAt: Date

    var reviewPreview: String {
        let trimmed = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "No review added yet." }
        if trimmed.count <= Constants.logReviewPreviewMaxLength {
            return trimmed
        }
        let index = trimmed.index(trimmed.startIndex, offsetBy: Constants.logReviewPreviewMaxLength)
        return String(trimmed[..<index]) + "..."
    }
}
