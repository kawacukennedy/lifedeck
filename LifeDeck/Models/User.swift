import Foundation
import SwiftUI

// MARK: - Life Domains
enum LifeDomain: String, CaseIterable, Identifiable {
    case health = "health"
    case finance = "finance" 
    case productivity = "productivity"
    case mindfulness = "mindfulness"
    
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
        case .productivity: return "brain.head.profile"
        case .mindfulness: return "leaf.fill"
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

// MARK: - User Goals
struct UserGoal: Codable, Identifiable {
    let id: UUID
    let domain: LifeDomain
    let description: String
    let targetValue: Double?
    let currentValue: Double
    let unit: String?
    
    init(domain: LifeDomain, description: String, targetValue: Double? = nil, currentValue: Double = 0, unit: String? = nil) {
        self.id = UUID()
        self.domain = domain
        self.description = description
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.unit = unit
    }
}

// MARK: - User Progress
struct UserProgress: Codable {
    var healthScore: Double = 0
    var financeScore: Double = 0
    var productivityScore: Double = 0
    var mindfulnessScore: Double = 0
    var lifeScore: Double = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lifePoints: Int = 0
    var totalCardsCompleted: Int = 0
    var lastActiveDate: Date?
    
    mutating func updateLifeScore() {
        lifeScore = (healthScore + financeScore + productivityScore + mindfulnessScore) / 4
    }
    
    func scoreForDomain(_ domain: LifeDomain) -> Double {
        switch domain {
        case .health: return healthScore
        case .finance: return financeScore
        case .productivity: return productivityScore
        case .mindfulness: return mindfulnessScore
        }
    }
    
    mutating func updateScore(for domain: LifeDomain, value: Double) {
        switch domain {
        case .health: healthScore = value
        case .finance: financeScore = value
        case .productivity: productivityScore = value
        case .mindfulness: mindfulnessScore = value
        }
        updateLifeScore()
    }
}

// MARK: - User Settings
struct UserSettings: Codable {
    var notificationsEnabled: Bool = true
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    var preferredDomains: [LifeDomain] = LifeDomain.allCases
    var maxDailyCards: Int = 5 // For free tier
    var soundEnabled: Bool = true
    var hapticEnabled: Bool = true
    var dataShareEnabled: Bool = false
    
    // Integration settings
    var healthKitEnabled: Bool = false
    var calendarEnabled: Bool = false
    var locationEnabled: Bool = false
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let pointsRequired: Int
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    let category: LifeDomain?
    
    init(title: String, description: String, icon: String, pointsRequired: Int, category: LifeDomain? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.pointsRequired = pointsRequired
        self.category = category
    }
}

// MARK: - User Model
class User: ObservableObject, Codable {
    @Published var id: UUID = UUID()
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var hasCompletedOnboarding: Bool = false
    @Published var goals: [UserGoal] = []
    @Published var progress: UserProgress = UserProgress()
    @Published var settings: UserSettings = UserSettings()
    @Published var achievements: [Achievement] = []
    @Published var joinDate: Date = Date()
    
    // Subscription status
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var subscriptionExpiryDate: Date?
    
    init() {
        setupDefaultAchievements()
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, email, hasCompletedOnboarding, goals, progress, settings, achievements, joinDate, subscriptionTier, subscriptionExpiryDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        hasCompletedOnboarding = try container.decode(Bool.self, forKey: .hasCompletedOnboarding)
        goals = try container.decode([UserGoal].self, forKey: .goals)
        progress = try container.decode(UserProgress.self, forKey: .progress)
        settings = try container.decode(UserSettings.self, forKey: .settings)
        achievements = try container.decode([Achievement].self, forKey: .achievements)
        joinDate = try container.decode(Date.self, forKey: .joinDate)
        subscriptionTier = try container.decode(SubscriptionTier.self, forKey: .subscriptionTier)
        subscriptionExpiryDate = try container.decodeIfPresent(Date.self, forKey: .subscriptionExpiryDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try container.encode(goals, forKey: .goals)
        try container.encode(progress, forKey: .progress)
        try container.encode(settings, forKey: .settings)
        try container.encode(achievements, forKey: .achievements)
        try container.encode(joinDate, forKey: .joinDate)
        try container.encode(subscriptionTier, forKey: .subscriptionTier)
        try container.encodeIfPresent(subscriptionExpiryDate, forKey: .subscriptionExpiryDate)
    }
    
    // MARK: - Methods
    func addGoal(_ goal: UserGoal) {
        goals.append(goal)
    }
    
    func updateProgress(for domain: LifeDomain, increment: Double) {
        progress.updateScore(for: domain, value: min(100, progress.scoreForDomain(domain) + increment))
    }
    
    func completeCard() {
        progress.totalCardsCompleted += 1
        progress.lifePoints += 10
        
        // Update streak
        let today = Calendar.current.startOfDay(for: Date())
        if let lastActive = progress.lastActiveDate,
           Calendar.current.startOfDay(for: lastActive) == Calendar.current.date(byAdding: .day, value: -1, to: today) {
            progress.currentStreak += 1
        } else if progress.lastActiveDate == nil || 
                  Calendar.current.startOfDay(for: progress.lastActiveDate!) != today {
            progress.currentStreak = 1
        }
        
        progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
        progress.lastActiveDate = Date()
        
        checkAchievements()
    }
    
    private func checkAchievements() {
        for index in achievements.indices {
            if !achievements[index].isUnlocked && progress.lifePoints >= achievements[index].pointsRequired {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
            }
        }
    }
    
    private func setupDefaultAchievements() {
        achievements = [
            Achievement(title: "First Steps", description: "Complete your first coaching card", icon: "star.fill", pointsRequired: 10),
            Achievement(title: "Week Strong", description: "Maintain a 7-day streak", icon: "flame.fill", pointsRequired: 70),
            Achievement(title: "Century Club", description: "Complete 100 coaching cards", icon: "trophy.fill", pointsRequired: 1000),
            Achievement(title: "Health Hero", description: "Complete 20 health cards", icon: "heart.fill", pointsRequired: 200, category: .health),
            Achievement(title: "Money Master", description: "Complete 20 finance cards", icon: "dollarsign.circle.fill", pointsRequired: 200, category: .finance),
            Achievement(title: "Productivity Pro", description: "Complete 20 productivity cards", icon: "brain.head.profile", pointsRequired: 200, category: .productivity),
            Achievement(title: "Mindful Maven", description: "Complete 20 mindfulness cards", icon: "leaf.fill", pointsRequired: 200, category: .mindfulness)
        ]
    }
    
    var isPremium: Bool {
        return subscriptionTier == .premium && (subscriptionExpiryDate == nil || subscriptionExpiryDate! > Date())
    }
    
    var dailyCardLimit: Int {
        return isPremium ? 50 : settings.maxDailyCards
    }
}

// MARK: - Extensions
extension LifeDomain: Codable {}
