import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var isShowingQuickLogSearch = false
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
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Home")
        .navigationDestination(for: UUID.self) { logID in
            LogDetailView(logID: logID)
        }
        .navigationDestination(isPresented: $isShowingQuickLogSearch) {
            SearchView()
        }
        .overlay(alignment: .bottomTrailing) {
            quickLogButton
                .padding(.trailing, AppTheme.Layout.contentPadding)
                .padding(.bottom, 20)
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

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Feed")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)

            HStack(spacing: 16) {
                stat(label: "Logs", value: "\(viewModel.totalLogCount)")
                stat(label: "Avg", value: String(format: "%.2f", viewModel.overallAverageRating))
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

    private var quickLogButton: some View {
        Button {
            isShowingQuickLogSearch = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.accentMuted)
                )
                .overlay(
                    Circle()
                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Quick Log Album")
        .accessibilityHint("Opens search so you can pick an album and log it quickly.")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(AppEnvironment.preview().modelContainer)
    .environment(\.appEnvironment, .preview())
}
