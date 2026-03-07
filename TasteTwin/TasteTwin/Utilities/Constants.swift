import Foundation

enum Constants {
    static let maxTagCount = 5
    static let minSearchQueryLength = 2
    static let searchDebounceMilliseconds = 350
    static let maxSearchResults = 30

    static let homeRecentLogLimit = 10
    static let logReviewPreviewMaxLength = 140

    static let tasteTwinMaxDimensionCount = 10
    static let tasteTwinLowConfidenceThreshold = 0.35
    static let tasteTwinMaxEvidencePerDimension = 6
    static let tasteUpdateRetryBatchSize = 12
    static let tasteUpdateMaxAutomaticAttempts = 3
    static let tasteTwinProgressPollMilliseconds = 300
    static let tasteTwinProgressMinVisibleSeconds = 1.0
    static let tasteTwinFallbackPillVisibleSeconds = 2.0
    static let tasteTwinRecentSaveSignalWindowSeconds = 20.0
    static let lastLogSaveTimestampDefaultsKey = "lastLogSaveTimestamp"
}
