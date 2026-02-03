import SwiftUI

// MARK: - Deck View
struct DeckView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager
    @StateObject private var viewModel = DeckViewModel()
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                DesignSystem.Gradients.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    Spacer()
                    
                    // Card Stack
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.currentCardIndex < viewModel.cards.count {
                        cardStackView
                    } else {
                        completionView
                    }
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControlsView
                }
            }
            .onAppear {
                viewModel.loadDailyCards(for: user)
            }
            .refreshable {
                viewModel.loadDailyCards(for: user)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
        }
        .navigationTitle("LifeDeck")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Deck")
                    .font(DesignSystem.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(viewModel.cards.count - viewModel.currentCardIndex) cards left")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Premium badge
                if user.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(DesignSystem.Colors.premium)
                        Text("PRO")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.premium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.premium.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Streak indicator
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(user.progress.currentStreak)")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.15))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, 8)
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            CardShuffleView()
                .frame(height: 300)
            
            Text("Generating your daily deck...")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
                .opacity(0.8)
        }
    }
    
    private var cardStackView: some View {
        ZStack {
            ForEach(viewModel.cards.indices, id: \.self) { index in
                if index >= viewModel.currentCardIndex && index < viewModel.currentCardIndex + 3 {
                    CoachingCardView(card: viewModel.cards[index])
                        .zIndex(Double(viewModel.cards.count - index))
                        .offset(y: CGFloat(index - viewModel.currentCardIndex) * 8)
                        .scaleEffect(1.0 - CGFloat(index - viewModel.currentCardIndex) * 0.05)
                        .offset(index == viewModel.currentCardIndex ? viewModel.dragOffset : .zero)
                        .rotationEffect(index == viewModel.currentCardIndex ? viewModel.dragRotation : .zero)
                        .opacity(index == viewModel.currentCardIndex ? 1.0 : 0.8)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    viewModel.dragOffset = value.translation
                    let rotationAmount = value.translation.width / 25
                    viewModel.dragRotation = Angle(degrees: Double(rotationAmount))
                }
                .onEnded { value in
                    viewModel.handleSwipeGesture(value, user: user) { shouldShowPaywall in
                        if shouldShowPaywall {
                            showingPaywall = true
                        }
                    }
                }
        )
    }
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.success)
            
            VStack(spacing: 8) {
                Text("All caught up!")
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Great job completing today's cards!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                viewModel.loadDailyCards()
            }) {
                Text("Refresh Cards")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.white.opacity(0.2))
                    .cornerRadius(25)
            }
        }
    }
    
    private var bottomControlsView: some View {
        VStack(spacing: 16) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<min(5, viewModel.cards.count), id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.currentCardIndex ? DesignSystem.Colors.success : .white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Swipe hints
            HStack(spacing: 20) {
                swipeHint(direction: "Left", action: "Skip", color: .red, icon: "arrow.left")
                swipeHint(direction: "Up", action: "Snooze", color: .orange, icon: "arrow.up")
                swipeHint(direction: "Right", action: "Complete", color: .green, icon: "arrow.right")
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private func swipeHint(direction: String, action: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(color)
            Text("\(direction)\n\(action)")
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 60)
    }
}

// MARK: - Deck ViewModel
class DeckViewModel: ObservableObject {
    @Published var cards: [CoachingCard] = []
    @Published var currentCardIndex = 0
    @Published var isLoading = true
    @Published var dragOffset: CGSize = .zero
    @Published var dragRotation: Angle = .zero
    
    func loadDailyCards(for user: User) {
        isLoading = true
        
        Task {
            do {
                // Use the AI service to generate cards
                let generatedCards = try await AiRecommendationService.shared.generateDailyCards(for: user)
                
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
    
    func handleSwipeGesture(_ value: DragGesture.Value, user: User, completion: @escaping (Bool) -> Void) {
        let threshold: CGFloat = 80
        
        withAnimation(DesignSystem.Animation.cardSwipe) {
            if value.translation.x > threshold {
                // Swipe right - complete card
                completeCard(at: currentCardIndex, user: user, completion: completion)
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
    
    private func completeCard(at index: Int, user: User, completion: @escaping (Bool) -> Void) {
        guard index < cards.count else { return }
        
        let card = cards[index]
        card.markCompleted()
        
        // Update user progress
        user.progress.completeCard(for: card.domain, points: card.points)
        user.lifePoints += card.points
        
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
        let cardsCopy = cards
        DispatchQueue.main.asyncAfter(deadline: .now() + 7200) {
            // Reshow snoozed card if still in app context
            self.cards.append(card)
        }
        
        withAnimation(DesignSystem.Animation.cardSwipe) {
            currentCardIndex += 1
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let cardCompleted = Notification.Name("cardCompleted")
}
// MARK: - Card Shuffle View
struct CardShuffleView: View {
    @State private var phase = 0.0
    private let cardCount = 3
    
    var body: some View {
        ZStack {
            ForEach(0..<cardCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                    .fill(DesignSystem.Gradients.primary)
                    .frame(width: 200, height: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(radius: 10)
                    .offset(x: offsetForIndex(index), y: yOffsetForIndex(index))
                    .rotationEffect(.degrees(rotationForIndex(index)))
                    .scaleEffect(scaleForIndex(index))
                    .zIndex(zIndexForIndex(index))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                phase += 1.0
            }
        }
    }
    
    private func offsetForIndex(_ index: Int) -> CGFloat {
        let normalizedPhase = phase - floor(phase)
        let totalIndex = Double(index) + normalizedPhase * Double(cardCount)
        let wrappedIndex = totalIndex.truncatingRemainder(dividingBy: Double(cardCount))
        
        // When a card is at the front (wrappedIndex close to 2), it "shuffles" to the back
        if wrappedIndex > 2.5 {
            return CGFloat((wrappedIndex - 2.5) * 400) // Slide out to the right
        } else if wrappedIndex < 0.5 {
            return CGFloat((0.5 - wrappedIndex) * -400) // Slide in from the left
        }
        return 0
    }
    
    private func yOffsetForIndex(_ index: Int) -> CGFloat {
        let wrappedIndex = (Double(index) + (phase - floor(phase)) * Double(cardCount)).truncatingRemainder(dividingBy: Double(cardCount))
        return CGFloat(wrappedIndex * 8)
    }
    
    private func rotationForIndex(_ index: Int) -> Double {
        let wrappedIndex = (Double(index) + (phase - floor(phase)) * Double(cardCount)).truncatingRemainder(dividingBy: Double(cardCount))
        return Double(wrappedIndex * 2 - 2)
    }
    
    private func scaleForIndex(_ index: Int) -> CGFloat {
        let wrappedIndex = (Double(index) + (phase - floor(phase)) * Double(cardCount)).truncatingRemainder(dividingBy: Double(cardCount))
        return CGFloat(0.9 + (wrappedIndex / Double(cardCount)) * 0.1)
    }
    
    private func zIndexForIndex(_ index: Int) -> Double {
        let wrappedIndex = (Double(index) + (phase - floor(phase)) * Double(cardCount)).truncatingRemainder(dividingBy: Double(cardCount))
        return wrappedIndex
    }
}
