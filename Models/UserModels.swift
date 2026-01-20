import Foundation
import SwiftUI

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
        case .health:
            return healthScore
        case .finance:
            return financeScore
        case .productivity:
            return productivityScore
        case .mindfulness:
            return mindfulnessScore
        }
    }
    
    func updateScore(for domain: LifeDomain, score: Double) {
        switch domain.type {
        case .health:
            healthScore = score
        case .finance:
            financeScore = score
        case .productivity:
            productivityScore = score
        case .mindfulness:
            mindfulnessScore = score
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
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    var weeklyReportsEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var soundEnabled: Bool = true
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

// MARK: - Life Domain Extension
extension LifeDomain: Identifiable {
    var id: String { type.rawValue }
    
    var displayName: String {
        switch type {
        case .health:
            return "Health"
        case .finance:
            return "Finance"
        case .productivity:
            return "Productivity"
        case .mindfulness:
            return "Mindfulness"
        }
    }
    
    var icon: String {
        switch type {
        case .health:
            return "heart.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .productivity:
            return "checkmark.circle.fill"
        case .mindfulness:
            return "brain.head.profile"
        }
    }
    
    static var allCases: [LifeDomain] {
        return [
            LifeDomain(type: .health, score: 50, progress: 0.5, completedCards: 0, totalCards: 0),
            LifeDomain(type: .finance, score: 50, progress: 0.5, completedCards: 0, totalCards: 0),
            LifeDomain(type: .productivity, score: 50, progress: 0.5, completedCards: 0, totalCards: 0),
            LifeDomain(type: .mindfulness, score: 50, progress: 0.5, completedCards: 0, totalCards: 0)
        ]
    }
}

// MARK: - Color Extensions
extension Color {
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain.type {
        case .health:
            return .red
        case .finance:
            return .green
        case .productivity:
            return .blue
        case .mindfulness:
            return .purple
        }
    }
}