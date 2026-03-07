import SwiftUI

struct AppRouter: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.scenePhase) private var scenePhase
    @State private var extractionProgressViewModel = GlobalExtractionProgressViewModel(
        statusRepository: UnimplementedTasteUpdateStatusRepository()
    )

    var body: some View {
        RootTabView()
            .safeAreaInset(edge: .top, spacing: 0) {
                if extractionProgressViewModel.shouldShowProgressBar {
                    ProgressView(value: max(0, min(1, extractionProgressViewModel.progressValue)))
                        .progressViewStyle(.linear)
                        .tint(AppTheme.Colors.accentMuted)
                        .padding(.horizontal, AppTheme.Layout.contentPadding)
                        .padding(.top, 6)
                }
            }
            .task {
                extractionProgressViewModel.configure(statusRepository: appEnvironment.tasteUpdateStatusRepository)
                await extractionProgressViewModel.refreshAndBeginIfNeeded()
                await appEnvironment.tasteUpdateCoordinator.retryPending(limit: Constants.tasteUpdateRetryBatchSize)
                await appEnvironment.tasteUpdateCoordinator.retryFailed(limit: Constants.tasteUpdateRetryBatchSize)
            }
            .onReceive(NotificationCenter.default.publisher(for: .didSaveLogEntry)) { _ in
                extractionProgressViewModel.beginProgressSession()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task {
                    await extractionProgressViewModel.refreshAndBeginIfNeeded()
                    await appEnvironment.tasteUpdateCoordinator.retryPending(limit: Constants.tasteUpdateRetryBatchSize)
                    await appEnvironment.tasteUpdateCoordinator.retryFailed(limit: Constants.tasteUpdateRetryBatchSize)
                }
            }
    }
}
