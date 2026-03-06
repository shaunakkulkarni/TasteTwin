import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([AlbumSearchResultDTO])
        case empty
        case error(String)
    }

    var query: String = ""
    var state: State = .idle

    private var searchTask: Task<Void, Never>?
    private var catalogService: MusicCatalogServiceProtocol
    private var albumRepository: AlbumRepositoryProtocol

    init(
        catalogService: MusicCatalogServiceProtocol,
        albumRepository: AlbumRepositoryProtocol
    ) {
        self.catalogService = catalogService
        self.albumRepository = albumRepository
    }

    func configure(
        catalogService: MusicCatalogServiceProtocol,
        albumRepository: AlbumRepositoryProtocol
    ) {
        self.catalogService = catalogService
        self.albumRepository = albumRepository
    }

    func onQueryChanged() {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= Constants.minSearchQueryLength else {
            state = .idle
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(Constants.searchDebounceMilliseconds))
            guard !Task.isCancelled else { return }
            await performSearch(trimmed)
        }
    }

    func cacheSelection(_ result: AlbumSearchResultDTO) async {
        do {
            _ = try await albumRepository.upsertAlbum(result.asAlbum())
        } catch {
            // No-op for Phase 2: caching failure should not block navigation.
        }
    }

    private func performSearch(_ query: String) async {
        state = .loading
        do {
            let results = try await catalogService.searchAlbums(query: query)
            if results.isEmpty {
                state = .empty
            } else {
                state = .loaded(Array(results.prefix(Constants.maxSearchResults)))
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
