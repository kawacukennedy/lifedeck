import Foundation
import SwiftUI

// MARK: - Basic Types
enum LifeDomainType: String, Codable, CaseIterable {
    case health, finance, productivity, mindfulness
    
    var displayName: String {
        switch self {
        case .health: return "Health"
        case .finance: return "Finance"
        case .productivity: return "Productivity"
        case .mindfulness: return "Mindfulness"
        }
    }
}

struct LifeDomain: Codable, Identifiable {
    let type: LifeDomainType
    var score: Double
    var progress: Double
    var completedCards: Int
    var totalCards: Int
    
    var id: String { type.rawValue }
    
    var displayName: String { type.displayName }
    
    var icon: String {
        switch type {
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .productivity: return "checkmark.circle.fill"
        case .mindfulness: return "brain.head.profile"
        }
    }
    
    static var allCases: [LifeDomain] {
        return LifeDomainType.allCases.map { LifeDomain(type: $0, score: 50, progress: 0.5, completedCards: 0, totalCards: 0) }
    }
}

struct Streaks: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var dailyStreak: Int = 0
    var weeklyStreak: Int = 0
}

struct Preferences: Codable {
    var notificationsEnabled: Bool = true
    var focusAreas: [LifeDomainType] = []
    var theme: String = "system"
}

// MARK: - Subscription Types
enum SubscriptionTier: String, Codable, CaseIterable {
    case free, premium
}

enum SubscriptionStatus: String, Codable, CaseIterable {
    case notSubscribed, active, expired, cancelled, pendingRenewal, inGracePeriod
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
    
    var isActive: Bool {
        switch status {
        case .active, .pendingRenewal, .inGracePeriod:
            return true
        case .notSubscribed, .expired, .cancelled:
            return false
        }
    }
    
    var isPremium: Bool {
        return tier == .premium && isActive
    }
}

// MARK: - User Goal
struct UserGoal: Codable, Identifiable {
    let id = UUID()
    let domain: LifeDomainType
    let description: String
    let targetValue: Int
    var currentValue: Int
    let unit: String
    let createdAt: Date
    var isCompleted: Bool
    
    init(domain: LifeDomainType, description: String, targetValue: Int, currentValue: Int = 0, unit: String, isCompleted: Bool = false) {
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

// MARK: - User Progress
class UserProgress: ObservableObject, Codable {
    @Published var healthScore: Double = 0
    @Published var financeScore: Double = 0
    @Published var productivityScore: Double = 0
    @Published var mindfulnessScore: Double = 0
    @Published var lifeScore: Double = 0
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
        switch domain.type {
        case .health: return healthScore
        case .finance: return financeScore
        case .productivity: return productivityScore
        case .mindfulness: return mindfulnessScore
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case healthScore, financeScore, productivityScore, mindfulnessScore
        case lifeScore, currentStreak, longestStreak, lifePoints, totalCardsCompleted
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        healthScore = try container.decodeIfPresent(Double.self, forKey: .healthScore) ?? 0
        financeScore = try container.decodeIfPresent(Double.self, forKey: .financeScore) ?? 0
        productivityScore = try container.decodeIfPresent(Double.self, forKey: .productivityScore) ?? 0
        mindfulnessScore = try container.decodeIfPresent(Double.self, forKey: .mindfulnessScore) ?? 0
        lifeScore = try container.decodeIfPresent(Double.self, forKey: .lifeScore) ?? 0
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
    var focusAreas: [LifeDomainType] = []
    var theme: String = "system"
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let unlockedAt: Date?
    let category: LifeDomainType?
    
    init(title: String, description: String, iconName: String, unlockedAt: Date? = nil, category: LifeDomainType? = nil) {
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

// MARK: - App User Model
class AppUser: ObservableObject, Codable {
    @Published var id: UUID = UUID()
    @Published var name: String
    @Published var email: String?
    @Published var hasCompletedOnboarding: Bool = false
    @Published var goals: [UserGoal] = []
    @Published var progress: UserProgress
    @Published var settings: UserSettings
    @Published var achievements: [Achievement] = []
    @Published var joinDate: Date = Date()
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var subscriptionExpiryDate: Date?
    @Published var subscription: AppSubscriptionInfo
    @Published var lifeDomains: [LifeDomain]
    @Published var streaks: Streaks
    @Published var preferences: Preferences
    @Published var lifePoints: Int = 0

    init(
        name: String, 
        email: String? = nil,
        hasCompletedOnboarding: Bool = false,
        goals: [UserGoal] = [],
        progress: UserProgress = UserProgress(),
        settings: UserSettings = UserSettings(),
        achievements: [Achievement] = [],
        joinDate: Date = Date(),
        subscriptionTier: SubscriptionTier = .free,
        subscriptionExpiryDate: Date? = nil,
        subscription: AppSubscriptionInfo = AppSubscriptionInfo(),
        lifeDomains: [LifeDomain] = [],
        streaks: Streaks = Streaks(),
        preferences: Preferences = Preferences(),
        lifePoints: Int = 0
    ) {
        self.name = name
        self.email = email
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.goals = goals
        self.progress = progress
        self.settings = settings
        self.achievements = achievements
        self.joinDate = joinDate
        self.subscriptionTier = subscriptionTier
        self.subscriptionExpiryDate = subscriptionExpiryDate
        self.subscription = subscription
        self.lifeDomains = lifeDomains.isEmpty ? LifeDomain.allCases : lifeDomains
        self.streaks = streaks
        self.preferences = preferences
        self.lifePoints = lifePoints
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, hasCompletedOnboarding, goals, progress, settings
        case achievements, joinDate, subscriptionTier, subscriptionExpiryDate
        case subscription, lifeDomains, streaks, preferences, lifePoints
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        goals = try container.decodeIfPresent([UserGoal].self, forKey: .goals) ?? []
        progress = try container.decodeIfPresent(UserProgress.self, forKey: .progress) ?? UserProgress()
        settings = try container.decodeIfPresent(UserSettings.self, forKey: .settings) ?? UserSettings()
        achievements = try container.decodeIfPresent([Achievement].self, forKey: .achievements) ?? []
        joinDate = try container.decodeIfPresent(Date.self, forKey: .joinDate) ?? Date()
        subscriptionTier = try container.decodeIfPresent(SubscriptionTier.self, forKey: .subscriptionTier) ?? .free
        subscriptionExpiryDate = try container.decodeIfPresent(Date.self, forKey: .subscriptionExpiryDate)
        subscription = try container.decodeIfPresent(AppSubscriptionInfo.self, forKey: .subscription) ?? AppSubscriptionInfo()
        lifeDomains = try container.decodeIfPresent([LifeDomain].self, forKey: .lifeDomains) ?? LifeDomain.allCases
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
        try container.encode(subscriptionTier, forKey: .subscriptionTier)
        try container.encodeIfPresent(subscriptionExpiryDate, forKey: .subscriptionExpiryDate)
        try container.encode(subscription, forKey: .subscription)
        try container.encode(lifeDomains, forKey: .lifeDomains)
        try container.encode(streaks, forKey: .streaks)
        try container.encode(preferences, forKey: .preferences)
        try container.encode(lifePoints, forKey: .lifePoints)
    }
}

// MARK: - Color Extensions
extension Color {
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain.type {
        case .health: return .red
        case .finance: return .green
        case .productivity: return .blue
        case .mindfulness: return .purple
        }
    }
}