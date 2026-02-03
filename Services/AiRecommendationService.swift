import Foundation

/**
 * AI Recommendation Service
 * Bridges the gap between the mobile client and the AI backend for card generation.
 */
class AiRecommendationService {
    static let shared = AiRecommendationService()
    
    private init() {}
    
    /**
     * Generates a set of daily micro-action cards tailored to the user's profile and goals.
     */
    func generateDailyCards(for user: User) async throws -> [CoachingCard] {
        // In a production environment, this would call the /v1/cards/daily endpoint
        // which then calls the OpenAI API.
        
        // Simulating API latency
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let domains = LifeDomain.allCases
        
        return domains.map { domain in
            CoachingCard(
                title: getTitleForDomain(domain),
                description: getDescriptionForDomain(domain),
                domain: domain,
                actionText: getActionForDomain(domain),
                difficulty: Double.random(in: 0.8...1.5),
                points: Int.random(in: 10...20),
                priority: .medium,
                estimatedDuration: .standard,
                isPremium: domain == .finance, // Mock one as premium
                aiGenerated: true
            )
        }
    }
    
    private func getTitleForDomain(_ domain: LifeDomain) -> String {
        switch domain {
        case .health: return ["Mindful Movement", "Hydration Goal", "Posture Alignment"].randomElement()!
        case .finance: return ["Budget Pulse", "Expense Log", "Savings Check"].randomElement()!
        case .productivity: return ["Deep Work Sprint", "Inbox Zero", "Focus Session"].randomElement()!
        case .mindfulness: return ["Breathing Space", "Gratitude Note", "Silence Minute"].randomElement()!
        }
    }
    
    private func getDescriptionForDomain(_ domain: LifeDomain) -> String {
        return "AI-personalized \(domain.displayName) action based on your recent activity and goals."
    }
    
    private func getActionForDomain(_ domain: LifeDomain) -> String {
        switch domain {
        case .health: return ["Drink 500ml of water", "Do 5 desk stretches", "Take a 5-minute walk"].randomElement()!
        case .finance: return ["Log your morning expenses", "Review your weekly savings goal", "Check for recurring subscriptions"].randomElement()!
        case .productivity: return ["Clear 10 unread emails", "Plan your top 3 tasks for today", "Spend 25m on your main project"].randomElement()!
        case .mindfulness: return ["Take 10 deep breaths", "Write 1 thing you're grateful for", "Sit still for 1 minute"].randomElement()!
        }
    }
}
