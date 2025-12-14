import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    init(user: User) {
        self.user = user
    }

    func updatePreferences(notificationsEnabled: Bool? = nil, focusAreas: [LifeDomainType]? = nil, theme: String? = nil) {
        if let notifications = notificationsEnabled {
            user.preferences.notificationsEnabled = notifications
        }
        if let areas = focusAreas {
            user.preferences.focusAreas = areas
        }
        if let theme = theme {
            user.preferences.theme = theme
        }
        saveUser()
    }

    func updateProfile(name: String, email: String?) {
        user.name = name
        user.email = email
        saveUser()
    }

    private func saveUser() {
        // In real app, save to UserDefaults or backend
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "user")
        }
    }

    func resetProgress() {
        user.lifeDomains = user.lifeDomains.map { domain in
            var newDomain = domain
            newDomain.score = 50
            newDomain.progress = 0.5
            newDomain.completedCards = 0
            return newDomain
        }
        user.streaks = Streaks(currentStreak: 0, longestStreak: 0, dailyStreak: 0, weeklyStreak: 0)
        user.lifePoints = 0
        saveUser()
    }
}