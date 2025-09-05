import Foundation
import SwiftUI

@MainActor
class DeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var isLoading = false
    
    init() {
        loadSampleCards()
    }
    
    private func loadSampleCards() {
        cards = SampleCards.allSampleCards()
    }
    
    func refreshCards() {
        // TODO: Implement AI card generation
        loadSampleCards()
    }
}
