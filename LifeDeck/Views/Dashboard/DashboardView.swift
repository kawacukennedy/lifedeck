import SwiftUI
import UIKit

struct DashboardView: View {
    let user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        AdaptiveContainer {
            if horizontalSizeClass == .regular {
                // iPad Layout: Two-column dashboard
                iPadDashboardLayout
            } else {
                // iPhone Layout: Single column
                iPhoneDashboardLayout
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - iPad Dashboard Layout
    
    private var iPadDashboardLayout: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Left Column: Life Score & Quick Stats
            VStack(spacing: DesignSystem.Spacing.lg) {
                lifeScoreSection
                quickStatsSection
            }
            .frame(maxWidth: .infinity)
            
            // Right Column: Domain Progress & Analytics
            VStack(spacing: DesignSystem.Spacing.lg) {
                domainProgressSection
                analyticsSection
            }
            .frame(maxWidth: .infinity)
        }
        .padding(DesignSystem.Spacing.lg)
    }
    
    // MARK: - iPhone Dashboard Layout
    
    private var iPhoneDashboardLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.betweenSections) {
                lifeScoreSection
                domainProgressSection
                quickStatsSection
                analyticsSection
            }
            .responsiveHorizontalPadding()
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
    }
    
    // MARK: - Dashboard Sections
    
    private var lifeScoreSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text(greeting)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(.secondary)
            
            Text(user.name.isEmpty ? "Your Progress" : "\(user.name)'s Progress")
                .font(DesignSystem.Typography.largeTitle)
                .foregroundColor(.primary)
        }
        
        VStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(
                        width: horizontalSizeClass == .regular ? 200 : 140,
                        height: horizontalSizeClass == .regular ? 200 : 140
                    )
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(user.progress.lifeScore / 100))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                DesignSystem.primaryBlue,
                                DesignSystem.teal
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(
                        width: horizontalSizeClass == .regular ? 200 : 140,
                        height: horizontalSizeClass == .regular ? 200 : 140
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: user.progress.lifeScore)
                
                // Life Score text
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("\(Int(user.progress.lifeScore))")
                        .font(.system(
                            size: horizontalSizeClass == .regular ? 56 : 36,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundColor(.primary)
                    
                    Text("LIFE SCORE")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                        .tracking(1.2)
                }
            }
            
            Text(lifeScoreDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var domainProgressSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Domain Breakdown")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.primary)
            
            AdaptiveGrid {
                ForEach(LifeDomain.allCases) { domain in
                    DomainProgressCard(
                        domain: domain,
                        score: user.progress.scoreForDomain(domain),
                        isPremium: subscriptionManager.isPremium
                    )
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Your Progress")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.primary)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                StatCard(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(user.progress.currentStreak)",
                    unit: "days",
                    color: .green
                )
                
                StatCard(
                    icon: "star.fill",
                    title: "Life Points",
                    value: "\(user.progress.lifePoints)",
                    unit: "points",
                    color: .orange
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Cards Done",
                    value: "\(user.progress.totalCardsCompleted)",
                    unit: "total",
                    color: DesignSystem.primaryBlue
                )
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Analytics")
                .font(DesignSystem.Typography.title)
                .foregroundColor(.primary)
            
            if subscriptionManager.isPremium {
                PremiumAnalyticsCompact(user: user)
            } else {
                UpgradePrompt()
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
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

// MARK: - Compact Components for iPad

struct PremiumAnalyticsCompact: View {
    let user: User
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Weekly trend chart (simplified)
            HStack {
                Text("Weekly Trend")
                    .font(DesignSystem.Typography.headline)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach([65, 68, 72, 70, 75, 78, 80], id: \.self) { value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(DesignSystem.primaryBlue.opacity(0.8))
                        .frame(width: 16, height: CGFloat(value) * 0.8)
                }
            }
            .frame(height: 60)
            
            Divider()
            
            // Quick insights
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Insights")
                    .font(DesignSystem.Typography.headline)
                
                HStack(spacing: 4) {
                    Text("💤")
                    Text("Sleep improved with mindfulness")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Text("💰")
                    Text("Budgeting reduced financial stress")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct UpgradePrompt: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Want deeper insights?")
                        .font(DesignSystem.Typography.headline)
                    
                    Text("Unlock advanced analytics, trends, and personalized insights with Premium.")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32))
                    .foregroundColor(.orange)
            }
            
            Button("Upgrade to Premium") {
                // Show paywall
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }
}

// MARK: - Reusable Components

struct DomainProgressCard: View {
    let domain: LifeDomain
    let score: Double
    let isPremium: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score / 100))
                    .stroke(Color.forDomain(domain), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: score)
                
                Image(systemName: domain.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.forDomain(domain))
            }
            
            VStack(spacing: 4) {
                Text(domain.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\(Int(score))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.forDomain(domain))
                
                if isPremium {
                    Text("+\(Int.random(in: 1...15))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        )
        .hoverEffect()
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
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .hoverEffect()
    }
}

// MARK: - Extensions

extension Color {
    static func forDomain(_ domain: LifeDomain) -> Color {
        switch domain {
        case .health:
            return .red
        case .finance:
            return .green
        case .productivity:
            return .blue
        case .mindfulness:
            return .purple
        }
    }
}

#Preview {
    NavigationView {
        DashboardView(user: User(name: "Test User"))
            .environmentObject(SubscriptionManager())
    }
}