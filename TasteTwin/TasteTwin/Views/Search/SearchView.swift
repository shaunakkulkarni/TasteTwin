import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.appEnvironment) private var appEnvironment

    @Binding private var path: NavigationPath
    @State private var viewModel = SearchViewModel(
        catalogService: MockMusicCatalogService(),
        albumRepository: UnimplementedAlbumRepository()
    )

    init(path: Binding<NavigationPath>) {
        _path = path
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            content
                .padding(.horizontal, AppTheme.Layout.contentPadding)
                .padding(.top, 12)
        }
        .navigationTitle("Search")
        .searchNavigationBarTitleDisplayMode()
        .searchable(text: $viewModel.query, prompt: "Search albums or artists")
        .onChange(of: viewModel.query) { _, _ in
            viewModel.onQueryChanged()
        }
        .task {
            viewModel.configure(
                catalogService: appEnvironment.musicCatalogService,
                albumRepository: appEnvironment.albumRepository
            )
        }
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .albumDetail(let result):
                AlbumDetailView(initialResult: result)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            VStack(alignment: .leading, spacing: 10) {
                Text("Find your next album")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Text("Type at least \(Constants.minSearchQueryLength) characters to search the catalog.")
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        case .loading:
            ProgressView()
                .tint(AppTheme.Colors.accentMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .error(let message):
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundStyle(AppTheme.Colors.danger)
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .empty:
            Text("No matching albums found.")
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case .loaded(let results):
            ScrollView {
                LazyVStack(spacing: AppTheme.Layout.cardSpacing) {
                    ForEach(results) { album in
                        Button {
                            Task {
                                await viewModel.cacheSelection(album)
                                path.append(SearchRoute.albumDetail(album))
                            }
                        } label: {
                            SearchResultCard(album: album)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, AppTheme.Layout.sectionSpacing)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private enum SearchRoute: Hashable {
    case albumDetail(AlbumSearchResultDTO)
}

private extension View {
    @ViewBuilder
    func searchNavigationBarTitleDisplayMode() -> some View {
        #if os(macOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.large)
        #endif
    }
}

#Preview {
    SearchViewPreviewContainer()
}

private struct SearchViewPreviewContainer: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            SearchView(path: $path)
        }
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
    }
}
