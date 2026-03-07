import SwiftUI
import SwiftData

struct TasteTwinView: View {
    @Environment(\.appEnvironment) private var appEnvironment

    @State private var viewModel = TasteTwinViewModel(
        tasteProfileService: UnimplementedTasteProfileService(),
        tasteRepository: UnimplementedTasteRepository(),
        statusRepository: UnimplementedTasteUpdateStatusRepository()
    )

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Layout.sectionSpacing) {
                    headerCard
                    if viewModel.shouldShowExtractionProgressBar {
                        extractionProgressBar
                    }
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
                    statusRepository: appEnvironment.tasteUpdateStatusRepository
                )
                await viewModel.refresh()
                if viewModel.isExtractionInFlight {
                    viewModel.beginExtractionProgressSession()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didSaveLogEntry)) { _ in
            viewModel.beginExtractionProgressSession()
        }
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

    private var extractionProgressBar: some View {
        ProgressView(value: max(0, min(1, viewModel.extractionProgressValue)))
            .progressViewStyle(.linear)
            .tint(AppTheme.Colors.accentMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                            Text("\"\(item.snippet)\"")
                                .font(.caption)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.Colors.inputBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
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

#Preview {
    NavigationStack {
        TasteTwinView()
    }
    .modelContainer(AppEnvironment.preview().modelContainer)
    .environment(\.appEnvironment, .preview())
}
