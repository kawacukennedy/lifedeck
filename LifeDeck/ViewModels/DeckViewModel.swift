import SwiftUI
import Foundation

// MARK: - Deck View Model
class DeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var currentCardIndex = 0
    @Published var isLoading = false
    @Published var dragOffset: CGSize = .zero
    @Published var dragRotation: Double = 0
    
    init() {
        loadCards()
    }
    
    func swipeCard(direction: SwipeDirection) {
        guard currentCardIndex < cards.count else { return }
        
        switch direction {
        case .right:
            cards[currentCardIndex].markCompleted()
            moveToNextCard()
        case .left:
            moveToNextCard()
        case .down:
            cards[currentCardIndex].snooze()
            moveToNextCard()
        }
    }
    
    func moveToNextCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentCardIndex += 1
            dragOffset = .zero
            dragRotation = 0
        }
    }
    
    func updateDrag(offset: CGSize) {
        dragOffset = offset
        dragRotation = Double(offset.width / 20)
    }
    
    func resetDrag() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dragOffset = .zero
            dragRotation = 0
        }
    }
    
    func handleDragEnd(offset: CGSize) {
        let threshold: CGFloat = 100
        
        if abs(offset.width) > threshold {
            // Swipe left or right
            if offset.width > 0 {
                swipeCard(direction: .right)
            } else {
                swipeCard(direction: .left)
            }
        } else if offset.height > threshold {
            // Swipe down
            swipeCard(direction: .down)
        } else {
            resetDrag()
        }
    }
    
    func loadCards() {
        isLoading = true
        
        Task {
            do {
                // Try to load cards from AI service
                // For demo purposes, we'll mix AI and sample cards
                let sampleCards = CoachingCard.sampleCards
                
                // You would integrate AIService here when API is ready
                // let aiCards = try await AIService.shared.generateDailyCards(user: currentUser)
                
                await MainActor.run {
                    self.cards = Array(sampleCards.prefix(5)) // Limit to 5 cards per day
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    // Fallback to sample cards if AI fails
                    self.cards = CoachingCard.sampleCards
                }
            }
        }
    }
    
    var currentCard: CoachingCard? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }
    
    var remainingCards: Int {
        max(0, cards.count - currentCardIndex)
    }
    
    var visibleCards: [CoachingCard] {
        guard currentCardIndex < cards.count else { return [] }
        let endIndex = min(currentCardIndex + 3, cards.count)
        return Array(cards[currentCardIndex..<endIndex])
    }
}

enum SwipeDirection {
    case left, right, down
}