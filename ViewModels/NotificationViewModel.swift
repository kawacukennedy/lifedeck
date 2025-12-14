import Foundation
import Combine

class NotificationViewModel: ObservableObject {
    @Published var notificationManager: NotificationManager
    @Published var user: User

    private var cancellables = Set<AnyCancellable>()

    init(notificationManager: NotificationManager, user: User) {
        self.notificationManager = notificationManager
        self.user = user
    }

    func scheduleDailyReminder() {
        let reminder = AppNotification(
            title: "Daily LifeDeck Check-in",
            message: "Don't forget to complete your daily coaching cards!",
            type: .dailyReminder,
            scheduledDate: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date(),
            userId: user.id
        )
        notificationManager.scheduleNotification(reminder)
    }

    func scheduleStreakMilestone() {
        if user.streaks.currentStreak > 0 && user.streaks.currentStreak % 7 == 0 {
            let milestone = AppNotification(
                title: "Streak Milestone! 🎉",
                message: "You've maintained a \(user.streaks.currentStreak)-day streak. Keep it up!",
                type: .streakMilestone,
                scheduledDate: Date(),
                userId: user.id
            )
            notificationManager.scheduleNotification(milestone)
        }
    }

    func scheduleProgressUpdate() {
        let progress = AppNotification(
            title: "Weekly Progress Update",
            message: "Check out your life improvements this week!",
            type: .progressUpdate,
            scheduledDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            userId: user.id
        )
        notificationManager.scheduleNotification(progress)
    }
}