import Foundation

struct AlbumSearchResultDTO: Identifiable, Codable, Hashable, Sendable {
    let appleMusicID: String
    let title: String
    let artistName: String
    let releaseYear: Int?
    let genreName: String?
    let artworkURL: String?

    var id: String { appleMusicID }
}

struct AlbumDetailDTO: Identifiable, Codable, Hashable, Sendable {
    let appleMusicID: String
    let title: String
    let artistName: String
    let releaseYear: Int?
    let genreName: String?
    let artworkURL: String?
    let trackCount: Int?

    var id: String { appleMusicID }
}

extension AlbumSearchResultDTO {
    func asAlbum() -> Album {
        Album(
            id: UUID(),
            appleMusicID: appleMusicID,
            title: title,
            artistName: artistName,
            releaseYear: releaseYear,
            genreName: genreName,
            artworkURL: artworkURL,
            trackCount: nil,
            cachedAt: .now
        )
    }
}

extension AlbumDetailDTO {
    func asAlbum(existingID: UUID? = nil) -> Album {
        Album(
            id: existingID ?? UUID(),
            appleMusicID: appleMusicID,
            title: title,
            artistName: artistName,
            releaseYear: releaseYear,
            genreName: genreName,
            artworkURL: artworkURL,
            trackCount: trackCount,
            cachedAt: .now
        )
    }
}
