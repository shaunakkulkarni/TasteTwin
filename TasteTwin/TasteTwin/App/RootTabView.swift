import SwiftUI
import SwiftData

struct RootTabView: View {
    enum Tab: Hashable {
        case home
        case search
        case tasteTwin
        case profile

        init?(index: Int) {
            switch index {
            case 0:
                self = .home
            case 1:
                self = .search
            case 2:
                self = .tasteTwin
            case 3:
                self = .profile
            default:
                return nil
            }
        }
    }

    @State private var selectedTab: Tab = .home
    @State private var homePath = NavigationPath()
    @State private var searchPath = NavigationPath()
    @State private var tasteTwinPath = NavigationPath()
    @State private var profilePath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView(path: $homePath)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack(path: $searchPath) {
                SearchView(path: $searchPath)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            NavigationStack(path: $tasteTwinPath) {
                TasteTwinView(path: $tasteTwinPath)
            }
            .tabItem {
                Label("Taste Twin", systemImage: "waveform.path.ecg")
            }
            .tag(Tab.tasteTwin)

            NavigationStack(path: $profilePath) {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
        }
        .background(
            TabBarTapObserver { index in
                guard let tappedTab = Tab(index: index) else { return }
                popToRoot(for: tappedTab)
                selectedTab = tappedTab
            }
        )
        .onChange(of: selectedTab) { _, newTab in
            popToRoot(for: newTab)
        }
        .tint(AppTheme.Colors.accentMuted)
        .preferredColorScheme(.dark)
    }

    private func popToRoot(for tab: Tab) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .search:
            searchPath = NavigationPath()
        case .tasteTwin:
            tasteTwinPath = NavigationPath()
        case .profile:
            profilePath = NavigationPath()
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
}
