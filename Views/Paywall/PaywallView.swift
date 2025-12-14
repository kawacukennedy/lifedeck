import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var isPurchasing = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: DesignSystem.xl) {
                    // Header
                    VStack(spacing: DesignSystem.md) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.premiumGold)

                        Text("Unlock Premium")
                            .font(DesignSystem.h1)
                            .foregroundColor(.white)

                        Text("Take your life optimization to the next level")
                            .font(DesignSystem.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, DesignSystem.xl)

                    // Feature Comparison
                    FeatureComparisonView()

                    // Pricing
                    VStack(spacing: DesignSystem.md) {
                        Text("$7.99/month")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color.premiumGold)

                        Text("Cancel anytime • No hidden fees")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Upgrade Button
                    Button(action: purchasePremium) {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Upgrade to Premium")
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(.premium)
                    .disabled(isPurchasing)
                    .padding(.horizontal)
                    .scaleEffect(isPurchasing ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isPurchasing)

                    // Free Tier Reminder
                    VStack(spacing: DesignSystem.sm) {
                        Text("Free Tier Includes:")
                            .font(.headline)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: DesignSystem.sm) {
                            FeatureRow(text: "5 daily coaching cards", included: true)
                            FeatureRow(text: "Basic progress tracking", included: true)
                            FeatureRow(text: "Streak building", included: true)
                            FeatureRow(text: "Life Points & achievements", included: true)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(DesignSystem.cornerRadius)
                    .padding(.horizontal)

                    Spacer(minLength: DesignSystem.xl)
                }
                .padding(.bottom)
            }
        }
        .alert("Purchase Successful!", isPresented: $showSuccess) {
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Welcome to LifeDeck Premium! Enjoy unlimited cards and advanced features.")
        }
    }

    private func purchasePremium() {
        isPurchasing = true
        Task {
            do {
                try await subscriptionManager.purchase()
                await MainActor.run {
                    isPurchasing = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    // Handle error
                }
            }
        }
    }
}

struct FeatureComparisonView: View {
    var body: some View {
        VStack(spacing: DesignSystem.sm) {
            // Header
            HStack {
                Text("Features")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Free")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 60)

                Text("Premium")
                    .font(.headline)
                    .foregroundColor(Color.premiumGold)
                    .frame(width: 80)
            }
            .padding(.horizontal)

            Divider()
                .background(Color.white.opacity(0.2))

            // Features
            Group {
                ComparisonRow(feature: "Daily Cards", free: "5", premium: "Unlimited", isPremium: true)
                ComparisonRow(feature: "Progress Analytics", free: "Basic", premium: "Advanced", isPremium: true)
                ComparisonRow(feature: "Data Integrations", free: "None", premium: "HealthKit, Plaid, Calendar", isPremium: true)
                ComparisonRow(feature: "Custom Rituals", free: "No", premium: "Yes", isPremium: true)
                ComparisonRow(feature: "AI Personalization", free: "Basic", premium: "Advanced", isPremium: true)
                ComparisonRow(feature: "Cross-Domain Insights", free: "No", premium: "Yes", isPremium: true)
                ComparisonRow(feature: "Exclusive Rewards", free: "No", premium: "Yes", isPremium: true)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
        .padding(.horizontal)
    }
}

struct ComparisonRow: View {
    let feature: String
    let free: String
    let premium: String
    let isPremium: Bool

    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(free)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 60)

            HStack(spacing: DesignSystem.sm) {
                Text(premium)
                    .font(.subheadline)
                    .foregroundColor(isPremium ? Color.premiumGold : .white)

                if isPremium {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.premiumGold)
                }
            }
            .frame(width: 80)
        }
        .padding(.vertical, DesignSystem.sm)
    }
}

struct FeatureRow: View {
    let text: String
    let included: Bool

    var body: some View {
        HStack {
            Image(systemName: included ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundColor(included ? .success : .error)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}