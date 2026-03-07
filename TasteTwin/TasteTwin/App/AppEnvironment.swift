import Foundation
import SwiftData
import SwiftUI

struct AppEnvironment {
    let modelContainer: ModelContainer
    let musicCatalogService: MusicCatalogServiceProtocol
    let tasteExtractionService: TasteExtractionServiceProtocol
    let tasteProfileService: TasteProfileServiceProtocol
    let tasteUpdateCoordinator: TasteUpdateCoordinating
    let albumRepository: AlbumRepositoryProtocol
    let logRepository: LogRepositoryProtocol
    let tasteRepository: TasteRepositoryProtocol
    let recommendationRepository: RecommendationRepositoryProtocol

    @MainActor
    static func live() -> AppEnvironment {
        let modelContainer = SwiftDataStack.makeModelContainer(inMemory: false, seed: SeedData.seedIfNeeded)
        let modelContext = modelContainer.mainContext
        let albumRepository = SwiftDataAlbumRepository(modelContext: modelContext)
        let logRepository = SwiftDataLogRepository(modelContext: modelContext)
        let tasteRepository = SwiftDataTasteRepository(modelContext: modelContext)
        let extractionService = AppleTasteExtractionService(client: AppleFoundationModelTasteClient())
        let tasteProfileService = TasteProfileService(tasteRepository: tasteRepository)
        let tasteUpdateCoordinator = TasteUpdateCoordinator(
            statusRepository: logRepository,
            logRepository: logRepository,
            albumRepository: albumRepository,
            extractionService: extractionService,
            tasteProfileService: tasteProfileService
        )

        return AppEnvironment(
            modelContainer: modelContainer,
            musicCatalogService: MockMusicCatalogService(),
            tasteExtractionService: extractionService,
            tasteProfileService: tasteProfileService,
            tasteUpdateCoordinator: tasteUpdateCoordinator,
            albumRepository: albumRepository,
            logRepository: logRepository,
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
        let albumRepository = SwiftDataAlbumRepository(modelContext: modelContext)
        let logRepository = SwiftDataLogRepository(modelContext: modelContext)
        let tasteRepository = SwiftDataTasteRepository(modelContext: modelContext)
        let extractionService = MockTasteExtractionService()
        let tasteProfileService = TasteProfileService(tasteRepository: tasteRepository)
        let tasteUpdateCoordinator = TasteUpdateCoordinator(
            statusRepository: logRepository,
            logRepository: logRepository,
            albumRepository: albumRepository,
            extractionService: extractionService,
            tasteProfileService: tasteProfileService
        )

        return AppEnvironment(
            modelContainer: modelContainer,
            musicCatalogService: MockMusicCatalogService(),
            tasteExtractionService: extractionService,
            tasteProfileService: tasteProfileService,
            tasteUpdateCoordinator: tasteUpdateCoordinator,
            albumRepository: albumRepository,
            logRepository: logRepository,
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
