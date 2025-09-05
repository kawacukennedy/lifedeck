import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedPeriod: SubscriptionProduct.SubscriptionPeriod = .yearly
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.lifeDeckPremiumGold)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get unlimited access to all premium features")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Feature Comparison
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Premium Features")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                            ForEach(SubscriptionComparison.premiumOnlyFeatures, id: \.name) { feature in
                                FeatureRow(
                                    icon: feature.icon,
                                    title: feature.name,
                                    description: feature.description
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Premium Button
                    Button("Start Premium - \(selectedPeriod == .monthly ? "$7.99/month" : "$79.99/year")") {
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
                    .padding()
                    
                    // Terms
                    Text("Secure payment via Apple ID • Cancel anytime")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
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
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.lifeDeckPrimary)
                .font(.title2)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.lifeDeckTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.lifeDeckCardBackground)
        .cornerRadius(12)
        .lifeDeckSubtleShadow()
    }
}
