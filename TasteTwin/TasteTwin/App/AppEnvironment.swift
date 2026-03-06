import Foundation
import SwiftData
import SwiftUI

struct AppEnvironment {
    let modelContainer: ModelContainer
    let albumRepository: AlbumRepositoryProtocol
    let logRepository: LogRepositoryProtocol
    let tasteRepository: TasteRepositoryProtocol
    let recommendationRepository: RecommendationRepositoryProtocol

    @MainActor
    static func live() -> AppEnvironment {
        let modelContainer = SwiftDataStack.makeModelContainer(inMemory: false, seed: SeedData.seedIfNeeded)
        return AppEnvironment(
            modelContainer: modelContainer,
            albumRepository: UnimplementedAlbumRepository(),
            logRepository: UnimplementedLogRepository(),
            tasteRepository: UnimplementedTasteRepository(),
            recommendationRepository: UnimplementedRecommendationRepository()
        )
    }

    @MainActor
    static func preview() -> AppEnvironment {
        let modelContainer = SwiftDataStack.makeModelContainer(inMemory: true) { context in
            SeedData.seedPreview(into: context)
        }
        return AppEnvironment(
            modelContainer: modelContainer,
            albumRepository: UnimplementedAlbumRepository(),
            logRepository: UnimplementedLogRepository(),
            tasteRepository: UnimplementedTasteRepository(),
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
