import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var recentLogs: [LogDisplayItem] = []
    var totalLogCount = 0
    var overallAverageRating = 0.0
    var isLoading = false
    var errorMessage: String?

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
            async let recentLogsTask = logRepository.fetchRecentLogs(limit: Constants.homeRecentLogLimit)
            async let allLogsTask = logRepository.fetchAllLogs()
            async let albumsTask = albumRepository.fetchAllAlbums()

            let logs = try await recentLogsTask
            let allLogs = try await allLogsTask
            let albums = try await albumsTask
            let albumByID = Dictionary(uniqueKeysWithValues: albums.map { ($0.id, $0) })

            totalLogCount = allLogs.count
            overallAverageRating = allLogs.isEmpty
                ? 0
                : allLogs.map(\.rating).reduce(0, +) / Double(allLogs.count)

            recentLogs = logs.map { log in
                let album = albumByID[log.albumID]
                return LogDisplayItem(
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
            }
        } catch {
            totalLogCount = 0
            overallAverageRating = 0
            errorMessage = error.localizedDescription
        }
    }
}
