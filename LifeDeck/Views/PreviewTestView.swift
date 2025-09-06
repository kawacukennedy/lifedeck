import SwiftUI

/// Standalone preview-only view for testing components without app launch
struct PreviewTestView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.betweenSections) {
                    
                    // Header
                    headerSection
                    
                    // Typography Test
                    typographySection
                    
                    // Domain Colors
                    domainColorsSection
                    
                    // Button Styles
                    buttonStylesSection
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .responsiveHorizontalPadding()
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
            .navigationTitle("Preview Test")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("🃏 LifeDeck")
                .font(DesignSystem.Typography.largeTitle)
                .foregroundColor(.lifeDeckTextPrimary)
            
            Text("Preview-Only Testing")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.lifeDeckTextSecondary)
            
            Text("Minimal • Calming • Premium • Futuristic")
                .font(DesignSystem.Typography.body)
                .foregroundColor(.lifeDeckTextTertiary)
                .multilineTextAlignment(.center)
        }
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.lifeDeckPrimary.opacity(0.3), lineWidth: 1)
                )
        )
        .iosNativeShadow()
    }
    
    // MARK: - Typography Section
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Typography Scale")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.lifeDeckTextPrimary)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Large Title Sample")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text("Title Sample")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text("Headline Sample")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text("Body text sample for regular content")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.lifeDeckTextSecondary)
                
                Text("Caption text for small details")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.lifeDeckTextTertiary)
            }
        }
        .fillWidth()
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
        )
    }
    
    // MARK: - Domain Colors Section
    private var domainColorsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Life Domains")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.lifeDeckTextPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                domainCard(title: "Health", color: .lifeDeckHealth, icon: "figure.run", emoji: "🏃")
                domainCard(title: "Finance", color: .lifeDeckFinance, icon: "dollarsign.circle", emoji: "💰")
                domainCard(title: "Productivity", color: .lifeDeckProductivity, icon: "timer", emoji: "⏳")
                domainCard(title: "Mindfulness", color: .lifeDeckMindfulness, icon: "leaf", emoji: "🧘")
            }
        }
    }
    
    private func domainCard(title: String, color: Color, icon: String, emoji: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(.lifeDeckTextPrimary)
            
            Text(emoji)
                .font(.title2)
        }
        .fillWidth()
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Button Styles Section
    private var buttonStylesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Button Styles")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.lifeDeckTextPrimary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Button("Primary Button") {}
                    .buttonStyle(.iosPrimary)
                
                Button("Secondary Button") {}
                    .buttonStyle(.iosSecondary)
                
                Button("Destructive Button") {}
                    .buttonStyle(.iosDestructive)
                
                Button("Plain Button") {}
                    .buttonStyle(.iosPlain)
            }
        }
        .fillWidth()
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
        )
    }
}

// MARK: - Preview
struct PreviewTestView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewTestView()
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("LifeDeck Preview Test")
    }
}
