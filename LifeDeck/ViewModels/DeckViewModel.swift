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

    func completeCard(_ card: CoachingCard) {
        // Mark card as completed
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].markCompleted()
        }
    }

    func dismissCard(_ card: CoachingCard) {
        // Mark card as dismissed
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].markDismissed()
        }
    }

    func snoozeCard(_ card: CoachingCard) {
        // Snooze card for later
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].snooze(until: Date().addingTimeInterval(24 * 60 * 60)) // 24 hours
        }
    }
}
