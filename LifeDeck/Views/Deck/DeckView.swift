import SwiftUI

// MARK: - Simple Deck View for iPad Testing

struct DeckView: View {
    let user: User
    @StateObject private var viewModel = SimpleDeckViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedCard: CoachingCard?
    @State private var showingCardDetail = false

    var body: some View {
        VStack(spacing: 20) {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .navigationTitle("Daily Deck")
        .sheet(isPresented: $showingCardDetail) {
            if let card = selectedCard {
                SimpleCardDetailView(card: card) {
                    showingCardDetail = false
                }
            }
        }
    }
    
    // MARK: - iPad Layout
    
    private var iPadLayout: some View {
        VStack(spacing: 30) {
            // Header
            headerSection
            
            // Card grid
            cardGridSection
        }
        .padding(30)
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("🃏 LifeDeck")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 30) {
                    statView(value: "\(user.progress.currentStreak)", label: "Streak", color: .green)
                    statView(value: "\(user.progress.lifePoints)", label: "Points", color: .orange)
                    statView(value: "\(user.progress.totalCardsCompleted)", label: "Cards", color: .blue)
                }
            }
            
            Text("AI-Powered Micro-Coach")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
    
    private var cardGridSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading cards...")
                    .frame(maxHeight: .infinity)
            } else if viewModel.cards.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                    ForEach(viewModel.cards) { card in
                        iPadCard(card: card)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Text("No cards available")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button("Refresh Cards") {
                Task { await viewModel.refreshCards() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - iPhone Layout
    
    private var iPhoneLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                
                statView(value: "\(user.progress.currentStreak)", label: "Streak", color: .green)
                statView(value: "\(user.progress.lifePoints)", label: "Points", color: .orange)
                statView(value: "\(user.progress.totalCardsCompleted)", label: "Cards", color: .blue)
                
                if viewModel.isLoading {
                    ProgressView("Loading cards...")
                        .foregroundColor(.secondary)
                } else if viewModel.cards.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 15) {
                        Text("Card Deck")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Button("Refresh Cards") {
                            Task { await viewModel.refreshCards() }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Components
    
    private func iPadCard(card: CoachingCard) -> some View {
        VStack(spacing: 15) {
            // Domain icon
            HStack {
                Image(systemName: card.domain.icon)
                    .font(.title2)
                    .foregroundColor(Color.forDomain(card.domain))
                
                Spacer()
                
                if card.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            // Card content
            VStack(alignment: .leading, spacing: 10) {
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text(card.actionText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 15) {
                Button("Complete") {
                    completeCard(card)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                
                Button("Details") {
                    selectedCard = card
                    showingCardDetail = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Skip") {
                    dismissCard(card)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .frame(width: 200, height: 260)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .onTapGesture {
            selectedCard = card
            showingCardDetail = true
        }
    }
    
    private func statView(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Actions
    
    private func completeCard(_ card: CoachingCard) async {
        await viewModel.completeCard(card)
        user.completeCard()
    }
    
    private func dismissCard(_ card: CoachingCard) async {
        await viewModel.dismissCard(card)
    }
}

// MARK: - Simple View Model

@MainActor
class SimpleDeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var isLoading = false
    
    init() {
        Task {
            await loadCards()
        }
    }
    
    func refreshCards() async {
        await loadCards()
    }
    
    func completeCard(_ card: CoachingCard) async {
        cards.removeAll { $0.id == card.id }
        await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func dismissCard(_ card: CoachingCard) async {
        cards.removeAll { $0.id == card.id }
        await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func loadCards() async {
        isLoading = true
        
        // Simulate API call
        await Task.sleep(nanoseconds: 2_000_000_000)
        
        cards = SampleCards.createHealthCards() + 
                 SampleCards.createFinanceCards() + 
                 SampleCards.createProductivityCards() + 
                 SampleCards.createMindfulnessCards()
        
        isLoading = false
    }
}

// MARK: - Simple Card Detail View

struct SimpleCardDetailView: View {
    let card: CoachingCard
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header
                HStack {
                    Image(systemName: card.domain.icon)
                        .font(.largeTitle)
                        .foregroundColor(Color.forDomain(card.domain))
                    
                    VStack(alignment: .leading) {
                        Text(card.domain.displayName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if card.isPremium {
                            Text("Premium Card")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                }
                
                // Content
                Text(card.title)
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                
                Text(card.actionText)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Actions
                VStack(spacing: 15) {
                    Button("Complete Card") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    HStack(spacing: 15) {
                        Button("Dismiss") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(25)
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Color Extension

extension Color {
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain {
        case .health:
            return .red
        case .finance:
            return .green
        case .productivity:
            return .blue
        case .mindfulness:
            return .purple
        }
    }
}

#Preview {
    NavigationView {
        DeckView(user: User(name: "Test User"))
    }
}