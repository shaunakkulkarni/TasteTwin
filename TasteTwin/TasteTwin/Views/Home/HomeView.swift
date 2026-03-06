import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel = HomeViewModel(
        logRepository: UnimplementedLogRepository(),
        albumRepository: UnimplementedAlbumRepository()
    )

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                    summaryCard

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppTheme.Colors.accentMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                    } else if let error = viewModel.errorMessage {
                        EmptyStateView(
                            title: "Couldn\'t load recent logs",
                            subtitle: error
                        )
                    } else if viewModel.recentLogs.isEmpty {
                        EmptyStateView(
                            title: "No logs yet",
                            subtitle: "Search and log an album to start building your feed."
                        )
                    } else {
                        VStack(spacing: AppTheme.Layout.cardSpacing) {
                            ForEach(viewModel.recentLogs) { item in
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
        .navigationTitle("Home")
        .navigationDestination(for: UUID.self) { logID in
            LogDetailView(logID: logID)
        }
        .task {
            viewModel.configure(
                logRepository: appEnvironment.logRepository,
                albumRepository: appEnvironment.albumRepository
            )
            await viewModel.refresh()
        }
        .onAppear {
            Task {
                await viewModel.refresh()
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Feed")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: 16) {
                stat(label: "Logs", value: "\(viewModel.totalLogs)")
                stat(label: "Avg", value: String(format: "%.2f", viewModel.averageRating))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
                .fill(AppTheme.Colors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius, style: .continuous)
                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                )
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
        HomeView()
    }
    .modelContainer(AppEnvironment.preview().modelContainer)
    .environment(\.appEnvironment, .preview())
}
