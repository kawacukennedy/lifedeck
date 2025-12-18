import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.lifeDeckPrimary)
                        
                        Text(user.name.isEmpty ? "User" : user.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(subscriptionManager.isPremium ? "Premium Member" : "Free Member")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(subscriptionManager.isPremium ? Color.lifeDeckPremiumGold : Color.lifeDeckTextTertiary)
                            )
                            .foregroundColor(subscriptionManager.isPremium ? .black : .white)
                    }
                    .padding()
                    
                    // Subscription Section
                    if !subscriptionManager.isPremium {
                        Button("Upgrade to Premium") {
                            ContentView.showPaywall()
                        }
                        .buttonStyle(.lifeDeckPremium)
                        .padding()
                    }
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            NavigationLink(destination: NotificationSettingsView()) {
                                SettingsRow(title: "Notifications", systemImage: "bell", hasChevron: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                            NavigationLink(destination: IntegrationSettingsView()) {
                                SettingsRow(title: "Integrations", systemImage: "link", hasChevron: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                            SettingsRow(title: "Data & Privacy", systemImage: "lock", hasChevron: true)
                            SettingsRow(title: "Support", systemImage: "questionmark.circle", hasChevron: true)
                            SettingsRow(title: "About", systemImage: "info.circle", hasChevron: true)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
            .navigationTitle("Profile")
        }
    }
}

struct SettingsRow: View {
    let title: String
    let systemImage: String
    let hasChevron: Bool
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.lifeDeckPrimary)
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(.lifeDeckTextPrimary)
            
            Spacer()
            
            if hasChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.lifeDeckTextTertiary)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.lifeDeckCardBackground)
        .cornerRadius(8)
        .lifeDeckSubtleShadow()
    }
}
