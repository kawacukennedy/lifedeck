import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedPeriod: SubscriptionProduct.SubscriptionPeriod = .yearly
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header with gradient background
                    VStack(spacing: 20) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.lifeDeckPremiumGold,
                                        Color.lifeDeckPremiumGradientEnd
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Unlock Your Full Potential")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.lifeDeckTextPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("with LifeDeck Premium")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.lifeDeckSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Get unlimited coaching, advanced insights, and full integrations")
                            .font(.body)
                            .foregroundColor(.lifeDeckTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                    
                    // Comparison Table
                    VStack(spacing: 16) {
                        Text("Free vs Premium")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.lifeDeckTextPrimary)
                            .padding(.horizontal)
                        
                        // Comparison rows
                        VStack(spacing: 8) {
                            ComparisonRow(
                                feature: "Daily coaching cards",
                                freeValue: "5 cards/day",
                                premiumValue: "Unlimited cards"
                            )
                            ComparisonRow(
                                feature: "Dashboard analytics",
                                freeValue: "Basic charts",
                                premiumValue: "Advanced insights + trends"
                            )
                            ComparisonRow(
                                feature: "AI personalization",
                                freeValue: "Basic",
                                premiumValue: "Advanced + contextual"
                            )
                            ComparisonRow(
                                feature: "Health/Finance sync",
                                freeValue: "❌",
                                premiumValue: "✅ Full integrations"
                            )
                            ComparisonRow(
                                feature: "Custom rituals",
                                freeValue: "❌",
                                premiumValue: "✅ Personalized routines"
                            )
                            ComparisonRow(
                                feature: "Premium badges",
                                freeValue: "❌",
                                premiumValue: "✅ Exclusive rewards"
                            )
                            ComparisonRow(
                                feature: "Priority support",
                                freeValue: "❌",
                                premiumValue: "✅ 24/7 support"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Premium CTA with glow
                    VStack(spacing: 16) {
                        Button("Upgrade to Premium") {
                            Task {
                                var purchaseSuccessful = false
                                if selectedPeriod == .monthly,
                                   let product = subscriptionManager.monthlyPremiumProduct {
                                    purchaseSuccessful = await subscriptionManager.purchaseSubscription(product)
                                } else if selectedPeriod == .yearly,
                                          let product = subscriptionManager.yearlyPremiumProduct {
                                    purchaseSuccessful = await subscriptionManager.purchaseSubscription(product)
                                }
                                
                                // Only dismiss if purchase was successful
                                if purchaseSuccessful {
                                    dismiss()
                                }
                            }
                        }
                        .buttonStyle(.lifeDeckPremium)
                        .padding(.horizontal)
                        
                        // Pricing info
                        Text("$7.99/month • Cancel anytime via Apple ID • No ads")
                            .font(.caption)
                            .foregroundColor(.lifeDeckTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.lifeDeckTextPrimary)
                }
            }
        }
    }
}

struct ComparisonRow: View {
    let feature: String
    let freeValue: String
    let premiumValue: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Feature name
            Text(feature)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.lifeDeckTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Free tier
            VStack(alignment: .center) {
                Text("Free")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.lifeDeckTextTertiary)
                    .textCase(.uppercase)
                
                Text(freeValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.lifeDeckTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80)
            
            // Premium tier
            VStack(alignment: .center) {
                Text("Premium")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.lifeDeckSecondary)
                    .textCase(.uppercase)
                
                Text(premiumValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.lifeDeckTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.lifeDeckCardBorder, lineWidth: 1)
                )
        )
    }
}
