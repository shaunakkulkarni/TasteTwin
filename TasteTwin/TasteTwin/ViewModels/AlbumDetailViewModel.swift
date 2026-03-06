import Foundation
import Observation

@MainActor
@Observable
final class AlbumDetailViewModel {
    var album: Album?
    var isLoading = false
    var errorMessage: String?
    var existingLogID: UUID?

    private(set) var initialResult: AlbumSearchResultDTO
    private var musicCatalogService: MusicCatalogServiceProtocol
    private var albumRepository: AlbumRepositoryProtocol
    private var logRepository: LogRepositoryProtocol

    init(
        initialResult: AlbumSearchResultDTO,
        musicCatalogService: MusicCatalogServiceProtocol,
        albumRepository: AlbumRepositoryProtocol,
        logRepository: LogRepositoryProtocol
    ) {
        self.initialResult = initialResult
        self.musicCatalogService = musicCatalogService
        self.albumRepository = albumRepository
        self.logRepository = logRepository
    }

    func configure(
        musicCatalogService: MusicCatalogServiceProtocol,
        albumRepository: AlbumRepositoryProtocol,
        logRepository: LogRepositoryProtocol
    ) {
        self.musicCatalogService = musicCatalogService
        self.albumRepository = albumRepository
        self.logRepository = logRepository
    }

    func loadIfNeeded() async {
        guard album == nil, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let cached = try await albumRepository.fetchAlbum(byAppleMusicID: initialResult.appleMusicID)
            if let cached {
                album = cached
            } else {
                let seeded = try await albumRepository.upsertAlbum(initialResult.asAlbum())
                album = seeded
            }

            do {
                let detail = try await musicCatalogService.fetchAlbumDetails(appleMusicID: initialResult.appleMusicID)
                let updated = try await albumRepository.upsertAlbum(detail.asAlbum(existingID: album?.id))
                album = updated
            } catch {
                // Continue with cached/seeded snapshot.
            }

            if let album {
                existingLogID = try await logRepository.fetchLog(forAlbumID: album.id)?.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
