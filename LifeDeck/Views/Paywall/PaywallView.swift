import SwiftUI
import StoreKit

// MARK: - Paywall View
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    headerView
                    
                    // Features
                    featuresView
                    
                    // Subscription Options
                    if !subscriptionManager.isLoading {
                        subscriptionOptionsView
                    } else {
                        loadingView
                    }
                    
                    // Error Display
            if let error = purchaseError {
                errorView
            }
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .navigationTitle("Upgrade to Premium")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Load products if not already loaded
            if subscriptionManager.products.isEmpty {
                subscriptionManager.loadProducts()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("Unlock Premium Features")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            Text("Get unlimited access to all coaching cards, advanced analytics, and personalized insights.")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.lg)
    }
    
    private var featuresView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Premium Features")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                featureRow(
                    icon: "infinity",
                    iconColor: DesignSystem.Colors.primary,
                    title: "Unlimited Cards",
                    description: "Access to all premium coaching cards"
                )
                
                featureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: DesignSystem.Colors.secondary,
                    title: "Advanced Analytics",
                    description: "Detailed insights and progress tracking"
                )
                
                featureRow(
                    icon: "brain.head.profile",
                    iconColor: DesignSystem.Colors.info,
                    title: "AI Personalization",
                    description: "Smarter card recommendations"
                )
                
                featureRow(
                    icon: "bell.badge",
                    iconColor: DesignSystem.Colors.warning,
                    title: "Priority Support",
                    description: "Get help faster with premium support"
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var subscriptionOptionsView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(subscriptionManager.products, id: \.id) { product in
                subscriptionOptionCard(product: product)
            }
            
            // Purchase Button
            if let product = selectedProduct ?? subscriptionManager.products.first {
                Button(action: {
                    purchaseProduct(product)
                }, label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Subscribe to Premium")
                                .font(DesignSystem.Typography.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(DesignSystem.Colors.primary)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                })
                .disabled(isPurchasing)
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            
            // Restore Purchases
            Button(action: {
                subscriptionManager.restorePurchases()
            }, label: {
                Text("Restore Purchases")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primary)
            })
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading subscription options...")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xl)
        .cardStyle()
    }
    
    private var errorView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DesignSystem.Colors.error)
            Text(purchaseError ?? "")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.error)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.error.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    private func subscriptionOptionCard(product: Product) -> some View {
        Button(action: {
            selectedProduct = product
        }, label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(formatPrice(product.price))
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
                
                Spacer()
                
                if selectedProduct?.id == product.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(selectedProduct?.id == product.id ? DesignSystem.Colors.primary : Color.clear, lineWidth: 2)
            )
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatPrice(_ price: Decimal) -> String {
        return "$\(price)"
    }
    
    func featureRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
    
    private func purchaseProduct(_ product: Product) {
        isPurchasing = true
        purchaseError = nil
        
        Task {
            await subscriptionManager.purchase(product)
            await MainActor.run {
                isPurchasing = false
                if subscriptionManager.isPremium {
                    dismiss()
                } else {
                    purchaseError = "Purchase failed"
                }
            }
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}

extension Product {
    var displayName: String {
        switch self.id {
        case "com.lifedeck.premium.monthly":
            return "Monthly"
        case "com.lifedeck.premium.yearly":
            return "Yearly (Save 20%)"
        default:
            return self.id
        }
    }
}