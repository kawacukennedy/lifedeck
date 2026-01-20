import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var user: User
    
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingPaywall = false
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Circle()
                            .fill(DesignSystem.Colors.primary)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(String(user.name.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name.isEmpty ? "User" : user.name)
                                .font(DesignSystem.Typography.title3)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Text(user.subscription.isPremium ? "Premium Member" : "Free Member")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(user.subscription.isPremium ? DesignSystem.Colors.premium : DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        if !user.subscription.isPremium {
                            Button(action: { showingPaywall = true }) {
                                Text("Upgrade")
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(DesignSystem.Colors.primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                
                // Stats
                Section {
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        statItem(title: "Life Points", value: "\(user.lifePoints)")
                        Divider()
                        statItem(title: "Cards Completed", value: "\(user.progress.totalCardsCompleted)")
                        Divider()
                        statItem(title: "Current Streak", value: "\(user.progress.currentStreak)")
                    }
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                
                // Preferences
                Section("Preferences") {
                    Toggle("Notifications", isOn: Binding(
                        get: { user.settings.notificationsEnabled },
                        set: { user.settings.notificationsEnabled = $0 }
                    ))
                    
                    Toggle("Weekly Reports", isOn: Binding(
                        get: { user.settings.weeklyReportsEnabled },
                        set: { user.settings.weeklyReportsEnabled = $0 }
                    ))
                    
                    Toggle("Haptics", isOn: Binding(
                        get: { user.settings.hapticsEnabled },
                        set: { user.settings.hapticsEnabled = $0 }
                    ))
                    
                    Toggle("Sound", isOn: Binding(
                        get: { user.settings.soundEnabled },
                        set: { user.settings.soundEnabled = $0 }
                    ))
                }
                
                // Focus Areas
                Section("Focus Areas") {
                    ForEach(LifeDomain.allCases) { domain in
                        HStack {
                            Image(systemName: domain.icon)
                                .foregroundColor(Color.forDomain(domain))
                            Text(domain.displayName)
                            Spacer()
                            if user.settings.focusAreas.contains(domain) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DesignSystem.Colors.success)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if user.settings.focusAreas.contains(domain) {
                                user.settings.focusAreas.removeAll { $0 == domain }
                            } else {
                                user.settings.focusAreas.append(domain)
                            }
                        }
                    }
                }
                
                // Account
                Section("Account") {
                    if user.subscription.isPremium {
                        NavigationLink(destination: subscriptionDetailsView) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(DesignSystem.Colors.premium)
                                Text("Subscription")
                            }
                        }
                    } else {
                        Button(action: { showingPaywall = true }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(DesignSystem.Colors.premium)
                                Text("Upgrade to Premium")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: dataExportView) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Data")
                        }
                    }
                    
                    NavigationLink(destination: privacyView) {
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("Privacy & Security")
                        }
                    }
                }
                
                // Support
                Section("Support") {
                    NavigationLink(destination: helpView) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help & Support")
                        }
                    }
                    
                    NavigationLink(destination: aboutView) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("About")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(DesignSystem.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var subscriptionDetailsView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.premium)
            
            Text("Premium Active")
                .font(DesignSystem.Typography.title1)
            
            Text("You have access to all premium features")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var dataExportView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Export your data")
                .font(DesignSystem.Typography.title2)
            
            Button("Export All Data") {
                // Export implementation
            }
            .primaryButtonStyle()
        }
        .padding()
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var privacyView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Privacy & Security")
                .font(DesignSystem.Typography.title2)
            
            Text("Your data is encrypted and secure. We never share your personal information.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding()
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var helpView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Help & Support")
                .font(DesignSystem.Typography.title2)
            
            Text("Need help? Contact us at support@lifedeck.app")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding()
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var aboutView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("LifeDeck")
                .font(DesignSystem.Typography.title1)
            
            Text("Version 1.0.0")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}