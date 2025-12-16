import SwiftUI

struct WatchDeckView: View {
    @EnvironmentObject var watchManager: WatchDataManager
    @State private var cards: [WatchCard] = []
    @State private var currentCardIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading cards...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            } else if cards.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("No cards available")
                        .font(.system(size: 14, weight: .medium))

                    Button("Refresh") {
                        loadCards()
                    }
                    .font(.system(size: 12))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                }
            } else {
                ZStack {
                    // Background cards (stack effect)
                    ForEach(cards.indices, id: \.self) { index in
                        if index > currentCardIndex && index <= currentCardIndex + 2 {
                            WatchCardView(card: cards[index])
                                .offset(y: CGFloat(index - currentCardIndex) * 8)
                                .scaleEffect(1.0 - CGFloat(index - currentCardIndex) * 0.05)
                                .opacity(1.0 - Double(index - currentCardIndex) * 0.3)
                        }
                    }

                    // Current card with gesture
                    if currentCardIndex < cards.count {
                        WatchCardView(card: cards[currentCardIndex])
                            .offset(x: dragOffset)
                            .rotationEffect(.degrees(dragOffset / 20))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation.width
                                    }
                                    .onEnded { value in
                                        let threshold: CGFloat = 100
                                        let velocity = value.predictedEndTranslation.width

                                        withAnimation(.spring()) {
                                            if abs(value.translation.width) > threshold || abs(velocity) > 500 {
                                                if value.translation.width > 0 {
                                                    // Swipe right - complete
                                                    completeCard()
                                                } else {
                                                    // Swipe left - dismiss
                                                    dismissCard()
                                                }
                                            } else {
                                                dragOffset = 0
                                            }
                                        }
                                    }
                            )
                            .overlay(
                                // Swipe indicators
                                HStack {
                                    if dragOffset > 50 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.green)
                                            .offset(x: -60)
                                    }

                                    Spacer()

                                    if dragOffset < -50 {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.red)
                                            .offset(x: 60)
                                    }
                                }
                            )
                    }
                }
            }
        }
        .navigationTitle("Deck")
        .onAppear {
            loadCards()
        }
    }

    private func loadCards() {
        isLoading = true

        // Simulate loading cards from phone via WatchConnectivity
        // In a real implementation, this would communicate with the iOS app
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.cards = [
                WatchCard(
                    id: "1",
                    title: "Morning Walk",
                    description: "Take a 10-minute walk to start your day",
                    domain: "Health",
                    actionType: "Quick"
                ),
                WatchCard(
                    id: "2",
                    title: "Budget Check",
                    description: "Review your spending for the day",
                    domain: "Finance",
                    actionType: "Standard"
                ),
                WatchCard(
                    id: "3",
                    title: "Focus Time",
                    description: "Work on your most important task for 25 minutes",
                    domain: "Productivity",
                    actionType: "Extended"
                ),
                WatchCard(
                    id: "4",
                    title: "Gratitude Moment",
                    description: "Write down 3 things you're grateful for",
                    domain: "Mindfulness",
                    actionType: "Quick"
                )
            ]
            self.isLoading = false
        }
    }

    private func completeCard() {
        // Send completion to phone
        sendActionToPhone(action: "complete", cardId: cards[currentCardIndex].id)

        // Haptic feedback
        WKInterfaceDevice.current().play(.success)

        // Move to next card
        withAnimation {
            dragOffset = 300
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentCardIndex += 1
            self.dragOffset = 0

            if self.currentCardIndex >= self.cards.count {
                // All cards completed
                self.showCompletionCelebration()
            }
        }
    }

    private func dismissCard() {
        // Send dismissal to phone
        sendActionToPhone(action: "dismiss", cardId: cards[currentCardIndex].id)

        // Haptic feedback
        WKInterfaceDevice.current().play(.failure)

        // Move to next card
        withAnimation {
            dragOffset = -300
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentCardIndex += 1
            self.dragOffset = 0

            if self.currentCardIndex >= self.cards.count {
                self.showCompletionCelebration()
            }
        }
    }

    private func sendActionToPhone(action: String, cardId: String) {
        // Send action to iOS app via WatchConnectivity
        let message: [String: Any] = [
            "action": action,
            "cardId": cardId,
            "timestamp": Date().timeIntervalSince1970
        ]

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send message to phone: \(error)")
        }
    }

    private func showCompletionCelebration() {
        // Show celebration animation
        WKInterfaceDevice.current().play(.notification)

        // In a real app, you might show a completion screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Reset for new cards
            self.currentCardIndex = 0
            self.loadCards()
        }
    }
}

struct WatchCardView: View {
    let card: WatchCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(card.domain)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(domainColor.opacity(0.2))
                    .foregroundColor(domainColor)
                    .cornerRadius(6)

                Spacer()

                Text(card.actionType)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }

            // Title
            Text(card.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)

            // Description
            Text(card.description)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(3)

            Spacer()

            // Action hint
            HStack {
                Image(systemName: "hand.draw")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Text("Swipe to act")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    private var domainColor: Color {
        switch card.domain {
        case "Health": return .green
        case "Finance": return .blue
        case "Productivity": return .orange
        case "Mindfulness": return .purple
        default: return .gray
        }
    }
}

struct WatchCard: Identifiable {
    let id: String
    let title: String
    let description: String
    let domain: String
    let actionType: String
}