import Foundation
import SwiftData

@MainActor
final class SwiftDataAlbumRepository: AlbumRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func upsertAlbum(_ album: Album) async throws -> Album {
        let descriptor = FetchDescriptor<AlbumRecord>(predicate: #Predicate { $0.appleMusicID == album.appleMusicID })
        if let record = try modelContext.fetch(descriptor).first {
            record.title = album.title
            record.artistName = album.artistName
            record.releaseYear = album.releaseYear
            record.genreName = album.genreName
            record.artworkURL = album.artworkURL
            record.trackCount = album.trackCount
            record.cachedAt = .now

            try modelContext.save()
            return record.asDomain()
        }

        let newRecord = AlbumRecord(
            id: album.id,
            appleMusicID: album.appleMusicID,
            title: album.title,
            artistName: album.artistName,
            releaseYear: album.releaseYear,
            genreName: album.genreName,
            artworkURL: album.artworkURL,
            trackCount: album.trackCount,
            cachedAt: .now
        )
        modelContext.insert(newRecord)
        try modelContext.save()
        return newRecord.asDomain()
    }

    func fetchAlbum(byAppleMusicID id: String) async throws -> Album? {
        let descriptor = FetchDescriptor<AlbumRecord>(predicate: #Predicate { $0.appleMusicID == id })
        return try modelContext.fetch(descriptor).first?.asDomain()
    }

    func fetchAlbum(byID id: UUID) async throws -> Album? {
        let descriptor = FetchDescriptor<AlbumRecord>(predicate: #Predicate { $0.id == id })
        return try modelContext.fetch(descriptor).first?.asDomain()
    }

    func fetchAllAlbums() async throws -> [Album] {
        let descriptor = FetchDescriptor<AlbumRecord>(sortBy: [SortDescriptor(\AlbumRecord.cachedAt, order: .reverse)])
        return try modelContext.fetch(descriptor).map { $0.asDomain() }
    }

    func fetchAlbums(matching query: String, limit: Int? = nil) async throws -> [Album] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return try await fetchAllAlbums()
        }

        let descriptor = FetchDescriptor<AlbumRecord>(sortBy: [SortDescriptor(\AlbumRecord.cachedAt, order: .reverse)])
        let matches = try modelContext.fetch(descriptor).filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.artistName.localizedCaseInsensitiveContains(trimmed)
        }

        let limited = limit.map { Array(matches.prefix($0)) } ?? matches
        return limited.map { $0.asDomain() }
    }
}

private extension AlbumRecord {
    func asDomain() -> Album {
        Album(
            id: id,
            appleMusicID: appleMusicID,
            title: title,
            artistName: artistName,
            releaseYear: releaseYear,
            genreName: genreName,
            artworkURL: artworkURL,
            trackCount: trackCount,
            cachedAt: cachedAt
        )
    }
}
