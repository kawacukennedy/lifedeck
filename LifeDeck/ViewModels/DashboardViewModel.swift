import SwiftUI

// MARK: - Dashboard View Model
class DashboardViewModel: ObservableObject {
    @Published var lifeScore = 75.0
    @Published var recentActivities: [String] = []
    
    func refreshData() {
        // Refresh data from user progress
        recentActivities = [
            "Completed Health card",
            "Extended streak to 5 days",
            "Reached Productivity goal",
            "Earned 50 life points"
        ]
    }
}