import Foundation
import SwiftData
import SwiftUI

struct AppEnvironment {
    let modelContainer: ModelContainer
    let musicCatalogService: MusicCatalogServiceProtocol
    let tasteExtractionService: TasteExtractionServiceProtocol
    let tasteProfileService: TasteProfileServiceProtocol
    let albumRepository: AlbumRepositoryProtocol
    let logRepository: LogRepositoryProtocol
    let tasteRepository: TasteRepositoryProtocol
    let recommendationRepository: RecommendationRepositoryProtocol

    @MainActor
    static func live() -> AppEnvironment {
        let modelContainer = SwiftDataStack.makeModelContainer(inMemory: false, seed: SeedData.seedIfNeeded)
        let modelContext = modelContainer.mainContext
        let tasteRepository = SwiftDataTasteRepository(modelContext: modelContext)

        return AppEnvironment(
            modelContainer: modelContainer,
            musicCatalogService: MockMusicCatalogService(),
            tasteExtractionService: MockTasteExtractionService(),
            tasteProfileService: TasteProfileService(tasteRepository: tasteRepository),
            albumRepository: SwiftDataAlbumRepository(modelContext: modelContext),
            logRepository: SwiftDataLogRepository(modelContext: modelContext),
            tasteRepository: tasteRepository,
            recommendationRepository: UnimplementedRecommendationRepository()
        )
    }

    @MainActor
    static func preview() -> AppEnvironment {
        let modelContainer = SwiftDataStack.makeModelContainer(inMemory: true) { context in
            SeedData.seedPreview(into: context)
        }
        let modelContext = modelContainer.mainContext
        let tasteRepository = SwiftDataTasteRepository(modelContext: modelContext)

        return AppEnvironment(
            modelContainer: modelContainer,
            musicCatalogService: MockMusicCatalogService(),
            tasteExtractionService: MockTasteExtractionService(),
            tasteProfileService: TasteProfileService(tasteRepository: tasteRepository),
            albumRepository: SwiftDataAlbumRepository(modelContext: modelContext),
            logRepository: SwiftDataLogRepository(modelContext: modelContext),
            tasteRepository: tasteRepository,
            recommendationRepository: UnimplementedRecommendationRepository()
        )
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment.preview()
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
