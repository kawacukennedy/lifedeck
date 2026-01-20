import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Life Score Section
                    lifeScoreSection
                    
                    // Domain Breakdown
                    domainBreakdownSection
                    
                    // Streak Section
                    streakSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.refreshData()
            }
        }
    }
    
    private var lifeScoreSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Life Score")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.secondaryBackground, lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(user.progress.lifeScore / 100))
                    .stroke(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: user.progress.lifeScore)
                
                VStack(spacing: 4) {
                    Text("\(Int(user.progress.lifeScore))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("out of 100")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .cardStyle()
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }
    
    private var domainBreakdownSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Domain Breakdown")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(LifeDomain.allCases) { domain in
                    domainProgressRow(domain: domain)
                }
            }
            .cardStyle()
        }
    }
    
    private func domainProgressRow(domain: LifeDomain) -> some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: domain.icon)
                        .font(.title3)
                        .foregroundColor(domain.color)
                    
                    Text(domain.displayName)
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                }
                
                Spacer()
                
                Text("\(Int(user.progress.scoreForDomain(domain)))")
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.bold)
                        .foregroundColor(domain.color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(DesignSystem.Colors.secondaryBackground)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.forDomain(domain))
                        .frame(
                            width: geometry.size.width * CGFloat(user.progress.scoreForDomain(domain) / 100),
                            height: 8
                        )
                        .cornerRadius(4)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: user.progress.scoreForDomain(domain))
                }
            }
            .frame(height: 8)
        }
        .padding(DesignSystem.Spacing.md)
    }
    
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Streaks")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                streakCard(
                    title: "Current",
                    value: "\(user.progress.currentStreak)",
                    subtitle: "days",
                    color: DesignSystem.Colors.success
                )
                
                streakCard(
                    title: "Longest",
                    value: "\(user.progress.longestStreak)",
                    subtitle: "days",
                    color: DesignSystem.Colors.primary
                )
            }
        }
    }
    
    private func streakCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(subtitle)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Recent Activity")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            if viewModel.recentActivities.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(Color.gray.opacity(0.6))
                    
                    Text("No recent activity")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.xl)
                .cardStyle()
            } else {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.recentActivities, id: \.self) { activity in
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Circle()
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: 8, height: 8)
                            
                            Text(activity)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Spacer()
                        }
                        .padding(.vertical, DesignSystem.Spacing.xs)
                    }
                }
                .cardStyle()
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}