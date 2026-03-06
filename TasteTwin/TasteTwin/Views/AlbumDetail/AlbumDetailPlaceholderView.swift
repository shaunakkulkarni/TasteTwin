import SwiftUI
import SwiftData

struct AlbumDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel: AlbumDetailViewModel

    init(initialResult: AlbumSearchResultDTO) {
        _viewModel = State(initialValue: AlbumDetailViewModel(
            initialResult: initialResult,
            musicCatalogService: MockMusicCatalogService(),
            albumRepository: UnimplementedAlbumRepository(),
            logRepository: UnimplementedLogRepository()
        ))
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            Group {
                if viewModel.isLoading && viewModel.album == nil {
                    ProgressView()
                        .tint(AppTheme.Colors.accentMuted)
                } else if let message = viewModel.errorMessage, viewModel.album == nil {
                    VStack(spacing: 12) {
                        Text(message)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        Button("Close") {
                            dismiss()
                        }
                    }
                    .padding(AppTheme.Layout.contentPadding)
                } else if let album = viewModel.album {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                            AlbumHeroCard(album: album)

                            NavigationLink {
                                LogEntryView(
                                    album: album,
                                    mode: viewModel.existingLogID.map { .edit($0) } ?? .create
                                )
                            } label: {
                                Label(viewModel.existingLogID == nil ? "Log Album" : "Edit Log", systemImage: "square.and.pencil")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.Colors.accentMuted)
                        }
                        .padding(AppTheme.Layout.contentPadding)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .navigationTitle("Album")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            viewModel.configure(
                musicCatalogService: appEnvironment.musicCatalogService,
                albumRepository: appEnvironment.albumRepository,
                logRepository: appEnvironment.logRepository
            )
            await viewModel.loadIfNeeded()
        }
    }
}

#Preview {
    NavigationStack {
        AlbumDetailView(initialResult: AlbumSearchResultDTO(
            appleMusicID: "1533869057",
            title: "folklore",
            artistName: "Taylor Swift",
            releaseYear: 2020,
            genreName: "Alternative",
            artworkURL: nil
        ))
    }
    .modelContainer(AppEnvironment.preview().modelContainer)
    .environment(\.appEnvironment, .preview())
}
