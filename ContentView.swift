import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var user: User = loadUser()

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(user: user)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            DeckView(user: user)
                .tabItem {
                    Label("Deck", systemImage: "rectangle.stack.fill")
                }
                .tag(1)

            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(Color.primary)
        .onChange(of: selectedTab) { _ in
            // Refresh user data when switching tabs
            user = loadUser()
        }
    }
}

private func loadUser() -> User {
    if let data = UserDefaults.standard.data(forKey: "user"),
       let user = try? JSONDecoder().decode(User.self, from: data) {
        return user
    }
    return User(name: "User") // Fallback
}