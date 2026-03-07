import Foundation
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
#if DEBUG
            if !inMemory {
                resetPersistentStoreArtifacts()
                do {
                    let container = try ModelContainer(for: schema, configurations: [configuration])
                    if let seed {
                        seed(container.mainContext)
                    }
                    return container
                } catch {
                    fatalError("Unable to recreate model container after store reset: \(error)")
                }
            }
#endif
            fatalError("Unable to create model container: \(error)")
        }
    }

    private static func resetPersistentStoreArtifacts() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }

        if let contents = try? fileManager.contentsOfDirectory(at: appSupportURL, includingPropertiesForKeys: nil) {
            for url in contents where isLikelySwiftDataArtifact(url.lastPathComponent) {
                try? fileManager.removeItem(at: url)
            }
        }
    }

    private static func isLikelySwiftDataArtifact(_ fileName: String) -> Bool {
        let lowercased = fileName.lowercased()
        if lowercased.contains("default.store") || lowercased.contains("tastetwin.store") {
            return true
        }
        return lowercased.hasSuffix(".store")
            || lowercased.hasSuffix(".sqlite")
            || lowercased.hasSuffix(".sqlite-shm")
            || lowercased.hasSuffix(".sqlite-wal")
            || lowercased.hasSuffix(".store-shm")
            || lowercased.hasSuffix(".store-wal")
    }
}
