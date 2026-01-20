import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager
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
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .onAppear {
            // Request notification permissions
            notificationManager.requestPermissions()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showDeck)) { _ in
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAnalytics)) { _ in
            selectedTab = 2
        }
    }
}