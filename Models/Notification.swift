import Foundation

struct AppNotification: Identifiable, Codable {
    var id: UUID
    var title: String
    var message: String
    var type: NotificationType
    var scheduledDate: Date
    var isDelivered: Bool
    var userId: UUID

    init(id: UUID = UUID(), title: String, message: String, type: NotificationType, scheduledDate: Date, userId: UUID) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.scheduledDate = scheduledDate
        self.isDelivered = false
        self.userId = userId
    }
}

enum NotificationType: String, Codable {
    case dailyReminder
    case streakMilestone
    case progressUpdate
    case premiumOffer
    case motivational
}