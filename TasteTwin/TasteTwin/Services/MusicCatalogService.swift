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
        AlbumDetailDTO(appleMusicID: "1589403688", title: "30", artistName: "Adele", releaseYear: 2021, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/5e/21/a1/5e21a1bb-0daa-c250-c95b-b3514bf3f1e8/886449666474.jpg/600x600bb.jpg", trackCount: 12),
        AlbumDetailDTO(appleMusicID: "1440891047", title: "DAMN.", artistName: "Kendrick Lamar", releaseYear: 2017, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/24/6c/4b/246c4bc9-6f57-5f73-cdbf-8f20b65d2ccf/17UMGIM99631.rgb.jpg/600x600bb.jpg", trackCount: 14),
        AlbumDetailDTO(appleMusicID: "1440828886", title: "To Pimp a Butterfly", artistName: "Kendrick Lamar", releaseYear: 2015, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/73/4d/d0/734dd00b-c15e-13f2-b21b-25afdff0a58d/15UMGIM11922.rgb.jpg/600x600bb.jpg", trackCount: 16),
        AlbumDetailDTO(appleMusicID: "1440842861", title: "Lemonade", artistName: "Beyonce", releaseYear: 2016, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/65/50/b2/6550b265-1f52-8d04-c267-accf6f430f99/886445875496.jpg/600x600bb.jpg", trackCount: 12),
        AlbumDetailDTO(appleMusicID: "1630005298", title: "RENAISSANCE", artistName: "Beyonce", releaseYear: 2022, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/4d/86/8b/4d868b3b-c1d7-b21d-a1cc-76c3c6f8fcf0/196587445071.jpg/600x600bb.jpg", trackCount: 16),
        AlbumDetailDTO(appleMusicID: "1573252620", title: "SOUR", artistName: "Olivia Rodrigo", releaseYear: 2021, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/96/dc/59/96dc59f7-749f-bf1a-9a53-6530df527969/21UMGIM26092.rgb.jpg/600x600bb.jpg", trackCount: 11),
        AlbumDetailDTO(appleMusicID: "1708881218", title: "GUTS", artistName: "Olivia Rodrigo", releaseYear: 2023, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/4c/0d/29/4c0d29a4-2d8e-0f9b-5766-1dfe6d16f6d4/23UMGIM84588.rgb.jpg/600x600bb.jpg", trackCount: 12),
        AlbumDetailDTO(appleMusicID: "1440892663", title: "Ctrl", artistName: "SZA", releaseYear: 2017, genreName: "R&B/Soul", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/1d/a2/76/1da2761b-37da-7d7f-c532-d6bf89ca7a8f/886446518897.jpg/600x600bb.jpg", trackCount: 14),
        AlbumDetailDTO(appleMusicID: "1440898340", title: "Melodrama", artistName: "Lorde", releaseYear: 2017, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/4b/d1/9b/4bd19b33-f89e-5715-976a-4cf9d7f13b1d/17UMGIM01813.rgb.jpg/600x600bb.jpg", trackCount: 11),
        AlbumDetailDTO(appleMusicID: "1160243552", title: "A Seat at the Table", artistName: "Solange", releaseYear: 2016, genreName: "R&B/Soul", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/e3/3c/c2/e33cc272-e062-f0b8-a9af-4bf3f1596f72/886446200495.jpg/600x600bb.jpg", trackCount: 21),
        AlbumDetailDTO(appleMusicID: "1474669063", title: "NORMAN F***ING ROCKWELL!", artistName: "Lana Del Rey", releaseYear: 2019, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music123/v4/03/37/2f/03372f8a-4224-0f11-e6ed-f9ba180a3947/19UM1IM26095.rgb.jpg/600x600bb.jpg", trackCount: 14),
        AlbumDetailDTO(appleMusicID: "1440760117", title: "Channel ORANGE", artistName: "Frank Ocean", releaseYear: 2012, genreName: "R&B/Soul", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/92/a7/f8/92a7f8d0-ee5b-9c67-a89e-b4f3db7ea4a3/886443729445.jpg/600x600bb.jpg", trackCount: 17),
        AlbumDetailDTO(appleMusicID: "1463409338", title: "IGOR", artistName: "Tyler, The Creator", releaseYear: 2019, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/e4/ff/58/e4ff58ce-f23c-95a8-af71-f9e197c29317/190295430878.jpg/600x600bb.jpg", trackCount: 12),
        AlbumDetailDTO(appleMusicID: "1575736678", title: "CALL ME IF YOU GET LOST", artistName: "Tyler, The Creator", releaseYear: 2021, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/cd/80/96/cd80964f-b2f2-b9d6-46d6-7d733f72d76f/194398792316.jpg/600x600bb.jpg", trackCount: 16),
        AlbumDetailDTO(appleMusicID: "1649434892", title: "Midnights", artistName: "Taylor Swift", releaseYear: 2022, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/74/57/f2/7457f259-9b67-f248-97cc-8de102668911/22UM1IM10326.rgb.jpg/600x600bb.jpg", trackCount: 13),
        AlbumDetailDTO(appleMusicID: "1440878138", title: "Invasion of Privacy", artistName: "Cardi B", releaseYear: 2018, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music128/v4/a8/fb/3f/a8fb3fb4-e850-33ed-faf9-c6ff1571318c/075679891739.jpg/600x600bb.jpg", trackCount: 13),
        AlbumDetailDTO(appleMusicID: "1450695723", title: "WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?", artistName: "Billie Eilish", releaseYear: 2019, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/ca/b2/60/cab26057-5fef-b7df-fc57-4b34f38fca9d/19UMGIM14771.rgb.jpg/600x600bb.jpg", trackCount: 14),
        AlbumDetailDTO(appleMusicID: "1450330588", title: "thank u, next", artistName: "Ariana Grande", releaseYear: 2019, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/59/07/30/590730d2-eb83-90b8-878d-bf1145fd91f1/18UMGIM91915.rgb.jpg/600x600bb.jpg", trackCount: 12),
        AlbumDetailDTO(appleMusicID: "1495799403", title: "Future Nostalgia", artistName: "Dua Lipa", releaseYear: 2020, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/e2/36/c7/e236c70c-f2cc-b4d5-8826-c7adc3996bd6/190295132055.jpg/600x600bb.jpg", trackCount: 11),
        AlbumDetailDTO(appleMusicID: "1161583970", title: "24K Magic", artistName: "Bruno Mars", releaseYear: 2016, genreName: "Pop", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/2d/e3/b2/2de3b24f-c316-8d4a-b495-58f626f7abec/075679901933.jpg/600x600bb.jpg", trackCount: 9),
        AlbumDetailDTO(appleMusicID: "1499378108", title: "After Hours", artistName: "The Weeknd", releaseYear: 2020, genreName: "R&B/Soul", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/72/d5/ab/72d5aba1-5d34-fb8b-f988-c8be7ac7955f/20UMGIM17539.rgb.jpg/600x600bb.jpg", trackCount: 14),
        AlbumDetailDTO(appleMusicID: "1530000001", title: "Punisher", artistName: "Phoebe Bridgers", releaseYear: 2020, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/63/14/2f/63142f54-6783-735d-89c8-f53c8305f6f9/191400010058.png/600x600bb.jpg", trackCount: 11),
        AlbumDetailDTO(appleMusicID: "1530000002", title: "Titanic Rising", artistName: "Weyes Blood", releaseYear: 2019, genreName: "Alternative", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/79/9e/25/799e25dd-c6a3-e0b0-ac47-89ed3a4af9ad/098787131043.png/600x600bb.jpg", trackCount: 10),
        AlbumDetailDTO(appleMusicID: "1530000003", title: "Flower Boy", artistName: "Tyler, The Creator", releaseYear: 2017, genreName: "Hip-Hop/Rap", artworkURL: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/98/e2/7b/98e27bca-2a8b-f358-f77a-4e4fa4ea5a8a/889854690467.png/600x600bb.jpg", trackCount: 14)
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
