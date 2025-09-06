import SwiftUI

struct DeckView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DeckViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.betweenSections) {
                
                // Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("🃏 Daily Coaching Cards")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Swipeable micro-coaching to transform your life")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.lifeDeckTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .responsiveCardPadding()
                
                // Sample Card
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("🏃 Take a 5-Minute Walk")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Step outside and take a quick walk to boost your energy and clear your mind.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.lifeDeckTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Button("Skip") {
                            // Handle skip
                        }
                        .buttonStyle(.iosSecondary)
                        
                        Button("Complete") {
                            user.completeCard()
                        }
                        .buttonStyle(.iosPrimary)
                    }
                }
                .responsiveCardPadding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.lifeDeckCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.lifeDeckHealth.opacity(0.3), lineWidth: 1)
                        )
                )
                .iosNativeShadow()
                
                // Stats
                HStack {
                    statCard("Streak", "\(user.progress.currentStreak)", .lifeDeckSuccess)
                    statCard("Points", "\(user.progress.lifePoints)", .lifeDeckWarning)
                    statCard("Cards", "\(user.progress.totalCardsCompleted)", .lifeDeckPrimary)
                }
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .responsiveHorizontalPadding()
        }
        .background(Color.lifeDeckBackground.ignoresSafeArea())
        .navigationTitle("Deck")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func statCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(value)
                .font(DesignSystem.Typography.title)
                .foregroundColor(color)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.lifeDeckTextSecondary)
        }
        .fillWidth()
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
        )
    }
}
