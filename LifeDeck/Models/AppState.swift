import SwiftUI
import Foundation

// MARK: - Main App State Manager

@MainActor
@Observable
class AppState: ObservableObject {
    // MARK: - User State
    var user: User
    var subscriptionManager: SubscriptionManager
    
    // MARK: - Card State
    var dailyCards: [CoachingCard] = []
    var completedCards: [CoachingCard] = []
    var deferredCards: [CoachingCard] = []
    var currentCardIndex: Int = 0
    
    // MARK: - UI State
    var selectedTab: TabItem = .today
    var showingOnboarding: Bool = false
    var showingPaywall: Bool = false
    var isLoading: Bool = false
    
    // MARK: - System State
    var colorScheme: ColorScheme = .light
    var dynamicTypeSize: DynamicTypeSize = .medium
    var reduceMotion: Bool = false
    
    init() {
        // Load or create user
        if let savedUser = UserDefaultsManager.loadUser() {
            self.user = savedUser
        } else {
            self.user = User()
            self.showingOnboarding = true
        }
        
        // Initialize subscription manager
        self.subscriptionManager = SubscriptionManager()
        
        // Load saved state
        loadAppState()
        
        // Load daily cards
        Task {
            await loadDailyCards()
        }
    }
    
    // MARK: - Card Management
    
    func loadDailyCards() async {
        isLoading = true
        
        // Generate daily cards based on user preferences
        let generator = CardGenerator(user: user, subscription: subscriptionManager.subscription)
        dailyCards = await generator.generateDailyCards()
        
        isLoading = false
    }
    
    func completeCard(_ card: CoachingCard) {
        if let index = dailyCards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = dailyCards[index]
            updatedCard.completedDate = Date()
            updatedCard.action = .complete
            
            completedCards.append(updatedCard)
            dailyCards.remove(at: index)
            
            // Update user progress
            user.completeCard()
            
            // Add life points
            let points = calculatePoints(for: updatedCard)
            user.lifePoints += points
            
            // Update domain progress
            updateDomainProgress(for: updatedCard)
            
            // Trigger haptic feedback
            DesignSystem.Haptics.success()
            
            // Save state
            saveAppState()
        }
    }
    
    func dismissCard(_ card: CoachingCard) {
        if let index = dailyCards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = dailyCards[index]
            updatedCard.action = .dismiss
            
            dailyCards.remove(at: index)
            
            // Trigger haptic feedback
            DesignSystem.Haptics.selection()
            
            // Save state
            saveAppState()
        }
    }
    
    func snoozeCard(_ card: CoachingCard, until: Date = Date().addingTimeInterval( 3600)) {
        if let index = dailyCards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = dailyCards[index]
            updatedCard.action = .snooze
            
            deferredCards.append(updatedCard)
            dailyCards.remove(at: index)
            
            // Schedule notification
            NotificationManager.shared.scheduleCardNotification(for: updatedCard, at: until)
            
            // Trigger haptic feedback
            DesignSystem.Haptics.selection()
            
            // Save state
            saveAppState()
        }
    }
    
    // MARK: - Progress Tracking
    
    private func calculatePoints(for card: CoachingCard) -> Int {
        var points = 10 // Base points
        
        // Bonus points for difficulty
        points += card.difficulty * 2
        
        // Bonus points for premium cards
        if card.isPremium {
            points += 5
        }
        
        // Bonus points for time of day (morning completion)
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 6 && hour <= 10 {
            points += 3
        }
        
        return points
    }
    
    private func updateDomainProgress(for card: CoachingCard) {
        let scoreIncrease = Double(card.difficulty) * 2.0
        let currentScore = user.scoreForDomain(card.domain)
        let newScore = min(100, currentScore + scoreIncrease)
        
        user.updateDomainProgress(card.domain, score: newScore)
    }
    
    // MARK: - Tab Management
    
    func selectTab(_ tab: TabItem) {
        selectedTab = tab
        saveAppState()
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        user.hasCompletedOnboarding = true
        showingOnboarding = false
        UserDefaultsManager.saveUser(user)
    }
    
    // MARK: - State Persistence
    
    private func loadAppState() {
        if let data = UserDefaults.standard.data(forKey: "AppState"),
           let state = try? JSONDecoder().decode(AppStateData.self, from: data) {
            selectedTab = state.selectedTab
            currentCardIndex = state.currentCardIndex
        }
    }
    
    private func saveAppState() {
        let state = AppStateData(
            selectedTab: selectedTab,
            currentCardIndex: currentCardIndex
        )
        
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: "AppState")
        }
        
        // Save user data
        UserDefaultsManager.saveUser(user)
    }
    
    // MARK: - System Integration
    
    func updateSystemSettings(colorScheme: ColorScheme, dynamicTypeSize: DynamicTypeSize, reduceMotion: Bool) {
        self.colorScheme = colorScheme
        self.dynamicTypeSize = dynamicTypeSize
        self.reduceMotion = reduceMotion
        
        // Update user preferences
        user.preferences.theme = colorScheme == .dark ? .dark : (colorScheme == .light ? .light : .system)
    }
}

// MARK: - Tab Items

enum TabItem: String, CaseIterable, Identifiable {
    case today = "Today"
    case deck = "Deck"
    case insights = "Insights"
    case profile = "Profile"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .today: return "house.fill"
        case .deck: return "rectangle.stack.fill"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.fill"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .today: return "house.fill"
        case .deck: return "rectangle.stack.fill"
        case .insights: return "chart.line.uptrend.xyaxis"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - App State Data for Persistence

struct AppStateData: Codable {
    let selectedTab: TabItem
    let currentCardIndex: Int
}

// MARK: - Card Generator

@MainActor
class CardGenerator {
    private let user: User
    private let subscription: Subscription
    
    init(user: User, subscription: Subscription) {
        self.user = user
        self.subscription = subscription
    }
    
    func generateDailyCards() async -> [CoachingCard] {
        var cards: [CoachingCard] = []
        
        // Generate cards based on user focus areas
        let focusDomains = user.preferences.focusAreas.isEmpty ? LifeDomain.allCases : user.preferences.focusAreas
        
        for domain in focusDomains {
            let domainCardCount = subscription.hasFeature(.dailyCards) ? 3 : 2
            
            for i in 0..<domainCardCount {
                let card = generateCard(for: domain, index: i)
                cards.append(card)
            }
        }
        
        // Add some AI-personalized cards if premium
        if subscription.hasFeature(.aiPersonalization) {
            let personalizedCards = generatePersonalizedCards()
            cards.append(contentsOf: personalizedCards)
        }
        
        // Shuffle cards
        cards.shuffle()
        
        // Limit based on subscription
        let maxCards = subscription.hasFeature(.unlimitedCards) ? cards.count : 5
        return Array(cards.prefix(maxCards))
    }
    
    private func generateCard(for domain: LifeDomain, index: Int) -> CoachingCard {
        let templates = getCardTemplates(for: domain)
        let template = templates[index % templates.count]
        
        return CoachingCard(
            title: template.title,
            actionText: template.action,
            explanation: template.explanation,
            domain: domain,
            isPremium: template.isPremium,
            aiGenerated: true,
            difficulty: Int.random(in: 1...3),
            estimatedTime: Int.random(in: 5...15),
            tags: template.tags,
            priority: .medium,
            context: .daily
        )
    }
    
    private func generatePersonalizedCards() -> [CoachingCard] {
        // AI would generate personalized cards based on user behavior
        // For now, return some sample personalized cards
        return [
            CoachingCard(
                title: "Evening Reflection",
                actionText: "Take 5 minutes to journal about today's achievements",
                explanation: "Based on your productivity patterns, an evening reflection helps consolidate learning and improve tomorrow's performance.",
                domain: .mindfulness,
                isPremium: true,
                aiGenerated: true,
                difficulty: 2,
                estimatedTime: 5,
                tags: ["reflection", "evening", "mindfulness"],
                priority: .medium,
                context: .daily
            )
        ]
    }
    
    private func getCardTemplates(for domain: LifeDomain) -> [CardTemplate] {
        switch domain {
        case .health:
            return [
                CardTemplate(
                    title: "Morning Hydration",
                    action: "Drink a glass of water upon waking",
                    explanation: "Starting your day hydrated boosts metabolism and energy levels.",
                    isPremium: false,
                    tags: ["hydration", "morning", "wellness"]
                ),
                CardTemplate(
                    title: "5-Min Stretch",
                    action: "Take a quick stretching break",
                    explanation: "Regular stretching improves flexibility and reduces tension.",
                    isPremium: false,
                    tags: ["stretching", "movement", "break"]
                ),
                CardTemplate(
                    title: "Healthy Meal Planning",
                    action: "Plan one healthy meal for tomorrow",
                    explanation: "Meal planning supports better nutrition choices and reduces stress.",
                    isPremium: true,
                    tags: ["nutrition", "planning", "meal prep"]
                )
            ]
            
        case .finance:
            return [
                CardTemplate(
                    title: "Daily Expense Review",
                    action: "Review today's spending",
                    explanation: "Being aware of daily expenses helps identify spending patterns.",
                    isPremium: false,
                    tags: ["expenses", "tracking", "awareness"]
                ),
                CardTemplate(
                    title: "Savings Goal Check",
                    action: "Review progress toward your savings goal",
                    explanation: "Regular check-ins keep you motivated and on track.",
                    isPremium: false,
                    tags: ["savings", "goals", "progress"]
                ),
                CardTemplate(
                    title: "Investment Portfolio Review",
                    action: "Review your investment allocation",
                    explanation: "Regular portfolio reviews ensure alignment with your goals.",
                    isPremium: true,
                    tags: ["investing", "portfolio", "review"]
                )
            ]
            
        case .productivity:
            return [
                CardTemplate(
                    title: "Priority Task",
                    action: "Identify your most important task today",
                    explanation: "Focusing on high-impact tasks drives meaningful progress.",
                    isPremium: false,
                    tags: ["prioritization", "focus", "planning"]
                ),
                CardTemplate(
                    title: "Deep Work Session",
                    action: "Schedule 25 minutes of focused work",
                    explanation: "Deep work sessions boost productivity and quality.",
                    isPremium: false,
                    tags: ["deep work", "focus", "pomodoro"]
                ),
                CardTemplate(
                    title: "Email Triage",
                    action: "Process your inbox to zero",
                    explanation: "A clear inbox reduces mental clutter and improves focus.",
                    isPremium: true,
                    tags: ["email", "organization", "productivity"]
                )
            ]
            
        case .mindfulness:
            return [
                CardTemplate(
                    title: "Mindful Breathing",
                    action: "Take 3 deep breaths, focusing on each one",
                    explanation: "Conscious breathing calms the nervous system and reduces stress.",
                    isPremium: false,
                    tags: ["breathing", "stress", "mindfulness"]
                ),
                CardTemplate(
                    title: "Gratitude Moment",
                    action: "Think of three things you're grateful for",
                    explanation: "Gratitude practice improves mood and overall wellbeing.",
                    isPremium: false,
                    tags: ["gratitude", "positivity", "mindfulness"]
                ),
                CardTemplate(
                    title: "Meditation Session",
                    action: "Take 10 minutes for guided meditation",
                    explanation: "Regular meditation improves focus and emotional regulation.",
                    isPremium: true,
                    tags: ["meditation", "focus", "stress reduction"]
                )
            ]
        }
    }
}

// MARK: - Card Template

struct CardTemplate {
    let title: String
    let action: String
    let explanation: String
    let isPremium: Bool
    let tags: [String]
}