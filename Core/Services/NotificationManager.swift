import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Manager
class NotificationManager: NSObject, ObservableObject {
    @Published var hasPermission: Bool = false
    @Published var notificationSettings: UNNotificationSettings?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermissions()
    }
    
    // MARK: - Permission Management
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasPermission = granted
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func checkPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationSettings = settings
                self?.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Local Notifications
    func scheduleDailyReminder(time: Date) {
        guard hasPermission else {
            requestPermissions()
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for your daily cards!"
        content.body = "Complete your LifeDeck cards to continue building momentum."
        content.sound = .default
        content.badge = 1
        
        // Create date components for specified time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // Create a trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleCardReminder(title: String, body: String, delay: TimeInterval = 3600) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling card reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func showLocalNotification(title: String, body: String) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleStreakReminder(currentStreak: Int) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🔥 Keep it going!"
        content.body = "You're on a \(currentStreak)-day streak! Complete your cards to maintain your momentum."
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false) // 30 minutes
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleWeeklyReport(dayOfWeek: Int = 1) { // 1 = Sunday
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Progress Report"
        content.body = "Check out your LifeDeck progress for this week!"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_REPORT"
        
        var components = DateComponents()
        components.weekday = dayOfWeek
        components.hour = 10 // 10 AM
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_report",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Notification Management
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getScheduledNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Badge Management
    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func clearBadge() {
        updateBadgeCount(0)
    }
    
    // MARK: - Notification Categories
    func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_CARD",
            title: "Complete",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_CARD",
            title: "Snooze",
            options: []
        )
        
        let cardCategory = UNNotificationCategory(
            identifier: "CARD_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let viewAction = UNNotificationAction(
            identifier: "VIEW_REPORT",
            title: "View Report",
            options: []
        )
        
        let reportCategory = UNNotificationCategory(
            identifier: "WEEKLY_REPORT",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([cardCategory, reportCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Show notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification actions
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.actionIdentifier
        let requestIdentifier = response.notification.request.identifier
        
        switch identifier {
        case "COMPLETE_CARD":
            // Handle card completion
            NotificationCenter.default.post(name: .completeCardFromNotification, object: nil)
        case "SNOOZE_CARD":
            // Handle card snoozing
            NotificationCenter.default.post(name: .snoozeCardFromNotification, object: nil)
        case "VIEW_REPORT":
            // Navigate to analytics
            NotificationCenter.default.post(name: .showAnalytics, object: nil)
        case UNNotificationDefaultActionIdentifier:
            // User tapped notification
            handleNotificationTap(requestIdentifier)
        default:
            break
        }
        
        completionHandler()
    }
    
    private func handleNotificationTap(_ identifier: String) {
        switch identifier {
        case "daily_reminder":
            NotificationCenter.default.post(name: .showDeck, object: nil)
        case "weekly_report":
            NotificationCenter.default.post(name: .showAnalytics, object: nil)
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let completeCardFromNotification = Notification.Name("completeCardFromNotification")
    static let snoozeCardFromNotification = Notification.Name("snoozeCardFromNotification")
    static let showDeck = Notification.Name("showDeck")
    static let showAnalytics = Notification.Name("showAnalytics")
}