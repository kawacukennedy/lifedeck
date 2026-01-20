import Foundation
import CoreData
import Combine

// MARK: - Data Service
class DataService: ObservableObject {
    static let shared = DataService()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LifeDeck")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
    
    // MARK: - User Data
    func saveUser(_ user: User) {
        let userEntity = UserEntity(context: context)
        userEntity.id = user.id.uuidString
        userEntity.name = user.name
        userEntity.email = user.email
        userEntity.hasCompletedOnboarding = user.hasCompletedOnboarding
        userEntity.joinDate = user.joinDate
        userEntity.lifePoints = Int16(user.lifePoints)
        
        // Save progress
        let progressEntity = UserProgressEntity(context: context)
        progressEntity.healthScore = user.progress.healthScore
        progressEntity.financeScore = user.progress.financeScore
        progressEntity.productivityScore = user.progress.productivityScore
        progressEntity.mindfulnessScore = user.progress.mindfulnessScore
        progressEntity.lifeScore = user.progress.lifeScore
        progressEntity.currentStreak = Int16(user.progress.currentStreak)
        progressEntity.longestStreak = Int16(user.progress.longestStreak)
        progressEntity.totalCardsCompleted = Int16(user.progress.totalCardsCompleted)
        progressEntity.lifePoints = Int16(user.progress.lifePoints)
        
        userEntity.progress = progressEntity
        
        // Save settings
        let settingsEntity = UserSettingsEntity(context: context)
        settingsEntity.notificationsEnabled = user.settings.notificationsEnabled
        settingsEntity.weeklyReportsEnabled = user.settings.weeklyReportsEnabled
        settingsEntity.hapticsEnabled = user.settings.hapticsEnabled
        settingsEntity.soundEnabled = user.settings.soundEnabled
        settingsEntity.autoStartDay = user.settings.autoStartDay
        
        userEntity.settings = settingsEntity
        
        saveContext()
    }
    
    func loadUser() -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let users = try context.fetch(request)
            guard let userEntity = users.first,
                  let user_id = UUID(uuidString: userEntity.id ?? "") else {
                return nil
            }
            
            // Create User object
            let user = User(
                name: userEntity.name ?? "",
                email: userEntity.email,
                hasCompletedOnboarding: userEntity.hasCompletedOnboarding
            )
            
            // Load progress if exists
            if let progressEntity = userEntity.progress {
                user.progress.healthScore = progressEntity.healthScore
                user.progress.financeScore = progressEntity.financeScore
                user.progress.productivityScore = progressEntity.productivityScore
                user.progress.mindfulnessScore = progressEntity.mindfulnessScore
                user.progress.lifeScore = progressEntity.lifeScore
                user.progress.currentStreak = Int(progressEntity.currentStreak)
                user.progress.longestStreak = Int(progressEntity.longestStreak)
                user.progress.totalCardsCompleted = Int(progressEntity.totalCardsCompleted)
                user.progress.lifePoints = Int(progressEntity.lifePoints)
            }
            
            // Load settings if exists
            if let settingsEntity = userEntity.settings {
                user.settings.notificationsEnabled = settingsEntity.notificationsEnabled
                user.settings.weeklyReportsEnabled = settingsEntity.weeklyReportsEnabled
                user.settings.hapticsEnabled = settingsEntity.hapticsEnabled
                user.settings.soundEnabled = settingsEntity.soundEnabled
                user.settings.autoStartDay = settingsEntity.autoStartDay
            }
            
            return user
        } catch {
            print("Failed to load user: \(error)")
            return nil
        }
    }
    
    // MARK: - Card Data
    func saveCard(_ card: CoachingCard) {
        let cardEntity = CardEntity(context: context)
        cardEntity.id = card.id.uuidString
        cardEntity.title = card.title
        cardEntity.cardDescription = card.description
        cardEntity.domain = card.domain.rawValue
        cardEntity.actionText = card.actionText
        cardEntity.difficulty = card.difficulty
        cardEntity.points = Int16(card.points)
        cardEntity.priority = card.priority.rawValue
        cardEntity.estimatedDuration = card.estimatedDuration.rawValue
        cardEntity.isPremium = card.isPremium
        cardEntity.aiGenerated = card.aiGenerated
        cardEntity.createdDate = card.createdDate
        cardEntity.completedDate = card.completedDate
        cardEntity.snoozedUntil = card.snoozedUntil
        cardEntity.tags = card.tags.joined(separator: ",")
        cardEntity.impact = card.impact
        cardEntity.userNote = card.userNote
        cardEntity.isBookmarked = card.isBookmarked
        
        saveContext()
    }
    
    func loadCards() -> [CoachingCard] {
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        do {
            let cardEntities = try context.fetch(request)
            return cardEntities.compactMap { entity in
                guard let card_id = UUID(uuidString: entity.id ?? ""),
                      let domain = LifeDomain(rawValue: entity.domain ?? ""),
                      let priority = CoachingCard.CardPriority(rawValue: entity.priority ?? ""),
                      let duration = CoachingCard.Duration(rawValue: entity.estimatedDuration ?? "") else {
                    return nil
                }
                
                let card = CoachingCard(
                    id: card_id,
                    title: entity.title ?? "",
                    description: entity.cardDescription ?? "",
                    domain: domain,
                    actionText: entity.actionText ?? "",
                    difficulty: entity.difficulty,
                    points: Int(entity.points),
                    priority: priority,
                    estimatedDuration: duration,
                    isPremium: entity.isPremium,
                    aiGenerated: entity.aiGenerated,
                    tags: entity.tags?.components(separatedBy: ",") ?? [],
                    impact: entity.impact
                )
                
                card.createdDate = entity.createdDate ?? Date()
                card.completedDate = entity.completedDate
                card.snoozedUntil = entity.snoozedUntil
                card.userNote = entity.userNote
                card.isBookmarked = entity.isBookmarked
                
                return card
            }
        } catch {
            print("Failed to load cards: \(error)")
            return []
        }
    }
    
    // MARK: - Clean Up
    func deleteAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
}

// MARK: - Core Data Extensions
extension User {
    var uuidString: String {
        return self.id.uuidString
    }
}

extension CoachingCard {
    var uuidString: String {
        return self.id.uuidString
    }
}