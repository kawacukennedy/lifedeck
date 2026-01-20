import SwiftUI

@main
struct LifeDeckApp: App {
    @StateObject private var user = User(name: "")
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(user)
                .environmentObject(subscriptionManager)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.setupNotificationCategories()
                }
        }
    }
}