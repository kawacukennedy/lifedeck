import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var user: User
    @Published var lifeScore: Double = 0
    @Published var recentCards: [CoachingCard] = []
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    init(user: User) {
        self.user = user
        calculateLifeScore()
        loadRecentCards()
    }

    func calculateLifeScore() {
        let domainScores = user.lifeDomains.map { $0.score }
        lifeScore = domainScores.reduce(0, +) / Double(domainScores.count)
    }

    func loadRecentCards() {
        // Mock data for now
        recentCards = [
            CoachingCard(text: "Drink 8 glasses of water today", domain: .health),
            CoachingCard(text: "Review your monthly budget", domain: .finance),
            CoachingCard(text: "Plan your top 3 priorities", domain: .productivity),
            CoachingCard(text: "Meditate for 5 minutes", domain: .mindfulness)
        ]
    }

    func updateDomainProgress(domain: LifeDomainType, progress: Double) {
        if let index = user.lifeDomains.firstIndex(where: { $0.type == domain }) {
            user.lifeDomains[index].progress = progress
            user.lifeDomains[index].score = progress * 100
            calculateLifeScore()
        }
    }
}