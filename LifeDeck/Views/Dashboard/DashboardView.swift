import SwiftUI
import UIKit

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
.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                    .padding(.top, DesignSystem.hasNotch ? 0 : DesignSystem.Spacing.sm)
                    
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
.shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                     .accessibilityElement(children: .combine)
                     .accessibilityLabel("Life Score: \(Int(user.progress.lifeScore)) out of 100. \(lifeScoreDescription)")
                     .accessibilityHint("Double tap to view detailed analytics")
                     .accessibilityValue("\(Int(user.progress.lifeScore))%")
                    
                    // Domain Progress
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Domain Breakdown")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(.lifeDeckTextPrimary)
.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                        
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
.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                    }
                    
                    // Quick Stats Row
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Your Progress")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(.lifeDeckTextPrimary)
.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
                        
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
.padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
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
.buttonStyle(LifeDeckPremiumButtonStyle())
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
                        .padding(.horizontal, DesignSystem.Spacing.screenHorizontal)
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
.rotationEffect(Angle.degrees(-90))
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
    @State private var insights: [AnalyticsInsight] = []
    @State private var trends: AnalyticsTrends?
    @State private var isLoading = true

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

            if isLoading {
                ProgressView("Loading analytics...")
                    .foregroundColor(.lifeDeckTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                // Weekly Trend Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Trends")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lifeDeckTextPrimary)

                    TrendChart(trends: trends)
                }
                .padding(.horizontal)

                // AI Insights
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Insights")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.lifeDeckTextPrimary)

                    if insights.isEmpty {
                        Text("Complete more cards to unlock personalized insights!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.lifeDeckTextSecondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(insights) { insight in
                            InsightRow(icon: insight.icon, text: insight.description)
                        }
                    }
                }
                .padding(.horizontal)
            }
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
        .onAppear {
            loadAnalytics()
        }
    }

    private func loadAnalytics() {
        // In a real implementation, this would call the analytics API
        // For now, we'll simulate loading and show sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.insights = [
                AnalyticsInsight(
                    id: "1",
                    icon: "💤",
                    description: "Your sleep quality improved when you completed evening mindfulness cards.",
                    type: .correlation
                ),
                AnalyticsInsight(
                    id: "2",
                    icon: "💰",
                    description: "Financial stress decreased after consistent budgeting exercises.",
                    type: .improvement
                ),
                AnalyticsInsight(
                    id: "3",
                    icon: "🎯",
                    description: "Productivity peaks at 10 AM - schedule important cards then.",
                    type: .pattern
                )
            ]

            self.trends = AnalyticsTrends(
                dates: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                values: [65, 68, 72, 70, 75, 78, 80],
                trend: .up,
                average: 72.6,
                changePercent: 8.2
            )

            self.isLoading = false
        }
    }
}

struct TrendChart: View {
    let trends: AnalyticsTrends?

    var body: some View {
        ZStack {
            if let trends = trends {
                // Simple bar chart representation
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(trends.values.enumerated()), id: \.offset) { index, value in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.lifeDeckPrimary.opacity(0.8),
                                            Color.lifeDeckSecondary.opacity(0.6)
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 20, height: CGFloat(value) * 1.2)

                            Text(trends.dates[index])
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.lifeDeckTextTertiary)
                        }
                    }
                }
                .frame(height: 120)

                // Trend indicator
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: trends.trend == .up ? "arrow.up" : "arrow.down")
                            .foregroundColor(trends.trend == .up ? .lifeDeckSuccess : .lifeDeckError)
                        Text("\(String(format: "%.1f", trends.changePercent))% this week")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.lifeDeckTextSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.lifeDeckBackground.opacity(0.8))
                    .cornerRadius(8)
                }
            } else {
                Rectangle()
                    .fill(Color.lifeDeckCardBorder.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(12)
                    .overlay(
                        Text("📈 Loading trends...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.lifeDeckTextSecondary)
                    )
            }
        }
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

// MARK: - Analytics Models

struct AnalyticsInsight: Identifiable {
    let id: String
    let icon: String
    let description: String
    let type: InsightType
}

enum InsightType {
    case correlation, improvement, pattern, achievement
}

struct AnalyticsTrends {
    let dates: [String]
    let values: [Double]
    let trend: TrendDirection
    let average: Double
    let changePercent: Double
}

enum TrendDirection {
    case up, down, stable
}
