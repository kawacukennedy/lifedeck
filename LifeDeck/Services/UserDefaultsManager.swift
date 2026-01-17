import Foundation

// MARK: - UserDefaults Manager

struct UserDefaultsManager {
    private static let userKey = "LifeDeckUser"
    private static let subscriptionKey = "LifeDeckSubscription"
    private static let onboardingKey = "HasCompletedOnboarding"
    
    // MARK: - User Management
    
    static func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    static func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    // MARK: - Subscription Management
    
    static func saveSubscription(_ subscription: Subscription) {
        if let data = try? JSONEncoder().encode(subscription) {
            UserDefaults.standard.set(data, forKey: subscriptionKey)
        }
    }
    
    static func loadSubscription() -> Subscription? {
        guard let data = UserDefaults.standard.data(forKey: subscriptionKey) else { return nil }
        return try? JSONDecoder().decode(Subscription.self, from: data)
    }
    
    // MARK: - Onboarding Management
    
    static func setOnboardingCompleted(_ completed: Bool) {
        UserDefaults.standard.set(completed, forKey: onboardingKey)
    }
    
    static func hasCompletedOnboarding() -> Bool {
        UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    // MARK: - Clear All Data
    
    static func clearAllData() {
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: subscriptionKey)
        UserDefaults.standard.removeObject(forKey: onboardingKey)
        UserDefaults.standard.removeObject(forKey: "AppState")
    }
}