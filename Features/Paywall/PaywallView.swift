import SwiftUI

// MARK: - Paywall View
struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    paywallHeader
                    
                    // Premium Features
                    featuresSection
                    
                    // Pricing
                    pricingSection
                    
                    // Testimonials
                    testimonialsSection
                    
                    // Guarantee
                    guaranteeSection
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .navigationTitle("Upgrade to Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            loadProducts()
        }
    }
    
    private var paywallHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DesignSystem.Colors.premium)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("LifeDeck Premium")
                        .font(DesignSystem.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Unlock your full potential")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Premium Features")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                featureCard(
                    icon: "infinity",
                    title: "Unlimited Cards",
                    description: "Access unlimited coaching cards daily"
                )
                
                featureCard(
                    icon: "brain.head.profile",
                    title: "AI Insights",
                    description: "Advanced AI-powered recommendations"
                )
                
                featureCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Analytics",
                    description: "Detailed progress tracking and insights"
                )
                
                featureCard(
                    icon: "gearshape.2",
                    title: "Priority Support",
                    description: "Get help faster with premium support"
                )
            }
        }
    }
    
    private func featureCard(icon: String, title: String, description: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(DesignSystem.Colors.primary)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.text)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .cardStyle()
    }
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Choose Your Plan")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    pricingCard(product: product)
                }
            }
        }
    }
    
    private func pricingCard(product: Product) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Plan name and period
            VStack(spacing: 4) {
                if let subscriptionPeriod = product.subscriptionPeriod {
                    Text(subscriptionPeriod)
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(product.localizedPrice)
                        .font(DesignSystem.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary)
                } else {
                    Text("Lifetime")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(product.localizedPrice)
                        .font(DesignSystem.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            // Most popular badge
            if product.id.contains("yearly") {
                Text("MOST POPULAR")
                    .font(DesignSystem.Typography.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.premium)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Spacing.cornerRadius)
                .stroke(
                    selectedProduct?.id == product.id 
                        ? DesignSystem.Colors.primary 
                        : DesignSystem.Colors.text.opacity(0.2),
                    lineWidth: selectedProduct?.id == product.id ? 2 : 1
                )
        )
        .scaleEffect(selectedProduct?.id == product.id ? 1.05 : 1.0)
        .animation(DesignSystem.Animation.quick, value: selectedProduct)
        .onTapGesture {
            selectedProduct = product
        }
    }
    
    private var testimonialsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("What Our Users Say")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: DesignSystem.Spacing.md) {
                testimonialCard(
                    name: "Sarah J.",
                    role: "Product Designer",
                    content: "LifeDeck Premium has transformed my daily routine. The AI insights are incredibly accurate and helpful!",
                    rating: 5
                )
                
                testimonialCard(
                    name: "Michael K.",
                    role: "Software Engineer",
                    content: "The unlimited cards feature is a game-changer. I love having so many options for growth every day.",
                    rating: 5
                )
            }
        }
    }
    
    private func testimonialCard(name: String, role: String, content: String, rating: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(role)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < rating ? "star.fill" : "star")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(index < rating ? DesignSystem.Colors.premium : DesignSystem.Colors.textTertiary)
                    }
                }
            }
            
            Text(content)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(4)
        }
        .cardStyle()
    }
    
    private var guaranteeSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "shield.checkerboard")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.success)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("30-Day Money Back Guarantee")
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("Not satisfied? Get a full refund within 30 days, no questions asked.")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Purchase Button
struct PurchaseButton: View {
    let product: Product
    let isLoading: Bool
    let action: () async throws -> Void
    
    var body: some View {
        Button(action: {
            Task {
                isLoading = true
                do {
                    try await action()
                } catch {
                    // Handle error
                    print("Purchase failed: \(error.localizedDescription)")
                }
                isLoading = false
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Subscribe Now")
                        .font(DesignSystem.Typography.buttonText)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Spacing.buttonHeight)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.Spacing.cornerRadius)
        }
        .disabled(isLoading)
    }
}

// MARK: - Restore Button
struct RestoreButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Restore Purchases")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.primary)
                .underline()
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }
}