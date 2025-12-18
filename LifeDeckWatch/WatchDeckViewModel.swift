//
//  WatchDeckViewModel.swift
//  LifeDeckWatch Watch App
//
//  Created on 2024
//

import SwiftUI
import Combine

class WatchDeckViewModel: ObservableObject {
    @Published var dailyCards: [WatchCard] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupNotifications()
    }

    func loadCards() {
        WatchDataManager.shared.sendMessageToPhone([
            "action": "getDailyCards"
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
                    // Remove completed card from local array
                    self.dailyCards.removeAll { $0.id == cardId }
                    // Provide haptic feedback
                    WKInterfaceDevice.current().play(.success)
                }
            }
        }
    }

    func dismissCard(_ cardId: String) {
        WatchDataManager.shared.sendMessageToPhone([
            "action": "dismissCard",
            "cardId": cardId
        ]) { response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool, success {
                    // Remove dismissed card from local array
                    self.dailyCards.removeAll { $0.id == cardId }
                    // Provide haptic feedback
                    WKInterfaceDevice.current().play(.failure)
                }
            }
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .watchDataReceived)
            .sink { notification in
                if let data = notification.object as? [String: Any],
                   let cards = data["dailyCards"] as? [[String: Any]] {
                    self.dailyCards = cards.compactMap { WatchCard.fromDict($0) }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Extended WatchCard Model

extension WatchCard {
    var domainColor: String {
        switch domain.lowercased() {
        case "health":
            return "green"
        case "finance":
            return "blue"
        case "productivity":
            return "orange"
        case "mindfulness":
            return "purple"
        default:
            return "gray"
        }
    }

    var actionText: String {
        // This would come from the card data, simplified for watch
        return "Complete this action"
    }

    var priority: String {
        // This would come from the card data
        return "MEDIUM"
    }
}