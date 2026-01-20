import Foundation
import SwiftUI

// MARK: - Deck View Model
class DeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var currentCardIndex = 0
    @Published var isLoading = true
    @Published var dragOffset: CGSize = .zero
    @Published var dragRotation: Angle = .zero
    
    func loadDailyCards() {
        isLoading = true
        
        Task {
            do {
                // Simulate AI card generation
                let generatedCards = try await generateAICards()
                
                await MainActor.run {
                    self.cards = generatedCards
                    self.isLoading = false
                    self.currentCardIndex = 0
                }
            } catch {
                await MainActor.run {
                    // Fallback to sample cards
                    self.cards = CoachingCard.sampleCards
                    self.isLoading = false
                    self.currentCardIndex = 0
                }
            }
        }
    }
    
    func handleSwipeGesture(_ value: DragGesture.Value, completion: @escaping (Bool) -> Void) {
        let threshold: CGFloat = 80
        
        withAnimation(DesignSystem.Animation.cardSwipe) {
            if value.translation.x > threshold {
                // Swipe right - complete card
                completeCard(at: currentCardIndex)
            } else if value.translation.x < -threshold {
                // Swipe left - dismiss card
                dismissCard(at: currentCardIndex)
            } else if value.translation.y < -threshold {
                // Swipe up - snooze card
                snoozeCard(at: currentCardIndex)
            }
            
            // Reset animations
            dragOffset = .zero
            dragRotation = .zero
        }
    }
    
    private func completeCard(at index: Int) {
        guard index < cards.count else { return }
        
        let card = cards[index]
        card.markCompleted()
        
        // Update user progress (this would normally be handled by parent view)
        // For now, just advance to next card
        withAnimation(DesignSystem.Animation.cardSwipe) {
            currentCardIndex += 1
        }
        
        // Show completion feedback
        NotificationCenter.default.post(name: .cardCompleted, object: card)
    }
    
    private func dismissCard(at index: Int) {
        guard index < cards.count else { return }
        
        withAnimation(DesignSystem.Animation.cardSwipe) {
            currentCardIndex += 1
        }
    }
    
    private func snoozeCard(at index: Int) {
        guard index < cards.count else { return }
        
        let card = cards[index]
        card.snooze()
        
        // Move card to end after 2 hours
        DispatchQueue.main.asyncAfter(deadline: .now() + 7200) {
            // Reshow snoozed card
            cards.append(card)
        }
        
        withAnimation(DesignSystem.Animation.cardSwipe) {
            currentCardIndex += 1
        }
    }
    
    private func generateAICards() async throws -> [CoachingCard] {
        // Simulate AI card generation with delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        let domains = LifeDomain.allCases
        var cards: [CoachingCard] = []
        
        for domain in domains {
            let card = CoachingCard(
                title: generateAICardTitle(for: domain),
                description: generateAICardDescription(for: domain),
                domain: domain,
                actionText: generateAICardAction(for: domain),
                difficulty: Double.random(in: 0.5...1.5),
                points: Int.random(in: 5...15),
                priority: .medium,
                estimatedDuration: .standard,
                aiGenerated: true
            )
            cards.append(card)
        }
        
        return cards
    }
    
    private func generateAICardTitle(for domain: LifeDomain) -> String {
        switch domain {
        case .health:
            return ["Mindful Movement", "Hydration Boost", "Healthy Snack Choice", "Posture Check"].randomElement() ?? "Health Focus"
        case .finance:
            return ["Daily Budget Review", "Expense Tracking", "Savings Opportunity", "Bill Organization"].randomElement() ?? "Finance Focus"
        case .productivity:
            return ["Deep Work Session", "Priority Setting", "Email Zero", "Meeting Preparation"].randomElement() ?? "Productivity Focus"
        case .mindfulness:
            return ["Breathing Exercise", "Gratitude Practice", "Mindful Moment", "Stress Check-in"].randomElement() ?? "Mindfulness Focus"
        }
    }
    
    private func generateAICardDescription(for domain: LifeDomain) -> String {
        switch domain {
        case .health:
            return "AI analysis suggests this action based on your recent activity patterns and goals."
        case .finance:
            return "Personalized recommendation based on your spending habits and financial objectives."
        case .productivity:
            return "Optimized for your current energy levels and task completion patterns."
        case .mindfulness:
            return "Tailored to your stress indicators and recent emotional patterns."
        }
    }
    
    private func generateAICardAction(for domain: LifeDomain) -> String {
        switch domain {
        case .health:
            return "Complete this health-focused activity"
        case .finance:
            return "Review and optimize your finances"
        case .productivity:
            return "Execute this productivity task"
        case .mindfulness:
            return "Practice this mindfulness exercise"
        }
    }
}

// MARK: - Dashboard View Model
class DashboardViewModel: ObservableObject {
    @Published var lifeScoreTrend: TrendDirection = .none
    @Published var recentActivities: [ActivityItem] = []
    
    enum TrendDirection {
        case up, down, none
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .none: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return DesignSystem.Colors.success
            case .down: return DesignSystem.Colors.error
            case .none: return DesignSystem.Colors.textSecondary
            }
        }
        
        var text: String {
            switch self {
            case .up: return "+5%"
            case .down: return "-3%"
            case .none: return "0%"
            }
        }
    }
    
    init() {
        loadRecentActivities()
        calculateTrend()
    }
    
    func refreshData() {
        loadRecentActivities()
        calculateTrend()
    }
    
    private func loadRecentActivities() {
        // Generate sample activities for demo
        let domains = LifeDomain.allCases
        var activities: [ActivityItem] = []
        
        for i in 0..<5 {
            let domain = domains.randomElement()!
            let activity = ActivityItem(
                title: generateActivityTitle(for: domain),
                domain: domain,
                date: Calendar.current.date(byAdding: .hour, value: -i*2, to: Date()) ?? Date(),
                pointsEarned: Int.random(in: 5...15)
            )
            activities.append(activity)
        }
        
        recentActivities = activities
    }
    
    private func calculateTrend() {
        // Simulate trend calculation
        let trends: [TrendDirection] = [.up, .down, .none]
        lifeScoreTrend = trends.randomElement() ?? .none
    }
    
    private func generateActivityTitle(for domain: LifeDomain) -> String {
        switch domain {
        case .health:
            return ["Morning Stretch", "Hydration Goal", "Healthy Meal", "Evening Walk"].randomElement() ?? "Health Activity"
        case .finance:
            return ["Budget Review", "Savings Transfer", "Expense Tracking", "Investment Check"].randomElement() ?? "Finance Activity"
        case .productivity:
            return ["Email Triage", "Task Planning", "Deep Work", "Meeting Prep"].randomElement() ?? "Productivity Activity"
        case .mindfulness:
            return ["Meditation", "Gratitude Journal", "Breathing Exercise", "Mindful Moment"].randomElement() ?? "Mindfulness Activity"
        }
    }
}

// MARK: - Analytics View Model
class AnalyticsViewModel: ObservableObject {
    @Published var lifeScoreData: [LifeScoreDataPoint] = []
    @Published var domainPerformanceData: [DomainDataPoint] = []
    @Published var completionRate: Int = 0
    
    init() {
        loadData()
    }
    
    func refreshData() {
        loadData()
    }
    
    private func loadData() {
        generateLifeScoreData()
        generateDomainPerformanceData()
        calculateCompletionRate()
    }
    
    private func generateLifeScoreData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        var dataPoints: [LifeScoreDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let score = Double.random(in: 45...85)
            let dataPoint = LifeScoreDataPoint(date: currentDate, score: score)
            dataPoints.append(dataPoint)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        lifeScoreData = dataPoints
    }
    
    private func generateDomainPerformanceData() {
        domainPerformanceData = LifeDomain.allCases.map { domain in
            DomainDataPoint(
                domain: domain,
                score: Double.random(in: 30...85)
            )
        }
    }
    
    private func calculateCompletionRate() {
        completionRate = Int.random(in: 60...95)
    }
}

// MARK: - Data Models
struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let domain: LifeDomain
    let date: Date
    let pointsEarned: Int
}

struct LifeScoreDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct DomainDataPoint: Identifiable {
    let id = UUID()
    let domain: LifeDomain
    let score: Double
}

enum Timeframe: CaseIterable {
    case week, month, quarter, year
    
    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .quarter: return "Quarter"
        case .year: return "Year"
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let cardCompleted = Notification.Name("cardCompleted")
}