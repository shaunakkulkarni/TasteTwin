import SwiftUI
import SwiftData

struct LogDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var showDeleteConfirmation = false
    @State private var viewModel: LogDetailViewModel

    init(logID: UUID) {
        _viewModel = State(initialValue: LogDetailViewModel(
            logID: logID,
            logRepository: UnimplementedLogRepository(),
            albumRepository: UnimplementedAlbumRepository()
        ))
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            content
                .padding(AppTheme.Layout.contentPadding)
        }
        .navigationTitle("Log Detail")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            Task {
                viewModel.configure(
                    logRepository: appEnvironment.logRepository,
                    albumRepository: appEnvironment.albumRepository
                )
                await viewModel.refresh()
            }
        }
        .alert("Delete this log?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    let didDelete = await viewModel.deleteLog()
                    if didDelete {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.item == nil {
            ProgressView()
                .tint(AppTheme.Colors.accentMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let item = viewModel.item {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                    hero(item)
                    metadata(item)
                    actions(item)
                }
            }
            .scrollIndicators(.hidden)
        } else {
            EmptyStateView(
                title: "Log not available",
                subtitle: viewModel.errorMessage ?? "Try returning to the feed and reopening the entry."
            )
        }
    }

    private func hero(_ item: LogDisplayItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            AsyncImage(url: URL(string: item.artworkURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.Colors.inputBackground)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(AppTheme.Colors.textTertiary)
                    }
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(item.albumTitle)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(item.artistName)
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            HStack(spacing: 10) {
                if let year = item.releaseYear {
                    Text(String(year))
                }
                if let genre = item.genreName {
                    Text(genre)
                        .lineLimit(1)
                }
                if let trackCount = item.trackCount {
                    Text("\(trackCount) tracks")
                }
            }
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .padding(16)
        .background(cardBackground)
    }

    private func metadata(_ item: LogDisplayItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating: \(item.rating, specifier: "%.1f") / 5")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if !item.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(item.reviewText)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            if !item.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.Colors.inputBackground, in: Capsule())
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }

            Text("Logged: \(item.loggedAt, format: .dateTime.month().day().year())")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
            Text("Updated: \(item.updatedAt, format: .dateTime.month().day().year().hour().minute())")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private func actions(_ item: LogDisplayItem) -> some View {
        VStack(spacing: 10) {
            NavigationLink {
                LogEntryView(
                    album: Album(
                        id: item.albumID,
                        appleMusicID: item.appleMusicID,
                        title: item.albumTitle,
                        artistName: item.artistName,
                        releaseYear: item.releaseYear,
                        genreName: item.genreName,
                        artworkURL: item.artworkURL,
                        trackCount: item.trackCount,
                        cachedAt: .now
                    ),
                    mode: .edit(item.id)
                )
            } label: {
                Label("Edit Log", systemImage: "square.and.pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.Colors.accentMuted)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                if viewModel.isDeleting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Label("Delete Log", systemImage: "trash")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.Colors.danger)
            .disabled(viewModel.isDeleting)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
            .fill(AppTheme.Colors.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
                    .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        LogDetailView(logID: UUID())
    }
    .modelContainer(AppEnvironment.preview().modelContainer)
    .environment(\.appEnvironment, .preview())
}
