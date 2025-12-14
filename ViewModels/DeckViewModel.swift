import Foundation
import Combine

class DeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var currentCardIndex: Int = 0
    @Published var isLoading = false
    @Published var user: User

    private var cancellables = Set<AnyCancellable>()

    init(user: User) {
        self.user = user
        loadCards()
    }

    func loadCards() {
        isLoading = true
        // Mock data - in real app, fetch from API
        cards = [
            CoachingCard(text: "Take a 10-minute walk outside", domain: .health, difficulty: 2, estimatedTime: 10),
            CoachingCard(text: "Save $5 today by skipping coffee", domain: .finance, difficulty: 1, estimatedTime: 1),
            CoachingCard(text: "Write down 3 things you're grateful for", domain: .productivity, difficulty: 1, estimatedTime: 5),
            CoachingCard(text: "Practice deep breathing for 2 minutes", domain: .mindfulness, difficulty: 1, estimatedTime: 2),
            CoachingCard(text: "Read 10 pages of a non-fiction book", domain: .productivity, difficulty: 3, estimatedTime: 15),
            CoachingCard(text: "Call a friend you haven't spoken to in a while", domain: .mindfulness, difficulty: 2, estimatedTime: 20)
        ]
        isLoading = false
    }

    func completeCard(_ card: CoachingCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].action = .complete
            cards[index].completedDate = Date()
            updateUserProgress(for: card)
            updateStreak()
        }
        nextCard()
    }

    func dismissCard(_ card: CoachingCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].action = .dismiss
        }
        nextCard()
    }

    func snoozeCard(_ card: CoachingCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].action = .snooze
        }
        nextCard()
    }

    private func nextCard() {
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
        } else {
            // Load more cards or show completion
            loadCards()
            currentCardIndex = 0
        }
    }

    private func updateUserProgress(for card: CoachingCard) {
        if let index = user.lifeDomains.firstIndex(where: { $0.type == card.domain }) {
            user.lifeDomains[index].completedCards += 1
            user.lifeDomains[index].progress += 0.1 // Increment progress
            user.lifeDomains[index].progress = min(user.lifeDomains[index].progress, 1.0)
            user.lifeDomains[index].score = user.lifeDomains[index].progress * 100
        }
        user.lifePoints += card.difficulty * 10
        saveUser()
    }

    private func updateStreak() {
        user.streaks.currentStreak += 1
        user.streaks.longestStreak = max(user.streaks.longestStreak, user.streaks.currentStreak)
        user.streaks.dailyStreak += 1
        saveUser()
    }

    private func saveUser() {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "user")
        }
    }

    var currentCard: CoachingCard? {
        cards.indices.contains(currentCardIndex) ? cards[currentCardIndex] : nil
    }
}