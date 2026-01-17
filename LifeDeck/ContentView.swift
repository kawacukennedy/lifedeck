import SwiftUI

struct ContentView: View {
    @StateObject var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        TabView {
            Text("Deck")
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Deck")
                }
                .tag(0)
            
            Text("Premium")
                .tabItem {
                    Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "crown")
                    Text("Premium")
                }
                .tag(1)
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}