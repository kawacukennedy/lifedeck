import SwiftUI
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
                viewModel.loadDailyCards()
            }
            .refreshable {
                viewModel.loadDailyCards()
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
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            
            Text("Generating your daily cards...")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.white)
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
                    viewModel.handleSwipeGesture(value) { shouldShowPaywall in
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
                completeCard(at: currentCardIndex, completion: completion)
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
    
    private func completeCard(at index: Int, completion: @escaping (Bool) -> Void) {
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

// MARK: - Notification Names
extension Notification.Name {
    static let cardCompleted = Notification.Name("cardCompleted")
}