import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header with time range selector
                    headerSection
                    
                    // Life Score Overview
                    lifeScoreSection
                    
                    // Domain Progress Chart
                    domainProgressSection
                    
                    // Activity Heatmap (Premium)
                    if subscriptionManager.isPremium {
                        activityHeatmapSection
                    }
                    
                    // Insights & Trends
                    insightsSection
                    
                    // Achievements
                    achievementsSection
                }
                .padding(.horizontal, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Progress")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
            }
            
            Text("Track your growth across all life domains")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Life Score Section
    
    private var lifeScoreSection: some View {
        VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(user.lifeScore))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Current Life Score")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Mini donut chart
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(user.lifeScore / 100))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.indigo
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: user.lifeScore)
                }
            }
            
            // Progress indicators
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ProgressIndicator(
                    title: "This Week",
                    value: weeklyProgress,
                    color: .green
                )
                
                ProgressIndicator(
                    title: "This Month",
                    value: monthlyProgress,
                    color: .blue
                )
                
                ProgressIndicator(
                    title: "Streak",
                    value: Double(user.currentStreak) / 30.0,
                    color: .orange
                )
                
                ProgressIndicator(
                    title: "Goals",
                    value: goalsProgress,
                    color: .purple
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Domain Progress Section
    
    private var domainProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Domain Progress")
                .font(.title2)
                .foregroundColor(.primary)
            
            if subscriptionManager.isPremium {
                // Chart view for premium users
                domainChart
            } else {
                // Simple progress bars for free users
                domainProgressBars
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var domainChart: some View {
        Chart {
            ForEach(LifeDomain.allCases, id: \.self) { domain in
                BarMark(
                    x: domain.displayName,
                    y: user.scoreForDomain(domain)
                )
                .foregroundStyle(by: .value("Domain"))
                .opacity(0.8)
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(preset: .automatic)
        }
        .chartYAxis {
            AxisMarks(preset: .automatic)
        }
        .chartForegroundStyleScale(range: 0.5...1.0)
        .chartPlotStyle { plotContent in
            plotContent
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var domainProgressBars: some View {
        VStack(spacing: 16) {
            ForEach(LifeDomain.allCases, id: \.self) { domain in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: domain.icon)
                            .foregroundColor(.forDomain(domain))
                        
                        Text(domain.displayName)
                            .font(.callout)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int(user.scoreForDomain(domain)))%")
                            .font(.callout)
                            .foregroundColor(.primary)
                    }
                    
                    ProgressView(value: user.scoreForDomain(domain) / 100.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .forDomain(domain)))
                        .scaleEffect(y: 2.0)
                }
            }
        }
    }
    
    // MARK: - Activity Heatmap Section (Premium)
    
    private var activityHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Heatmap")
                .font(.title2)
                .foregroundColor(.primary)
            
            Text("Your daily activity patterns over last \(selectedTimeRange.rawValue.lowercased())")
                .font(.callout)
                .foregroundColor(.secondary)
            
            // Simplified heatmap grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                ForEach(0..<28, id: \.self) { day in
                    Rectangle()
                        .fill(heatmapColor(for: day))
                        .frame(height: 20)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            Group {
                if !subscriptionManager.isPremium {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Premium Feature")
                                .font(.caption1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .cornerRadius(12)
                            Spacer()
                        }
                        .padding(16)
                    }
                }
            }
        )
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Insights")
                .font(.title2)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 16) {
                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Most Productive Time",
                    description: productivityInsight,
                    color: .green
                )
                
                InsightCard(
                    icon: "target",
                    title: "Top Performing Domain",
                    description: topDomainInsight,
                    color: .blue
                )
                
                InsightCard(
                    icon: "calendar.badge.clock",
                    title: "Consistency Score",
                    description: consistencyInsight,
                    color: .purple
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Achievements Section
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.title2)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(recentAchievements, id: \.id) { achievement in
                    AchievementView(achievement: achievement)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Helper Properties
    
    private var weeklyProgress: Double {
        // Calculate based on cards completed this week
        let thisWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let weekCompleted = user.totalCardsCompleted // Simplified for now
        return min(1.0, Double(weekCompleted) / 7.0)
    }
    
    private var monthlyProgress: Double {
        let thisMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        let monthCompleted = user.totalCardsCompleted // Simplified for now
        return min(1.0, Double(monthCompleted) / 30.0)
    }
    
    private var goalsProgress: Double {
        // Based on user's domain goals vs current progress
        let totalGoal = Double(LifeDomain.allCases.count * 100)
        let currentProgress = LifeDomain.allCases.reduce(0) { sum, domain in
            sum + user.scoreForDomain(domain)
        }
        
        return currentProgress / totalGoal
    }
    
    private var productivityInsight: String {
        let hour = 9 // Would be calculated from actual data
        return "You're most productive at \(hour):00 AM"
    }
    
    private var topDomainInsight: String {
        let topDomain = LifeDomain.allCases.max { domain1, domain2 in
            user.scoreForDomain(domain1) < user.scoreForDomain(domain2)
        }
        
        return "\(topDomain?.displayName ?? "Health") is your strongest area"
    }
    
    private var consistencyInsight: String {
        let consistencyScore = weeklyProgress * 100
        return "You've been consistent \(Int(consistencyScore))% of the time"
    }
    
    private var recentAchievements: [Achievement] {
        // Return mock achievements for now
        [
            Achievement(
                id: UUID(),
                title: "Week Warrior",
                description: "7-day streak achieved",
                icon: "flame.fill",
                color: .orange,
                unlockedDate: Date().addingTimeInterval(-86400) // Yesterday
            ),
            Achievement(
                id: UUID(),
                title: "Health Hero",
                description: "Completed 10 health cards",
                icon: "heart.fill",
                color: .red,
                unlockedDate: Date().addingTimeInterval(-172800) // 2 days ago
            ),
            Achievement(
                id: UUID(),
                title: "Mindfulness Master",
                description: "30-day mindfulness streak",
                icon: "brain.head.profile",
                color: .purple,
                unlockedDate: Date().addingTimeInterval(-259200) // 3 days ago
            )
        ]
    }
    
    private func heatmapColor(for day: Int) -> Color {
        // Simple heatmap coloring based on activity
        let intensity = Double.random(in: 0...1) // Would be based on actual data
        let baseColor = Color.red // Use health color or overall
        
        return baseColor.opacity(intensity * 0.8)
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption1)
                .foregroundColor(.secondary)
            
            ProgressView(value: value)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 1.5)
            
            Text("\(Int(value * 100))%")
                .font(.caption1)
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievement View

struct AchievementView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.color)
                .frame(width: 40, height: 40)
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.caption1)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption1)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Time Range

enum TimeRange: CaseIterable {
    case day
    case week
    case month
    case year
    
    var displayName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

// MARK: - Achievement Model

struct Achievement: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let color: Color
    let unlockedDate: Date
}

#Preview {
    InsightsView()
        .environmentObject(User())
        .environmentObject(SubscriptionManager())
}