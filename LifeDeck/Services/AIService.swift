import Foundation

// MARK: - AI Service (Mock Implementation)
class AIService: ObservableObject {
    static let shared = AIService()
    
    private init() {}
    
    // MARK: - Generate Daily Cards
    func generateDailyCards(user: User) async throws -> [CoachingCard] {
        // Mock AI-generated cards based on user profile
        var cards: [CoachingCard] = []
        
        // Generate cards based on user's focus areas
        let focusAreas = user.settings.focusAreas.isEmpty ? LifeDomain.allCases : user.settings.focusAreas
        
        for domain in focusAreas {
            let card = generateCardForDomain(domain, user: user)
            cards.append(card)
        }
        
        // Add a few general wellness cards if needed
        if cards.count < 3 {
            cards.append(contentsOf: generateGeneralCards(user: user))
        }
        
        return Array(cards.prefix(5)) // Limit to 5 cards per day
    }
    
    // MARK: - Generate Card Based on Domain
    func generateCard(for domain: LifeDomain, userProfile: User) async throws -> CoachingCard {
        return generateCardForDomain(domain, user: userProfile)
    }
    
    // MARK: - Generate Card for Domain
    private func generateCardForDomain(_ domain: LifeDomain, user: User) -> CoachingCard {
        let domainScore = user.progress.scoreForDomain(domain)
        
        switch domain {
        case .health:
            if domainScore < 30 {
                return CoachingCard(
                    title: "5-Minute Stretch Break",
                    description: "Stand up and stretch for 5 minutes to improve circulation and reduce stiffness.",
                    domain: domain,
                    actionText: "Take a 5-minute stretch break",
                    difficulty: 1.0,
                    points: 5,
                    priority: .low,
                    estimatedDuration: .quick,
                    tags: ["stretch", "movement", "health"]
                )
            } else if domainScore < 60 {
                return CoachingCard(
                    title: "Healthy Meal Planning",
                    description: "Plan and prep one healthy meal for tomorrow to build better nutrition habits.",
                    domain: domain,
                    actionText: "Plan tomorrow's healthy meal",
                    difficulty: 1.5,
                    points: 10,
                    priority: .medium,
                    estimatedDuration: .standard,
                    tags: ["nutrition", "planning", "health"]
                )
            } else {
                return CoachingCard(
                    title: "Advanced Workout Goal",
                    description: "Set a specific fitness goal for this week with measurable progress indicators.",
                    domain: domain,
                    actionText: "Set weekly fitness goal",
                    difficulty: 2.0,
                    points: 15,
                    priority: .high,
                    estimatedDuration: .standard,
                    tags: ["fitness", "goals", "health"],
                    isPremium: true
                )
            }
            
        case .finance:
            if domainScore < 30 {
                return CoachingCard(
                    title: "Track Today's Spending",
                    description: "Record every expense today, no matter how small, to build awareness of spending patterns.",
                    domain: domain,
                    actionText: "Record all expenses today",
                    difficulty: 1.2,
                    points: 8,
                    priority: .medium,
                    estimatedDuration: .standard,
                    tags: ["finance", "tracking", "awareness"]
                )
            } else if domainScore < 60 {
                return CoachingCard(
                    title: "Review Monthly Budget",
                    description: "Compare this month's spending against your budget and identify areas for improvement.",
                    domain: domain,
                    actionText: "Review monthly budget vs actual",
                    difficulty: 1.5,
                    points: 12,
                    priority: .medium,
                    estimatedDuration: .standard,
                    tags: ["finance", "budget", "review"]
                )
            } else {
                return CoachingCard(
                    title: "Investment Portfolio Review",
                    description: "Analyze your current investment portfolio and rebalance if needed for optimal returns.",
                    domain: domain,
                    actionText: "Review and rebalance portfolio",
                    difficulty: 2.0,
                    points: 20,
                    priority: .high,
                    estimatedDuration: .extended,
                    tags: ["finance", "investment", "review"],
                    isPremium: true
                )
            }
            
        case .productivity:
            if domainScore < 30 {
                return CoachingCard(
                    title: "Single Task Focus",
                    description: "Choose one important task and work on it exclusively for 25 minutes without distractions.",
                    domain: domain,
                    actionText: "Focus on one task for 25 minutes",
                    difficulty: 1.3,
                    points: 10,
                    priority: .high,
                    estimatedDuration: .short,
                    tags: ["productivity", "focus", "deep-work"]
                )
            } else if domainScore < 60 {
                return CoachingCard(
                    title: "Email Inbox Zero",
                    description: "Process your entire email inbox to zero and set up a system for maintaining it.",
                    domain: domain,
                    actionText: "Process inbox to zero",
                    difficulty: 1.8,
                    points: 15,
                    priority: .high,
                    estimatedDuration: .standard,
                    tags: ["productivity", "email", "organization"]
                )
            } else {
                return CoachingCard(
                    title: "System Implementation Project",
                    description: "Design and implement a small system to automate a repetitive task in your workflow.",
                    domain: domain,
                    actionText: "Design automation system",
                    difficulty: 2.5,
                    points: 25,
                    priority: .high,
                    estimatedDuration: .extended,
                    tags: ["productivity", "automation", "system"],
                    isPremium: true
                )
            }
            
        case .mindfulness:
            if domainScore < 30 {
                return CoachingCard(
                    title: "3-Minute Breathing Exercise",
                    description: "Practice box breathing for 3 minutes to reduce stress and improve focus.",
                    domain: domain,
                    actionText: "Practice 3-minute breathing exercise",
                    difficulty: 1.0,
                    points: 5,
                    priority: .low,
                    estimatedDuration: .quick,
                    tags: ["mindfulness", "breathing", "stress-reduction"]
                )
            } else if domainScore < 60 {
                return CoachingCard(
                    title: "Gratitude Journal Entry",
                    description: "Write down three specific things you're grateful for today and why they matter.",
                    domain: domain,
                    actionText: "Write three gratitudes",
                    difficulty: 1.2,
                    points: 8,
                    priority: .medium,
                    estimatedDuration: .short,
                    tags: ["mindfulness", "gratitude", "journaling"]
                )
            } else {
                return CoachingCard(
                    title: "Meditation Session",
                    description: "Complete a 15-minute guided meditation session focusing on present moment awareness.",
                    domain: domain,
                    actionText: "Complete 15-minute meditation",
                    difficulty: 1.5,
                    points: 15,
                    priority: .high,
                    estimatedDuration: .standard,
                    tags: ["mindfulness", "meditation", "presence"],
                    isPremium: true
                )
            }
        }
    }
    
    // MARK: - Generate General Cards
    private func generateGeneralCards(user: User) -> [CoachingCard] {
        let lifeScore = user.progress.lifeScore
        
        if lifeScore < 50 {
            return [
                CoachingCard(
                    title: "Morning Routine Setup",
                    description: "Establish a simple 5-minute morning routine to start your day with intention.",
                    domain: .mindfulness,
                    actionText: "Create 5-minute morning routine",
                    difficulty: 1.0,
                    points: 7,
                    priority: .low,
                    estimatedDuration: .quick,
                    tags: ["mindfulness", "routine", "morning"]
                ),
                CoachingCard(
                    title: "Weekly Review Session",
                    description: "Take 10 minutes to review this week's accomplishments and set intentions for next week.",
                    domain: .productivity,
                    actionText: "Review week and set intentions",
                    difficulty: 1.3,
                    points: 10,
                    priority: .medium,
                    estimatedDuration: .short,
                    tags: ["productivity", "review", "planning"]
                )
            ]
        } else if lifeScore < 75 {
            return [
                CoachingCard(
                    title: "Learning Goal Setting",
                    description: "Identify one skill to learn this month and break it into manageable weekly steps.",
                    domain: .productivity,
                    actionText: "Set monthly learning goal",
                    difficulty: 1.8,
                    points: 15,
                    priority: .high,
                    estimatedDuration: .standard,
                    tags: ["productivity", "learning", "goals"]
                ),
                CoachingCard(
                    title: "Connection Activity",
                    description: "Reach out to one friend or family member for a meaningful conversation today.",
                    domain: .mindfulness,
                    actionText: "Have meaningful conversation",
                    difficulty: 1.5,
                    points: 12,
                    priority: .medium,
                    estimatedDuration: .standard,
                    tags: ["mindfulness", "connection", "relationships"]
                )
            ]
        } else {
            return [
                CoachingCard(
                    title: "Legacy Project",
                    description: "Start work on a personal legacy project that could impact others positively.",
                    domain: .productivity,
                    actionText: "Begin legacy project",
                    difficulty: 2.5,
                    points: 30,
                    priority: .high,
                    estimatedDuration: .extended,
                    tags: ["productivity", "legacy", "purpose"],
                    isPremium: true
                ),
                CoachingCard(
                    title: "Teaching Opportunity",
                    description: "Share your expertise by teaching someone else a skill you've mastered.",
                    domain: .mindfulness,
                    actionText: "Teach a skill to someone",
                    difficulty: 2.0,
                    points: 25,
                    priority: .high,
                    estimatedDuration: .extended,
                    tags: ["mindfulness", "teaching", "growth"],
                    isPremium: true
                )
            ]
        }
    }
}