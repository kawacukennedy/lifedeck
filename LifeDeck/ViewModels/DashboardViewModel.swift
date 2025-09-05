import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    
    init() {
        // Initialize dashboard data
    }
    
    func refreshData() {
        // TODO: Implement dashboard data refresh
    }
}
