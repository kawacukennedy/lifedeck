import SwiftUI

/// Minimal view for quick testing and previews
struct QuickTestView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Design System Test
                designSystemTest
                    .tabItem {
                        Image(systemName: "paintbrush.fill")
                        Text("Design")
                    }
                    .tag(0)
                
                // Components Test
                componentsTest
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("Components")
                    }
                    .tag(1)
                    
                // Colors Test
                colorsTest
                    .tabItem {
                        Image(systemName: "palette.fill")
                        Text("Colors")
                    }
                    .tag(2)
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Design System Test
    private var designSystemTest: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.betweenSections) {
                
                // Header
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("🃏 LifeDeck")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Design System Test")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.lifeDeckTextSecondary)
                }
                .responsiveCardPadding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.lifeDeckCardBackground)
                )
                
                // Typography Test
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Typography Scale")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Large Title")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Title Text")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Headline Text")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Text("Body Text")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.lifeDeckTextSecondary)
                    
                    Text("Caption Text")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.lifeDeckTextTertiary)
                }
                .fillWidth()
                .responsiveCardPadding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.lifeDeckCardBackground)
                )
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .responsiveHorizontalPadding()
        }
        .navigationTitle("Design System")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Components Test
    private var componentsTest: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                
                // Buttons
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Button Styles")
                        .font(DesignSystem.Typography.title)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Button("Primary Button") {}
                        .buttonStyle(.iosPrimary)
                    
                    Button("Secondary Button") {}
                        .buttonStyle(.iosSecondary)
                        
                    Button("Destructive Button") {}
                        .buttonStyle(.iosDestructive)
                }
                .fillWidth()
                .responsiveCardPadding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.lifeDeckCardBackground)
                )
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .responsiveHorizontalPadding()
        }
        .navigationTitle("Components")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Colors Test
    private var colorsTest: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                
                Text("Color Palette")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                // Domain Colors
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                    colorSwatch("Health", .lifeDeckHealth)
                    colorSwatch("Finance", .lifeDeckFinance)
                    colorSwatch("Productivity", .lifeDeckProductivity)
                    colorSwatch("Mindfulness", .lifeDeckMindfulness)
                }
                
                // System Colors
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                    colorSwatch("Primary", .lifeDeckPrimary)
                    colorSwatch("Secondary", .lifeDeckSecondary)
                    colorSwatch("Success", .lifeDeckSuccess)
                    colorSwatch("Warning", .lifeDeckWarning)
                }
                
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .responsiveHorizontalPadding()
        }
        .navigationTitle("Colors")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(height: 60)
            
            Text(name)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.lifeDeckTextSecondary)
        }
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
        )
    }
}

// MARK: - Preview
struct QuickTestView_Previews: PreviewProvider {
    static var previews: some View {
        QuickTestView()
            .previewDevice("iPhone 15 Pro")
            .preferredColorScheme(.dark)
    }
}
