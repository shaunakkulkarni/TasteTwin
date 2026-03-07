import SwiftUI
import SwiftData

struct TasteTwinView: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Binding private var path: NavigationPath

    @State private var viewModel = TasteTwinViewModel(
        tasteProfileService: UnimplementedTasteProfileService(),
        tasteRepository: UnimplementedTasteRepository(),
        statusRepository: UnimplementedTasteUpdateStatusRepository(),
        logRepository: UnimplementedLogRepository(),
        albumRepository: UnimplementedAlbumRepository()
    )

    init(path: Binding<NavigationPath>) {
        _path = path
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                    headerCard
                    #if DEBUG
                    if viewModel.shouldShowExtractionFallbackPill {
                        extractionFallbackPill
                    }
                    #endif
                    content
                }
                .padding(AppTheme.Layout.contentPadding)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Taste Twin")
        .onAppear {
            Task {
                viewModel.configure(
                    tasteProfileService: appEnvironment.tasteProfileService,
                    tasteRepository: appEnvironment.tasteRepository,
                    statusRepository: appEnvironment.tasteUpdateStatusRepository,
                    logRepository: appEnvironment.logRepository,
                    albumRepository: appEnvironment.albumRepository
                )
                await viewModel.refresh()
            }
        }
        .navigationDestination(for: TasteTwinRoute.self) { route in
            switch route {
            case .albumDetail(let result):
                AlbumDetailView(initialResult: result)
            case .logDetail(let logID):
                LogDetailView(logID: logID)
            }
        }
        #if DEBUG
        .onReceive(NotificationCenter.default.publisher(for: .didUseMockExtractionFallback)) { _ in
            viewModel.showMockExtractionFallbackIndicator()
        }
        #endif
    }

    private var content: some View {
        Group {
            if viewModel.isLoading && viewModel.dimensions.isEmpty {
                ProgressView()
                    .tint(AppTheme.Colors.accentMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: "Couldn\'t load Taste Twin",
                    subtitle: error
                )
            } else if viewModel.dimensions.isEmpty {
                EmptyStateView(
                    title: "No taste dimensions yet",
                    subtitle: "Log more albums to build your Taste Twin profile."
                )
            } else {
                VStack(spacing: AppTheme.Layout.cardSpacing) {
                    ForEach(viewModel.dimensions) { dimension in
                        dimensionCard(dimension)
                    }
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inferred Taste Profile")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textPrimary)
            Text("Dimensions are sorted by weight and low-confidence signals are hidden.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private var extractionFallbackPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "flask")
                .font(.caption.weight(.semibold))
            Text("Using test extraction")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(AppTheme.Colors.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.Colors.inputBackground, in: Capsule())
    }

    private func dimensionCard(_ dimension: TasteDimension) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.displayName(for: dimension))
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                Spacer()
                Text("\(Int((dimension.weight * 100).rounded()))")
                    .font(.title3.monospacedDigit().weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }

            ProgressView(value: min(1.0, max(0.0, dimension.weight)))
                .tint(AppTheme.Colors.accentMuted)

            Text(viewModel.confidenceText(for: dimension))
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textTertiary)

            if !dimension.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(dimension.summary)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            let evidence = viewModel.evidence(for: dimension.id)
            if !evidence.isEmpty {
                Button {
                    viewModel.toggleExpanded(for: dimension.id)
                } label: {
                    HStack {
                        Text(viewModel.isExpanded(dimension.id) ? "Hide Evidence" : "Show Evidence")
                        Spacer()
                        Text("\(evidence.count)")
                            .font(.caption.monospacedDigit())
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.accentMuted)
                }
                .buttonStyle(.plain)

                if viewModel.isExpanded(dimension.id) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(evidence, id: \.id) { item in
                            Button {
                                switch item.destination {
                                case .album(let album):
                                    path.append(TasteTwinRoute.albumDetail(album))
                                case .logDetail(let logID):
                                    path.append(TasteTwinRoute.logDetail(logID))
                                }
                            } label: {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "link")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(AppTheme.Colors.accentMuted)
                                        .padding(.top, 2)
                                    Text("\"\(item.snippet)\"")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.Colors.textSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "chevron.right")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(AppTheme.Colors.textTertiary)
                                        .padding(.top, 2)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.Colors.inputBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
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
}

private enum TasteTwinRoute: Hashable {
    case albumDetail(AlbumSearchResultDTO)
    case logDetail(UUID)
}

#Preview {
    TasteTwinViewPreviewContainer()
}

private struct TasteTwinViewPreviewContainer: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            TasteTwinView(path: $path)
        }
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
    }
}
