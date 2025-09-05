import SwiftUI

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
            }
            .tabItem {
                Image(systemName: "rectangle.stack.fill")
                Text("Deck")
            }
            .tag(0)
            
            // Dashboard Tab - Progress and analytics
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "chart.xyaxis.line")
                Text("Dashboard")
            }
            .tag(1)
            
            // Profile Tab - User settings and subscription
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Profile")
            }
            .tag(2)
        }
        .accentColor(.lifeDeckPrimary)
        .onReceive(NotificationCenter.default.publisher(for: .showPaywall)) { _ in
            showingPaywall = true
        }
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
        Group {
            // Preview with completed onboarding
            ContentView()
                .environmentObject(sampleUser)
                .environmentObject(SubscriptionManager())
                .previewDisplayName("Main App")
            
            // Preview with onboarding
            ContentView()
                .environmentObject(newUser)
                .environmentObject(SubscriptionManager())
                .previewDisplayName("Onboarding")
        }
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
