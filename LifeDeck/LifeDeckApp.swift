import SwiftUI

@main
struct LifeDeckApp: App {
    @StateObject private var user = User()
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    init() {
        // Configure app appearance
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            // Use full ContentView
            ContentView()
                .environmentObject(user)
                .environmentObject(subscriptionManager)
                .onAppear {
                    // Load user data on app launch
                    loadUserData()
                    // Initialize subscription manager
                    Task {
                        await subscriptionManager.initialize()
                    }
                    // Setup debug data for testing
                    setupDebugData()
                }
                .onChange(of: user.hasCompletedOnboarding) { _ in
                    // Save user data when onboarding status changes
                    saveUserData()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set accent color
        UIView.appearance().tintColor = UIColor.systemBlue
    }
    
    private func loadUserData() {
        if let userData = UserDefaults.standard.data(forKey: "lifedeck_user"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            // Update current user with loaded data
            user.id = decodedUser.id
            user.name = decodedUser.name
            user.email = decodedUser.email
            user.hasCompletedOnboarding = decodedUser.hasCompletedOnboarding
            user.goals = decodedUser.goals
            user.progress = decodedUser.progress
            user.settings = decodedUser.settings
            user.achievements = decodedUser.achievements
            user.joinDate = decodedUser.joinDate
            user.subscriptionTier = decodedUser.subscriptionTier
            user.subscriptionExpiryDate = decodedUser.subscriptionExpiryDate
        }
    }
    
    private func saveUserData() {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "lifedeck_user")
        }
    }
}

// MARK: - App State Management
extension LifeDeckApp {
    /// Handle app lifecycle events
    private func handleAppLifecycleEvents() {
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Refresh subscription status when app comes to foreground
            Task {
                await subscriptionManager.refreshSubscriptionStatus()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Save user data when app goes to background
            saveUserData()
        }
    }
}

// MARK: - Debug Helpers
extension LifeDeckApp {
    private func setupDebugData() {
        // Debug: Skip onboarding and show main app content
        user.hasCompletedOnboarding = true
        user.name = "Alex Johnson"
        user.email = "alex@lifedeck.app"
        
        // Populate with sample data for testing
        if user.goals.isEmpty {
            user.goals = [
                UserGoal(domain: .health, description: "Walk 10,000 steps daily", targetValue: 10000, currentValue: 6500, unit: "steps"),
                UserGoal(domain: .finance, description: "Save $500 monthly", targetValue: 500, currentValue: 150, unit: "dollars"),
                UserGoal(domain: .productivity, description: "Complete 3 important tasks daily", targetValue: 3, currentValue: 1, unit: "tasks"),
                UserGoal(domain: .mindfulness, description: "Meditate 10 minutes daily", targetValue: 10, currentValue: 5, unit: "minutes")
            ]
        }
            
        user.progress.healthScore = 65
        user.progress.financeScore = 30
        user.progress.productivityScore = 45
        user.progress.mindfulnessScore = 50
        user.progress.updateLifeScore()
        user.progress.currentStreak = 3
        user.progress.lifePoints = 180
        user.progress.totalCardsCompleted = 15
    }
}
