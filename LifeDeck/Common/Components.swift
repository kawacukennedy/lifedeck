import SwiftUI

// MARK: - Atoms

/// Primary Button component as per design system specs
struct PrimaryButton: View {
    let text: String
    let onPress: () -> Void
    let disabled: Bool

    init(text: String, onPress: @escaping () -> Void, disabled: Bool = false) {
        self.text = text
        self.onPress = onPress
        self.disabled = disabled
    }

    var body: some View {
        Button(action: onPress) {
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(minWidth: 200, minHeight: 56)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(LifeDeckPrimaryButtonStyle(isDisabled: disabled))
        .disabled(disabled)
    }
}

/// Card Surface component as per design system specs
struct CardSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color.lifeDeckCardBackground)
            .cornerRadius(24)
            .lifeDeckCardShadow()
    }
}

// MARK: - Molecules

/// Coaching Card molecule with swipable functionality and CTA
struct CoachingCardView: View {
    let card: CoachingCard
    let onSwipe: (SwipeDirection) -> Void
    let onAction: () -> Void

    @State private var offset = CGSize.zero
    @State private var swipeDirection: SwipeDirection?

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 16) {
                // Domain icon and title
                HStack {
                    Image(systemName: card.domain.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.forDomain(card.domain))
                        .frame(width: 40, height: 40)
                        .background(Color.forDomain(card.domain).opacity(0.1))
                        .cornerRadius(20)
                        .accessibility(hidden: true)

                    VStack(alignment: .leading) {
                        Text(card.title)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.lifeDeckTextPrimary)

                        Text(card.domain.displayName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.lifeDeckTextSecondary)
                    }

                    Spacer()
                }

                // Action text
                Text(card.actionText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .lineLimit(3)

                // CTA Button
                Button(action: onAction) {
                    Text("Complete Action")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.lifeDeckPrimary)
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
                .accessibility(label: Text("Complete \(card.title) action"))
                .accessibility(hint: Text("Double tap to complete this coaching card"))
            }
        }
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    swipeDirection = determineSwipeDirection(gesture.translation)
                }
                .onEnded { gesture in
                    let direction = determineSwipeDirection(gesture.translation)
                    if let direction = direction {
                        onSwipe(direction)
                        // Animate back
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    } else {
                        // Reset if not a clear swipe
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
                    swipeDirection = nil
                }
        )
        .overlay(
            Group {
                if let direction = swipeDirection {
                    DesignSystem.CardEffects.swipeBorder(for: direction, intensity: min(abs(offset.width) / 100, 1))
                }
            }
        )
        .accessibility(label: Text("\(card.title) in \(card.domain.displayName) domain"))
        .accessibility(hint: Text("Swipe right to complete, left to dismiss, down to snooze"))
        .accessibility(addTraits: .isButton)
    }

    private func determineSwipeDirection(_ translation: CGSize) -> SwipeDirection? {
        let threshold: CGFloat = 50
        if abs(translation.width) > threshold {
            return translation.width > 0 ? .right : .left
        } else if abs(translation.height) > threshold {
            return translation.height > 0 ? .down : .up
        }
        return nil
    }
}

// MARK: - Organisms

/// Deck View organism with stacked card deck and gesture handling
struct DeckView: View {
    let cards: [CoachingCard]
    let onCardAction: (CoachingCard, SwipeDirection) -> Void

    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            ForEach(cards.indices, id: \.self) { index in
                CoachingCardView(
                    card: cards[index],
                    onSwipe: { direction in
                        onCardAction(cards[index], direction)
                        if index == currentIndex {
                            currentIndex = min(currentIndex + 1, cards.count - 1)
                        }
                    },
                    onAction: {
                        onCardAction(cards[index], .right) // Treat action as complete
                        if index == currentIndex {
                            currentIndex = min(currentIndex + 1, cards.count - 1)
                        }
                    }
                )
                .offset(y: CGFloat(index - currentIndex) * 20)
                .scaleEffect(1 - CGFloat(index - currentIndex) * 0.05)
                .opacity(index >= currentIndex ? 1 : 0)
                .zIndex(Double(cards.count - index))
            }
        }
        .animation(.spring(), value: currentIndex)
    }
}

// MARK: - Templates

/// Main Layout template with bottom navigation and content area
struct MainLayout<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.lifeDeckBackground
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Navigation placeholder
                HStack {
                    Spacer()
                    Text("Navigation")
                        .foregroundColor(.lifeDeckTextSecondary)
                    Spacer()
                }
                .frame(height: 60)
                .background(Color.lifeDeckCardBackground)
            }
        }
    }
}