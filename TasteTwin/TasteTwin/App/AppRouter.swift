import SwiftUI

struct AppRouter: View {
    @Environment(\.appEnvironment) private var appEnvironment
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        RootTabView()
            .task {
                await appEnvironment.tasteUpdateCoordinator.retryPending(limit: Constants.tasteUpdateRetryBatchSize)
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task {
                    await appEnvironment.tasteUpdateCoordinator.retryPending(limit: Constants.tasteUpdateRetryBatchSize)
                }
            }
    }
}
