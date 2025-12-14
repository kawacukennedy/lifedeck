import SwiftUI

let appVersion = "1.0.0"
let appBuild = "1"

@main
struct LifeDeckApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding() {
                ContentView()
                    .environmentObject(subscriptionManager)
            } else {
                OnboardingView()
            }
        }
    }

    private func hasCompletedOnboarding() -> Bool {
        UserDefaults.standard.data(forKey: "user") != nil
    }
}