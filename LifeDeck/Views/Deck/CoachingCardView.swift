import SwiftUI

struct CoachingCardView: View {
    let card: CoachingCard
    let onCompleted: () -> Void
    let onDismissed: () -> Void
    let onSnoozed: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var dragRotation: Double = 0
    @GestureState private var isDragging: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with domain and time estimate
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: card.icon)
                        .foregroundColor(.lifeDeckTextPrimary)
                        .font(.title3)
                    
                    Text(card.domain.displayName.uppercased())
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.lifeDeckTextSecondary)
                }
                
                Spacer()
                
                Text(card.actionType.estimatedDuration)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.lifeDeckCardBackground)
                    )
            }
            
            // Card content
            VStack(alignment: .leading, spacing: 16) {
                Text(card.title)
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text(card.description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .lineLimit(DesignSystem.deviceType == .compact ? 2 : 3)
                
                Text(card.actionText)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckPrimary)
                    .padding(.top, DesignSystem.Spacing.sm)
            }
            
            Spacer()
            
            // Swipe instructions
            HStack {
                Label("Complete", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.lifeDeckSuccess)
                
                Spacer()
                
                Label("Snooze", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.lifeDeckWarning)
                
                Spacer()
                
                Label("Dismiss", systemImage: "xmark.circle")
                    .font(.caption)
                    .foregroundColor(.lifeDeckError)
            }
            .opacity(isDragging ? 0.8 : 0.4)
        }
        .responsiveCardPadding()
        .frame(
            maxWidth: DesignSystem.Layout.cardWidth,
            maxHeight: DesignSystem.Layout.cardHeight
        )
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.deviceType == .compact ? 20 : 24)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.deviceType == .compact ? 20 : 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.lifeDeckPrimary.opacity(0.3),
                                    Color.lifeDeckSecondary.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .iosNativeShadow(elevation: .high)
        .offset(dragOffset)
        .rotationEffect(.degrees(dragRotation))
        .scaleEffect(isDragging ? 0.95 : 1.0)
        .animation(DesignSystem.Animation.springDefault, value: dragOffset)
        .animation(DesignSystem.Animation.springDefault, value: isDragging)
        .gesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    dragOffset = value.translation
                    
                    // Rotation effect based on horizontal drag
                    dragRotation = Double(value.translation.width / 20)
                    
                    // Haptic feedback for different swipe directions
                    if abs(value.translation.width) > 50 || abs(value.translation.height) > 50 {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
                .onEnded { value in
                    let swipeThreshold: CGFloat = 100
                    
                    if value.translation.width > swipeThreshold {
                        // Swipe Right - Complete
                        withAnimation(.spring()) {
                            dragOffset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onCompleted()
                        }
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                        
                    } else if value.translation.width < -swipeThreshold {
                        // Swipe Left - Dismiss
                        withAnimation(.spring()) {
                            dragOffset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismissed()
                        }
                        let errorFeedback = UINotificationFeedbackGenerator()
                        errorFeedback.notificationOccurred(.error)
                        
                    } else if value.translation.height > swipeThreshold {
                        // Swipe Down - Snooze
                        withAnimation(.spring()) {
                            dragOffset = CGSize(width: 0, height: 500)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSnoozed()
                        }
                        let warningFeedback = UINotificationFeedbackGenerator()
                        warningFeedback.notificationOccurred(.warning)
                        
                    } else {
                        // Snap back to center
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = .zero
                            dragRotation = 0
                        }
                    }
                }
        )
    }
}
