import SwiftUI

struct DeckView: View {
    @StateObject private var viewModel: DeckViewModel
    @State private var showCompletionAnimation = false

    init(user: AppUser) {
        _viewModel = StateObject(wrappedValue: DeckViewModel(user: user))
    }

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)

            VStack(spacing: DesignSystem.xl) {
                // Header
                HStack {
                    Text("Daily Deck")
                        .font(DesignSystem.h1)
                        .foregroundColor(.white)

                    Spacer()

                    // Streak indicator
                    HStack(spacing: DesignSystem.sm) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(viewModel.user.streaks.currentStreak)")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, DesignSystem.md)
                    .padding(.vertical, DesignSystem.sm)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(DesignSystem.cornerRadius)
                }
                .padding(.horizontal)

                Spacer()

                // Card stack
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
                            .scaleEffect(1.5)
                    } else {
                        ForEach(viewModel.cards.indices, id: \.self) { index in
                            if index >= viewModel.currentCardIndex && index < viewModel.currentCardIndex + 3 {
                                CoachingCardView(card: viewModel.cards[index]) { action in
                                    handleCardAction(action, for: viewModel.cards[index])
                                }
                                .zIndex(Double(viewModel.cards.count - index))
                                .offset(y: CGFloat(index - viewModel.currentCardIndex) * 8)
                                .scaleEffect(1.0 - CGFloat(index - viewModel.currentCardIndex) * 0.05)
                            }
                        }
                    }
                }

                Spacer()

                // Action hints
                VStack(spacing: DesignSystem.sm) {
                    Text("Swipe right to complete • Left to dismiss • Up to snooze")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)

                    // Progress
                    HStack(spacing: DesignSystem.sm) {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(index < viewModel.currentCardIndex % 5 ? Color.primary : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Completion animation
            if showCompletionAnimation {
                CompletionAnimation()
                    .zIndex(100)
            }
        }
        .onAppear {
            viewModel.loadCards()
        }
    }

    private func handleCardAction(_ action: CardAction, for card: CoachingCard) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        switch action {
        case .complete:
            viewModel.completeCard(card)
            showCompletionAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCompletionAnimation = false
            }
            // Check for streak milestone
            if viewModel.user.streaks.currentStreak > 0 && viewModel.user.streaks.currentStreak % 5 == 0 {
                // Show extra celebration for milestones
            }
        case .dismiss:
            viewModel.dismissCard(card)
        case .snooze:
            viewModel.snoozeCard(card)
        }
    }
}

struct CompletionAnimation: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)

            VStack {
                ZStack {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 20, height: 20)
                            .offset(y: -100)
                            .rotationEffect(.degrees(Double(index) * 60))
                            .scaleEffect(scale)
                            .opacity(opacity)
                    }

                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }

                Text("Great job!")
                    .font(.title)
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                }
            }
        }
    }
}