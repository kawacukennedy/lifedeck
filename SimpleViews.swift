import SwiftUI

// MARK: - Simple Deck View
struct SimpleDeckView: View {
    @StateObject private var user: AppUser
    
    init(user: AppUser) {
        _user = StateObject(wrappedValue: user)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Daily Deck")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Swipe through your daily coaching cards")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Simple card placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("Today's Cards")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("5 cards remaining")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    )
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 20) {
                    Button("Dismiss") {
                        // Dismiss action
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Button("Complete") {
                        // Complete action
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding()
            .navigationTitle("LifeDeck")
        }
    }
}

struct SimpleContentView: View {
    @StateObject private var user = AppUser(name: "User")
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SimpleDeckView(user: user)
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Deck")
                }
                .tag(0)
            
            SimpleDashboardView(user: user)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(1)
            
            SimpleAnalyticsView(user: user)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(2)
            
            SimpleProfileView(user: user)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
    }
}

// Update loadUser function
func loadUser() -> AppUser {
    return AppUser(name: "User")
}