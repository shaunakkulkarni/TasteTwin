import Foundation

@MainActor
protocol RecommendationRepositoryProtocol {
    func saveRecommendation(_ recommendation: Recommendation) async throws -> Recommendation
    func saveReceipt(_ receipt: RecommendationReceipt) async throws -> RecommendationReceipt
    func saveFeedback(_ feedback: RecommendationFeedback) async throws -> RecommendationFeedback
    func fetchActiveRecommendation() async throws -> Recommendation?
}

struct UnimplementedRecommendationRepository: RecommendationRepositoryProtocol {
    func saveRecommendation(_ recommendation: Recommendation) async throws -> Recommendation { recommendation }
    func saveReceipt(_ receipt: RecommendationReceipt) async throws -> RecommendationReceipt { receipt }
    func saveFeedback(_ feedback: RecommendationFeedback) async throws -> RecommendationFeedback { feedback }
    func fetchActiveRecommendation() async throws -> Recommendation? { nil }
}
