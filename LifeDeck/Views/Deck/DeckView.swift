import SwiftUI

struct DeckView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DeckViewModel()

    var body: some View {
        MainLayout {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Header
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("🃏 LifeDeck")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(.lifeDeckTextPrimary)

                    Text("AI-Powered Micro-Coach")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.lifeDeckTextSecondary)

                    Text("Your daily coaching cards await!")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.lifeDeckTextPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                .padding(.top, DesignSystem.Spacing.lg)

                // Stats
                HStack(spacing: DesignSystem.Spacing.xl) {
                    StatView(value: "\(user.progress.currentStreak)", label: "Streak", color: .lifeDeckSuccess)
                    StatView(value: "\(user.progress.lifePoints)", label: "Points", color: .lifeDeckWarning)
                    StatView(value: "\(user.progress.totalCardsCompleted)", label: "Cards", color: .lifeDeckInfo)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)

                // Deck
                if viewModel.isLoading {
                    ProgressView("Loading cards...")
                        .foregroundColor(.lifeDeckTextSecondary)
                        .frame(maxHeight: .infinity)
                } else if viewModel.cards.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("No cards available")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.lifeDeckTextSecondary)

                        PrimaryButton(text: "Refresh", onPress: {
                            Task { await viewModel.refreshCards() }
                        })
                    }
                    .frame(maxHeight: .infinity)
                 } else {
                     DeckView(cards: viewModel.cards) { card, direction in
                         Task {
                             await handleCardAction(card, direction: direction)
                         }
                     }
                     .frame(maxHeight: .infinity)
                     .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                 }

                // Refresh button
                PrimaryButton(text: "Refresh Cards", onPress: {
                    Task { await viewModel.refreshCards() }
                })
                .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
        .background(Color.lifeDeckBackground.ignoresSafeArea())
        .navigationTitle("Daily Deck")
        .navigationBarTitleDisplayMode(.large)
        .alert(item: Binding<Error?>(
            get: { viewModel.error },
            set: { viewModel.error = $0 }
        )) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func handleCardAction(_ card: CoachingCard, direction: SwipeDirection) async {
        switch direction {
        case .right:
            await viewModel.completeCard(card)
            user.completeCard()
        case .left:
            await viewModel.dismissCard(card)
        case .down:
            await viewModel.snoozeCard(card)
        case .up:
            // Could show details or something
            break
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(value)
                .font(DesignSystem.Typography.title)
                .foregroundColor(color)
            Text(label)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.lifeDeckTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
