import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    var logs: [LogDisplayItem] = []
    var isLoading = false
    var errorMessage: String?

    var totalLogs: Int {
        logs.count
    }

    var averageRating: Double {
        guard !logs.isEmpty else { return 0 }
        return logs.map(\.rating).reduce(0, +) / Double(logs.count)
    }

    var recentTags: [String] {
        Array(Set(logs.flatMap(\.tags))).sorted().prefix(8).map { $0 }
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
            let entries = try await logRepository.fetchAllLogs()
            let albums = try await albumRepository.fetchAllAlbums()
            let albumByID = Dictionary(uniqueKeysWithValues: albums.map { ($0.id, $0) })

            logs = entries.map { log in
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
