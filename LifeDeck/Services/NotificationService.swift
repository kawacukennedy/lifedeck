import Foundation
import UserNotifications
import Combine

// MARK: - Notification Service
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Request Permissions
    func requestNotificationPermissions() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Error requesting notification permissions: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Daily Reminder
    func scheduleDailyReminder(at date: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Cards Ready"
        content.body = "Your personalized coaching cards are ready for today!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            } else {
                print("Daily reminder scheduled successfully")
            }
        }
    }
    
    // MARK: - Schedule Card Completion Reminder
    func scheduleCardCompletionReminder(for domain: LifeDomain) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Great job! 🎉"
        content.body = "You've completed a \(domain.displayName) card! Keep up the great work."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "card_completion_\(domain.rawValue)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling completion reminder: \(error)")
            } else {
                print("Completion reminder scheduled successfully")
            }
        }
    }
    
    // MARK: - Schedule Streak Reminder
    func scheduleStreakReminder(streakLength: Int) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Active!"
        content.body = "You're on a \(streakLength)-day streak! Don't break the chain."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error)")
            } else {
                print("Streak reminder scheduled successfully")
            }
        }
    }
    
    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("All notifications cancelled")
    }
    
    // MARK: - Get Notification Settings
    func getNotificationSettings() async -> UNNotificationSettings {
        let center = UNUserNotificationCenter.current()
        return await center.notificationSettings()
    }
}

// MARK: - Notification Categories
extension NotificationService {
    func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Mark Complete Action
        let completeAction = UNNotificationAction(
            identifier: "MARK_COMPLETE",
            title: "Mark Complete",
            options: []
        )
        
        // Snooze Action
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "DAILY_CARD_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: []
        )
        
        center.setNotificationCategories([category])
    }
}