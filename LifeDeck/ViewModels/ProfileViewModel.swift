import SwiftUI

// MARK: - Profile View Model
class ProfileViewModel: ObservableObject {
    @Published var notificationsEnabled = true
    @Published var weeklyReportsEnabled = true
    @Published var hapticsEnabled = true
    @Published var soundEnabled = true
    
    func updateSettings() {
        // Save settings implementation
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(weeklyReportsEnabled, forKey: "weeklyReportsEnabled")
        UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
    }
}