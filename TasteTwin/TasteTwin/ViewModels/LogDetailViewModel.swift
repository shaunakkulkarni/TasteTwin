import Foundation
import Observation

@MainActor
@Observable
final class LogDetailViewModel {
    let logID: UUID

    var item: LogDisplayItem?
    var isLoading = false
    var errorMessage: String?
    var isDeleting = false

    private var logRepository: LogRepositoryProtocol
    private var albumRepository: AlbumRepositoryProtocol

    init(logID: UUID, logRepository: LogRepositoryProtocol, albumRepository: AlbumRepositoryProtocol) {
        self.logID = logID
        self.logRepository = logRepository
        self.albumRepository = albumRepository
    }

    func configure(logRepository: LogRepositoryProtocol, albumRepository: AlbumRepositoryProtocol) {
        self.logRepository = logRepository
        self.albumRepository = albumRepository
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let log = try await logRepository.fetchLog(byID: logID) else {
                errorMessage = "This log no longer exists."
                item = nil
                return
            }

            let album = try await albumRepository.fetchAlbum(byID: log.albumID)
            item = LogDisplayItem(
                id: log.id,
                albumID: log.albumID,
                appleMusicID: album?.appleMusicID ?? "",
                albumTitle: album?.title ?? "Unknown Album",
                artistName: album?.artistName ?? "Unknown Artist",
                releaseYear: album?.releaseYear,
                genreName: album?.genreName,
                trackCount: album?.trackCount,
                artworkURL: album?.artworkURL,
                rating: log.rating,
                reviewText: log.reviewText,
                tags: log.tags,
                loggedAt: log.loggedAt,
                updatedAt: log.updatedAt
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLog() async -> Bool {
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await logRepository.deleteLog(id: logID)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
