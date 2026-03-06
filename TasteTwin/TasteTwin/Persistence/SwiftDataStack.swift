import SwiftData

enum SwiftDataStack {
    static let schema = Schema([
        AlbumRecord.self,
        LogEntryRecord.self,
        TasteDimensionRecord.self,
        TasteEvidenceRecord.self,
        RecommendationRecord.self,
        RecommendationReceiptRecord.self,
        ClarifyingQuestionRecord.self,
        RecommendationFeedbackRecord.self
    ])

    static func makeModelContainer(
        inMemory: Bool,
        seed: ((ModelContext) -> Void)? = nil
    ) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            if let seed {
                seed(container.mainContext)
            }
            return container
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }
}
