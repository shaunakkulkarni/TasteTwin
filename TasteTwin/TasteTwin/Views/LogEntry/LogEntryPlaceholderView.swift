import SwiftUI
import SwiftData

struct LogEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel: LogEntryViewModel

    init(album: Album, mode: LogEntryViewModel.Mode) {
        _viewModel = State(initialValue: LogEntryViewModel(
            album: album,
            mode: mode,
            logRepository: UnimplementedLogRepository(),
            tasteUpdateCoordinator: UnimplementedTasteUpdateCoordinator()
        ))
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                    headerCard
                    ratingCard
                    reviewCard
                    tagsCard
                    saveButton
                }
                .padding(AppTheme.Layout.contentPadding)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(viewModel.navigationTitle)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            viewModel.configure(
                logRepository: appEnvironment.logRepository,
                tasteUpdateCoordinator: appEnvironment.tasteUpdateCoordinator
            )
            await viewModel.loadIfNeeded()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.album.title)
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text(viewModel.album.artistName)
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Slider(value: $viewModel.rating, in: 0...5, step: 0.5)
                .tint(AppTheme.Colors.accentMuted)

            Text(viewModel.rating > 0 ? "\(viewModel.rating, specifier: "%.1f") / 5" : "Required")
                .font(.caption)
                .foregroundStyle(viewModel.rating > 0 ? AppTheme.Colors.textSecondary : AppTheme.Colors.danger)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Review")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            TextEditor(text: $viewModel.reviewText)
                .frame(minHeight: 120)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(AppTheme.Colors.inputBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Optional but encouraged")
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tags")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Text("\(viewModel.tags.count)/\(Constants.maxTagCount)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textTertiary)
            }

            TagInputChips(tags: $viewModel.tags, text: $viewModel.tagInput) {
                viewModel.addTag()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.danger)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var saveButton: some View {
        Button {
            Task {
                let didSave = await viewModel.save()
                if didSave {
                    dismiss()
                }
            }
        } label: {
            if viewModel.isSaving {
                ProgressView()
                    .tint(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            } else {
                Text("Save Log")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.Colors.accentMuted)
        .disabled(viewModel.isSaving)
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
