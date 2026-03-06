import SwiftUI
import SwiftData

@main
struct TasteTwinApp: App {
    private let environment = AppEnvironment.live()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(\.appEnvironment, environment)
                .modelContainer(environment.modelContainer)
        }
    }
}
