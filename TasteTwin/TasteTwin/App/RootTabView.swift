import SwiftUI
import SwiftData

struct RootTabView: View {
    enum Tab: Hashable {
        case home
        case search
        case profile
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(AppEnvironment.preview().modelContainer)
        .environment(\.appEnvironment, .preview())
}
