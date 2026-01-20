import Foundation
import SwiftUI

// MARK: - Coaching Card Model
class CoachingCard: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var title: String
    @Published var description: String
    @Published var domain: LifeDomain
    @Published var actionText: String
    @Published var difficulty: Double
    @Published var points: Int
    @Published var priority: CardPriority
    @Published var estimatedDuration: Duration
    @Published var isPremium: Bool
    @Published var aiGenerated: Bool
    @Published var createdDate: Date
    @Published var completedDate: Date?
    @Published var snoozedUntil: Date?
    @Published var tags: [String]
    @Published var impact: Double
    @Published var userNote: String?
    @Published var isBookmarked: Bool
    
    enum CardPriority: String, Codable, CaseIterable {
        case low, medium, high, critical
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium" 
            case .high: return "High"
            case .critical: return "Critical"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
    
    enum Duration: String, Codable, CaseIterable {
        case quick = "2 min"
        case short = "5 min"
        case standard = "10 min"
        case extended = "15 min"
        
        var minutes: Int {
            switch self {
            case .quick: return 2
            case .short: return 5
            case .standard: return 10
            case .extended: return 15
            }
        }
        
        var color: Color {
            switch self {
            case .quick: return .green
            case .short: return .blue
            case .standard: return .orange
            case .extended: return .red
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        domain: LifeDomain,
        actionText: String,
        difficulty: Double = 1.0,
        points: Int = 10,
        priority: CardPriority = .medium,
        estimatedDuration: Duration = .standard,
        isPremium: Bool = false,
        aiGenerated: Bool = true,
        tags: [String] = [],
        impact: Double = 5.0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.domain = domain
        self.actionText = actionText
        self.difficulty = difficulty
        self.points = points
        self.priority = priority
        self.estimatedDuration = estimatedDuration
        self.isPremium = isPremium
        self.aiGenerated = aiGenerated
        self.createdDate = Date()
        self.tags = tags
        self.impact = impact
        self.userNote = nil
        self.isBookmarked = false
    }
    
    // MARK: - Actions
    func markCompleted() {
        self.completedDate = Date()
    }
    
    func snooze() {
        self.snoozedUntil = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
    }
    
    func toggleBookmark() {
        self.isBookmarked.toggle()
    }
    
    func addUserNote(_ note: String) {
        self.userNote = note
    }
    
    // MARK: - Computed Properties
    var isCompleted: Bool {
        completedDate != nil
    }
    
    var isSnoozed: Bool {
        guard let snoozedUntil = snoozedUntil else { return false }
        return snoozedUntil > Date()
    }
    
    var isAvailable: Bool {
        !isCompleted && !isSnoozed
    }
    
    var domainColor: Color {
        domain.color
    }
    
    var domainIcon: String {
        domain.icon
    }
    
    var difficultyStars: String {
        let fullStars = Int(difficulty.rounded())
        return String(repeating: "⭐", count: min(fullStars, 5))
    }
    
    var timeEstimateDisplay: String {
        estimatedDuration.rawValue
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, title, description, domain, actionText, difficulty, points
        case priority, estimatedDuration, isPremium, aiGenerated
        case createdDate, completedDate, snoozedUntil, tags, impact
        case userNote, isBookmarked
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        domain = try container.decode(LifeDomain.self, forKey: .domain)
        actionText = try container.decode(String.self, forKey: .actionText)
        difficulty = try container.decode(Double.self, forKey: .difficulty)
        points = try container.decode(Int.self, forKey: .points)
        priority = try container.decode(CardPriority.self, forKey: .priority)
        estimatedDuration = try container.decode(Duration.self, forKey: .estimatedDuration)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        aiGenerated = try container.decode(Bool.self, forKey: .aiGenerated)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        completedDate = try container.decodeIfPresent(Date.self, forKey: .completedDate)
        snoozedUntil = try container.decodeIfPresent(Date.self, forKey: .snoozedUntil)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        impact = try container.decodeIfPresent(Double.self, forKey: .impact) ?? 5.0
        userNote = try container.decodeIfPresent(String.self, forKey: .userNote)
        isBookmarked = try container.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(domain, forKey: .domain)
        try container.encode(actionText, forKey: .actionText)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(points, forKey: .points)
        try container.encode(priority, forKey: .priority)
        try container.encode(estimatedDuration, forKey: .estimatedDuration)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(aiGenerated, forKey: .aiGenerated)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encodeIfPresent(completedDate, forKey: .completedDate)
        try container.encodeIfPresent(snoozedUntil, forKey: .snoozedUntil)
        try container.encode(tags, forKey: .tags)
        try container.encode(impact, forKey: .impact)
        try container.encodeIfPresent(userNote, forKey: .userNote)
        try container.encode(isBookmarked, forKey: .isBookmarked)
    }
}

// MARK: - Sample Cards Extension
extension CoachingCard {
    static let sampleCards: [CoachingCard] = [
        CoachingCard(
            title: "Morning Hydration",
            description: "Start your day with a full glass of water to kickstart your metabolism and hydrate your body.",
            domain: .health,
            actionText: "Drink 8oz of water right now",
            difficulty: 1.0,
            points: 5,
            priority: .low,
            estimatedDuration: .quick,
            tags: ["hydration", "morning", "health"]
        ),
        CoachingCard(
            title: "5-Minute Stretch",
            description: "Quick full-body stretch to improve circulation and flexibility.",
            domain: .health,
            actionText: "Complete 5-minute stretch routine",
            difficulty: 1.2,
            points: 8,
            priority: .medium,
            estimatedDuration: .quick,
            tags: ["stretch", "exercise", "flexibility"]
        ),
        CoachingCard(
            title: "Email Triage",
            description: "Process your inbox efficiently with the 2-minute rule.",
            domain: .productivity,
            actionText: "Triage 10 emails in 2 minutes",
            difficulty: 1.5,
            points: 12,
            priority: .high,
            estimatedDuration: .standard,
            tags: ["email", "productivity", "organization"]
        ),
        CoachingCard(
            title: "Gratitude Journal",
            description: "Write down three things you're grateful for today.",
            domain: .mindfulness,
            actionText: "Write 3 gratitudes in your journal",
            difficulty: 1.0,
            points: 7,
            priority: .medium,
            estimatedDuration: .short,
            tags: ["gratitude", "mindfulness", "journal"]
        ),
        CoachingCard(
            title: "Budget Review",
            description: "Quick review of today's spending and update your budget tracker.",
            domain: .finance,
            actionText: "Review and log today's expenses",
            difficulty: 1.3,
            points: 10,
            priority: .medium,
            estimatedDuration: .standard,
            isPremium: true,
            tags: ["budget", "finance", "review"]
        )
    ]
}