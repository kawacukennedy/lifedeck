import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedTab = 0
    @State private var showingPaywall = false
    
    var body: some View {
        Group {
            if !user.hasCompletedOnboarding {
                // Show onboarding if not completed
                OnboardingView()
            } else {
                // Main app interface
                mainAppView
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
    
    private var mainAppView: some View {
        TabView(selection: $selectedTab) {
            // Deck Tab - Main coaching cards interface
            NavigationView {
                DeckView()
                    .background(Color.lifeDeckBackground.ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: selectedTab == 0 ? "rectangle.stack.fill" : "rectangle.stack")
                Text("Deck")
            }
            .tag(0)
            
            // Dashboard Tab - Progress and analytics
            NavigationView {
                DashboardView()
                    .background(Color.lifeDeckBackground.ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: selectedTab == 1 ? "chart.xyaxis.line" : "chart.line.uptrend.xyaxis")
                Text("Progress")
            }
            .tag(1)
            
            // Premium Tab - Premium features or upgrade
            NavigationView {
                if subscriptionManager.isPremium {
                    PremiumFeaturesView()
                        .background(Color.lifeDeckBackground.ignoresSafeArea())
                } else {
                    PaywallView()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "crown")
                Text("Premium")
            }
            .tag(2)
            
            // LifeDeck Showcase Tab - Design system demo
            NavigationView {
                LifeDeckShowcaseView()
                    .background(Color.lifeDeckBackground.ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: selectedTab == 3 ? "paintbrush.fill" : "paintbrush")
                Text("Design")
            }
            .tag(3)
            
            // Profile Tab - User settings and subscription  
            NavigationView {
                ProfileView()
                    .background(Color.lifeDeckBackground.ignoresSafeArea())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                Text("Profile")
            }
            .tag(4)
        }
        .accentColor(.lifeDeckPrimary)
        .preferredColorScheme(.dark)
        .onAppear {
            setupTabBarAppearance()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPaywall)) { _ in
            showingPaywall = true
        }
    }
    
    /// Setup native iOS tab bar appearance
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.lifeDeckCardBackground)
        tabBarAppearance.shadowColor = UIColor(Color.lifeDeckSeparator.opacity(0.3))
        
        // Normal state
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.lifeDeckTextSecondary)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.lifeDeckTextSecondary),
            .font: UIFont.systemFont(ofSize: DesignSystem.deviceType == .compact ? 10 : 11, weight: .medium)
        ]
        
        // Selected state
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.lifeDeckPrimary)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.lifeDeckPrimary),
            .font: UIFont.systemFont(ofSize: DesignSystem.deviceType == .compact ? 10 : 11, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set tint colors
        UITabBar.appearance().tintColor = UIColor(Color.lifeDeckPrimary)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.lifeDeckTextSecondary)
    }
}

// MARK: - Premium Features View
struct PremiumFeaturesView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.betweenSections) {
                // Premium Status Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(.lifeDeckPremiumGold)
                        
                        Text("Premium Active")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(.lifeDeckTextPrimary)
                    }
                    
                    Text("Enjoy unlimited access to all features")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.lifeDeckTextSecondary)
                        .multilineTextAlignment(.center)
                }
.padding(DesignSystem.Spacing.cardPadding)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.lifeDeckCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.lifeDeckPremiumGold.opacity(0.4),
                                            Color.lifeDeckPrimary.opacity(0.4)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
.shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                
                // Premium Features Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: DesignSystem.Layout.gridColumns), spacing: DesignSystem.Spacing.md) {
                    PremiumFeatureCard(
                        icon: "infinity",
                        title: "Unlimited Cards",
                        description: "Access to all coaching cards without daily limits",
                        color: .lifeDeckSuccess
                    )
                    
                    PremiumFeatureCard(
                        icon: "brain.head.profile",
                        title: "Advanced AI",
                        description: "Contextual and adaptive AI coaching",
                        color: .lifeDeckPrimary
                    )
                    
                    PremiumFeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Full Analytics",
                        description: "Detailed insights and trend analysis",
                        color: .lifeDeckSecondary
                    )
                    
                    PremiumFeatureCard(
                        icon: "link",
                        title: "Integrations",
                        description: "Connect with Health, Calendar, and Finance apps",
                        color: .lifeDeckWarning
                    )
                }
                .responsiveHorizontalPadding()
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PremiumFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.title)
                .foregroundColor(color)
            
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
.padding(DesignSystem.Spacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
        )
.shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showPaywall = Notification.Name("show_paywall")
    static let subscriptionChanged = Notification.Name("subscription_changed")
    static let cardCompleted = Notification.Name("card_completed")
    static let achievementUnlocked = Notification.Name("achievement_unlocked")
}

// MARK: - Content View Modifiers
extension ContentView {
    /// Apply consistent styling across the app
    private func applyAppStyling<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        content()
            .background(Color.lifeDeckBackground.ignoresSafeArea())
            .preferredColorScheme(.light) // Force light mode for consistency
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Simplified preview to prevent timeout
        ContentView()
            .environmentObject(sampleUser)
            .environmentObject(SubscriptionManager())
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("Main App")
    }
    
    static var sampleUser: User {
        let user = User()
        user.hasCompletedOnboarding = true
        user.name = "Alex Johnson"
        user.email = "alex@example.com"
        user.goals = [
            UserGoal(domain: .health, description: "Walk 10,000 steps daily", targetValue: 10000, currentValue: 7500, unit: "steps"),
            UserGoal(domain: .finance, description: "Save $500 monthly", targetValue: 500, currentValue: 250, unit: "dollars"),
            UserGoal(domain: .productivity, description: "Complete 3 tasks daily", targetValue: 3, currentValue: 2, unit: "tasks"),
            UserGoal(domain: .mindfulness, description: "Meditate 10 minutes daily", targetValue: 10, currentValue: 8, unit: "minutes")
        ]
        user.progress.healthScore = 75
        user.progress.financeScore = 50
        user.progress.productivityScore = 67
        user.progress.mindfulnessScore = 80
        user.progress.updateLifeScore()
        user.progress.currentStreak = 5
        user.progress.lifePoints = 450
        user.progress.totalCardsCompleted = 45
        return user
    }
    
    static var newUser: User {
        let user = User()
        user.hasCompletedOnboarding = false
        return user
    }
}

// MARK: - App-wide Helpers
extension ContentView {
    /// Show paywall from any view in the app
    static func showPaywall() {
        NotificationCenter.default.post(name: .showPaywall, object: nil)
    }
    
    /// Notify that a card was completed
    static func notifyCardCompleted() {
        NotificationCenter.default.post(name: .cardCompleted, object: nil)
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Notify that an achievement was unlocked
    static func notifyAchievementUnlocked(_ achievement: Achievement) {
        NotificationCenter.default.post(name: .achievementUnlocked, object: achievement)
        
        // Add celebration haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Show achievement celebration
    static func showAchievementCelebration(for achievement: Achievement) {
        // This could trigger a celebration view or animation
        // For now, we'll use the notification system
        notifyAchievementUnlocked(achievement)
    }
}

// MARK: - App Lifecycle Handling
extension ContentView {
    /// Handle app becoming active
    private func handleAppBecameActive() {
        // Refresh subscription status
        Task {
            await subscriptionManager.refreshSubscriptionStatus()
        }
        
        // Check for expired snoozed cards
        // This would typically be handled by a view model
        
        // Update streak if needed
        updateDailyStreak()
    }
    
    /// Update daily streak based on last active date
    private func updateDailyStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastActiveDate = user.progress.lastActiveDate else {
            // First time opening the app
            return
        }
        
        let lastActive = calendar.startOfDay(for: lastActiveDate)
        let daysBetween = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0
        
        if daysBetween > 1 {
            // Streak broken - reset to 0
            user.progress.currentStreak = 0
        }
        // If daysBetween == 1, streak continues
        // If daysBetween == 0, same day
    }
}
