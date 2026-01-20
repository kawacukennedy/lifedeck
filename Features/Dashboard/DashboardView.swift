import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    headerView
                    
                    // Life Score
                    lifeScoreSection
                    
                    // Domain Breakdown
                    domainProgressSection
                    
                    // Stats
                    statsSection
                    
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
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Welcome back, \(user.name)")
                .font(DesignSystem.Typography.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("Here's your progress overview")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .padding(.bottom, DesignSystem.Spacing.md)
    }
    
    private var lifeScoreSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Life Score")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                if viewModel.lifeScoreTrend != .none {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.lifeScoreTrend.icon)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(viewModel.lifeScoreTrend.color)
                        
                        Text(viewModel.lifeScoreTrend.text)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(viewModel.lifeScoreTrend.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(viewModel.lifeScoreTrend.color.opacity(0.1))
                    .cornerRadius(DesignSystem.Spacing.smallCornerRadius)
                }
            }
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(DesignSystem.Colors.text.opacity(0.1), lineWidth: 8)
                    .frame(width: 180, height: 180)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(user.progress.lifeScore / 100))
                    .stroke(
                        DesignSystem.Gradients.primary,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 4) {
                    Text("\(Int(user.progress.lifeScore))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text("LIFE SCORE")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .tracking(1.2)
                }
            }
            
            Text(getLifeScoreDescription())
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var domainProgressSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Domain Progress")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                ForEach(LifeDomain.allCases) { domain in
                    domainCard(domain: domain, score: user.progress.scoreForDomain(domain))
                }
            }
        }
    }
    
    private var domainCard: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: domain.icon)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(Color.forDomain(domain))
                
                Spacer()
                
                Text("\(Int(score))%")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.forDomain(domain))
            }
            
            Text(domain.displayName)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.leading)
        }
        .cardStyle()
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Your Progress")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                statCard(icon: "flame.fill", title: "Current Streak", value: "\(user.progress.currentStreak)", unit: "days", color: DesignSystem.Colors.success)
                statCard(icon: "star.fill", title: "Life Points", value: "\(user.lifePoints)", unit: "points", color: DesignSystem.Colors.premium)
                statCard(icon: "checkmark.circle.fill", title: "Cards Done", value: "\(user.progress.totalCardsCompleted)", unit: "total", color: DesignSystem.Colors.primary)
            }
        }
    }
    
    private func statCard(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(unit)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
            
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .cardStyle()
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Recent Activity")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            if viewModel.recentActivities.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("No recent activity")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Complete some cards to see your activity here")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(DesignSystem.Spacing.xl)
                .cardStyle()
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.recentActivities) { activity in
                        activityRow(activity: activity)
                    }
                }
            }
        }
    }
    
    private func activityRow(activity: ActivityItem) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: activity.domain.icon)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(Color.forDomain(activity.domain))
                .frame(width: 32, height: 32)
                .background(Color.forDomain(activity.domain).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            if activity.pointsEarned > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "plus")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.success)
                    
                    Text("\(activity.pointsEarned)")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .cardStyle()
    }
    
    private func getLifeScoreDescription() -> String {
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

// MARK: - Dashboard ViewModel
class DashboardViewModel: ObservableObject {
    @Published var lifeScoreTrend: TrendDirection = .none
    @Published var recentActivities: [ActivityItem] = []
    
    enum TrendDirection {
        case up, down, none
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .none: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return DesignSystem.Colors.success
            case .down: return DesignSystem.Colors.error
            case .none: return DesignSystem.Colors.textSecondary
            }
        }
        
        var text: String {
            switch self {
            case .up: return "+5%"
            case .down: return "-3%"
            case .none: return "0%"
            }
        }
    }
    
    init() {
        loadRecentActivities()
        calculateTrend()
    }
    
    func refreshData() {
        loadRecentActivities()
        calculateTrend()
    }
    
    private func loadRecentActivities() {
        // Generate sample activities for demo
        let domains = LifeDomain.allCases
        var activities: [ActivityItem] = []
        
        for i in 0..<5 {
            let domain = domains.randomElement()!
            let activity = ActivityItem(
                title: generateActivityTitle(for: domain),
                domain: domain,
                date: Calendar.current.date(byAdding: .hour, value: -i*2, to: Date()) ?? Date(),
                pointsEarned: Int.random(in: 5...15)
            )
            activities.append(activity)
        }
        
        recentActivities = activities
    }
    
    private func calculateTrend() {
        // Simulate trend calculation
        let trends: [TrendDirection] = [.up, .down, .none]
        lifeScoreTrend = trends.randomElement() ?? .none
    }
    
    private func generateActivityTitle(for domain: LifeDomain) -> String {
        switch domain {
        case .health:
            return ["Morning Stretch", "Hydration Goal", "Healthy Meal", "Evening Walk"].randomElement() ?? "Health Activity"
        case .finance:
            return ["Budget Review", "Savings Transfer", "Expense Tracking", "Investment Check"].randomElement() ?? "Finance Activity"
        case .productivity:
            return ["Email Triage", "Task Planning", "Deep Work", "Meeting Prep"].randomElement() ?? "Productivity Activity"
        case .mindfulness:
            return ["Meditation", "Gratitude Journal", "Breathing Exercise", "Mindful Moment"].randomElement() ?? "Mindfulness Activity"
        }
    }
}

// MARK: - Activity Item
struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let domain: LifeDomain
    let date: Date
    let pointsEarned: Int
}