import Foundation
import SwiftData

enum SeedData {
    static func seedIfNeeded(into context: ModelContext) {
        let descriptor = FetchDescriptor<AlbumRecord>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else {
            return
        }

        seedPreview(into: context)
    }

    static func seedPreview(into context: ModelContext) {
        let now = Date()

        let folklore = AlbumRecord(
            appleMusicID: "1533869057",
            title: "folklore",
            artistName: "Taylor Swift",
            releaseYear: 2020,
            genreName: "Alternative",
            artworkURL: nil,
            trackCount: 16,
            cachedAt: now
        )

        let randomAccessMemories = AlbumRecord(
            appleMusicID: "617154241",
            title: "Random Access Memories",
            artistName: "Daft Punk",
            releaseYear: 2013,
            genreName: "Electronic",
            artworkURL: nil,
            trackCount: 13,
            cachedAt: now
        )

        let blonde = AlbumRecord(
            appleMusicID: "1146195596",
            title: "Blonde",
            artistName: "Frank Ocean",
            releaseYear: 2016,
            genreName: "R&B/Soul",
            artworkURL: nil,
            trackCount: 17,
            cachedAt: now
        )

        let log1 = LogEntryRecord(
            album: folklore,
            rating: 4.8,
            reviewText: "Loved the intimate songwriting and low-key production.",
            tags: ["lyrical", "moody", "autumn"],
            loggedAt: Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now,
            updatedAt: now,
            tasteUpdateStatus: .succeeded
        )

        let log2 = LogEntryRecord(
            album: randomAccessMemories,
            rating: 4.6,
            reviewText: "Warm analog textures and infectious grooves.",
            tags: ["groovy", "detailed production"],
            loggedAt: Calendar.current.date(byAdding: .day, value: -4, to: now) ?? now,
            updatedAt: now,
            tasteUpdateStatus: .succeeded
        )

        let log3 = LogEntryRecord(
            album: blonde,
            rating: 4.9,
            reviewText: "Emotionally direct vocals with layered atmosphere.",
            tags: ["vocals", "emotional", "late-night"],
            loggedAt: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now,
            updatedAt: now,
            tasteUpdateStatus: .succeeded
        )

        let vocalFocus = TasteDimensionRecord(
            name: "vocalFocus",
            weight: 0.89,
            confidence: 0.83,
            summary: "Strong preference for emotionally expressive lead vocals.",
            updatedAt: now
        )

        let productionStyle = TasteDimensionRecord(
            name: "productionStyle",
            weight: 0.76,
            confidence: 0.79,
            summary: "Favors detailed and texture-rich production choices.",
            updatedAt: now
        )

        let evidence1 = TasteEvidenceRecord(
            tasteDimension: vocalFocus,
            logEntry: log3,
            snippet: "Emotionally direct vocals with layered atmosphere.",
            evidenceType: .reviewSnippet,
            weightContribution: 0.88,
            strength: 0.88
        )

        let evidence2 = TasteEvidenceRecord(
            tasteDimension: productionStyle,
            logEntry: log2,
            snippet: "Warm analog textures and infectious grooves.",
            evidenceType: .reviewSnippet,
            weightContribution: 0.8,
            strength: 0.8
        )

        let recommendation = RecommendationRecord(
            album: folklore,
            score: 0.82,
            confidence: 0.74,
            status: .active,
            explanationText: "You consistently favor lyric-forward albums with intimate vocals.",
            createdAt: now
        )

        let receipt = RecommendationReceiptRecord(
            recommendation: recommendation,
            logEntry: log1,
            snippet: "Loved the intimate songwriting and low-key production.",
            linkedDimension: "lyricFocus"
        )

        let feedback = RecommendationFeedbackRecord(
            recommendation: recommendation,
            feedbackType: .savedForLater,
            createdAt: now
        )

        context.insert(folklore)
        context.insert(randomAccessMemories)
        context.insert(blonde)
        context.insert(log1)
        context.insert(log2)
        context.insert(log3)
        context.insert(vocalFocus)
        context.insert(productionStyle)
        context.insert(evidence1)
        context.insert(evidence2)
        context.insert(recommendation)
        context.insert(receipt)
        context.insert(feedback)

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to seed preview data: \(error)")
        }
    }
}
