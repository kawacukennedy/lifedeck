import Foundation
import SwiftUI

@MainActor
class DeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let apiService = APIService.shared

    init() {
        Task {
            await loadDailyCards()
        }
    }

    func loadDailyCards() async {
        isLoading = true
        error = nil

        do {
            cards = try await apiService.fetchDailyCards()
        } catch {
            self.error = error
            // Fallback to sample cards
            cards = SampleCards.allSampleCards()
        }

        isLoading = false
    }

    func refreshCards() async {
        await loadDailyCards()
    }

    func completeCard(_ card: CoachingCard) async {
        do {
            try await apiService.completeCard(card.id.uuidString)
            // Update local state
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].markCompleted()
            }
        } catch {
            self.error = error
        }
    }

    func dismissCard(_ card: CoachingCard) async {
        do {
            try await apiService.dismissCard(card.id.uuidString)
            // Remove from local state
            cards.removeAll { $0.id == card.id }
        } catch {
            self.error = error
        }
    }

    func snoozeCard(_ card: CoachingCard) async {
        let snoozeUntil = Date().addingTimeInterval(24 * 60 * 60) // 24 hours
        do {
            try await apiService.snoozeCard(card.id.uuidString, until: snoozeUntil)
            // Update local state
            if let index = cards.firstIndex(where: { $0.id == card.id }) {
                cards[index].snooze(until: snoozeUntil)
            }
        } catch {
            self.error = error
        }
    }
}
