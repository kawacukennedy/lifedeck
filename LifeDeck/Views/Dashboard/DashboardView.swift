import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.betweenSections) {
                    // Header with greeting
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(greeting)
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(.lifeDeckTextSecondary)
                        
                        Text(user.name.isEmpty ? "Your Progress" : "\(user.name)'s Progress")
                            .font(DesignSystem.Typography.largeTitle)
                            .foregroundColor(.lifeDeckTextPrimary)
                    }
                    .responsiveHorizontalPadding()
                    .conditionalTopSafeArea()
                    
                    // Life Score Overview with circular progress
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        ZStack {
                            // Background circle
                            Circle()
                                .stroke(Color.lifeDeckCardBorder, lineWidth: DesignSystem.deviceType == .compact ? 6 : 8)
                                .frame(
                                    width: DesignSystem.deviceType == .compact ? 140 : 180,
                                    height: DesignSystem.deviceType == .compact ? 140 : 180
                                )
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: CGFloat(user.progress.lifeScore / 100))
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.lifeDeckPrimary,
                                            Color.lifeDeckSecondary
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: DesignSystem.deviceType == .compact ? 6 : 8, lineCap: .round)
                                )
                                .frame(
                                    width: DesignSystem.deviceType == .compact ? 140 : 180,
                                    height: DesignSystem.deviceType == .compact ? 140 : 180
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: user.progress.lifeScore)
                            
                            // Life Score text
                            VStack(spacing: DesignSystem.Spacing.xs) {
                                Text("\(Int(user.progress.lifeScore))")
                                    .font(
                                        .system(
                                            size: DesignSystem.deviceType == .compact ? 36 : 48,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundColor(.lifeDeckTextPrimary)
                                
                                Text("LIFE SCORE")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(.lifeDeckTextSecondary)
                                    .tracking(1.2)
                            }
                        }
                        
                        Text(lifeScoreDescription)
                            .font(.body)
                            .foregroundColor(.lifeDeckTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .fillWidth()
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.deviceType == .compact ? 16 : 20)
                            .fill(Color.lifeDeckCardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.deviceType == .compact ? 16 : 20)
                                    .stroke(Color.lifeDeckCardBorder, lineWidth: 1)
                            )
                    )
                    .iosNativeShadow(elevation: .medium)
                    .responsiveHorizontalPadding()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Life Score: \(Int(user.progress.lifeScore)) out of 100. \(lifeScoreDescription)")
                    
                    // Domain Progress
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Domain Breakdown")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(.lifeDeckTextPrimary)
                            .responsiveHorizontalPadding()
                        
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: DesignSystem.Layout.gridColumns),
                            spacing: DesignSystem.Spacing.md
                        ) {
                            ForEach(LifeDomain.allCases) { domain in
                                DomainProgressCard(
                                    domain: domain,
                                    score: user.progress.scoreForDomain(domain),
                                    isPremium: subscriptionManager.isPremium
                                )
                            }
                        }
                        .responsiveHorizontalPadding()
                    }
                    
                    // Quick Stats Row
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Your Progress")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(.lifeDeckTextPrimary)
                            .responsiveHorizontalPadding()
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            StatCard(
                                icon: "flame.fill",
                                title: "Current Streak",
                                value: "\(user.progress.currentStreak)",
                                unit: "days",
                                color: .lifeDeckSuccess
                            )
                            StatCard(
                                icon: "star.fill",
                                title: "Life Points",
                                value: "\(user.progress.lifePoints)",
                                unit: "points",
                                color: .lifeDeckPremiumGold
                            )
                            StatCard(
                                icon: "checkmark.circle.fill",
                                title: "Cards Done",
                                value: "\(user.progress.totalCardsCompleted)",
                                unit: "total",
                                color: .lifeDeckPrimary
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Premium Analytics Section
                    if subscriptionManager.isPremium {
                        PremiumAnalyticsSection(user: user)
                    } else {
                        // Free tier limited analytics with upsell
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Want deeper insights?")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.lifeDeckTextPrimary)
                                    
                                    Text("Unlock advanced analytics, trends, and personalized insights with Premium.")
                                        .font(.body)
                                        .foregroundColor(.lifeDeckTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 40))
                                    .foregroundColor(.lifeDeckPremiumGold)
                            }
                            
                            Button("Upgrade to Premium") {
                                // Show paywall
                            }
                            .buttonStyle(.lifeDeckPremium)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.lifeDeckCardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.lifeDeckPremiumGold.opacity(0.3),
                                                    Color.lifeDeckPrimary.opacity(0.3)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Helper Properties
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    private var lifeScoreDescription: String {
        let score = user.progress.lifeScore
        switch score {
        case 0..<25: return "You're just getting started. Every small step counts!"
        case 25..<50: return "You're building momentum. Keep pushing forward!"
        case 50..<75: return "Great progress! You're on your way to excellent wellness."
        case 75..<90: return "Outstanding! You're living a well-balanced life."
        default: return "Exceptional! You're a true wellness champion."
        }
    }
}

struct DomainProgressCard: View {
    let domain: LifeDomain
    let score: Double
    let isPremium: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Domain icon with circular progress
            ZStack {
                Circle()
                    .stroke(Color.lifeDeckCardBorder, lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score / 100))
                    .stroke(Color.forDomain(domain), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: score)
                
                Image(systemName: domain.icon)
                    .font(.title3)
                    .foregroundColor(Color.forDomain(domain))
            }
            
            VStack(spacing: 4) {
                Text(domain.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Text("\(Int(score))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.forDomain(domain))
                
                if isPremium {
                    Text(domainTrend)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(trendColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.lifeDeckTextTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.lifeDeckCardBorder, lineWidth: 1)
                )
        )
    }
    
    private var domainTrend: String {
        // Simulated trend data - in real app this would come from user data
        let trends = ["+5%", "+12%", "-3%", "+8%", "+15%"]
        return trends.randomElement() ?? "+5%"
    }
    
    private var trendColor: Color {
        return domainTrend.hasPrefix("+") ? .lifeDeckSuccess : .lifeDeckError
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.lifeDeckTextPrimary)
            
            Text(unit)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.lifeDeckTextTertiary)
                .textCase(.uppercase)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.lifeDeckTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
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

// MARK: - Premium Analytics Section
struct PremiumAnalyticsSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Advanced Analytics")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.lifeDeckTextPrimary)
                
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundColor(.lifeDeckPremiumGold)
            }
            .padding(.horizontal)
            
            // Weekly Trend Chart Placeholder
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Trends")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.lifeDeckTextPrimary)
                
                // Simulated chart area
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.lifeDeckPrimary.opacity(0.3),
                                Color.lifeDeckSecondary.opacity(0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        Text("📈 Life Score trending up +8% this week")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.lifeDeckTextSecondary)
                    )
            }
            .padding(.horizontal)
            
            // Insights
            VStack(alignment: .leading, spacing: 12) {
                Text("AI Insights")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.lifeDeckTextPrimary)
                
                VStack(alignment: .leading, spacing: 8) {
                    InsightRow(icon: "💤", text: "Your sleep quality improved when you completed evening mindfulness cards.")
                    InsightRow(icon: "💰", text: "Financial stress decreased after consistent budgeting exercises.")
                    InsightRow(icon: "🎯", text: "Productivity peaks at 10 AM - schedule important cards then.")
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.lifeDeckCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.lifeDeckPremiumGold.opacity(0.3),
                                    Color.lifeDeckPrimary.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .padding(.horizontal)
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title3)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.lifeDeckTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.lifeDeckBackground.opacity(0.5))
        )
    }
}
