import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var user: User
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DeckView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Deck")
                }
                .tag(0)
            
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(User(name: "Test User"))
    }
}