//
//  WatchDashboardViewModel.swift
//  LifeDeckWatch Watch App
//
//  Created on 2024
//

import SwiftUI
import Combine

class WatchDashboardViewModel: ObservableObject {
    @Published var lifeScore: Int = 0
    @Published var currentStreak: Int = 0
    @Published var healthScore: Int = 0
    @Published var financeScore: Int = 0
    @Published var productivityScore: Int = 0
    @Published var mindfulnessScore: Int = 0
    @Published var dailyCards: [WatchCard] = []
    @Published var recentAchievements: [WatchAchievement] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupNotifications()
        loadLocalData()
    }

    func loadData() {
        // Request data from iOS app
        WatchDataManager.shared.sendMessageToPhone([
            "action": "getDashboardData"
        ]) { response in
            DispatchQueue.main.async {
                self.updateFromResponse(response)
            }
        }
    }

    func refreshData() {
        loadData()
    }

    func loadNewCards() {
        WatchDataManager.shared.sendMessageToPhone([
            "action": "loadDailyCards"
        ]) { response in
            DispatchQueue.main.async {
                if let cards = response["cards"] as? [[String: Any]] {
                    self.dailyCards = cards.compactMap { WatchCard.fromDict($0) }
                }
            }
        }
    }

    func completeCard(_ cardId: String) {
        WatchDataManager.shared.sendMessageToPhone([
            "action": "completeCard",
            "cardId": cardId
        ]) { response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool, success {
                    // Update local card status
                    if let index = self.dailyCards.firstIndex(where: { $0.id == cardId }) {
                        self.dailyCards[index].isCompleted = true
                    }
                    // Refresh dashboard data
                    self.loadData()
                }
            }
        }
    }

    func updateFromNotification(_ data: [String: Any]) {
        updateFromResponse(data)
    }

    private func updateFromResponse(_ response: [String: Any]) {
        if let progress = response["progress"] as? [String: Any] {
            lifeScore = calculateLifeScore(from: progress)
            currentStreak = progress["currentStreak"] as? Int ?? 0
            healthScore = progress["healthScore"] as? Int ?? 0
            financeScore = progress["financeScore"] as? Int ?? 0
            productivityScore = progress["productivityScore"] as? Int ?? 0
            mindfulnessScore = progress["mindfulnessScore"] as? Int ?? 0
        }

        if let cards = response["dailyCards"] as? [[String: Any]] {
            dailyCards = cards.compactMap { WatchCard.fromDict($0) }
        }

        if let achievements = response["recentAchievements"] as? [[String: Any]] {
            recentAchievements = achievements.compactMap { WatchAchievement.fromDict($0) }
        }

        // Update complication data
        let nextCardTitle = dailyCards.first(where: { !$0.isCompleted })?.title ?? "All cards complete!"
        WatchDataManager.shared.updateComplicationData(
            lifeScore: lifeScore,
            streak: currentStreak,
            nextCardTitle: nextCardTitle
        )
    }

    private func calculateLifeScore(from progress: [String: Any]) -> Int {
        let health = progress["healthScore"] as? Int ?? 0
        let finance = progress["financeScore"] as? Int ?? 0
        let productivity = progress["productivityScore"] as? Int ?? 0
        let mindfulness = progress["mindfulnessScore"] as? Int ?? 0

        return (health + finance + productivity + mindfulness) / 4
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .watchDataReceived)
            .sink { notification in
                if let data = notification.object as? [String: Any] {
                    self.updateFromResponse(data)
                }
            }
            .store(in: &cancellables)
    }

    private func loadLocalData() {
        // Load cached data from UserDefaults
        lifeScore = UserDefaults.standard.integer(forKey: "lifeScore")
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        healthScore = UserDefaults.standard.integer(forKey: "healthScore")
        financeScore = UserDefaults.standard.integer(forKey: "financeScore")
        productivityScore = UserDefaults.standard.integer(forKey: "productivityScore")
        mindfulnessScore = UserDefaults.standard.integer(forKey: "mindfulnessScore")
    }
}

// MARK: - Data Models

struct WatchCard: Identifiable {
    let id: String
    let title: String
    let domain: String
    var isCompleted: Bool

    static func fromDict(_ dict: [String: Any]) -> WatchCard? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let domain = dict["domain"] as? String else {
            return nil
        }

        return WatchCard(
            id: id,
            title: title,
            domain: domain,
            isCompleted: dict["isCompleted"] as? Bool ?? false
        )
    }
}

struct WatchAchievement: Identifiable {
    let id: String
    let title: String
    let description: String

    static func fromDict(_ dict: [String: Any]) -> WatchAchievement? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let description = dict["description"] as? String else {
            return nil
        }

        return WatchAchievement(id: id, title: title, description: description)
    }
}