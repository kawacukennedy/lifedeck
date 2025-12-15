import SwiftUI

@main
struct LifeDeckWatchApp: App {
    @StateObject private var watchManager = WatchDataManager()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchDashboardView()
                    .environmentObject(watchManager)
            }
        }
    }
}