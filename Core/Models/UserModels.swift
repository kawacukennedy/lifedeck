import Foundation
import SwiftUI

// MARK: - Life Domains
enum LifeDomain: String, Codable, CaseIterable, Identifiable {
    case health, finance, productivity, mindfulness
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .health: return "Health"
        case .finance: return "Finance"
        case .productivity: return "Productivity"
        case .mindfulness: return "Mindfulness"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .productivity: return "checkmark.circle.fill"
        case .mindfulness: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .red
        case .finance: return .green
        case .productivity: return .blue
        case .mindfulness: return .purple
        }
    }
}

// MARK: - Subscription Models
enum SubscriptionTier: String, Codable, CaseIterable {
    case free, premium
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }
}

enum SubscriptionStatus: String, Codable, CaseIterable {
    case notSubscribed, active, expired, cancelled, pendingRenewal, inGracePeriod
    
    var isActive: Bool {
        switch self {
        case .active, .pendingRenewal, .inGracePeriod:
            return true
        case .notSubscribed, .expired, .cancelled:
            return false
        }
    }
}

struct AppSubscriptionInfo: Codable {
    let tier: SubscriptionTier
    let status: SubscriptionStatus
    let startDate: Date?
    let expiryDate: Date?
    let autoRenewEnabled: Bool
    let productId: String?
    let transactionId: String?
    let originalTransactionId: String?
    let purchaseDate: Date?
    
    init(tier: SubscriptionTier = .free, status: SubscriptionStatus = .notSubscribed) {
        self.tier = tier
        self.status = status
        self.startDate = nil
        self.expiryDate = nil
        self.autoRenewEnabled = false
        self.productId = nil
        self.transactionId = nil
        self.originalTransactionId = nil
        self.purchaseDate = nil
    }
    
    var isPremium: Bool {
        return tier == .premium && status.isActive
    }
}

// MARK: - User Progress
class UserProgress: ObservableObject, Codable {
    @Published var healthScore: Double = 50
    @Published var financeScore: Double = 50
    @Published var productivityScore: Double = 50
    @Published var mindfulnessScore: Double = 50
    @Published var lifeScore: Double = 50
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lifePoints: Int = 0
    @Published var totalCardsCompleted: Int = 0
    
    init() {}
    
    func updateLifeScore() {
        let domainScores = [healthScore, financeScore, productivityScore, mindfulnessScore]
        lifeScore = domainScores.reduce(0, +) / Double(domainScores.count)
    }
    
    func scoreForDomain(_ domain: LifeDomain) -> Double {
        switch domain {
        case .health: return healthScore
        case .finance: return financeScore
        case .productivity: return productivityScore
        case .mindfulness: return mindfulnessScore
        }
    }
    
    func updateScore(for domain: LifeDomain, score: Double) {
        switch domain {
        case .health:
            healthScore = min(max(score, 0), 100)
        case .finance:
            financeScore = min(max(score, 0), 100)
        case .productivity:
            productivityScore = min(max(score, 0), 100)
        case .mindfulness:
            mindfulnessScore = min(max(score, 0), 100)
        }
        updateLifeScore()
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case healthScore, financeScore, productivityScore, mindfulnessScore
        case lifeScore, currentStreak, longestStreak, lifePoints, totalCardsCompleted
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        healthScore = try container.decodeIfPresent(Double.self, forKey: .healthScore) ?? 50
        financeScore = try container.decodeIfPresent(Double.self, forKey: .financeScore) ?? 50
        productivityScore = try container.decodeIfPresent(Double.self, forKey: .productivityScore) ?? 50
        mindfulnessScore = try container.decodeIfPresent(Double.self, forKey: .mindfulnessScore) ?? 50
        lifeScore = try container.decodeIfPresent(Double.self, forKey: .lifeScore) ?? 50
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        longestStreak = try container.decodeIfPresent(Int.self, forKey: .longestStreak) ?? 0
        lifePoints = try container.decodeIfPresent(Int.self, forKey: .lifePoints) ?? 0
        totalCardsCompleted = try container.decodeIfPresent(Int.self, forKey: .totalCardsCompleted) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(healthScore, forKey: .healthScore)
        try container.encode(financeScore, forKey: .financeScore)
        try container.encode(productivityScore, forKey: .productivityScore)
        try container.encode(mindfulnessScore, forKey: .mindfulnessScore)
        try container.encode(lifeScore, forKey: .lifeScore)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(longestStreak, forKey: .longestStreak)
        try container.encode(lifePoints, forKey: .lifePoints)
        try container.encode(totalCardsCompleted, forKey: .totalCardsCompleted)
    }
}

// MARK: - User Settings
struct UserSettings: Codable {
    var notificationsEnabled: Bool = true
    var focusAreas: [LifeDomain] = []
    var theme: String = "system"
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    var weeklyReportsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true
    var autoStartDay: Bool = false
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let unlockedAt: Date?
    let category: LifeDomain?
    
    init(title: String, description: String, iconName: String, unlockedAt: Date? = nil, category: LifeDomain? = nil) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.unlockedAt = unlockedAt
        self.category = category
    }
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}

// MARK: - User Goal
struct UserGoal: Codable, Identifiable {
    let id = UUID()
    let domain: LifeDomain
    let description: String
    let targetValue: Int
    var currentValue: Int
    let unit: String
    let createdAt: Date
    var isCompleted: Bool
    
    init(domain: LifeDomain, description: String, targetValue: Int, currentValue: Int = 0, unit: String, isCompleted: Bool = false) {
        self.domain = domain
        self.description = description
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
        self.createdAt = Date()
        self.isCompleted = isCompleted
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
    
    var isAchieved: Bool {
        currentValue >= targetValue
    }
}

// MARK: - Streaks
struct Streaks: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var dailyStreak: Int = 0
    var weeklyStreak: Int = 0
    var monthlyStreak: Int = 0
}

// MARK: - Preferences
struct Preferences: Codable {
    var notificationsEnabled: Bool = true
    var focusAreas: [LifeDomain] = []
    var theme: String = "system"
    var autoDarkMode: Bool = false
    var language: String = "en"
}

// MARK: - Main User Model
class User: ObservableObject, Codable {
    @Published var id: UUID
    @Published var name: String
    @Published var email: String?
    @Published var hasCompletedOnboarding: Bool
    @Published var goals: [UserGoal]
    @Published var progress: UserProgress
    @Published var settings: UserSettings
    @Published var achievements: [Achievement]
    @Published var joinDate: Date
    @Published var subscription: AppSubscriptionInfo
    @Published var streaks: Streaks
    @Published var preferences: Preferences
    @Published var lifePoints: Int

    init(
        name: String,
        email: String? = nil,
        hasCompletedOnboarding: Bool = false,
        goals: [UserGoal] = [],
        progress: UserProgress = UserProgress(),
        settings: UserSettings = UserSettings(),
        achievements: [Achievement] = [],
        joinDate: Date = Date(),
        subscription: AppSubscriptionInfo = AppSubscriptionInfo(),
        streaks: Streaks = Streaks(),
        preferences: Preferences = Preferences(),
        lifePoints: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.goals = goals
        self.progress = progress
        self.settings = settings
        self.achievements = achievements
        self.joinDate = joinDate
        self.subscription = subscription
        self.streaks = streaks
        self.preferences = preferences
        self.lifePoints = lifePoints
    }
    
    var isPremium: Bool {
        subscription.isPremium
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, email, hasCompletedOnboarding, goals, progress, settings
        case achievements, joinDate, subscription, streaks, preferences, lifePoints
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "User"
        email = try container.decodeIfPresent(String.self, forKey: .email)
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        goals = try container.decodeIfPresent([UserGoal].self, forKey: .goals) ?? []
        progress = try container.decodeIfPresent(UserProgress.self, forKey: .progress) ?? UserProgress()
        settings = try container.decodeIfPresent(UserSettings.self, forKey: .settings) ?? UserSettings()
        achievements = try container.decodeIfPresent([Achievement].self, forKey: .achievements) ?? []
        joinDate = try container.decodeIfPresent(Date.self, forKey: .joinDate) ?? Date()
        subscription = try container.decodeIfPresent(AppSubscriptionInfo.self, forKey: .subscription) ?? AppSubscriptionInfo()
        streaks = try container.decodeIfPresent(Streaks.self, forKey: .streaks) ?? Streaks()
        preferences = try container.decodeIfPresent(Preferences.self, forKey: .preferences) ?? Preferences()
        lifePoints = try container.decodeIfPresent(Int.self, forKey: .lifePoints) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(goals, forKey: .goals)
        try container.encode(progress, forKey: .progress)
        try container.encode(settings, forKey: .settings)
        try container.encode(achievements, forKey: .achievements)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(subscription, forKey: .subscription)
        try container.encode(streaks, forKey: .streaks)
        try container.encode(preferences, forKey: .preferences)
        try container.encode(lifePoints, forKey: .lifePoints)
    }
}