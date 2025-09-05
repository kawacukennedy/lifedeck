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
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.lifeDeckTextSecondary)
                }
                
                Spacer()
                
                Text(card.actionType.estimatedDuration)
                    .font(.system(size: 12, weight: .medium))
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
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text(card.description)
                    .font(.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .lineLimit(3)
                
                Text(card.actionText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.lifeDeckPrimary)
                    .padding(.top, 8)
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
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
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
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 20,
            x: 0,
            y: 10
        )
        .offset(dragOffset)
        .rotationEffect(.degrees(dragRotation))
        .scaleEffect(isDragging ? 0.95 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDragging)
        .gesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    dragOffset = value.translation
                    
                    // Rotation effect based on horizontal drag
                    dragRotation = Double(value.translation.x / 20)
                    
                    // Haptic feedback for different swipe directions
                    if abs(value.translation.x) > 50 || abs(value.translation.y) > 50 {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
                .onEnded { value in
                    let swipeThreshold: CGFloat = 100
                    
                    if value.translation.x > swipeThreshold {
                        // Swipe Right - Complete
                        withAnimation(.spring()) {
                            dragOffset = CGSize(width: 500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onCompleted()
                        }
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                        
                    } else if value.translation.x < -swipeThreshold {
                        // Swipe Left - Dismiss
                        withAnimation(.spring()) {
                            dragOffset = CGSize(width: -500, height: 0)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismissed()
                        }
                        let errorFeedback = UINotificationFeedbackGenerator()
                        errorFeedback.notificationOccurred(.error)
                        
                    } else if value.translation.y > swipeThreshold {
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
