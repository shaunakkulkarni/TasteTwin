import Foundation

@MainActor
protocol AlbumRepositoryProtocol {
    func upsertAlbum(_ album: Album) async throws -> Album
    func fetchAlbum(byAppleMusicID id: String) async throws -> Album?
    func fetchAlbum(byID id: UUID) async throws -> Album?
    func fetchAllAlbums() async throws -> [Album]
}

struct UnimplementedAlbumRepository: AlbumRepositoryProtocol {
    func upsertAlbum(_ album: Album) async throws -> Album { album }
    func fetchAlbum(byAppleMusicID id: String) async throws -> Album? { nil }
    func fetchAlbum(byID id: UUID) async throws -> Album? { nil }
    func fetchAllAlbums() async throws -> [Album] { [] }
}
