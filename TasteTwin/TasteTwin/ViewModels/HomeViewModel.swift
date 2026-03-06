import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var recentLogs: [LogDisplayItem] = []
    var isLoading = false
    var errorMessage: String?

    var totalLogs: Int {
        recentLogs.count
    }

    var averageRating: Double {
        guard !recentLogs.isEmpty else { return 0 }
        return recentLogs.map(\.rating).reduce(0, +) / Double(recentLogs.count)
    }

    private var logRepository: LogRepositoryProtocol
    private var albumRepository: AlbumRepositoryProtocol

    init(logRepository: LogRepositoryProtocol, albumRepository: AlbumRepositoryProtocol) {
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
            let logs = try await logRepository.fetchRecentLogs(limit: Constants.homeRecentLogLimit)
            let albums = try await albumRepository.fetchAllAlbums()
            let albumByID = Dictionary(uniqueKeysWithValues: albums.map { ($0.id, $0) })

            recentLogs = logs.map { log in
                let album = albumByID[log.albumID]
                return LogDisplayItem(
                    id: log.id,
                    albumID: log.albumID,
                    appleMusicID: album?.appleMusicID ?? "",
                    albumTitle: album?.title ?? "Unknown Album",
                    artistName: album?.artistName ?? "Unknown Artist",
                    artworkURL: album?.artworkURL,
                    rating: log.rating,
                    reviewText: log.reviewText,
                    tags: log.tags,
                    loggedAt: log.loggedAt,
                    updatedAt: log.updatedAt
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
