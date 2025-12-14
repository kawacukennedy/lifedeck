import SwiftUI

struct CoachingCardView: View {
    let card: CoachingCard
    @State private var offset: CGSize = .zero
    @State private var rotation: Angle = .zero
    let onSwipe: (CardAction) -> Void

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: DesignSystem.cardCornerRadius)
                .fill(cardBackground)
                .shadow(color: cardShadowColor.opacity(0.3), radius: 16, x: 0, y: 8)

            // Card content
            VStack(alignment: .leading, spacing: DesignSystem.lg) {
                // Header
                HStack {
                    domainIcon
                        .font(.system(size: 24))
                        .foregroundColor(cardTextColor)

                    Spacer()

                    if card.isPremium {
                        HStack(spacing: DesignSystem.sm) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(Color.premiumGold)
                            Text("Premium")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.premiumGold)
                        }
                        .padding(.horizontal, DesignSystem.sm)
                        .padding(.vertical, 4)
                        .background(Color.premiumGold.opacity(0.2))
                        .cornerRadius(DesignSystem.cornerRadius / 2)
                    }

                    Text("\(card.estimatedTime)m")
                        .font(.caption)
                        .foregroundColor(cardTextColor.opacity(0.7))
                }

                // Main text
                Text(card.text)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(cardTextColor)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Footer
                HStack {
                    difficultyIndicator
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(card.domain.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(cardTextColor.opacity(0.7))
                        Text("\(card.estimatedTime) min")
                            .font(.caption2)
                            .foregroundColor(cardTextColor.opacity(0.5))
                    }
                }
            }
            .padding(DesignSystem.xl)
        }
        .frame(height: 420)
        .padding(.horizontal)
        .offset(offset)
        .rotationEffect(rotation)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    rotation = Angle(degrees: Double(gesture.translation.width / 20))
                }
                .onEnded { gesture in
                    withAnimation(.spring()) {
                        handleSwipe(gesture)
                    }
                }
        )
        .accessibilityLabel("\(card.domain.rawValue.capitalized) card: \(card.text)")
        .accessibilityHint("Swipe right to complete, left to dismiss, or up to snooze")
        .accessibilityAction(named: "Complete") {
            onSwipe(.complete)
        }
        .accessibilityAction(named: "Dismiss") {
            onSwipe(.dismiss)
        }
        .accessibilityAction(named: "Snooze") {
            onSwipe(.snooze)
        }
    }

    private var cardBackground: some ShapeStyle {
        LinearGradient(
            gradient: Gradient(colors: [cardColor.opacity(0.8), cardColor.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardColor: Color {
        switch card.domain {
        case .health: return .health
        case .finance: return .finance
        case .productivity: return .productivity
        case .mindfulness: return .mindfulness
        }
    }

    private var cardTextColor: Color {
        .white
    }

    private var cardShadowColor: Color {
        cardColor
    }

    private var domainIcon: some View {
        switch card.domain {
        case .health: return Image(systemName: "heart.fill")
        case .finance: return Image(systemName: "dollarsign.circle.fill")
        case .productivity: return Image(systemName: "checkmark.circle.fill")
        case .mindfulness: return Image(systemName: "brain.head.profile")
        }
    }

    private var difficultyIndicator: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { level in
                Circle()
                    .fill(level <= card.difficulty ? cardTextColor : cardTextColor.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private func handleSwipe(_ gesture: DragGesture.Value) {
        let width = gesture.translation.width
        let height = gesture.translation.height

        if abs(width) > swipeThreshold {
            if width > 0 {
                // Swipe right - complete
                offset = CGSize(width: 500, height: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipe(.complete)
                }
            } else {
                // Swipe left - dismiss
                offset = CGSize(width: -500, height: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipe(.dismiss)
                }
            }
        } else if height < -swipeThreshold {
            // Swipe up - snooze
            offset = CGSize(width: 0, height: -500)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwipe(.snooze)
            }
        } else {
            // Reset
            offset = .zero
            rotation = .zero
        }
    }
}