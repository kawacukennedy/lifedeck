import Foundation

enum LifeDomainType: String, Codable {
    case health
    case finance
    case productivity
    case mindfulness
}

struct LifeDomain: Codable {
    var type: LifeDomainType
    var score: Double // 0-100
    var progress: Double // 0-1
    var completedCards: Int
    var totalCards: Int
}

struct Streaks: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var dailyStreak: Int
    var weeklyStreak: Int
}

struct Preferences: Codable {
    var notificationsEnabled: Bool
    var focusAreas: [LifeDomainType]
    var theme: String // light, dark
}

struct User: Codable {
    var id: UUID
    var name: String
    var email: String?
    var subscription: Subscription
    var lifeDomains: [LifeDomain]
    var streaks: Streaks
    var preferences: Preferences
    var lifePoints: Int
    var joinedDate: Date

    init(id: UUID = UUID(), name: String, email: String? = nil, subscription: Subscription = .free, lifeDomains: [LifeDomain] = [], streaks: Streaks = Streaks(currentStreak: 0, longestStreak: 0, dailyStreak: 0, weeklyStreak: 0), preferences: Preferences = Preferences(notificationsEnabled: true, focusAreas: [], theme: "system"), lifePoints: Int = 0, joinedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.subscription = subscription
        self.lifeDomains = lifeDomains.isEmpty ? [
            LifeDomain(type: .health, score: 50, progress: 0.5, completedCards: 0, totalCards: 0),
            LifeDomain(type: .finance, score: 50, progress: 0.5, completedCards: 0, totalCards: 0),
            LifeDomain(type: .productivity, score: 50, progress: 0.5, completedCards: 0, totalCards: 0),
            LifeDomain(type: .mindfulness, score: 50, progress: 0.5, completedCards: 0, totalCards: 0)
        ] : lifeDomains
        self.streaks = streaks
        self.preferences = preferences
        self.lifePoints = lifePoints
        self.joinedDate = joinedDate
    }
}