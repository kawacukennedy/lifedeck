import Foundation

enum CardAction: String, Codable {
    case complete
    case dismiss
    case snooze
}

struct CoachingCard: Identifiable, Codable {
    var id: UUID
    var text: String
    var domain: LifeDomainType
    var isPremium: Bool
    var aiGenerated: Bool
    var difficulty: Int // 1-5
    var estimatedTime: Int // minutes
    var tags: [String]
    var createdDate: Date
    var completedDate: Date?
    var action: CardAction?

    init(id: UUID = UUID(), text: String, domain: LifeDomainType, isPremium: Bool = false, aiGenerated: Bool = true, difficulty: Int = 1, estimatedTime: Int = 5, tags: [String] = [], createdDate: Date = Date()) {
        self.id = id
        self.text = text
        self.domain = domain
        self.isPremium = isPremium
        self.aiGenerated = aiGenerated
        self.difficulty = difficulty
        self.estimatedTime = estimatedTime
        self.tags = tags
        self.createdDate = createdDate
    }
}