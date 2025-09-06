import SwiftUI

/// Showcase view demonstrating the LifeDeck design system
struct LifeDeckShowcaseView: View {
    @State private var isPremium = false
    @State private var showBounce = false
    @State private var selectedDomain: LifeDomain = .health
    @State private var swipeDirection: SwipeDirection? = nil
    @State private var swipeIntensity: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.betweenSections) {
                    
                    // Hero Section
                    heroSection
                    
                    // Domain Cards
                    domainCardsSection
                    
                    // Premium Showcase
                    premiumSection
                    
                    // Animation Playground  
                    animationPlayground
                    
                    Spacer(minLength: DesignSystem.Spacing.xxl)
                }
                .responsiveHorizontalPadding()
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
            .navigationTitle("LifeDeck Design")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("🃏 LifeDeck")
                .font(DesignSystem.Typography.largeTitle)
                .foregroundColor(.lifeDeckTextPrimary)
            
            Text("AI-Powered Micro-Coach")
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
                        .stroke(LinearGradient.lifeDeckPrimary, lineWidth: 1)
                        .opacity(0.3)
                )
        )
        .iosNativeShadow()
        .premiumGlow(isPremium)
    }
    
    // MARK: - Domain Cards Section
    private var domainCardsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Life Domains")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.lifeDeckTextPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                ForEach(LifeDomain.allCases, id: \.id) { domain in
                    domainCard(for: domain)
                }
            }
        }
    }
    
    private func domainCard(for domain: LifeDomain) -> some View {
        Button(action: {
            selectedDomain = domain
            withAnimation(DesignSystem.Animation.springBouncy) {
                // Card selection feedback
            }
        }) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Domain icon with glow
                DesignSystem.DomainEffects.domainIcon(for: domain, size: 32)
                
                Text(domain.displayName)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text(domain.emoji)
                    .font(.title2)
            }
            .fillWidth()
            .responsiveCardPadding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.lifeDeckCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.forDomain(domain).opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(selectedDomain == domain ? 1.05 : 1.0)
            .animation(DesignSystem.Animation.springDefault, value: selectedDomain)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Premium Section
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Premium Features")
                    .font(DesignSystem.Typography.title)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Spacer()
                
                Toggle("Premium", isOn: $isPremium)
                    .toggleStyle(SwitchToggleStyle(tint: Color.lifeDeckPremiumGold))
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                premiumFeatureCard(
                    title: "Unlimited Cards",
                    description: "Access to all coaching cards without daily limits",
                    isLocked: !isPremium
                )
                
                premiumFeatureCard(
                    title: "Advanced Analytics", 
                    description: "Detailed insights and trend analysis",
                    isLocked: !isPremium
                )
                
                premiumFeatureCard(
                    title: "AI Personalization",
                    description: "Contextual and adaptive coaching",
                    isLocked: !isPremium
                )
            }
            
            // Premium CTA Button
            if !isPremium {
                Button(action: {
                    withAnimation(DesignSystem.Animation.premiumBounce) {
                        showBounce.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to Premium")
                        Text("$7.99/month")
                            .font(DesignSystem.Typography.caption)
                    }
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(.lifeDeckTextPrimary)
                    .fillWidth()
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(
                        ZStack {
                            // Glow effect
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient.lifeDeckPrimary)
                                .blur(radius: 8)
                                .opacity(0.6)
                            
                            // Button background
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient.lifeDeckPrimary)
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .upgradeBounce(showBounce)
            }
        }
    }
    
    private func premiumFeatureCard(title: String, description: String, isLocked: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text(description)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if !isLocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.lifeDeckSuccess)
                    .font(.title3)
            }
        }
        .responsiveCardPadding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.lifeDeckCardBackground)
        )
        .premiumLocked(isLocked)
        .premiumEnhanced(!isLocked)
    }
    
    // MARK: - Animation Playground
    private var animationPlayground: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Animation Playground")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.lifeDeckTextPrimary)
            
            // Card Swipe Demo
            VStack {
                Text("Swipe Card Demo")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.lifeDeckCardBackground)
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Text("Coaching Card")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(.lifeDeckTextPrimary)
                            
                            Text("Do 5 pushups now")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(.lifeDeckTextSecondary)
                        }
                    )
                    .cardSwipeFeedback(direction: swipeDirection, intensity: swipeIntensity)
                
                // Swipe Controls
                HStack(spacing: DesignSystem.Spacing.md) {
                    swipeButton("❌", .left)
                    swipeButton("⏰", .down) 
                    swipeButton("ℹ️", .up)
                    swipeButton("✅", .right)
                }
            }
        }
    }
    
    private func swipeButton(_ emoji: String, _ direction: SwipeDirection) -> some View {
        Button(action: {
            swipeDirection = direction
            withAnimation(DesignSystem.Animation.cardSwipe) {
                swipeIntensity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(DesignSystem.Animation.cardSwipe) {
                    swipeIntensity = 0.0
                    swipeDirection = nil
                }
            }
        }) {
            Text(emoji)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(Color.lifeDeckCardBackground)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Mark as Done
    
    private func markTodoAsDone() {
        // Mark the showcase todo as done
    }
}

// MARK: - Preview
struct LifeDeckShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        // Simplified preview
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("🎨 Design System")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text("LifeDeck Design Showcase")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(.lifeDeckTextSecondary)
                
                // Sample domain card
                HStack {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundColor(.lifeDeckHealth)
                    
                    Text("Health Domain")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.lifeDeckTextPrimary)
                    
                    Spacer()
                    
                    Text("🏃")
                        .font(.title2)
                }
                .responsiveCardPadding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.lifeDeckCardBackground)
                )
            }
            .responsiveHorizontalPadding()
        }
        .background(Color.lifeDeckBackground.ignoresSafeArea())
        .previewDevice("iPhone 15 Pro")
        .preferredColorScheme(.dark)
    }
}
