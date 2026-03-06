import Foundation

protocol MusicCatalogServiceProtocol {
    func searchAlbums(query: String) async throws -> [AlbumSearchResultDTO]
    func fetchAlbumDetails(appleMusicID: String) async throws -> AlbumDetailDTO
}

enum MusicCatalogServiceError: Error, LocalizedError {
    case notFound
    case mockFailure

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Album details were not found."
        case .mockFailure:
            return "Mock catalog failed to load."
        }
    }
}

struct MockMusicCatalogService: MusicCatalogServiceProtocol {
    private let albums: [AlbumDetailDTO] = [
        AlbumDetailDTO(appleMusicID: "1533869057", title: "folklore", artistName: "Taylor Swift", releaseYear: 2020, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/11/5f/24/115f2438-8d0a-33cc-18f0-471ef90cf8f5/20UMGIM64299.rgb.jpg/600x600bb.jpg", trackCount: 16),
        AlbumDetailDTO(appleMusicID: "617154241", title: "Random Access Memories", artistName: "Daft Punk", releaseYear: 2013, genreName: "Electronic", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/9f/0a/96/9f0a968f-580b-548f-c7df-f9e2f7bcfd54/886443919266.jpg/600x600bb.jpg", trackCount: 13),
        AlbumDetailDTO(appleMusicID: "1146195596", title: "Blonde", artistName: "Frank Ocean", releaseYear: 2016, genreName: "R&B/Soul", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/27/2f/03/272f0300-f46a-6e85-02a4-e2b7ff5fdf9d/886446522276.jpg/600x600bb.jpg", trackCount: 17),
        AlbumDetailDTO(appleMusicID: "1649439304", title: "SOS", artistName: "SZA", releaseYear: 2022, genreName: "R&B/Soul", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/df/4f/2f/df4f2f74-2165-2ee6-ee67-aa726f6e4936/196589872936.jpg/600x600bb.jpg", trackCount: 23),
        AlbumDetailDTO(appleMusicID: "1613297650", title: "Mr. Morale & The Big Steppers", artistName: "Kendrick Lamar", releaseYear: 2022, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/95/cc/ca/95cccac7-963f-0c76-5cd8-2e589f10f30f/22UMGIM50062.rgb.jpg/600x600bb.jpg", trackCount: 18),
        AlbumDetailDTO(appleMusicID: "1065681363", title: "ANTI", artistName: "Rihanna", releaseYear: 2016, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/89/1d/3c/891d3c42-2fa7-0833-6f1f-4f370f1c8f95/16UMGIM05106.rgb.jpg/600x600bb.jpg", trackCount: 13),
        AlbumDetailDTO(appleMusicID: "1440935467", title: "Currents", artistName: "Tame Impala", releaseYear: 2015, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/d9/12/f7/d912f76c-3e54-cf77-1835-d5779cf0f6a7/00602547252765.rgb.jpg/600x600bb.jpg", trackCount: 13),
        AlbumDetailDTO(appleMusicID: "1589403688", title: "30", artistName: "Adele", releaseYear: 2021, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/5e/21/a1/5e21a1bb-0daa-c250-c95b-b3514bf3f1e8/886449666474.jpg/600x600bb.jpg", trackCount: 12)
    ]

    func searchAlbums(query: String) async throws -> [AlbumSearchResultDTO] {
        try await Task.sleep(for: .milliseconds(300))

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        if trimmed.localizedCaseInsensitiveContains("error") {
            throw MusicCatalogServiceError.mockFailure
        }

        return albums
            .filter {
                $0.title.localizedCaseInsensitiveContains(trimmed) ||
                $0.artistName.localizedCaseInsensitiveContains(trimmed)
            }
            .map {
                AlbumSearchResultDTO(
                    appleMusicID: $0.appleMusicID,
                    title: $0.title,
                    artistName: $0.artistName,
                    releaseYear: $0.releaseYear,
                    genreName: $0.genreName,
                    artworkURL: $0.artworkURL
                )
            }
    }

    func fetchAlbumDetails(appleMusicID: String) async throws -> AlbumDetailDTO {
        try await Task.sleep(for: .milliseconds(250))

        guard let match = albums.first(where: { $0.appleMusicID == appleMusicID }) else {
            throw MusicCatalogServiceError.notFound
        }
        return match
    }
}
