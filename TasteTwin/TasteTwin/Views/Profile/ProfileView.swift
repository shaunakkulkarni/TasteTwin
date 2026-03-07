import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel = ProfileViewModel(
        logRepository: UnimplementedLogRepository(),
        albumRepository: UnimplementedAlbumRepository()
    )

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                    statsCard
                    tagsCard

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppTheme.Colors.accentMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    } else if let error = viewModel.errorMessage {
                        EmptyStateView(title: "Unable to load profile", subtitle: error)
                    } else if viewModel.logs.isEmpty {
                        EmptyStateView(title: "No log history yet", subtitle: "Log albums from Search to populate your profile.")
                    } else {
                        VStack(spacing: AppTheme.Layout.cardSpacing) {
                            ForEach(viewModel.logs) { item in
                                NavigationLink(value: item.id) {
                                    LogCardView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(AppTheme.Layout.contentPadding)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Profile")
        .navigationDestination(for: UUID.self) { logID in
            LogDetailView(logID: logID)
        }
        .onAppear {
            Task {
                viewModel.configure(
                    logRepository: appEnvironment.logRepository,
                    albumRepository: appEnvironment.albumRepository
                )
                await viewModel.refresh()
            }
        }
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Profile")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: 16) {
                stat(label: "Total Logs", value: "\(viewModel.totalLogs)")
                stat(label: "Average", value: String(format: "%.2f", viewModel.averageRating))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private var tagsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Tags")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            if viewModel.recentTags.isEmpty {
                Text("No tags yet")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.recentTags, id: \.self) { tag in
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
            .fill(AppTheme.Colors.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
                    .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
            )
    }

    private func stat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)
            Text(value)
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(AppEnvironment.preview().modelContainer)
    .environment(\.appEnvironment, .preview())
}
