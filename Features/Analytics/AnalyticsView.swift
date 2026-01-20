import SwiftUI
import Charts

// MARK: - Analytics View
struct AnalyticsView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeframe: Timeframe = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Timeframe selector
                    timeframeSelector
                    
                    // Life Score Chart
                    lifeScoreChart
                    
                    // Domain Performance
                    domainPerformanceSection
                    
                    // Streak Analysis
                    streakAnalysisSection
                    
                    // Achievements
                    achievementsSection
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.refreshData()
            }
        }
    }
    
    private var timeframeSelector: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.displayName).tag(timeframe)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.bottom, DesignSystem.Spacing.sm)
    }
    
    private var lifeScoreChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Life Score Trend")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            if #available(iOS 16.0, *) {
                Chart(viewModel.lifeScoreData) { dataPoint in
                    LineMark(
                        x: dataPoint.date,
                        y: dataPoint.score
                    )
                    .foregroundStyle(DesignSystem.Gradients.primary)
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel("\(Int(value))")
                    }
                }
                .frame(height: 200)
                .cardStyle()
            } else {
                // Fallback for older iOS versions
                VStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(viewModel.lifeScoreData) { dataPoint in
                        HStack {
                            Text(dataPoint.date.formatted(date: .abbreviated))
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Spacer()
                            
                            Text("\(Int(dataPoint.score))")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.text)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
    
    private var domainPerformanceSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Domain Performance")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            if #available(iOS 16.0, *) {
                Chart(viewModel.domainPerformanceData) { dataPoint in
                    BarMark(
                        x: dataPoint.domain.displayName,
                        y: dataPoint.score
                    )
                    .foregroundStyle(Color.forDomain(dataPoint.domain))
                    .cornerRadius(4)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel("\(Int(value))")
                    }
                }
                .frame(height: 200)
                .cardStyle()
            } else {
                // Fallback
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                    ForEach(viewModel.domainPerformanceData) { dataPoint in
                        domainPerformanceItem(dataPoint: dataPoint)
                    }
                }
            }
        }
    }
    
    private func domainPerformanceItem(dataPoint: DomainDataPoint) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text("\(Int(dataPoint.score))%")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.forDomain(dataPoint.domain))
            
            Text(dataPoint.domain.displayName)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
        }
        .cardStyle()
    }
    
    private var streakAnalysisSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Streak Analysis")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                streakCard(
                    title: "Current Streak",
                    value: "\(user.progress.currentStreak)",
                    subtitle: "days",
                    color: DesignSystem.Colors.success
                )
                
                streakCard(
                    title: "Longest Streak",
                    value: "\(user.progress.longestStreak)",
                    subtitle: "days",
                    color: DesignSystem.Colors.primary
                )
                
                streakCard(
                    title: "Completion Rate",
                    value: "\(viewModel.completionRate)%",
                    subtitle: "this week",
                    color: DesignSystem.Colors.premium
                )
            }
        }
    }
    
    private func streakCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(value)
                .font(DesignSystem.Typography.statValue)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(DesignSystem.Typography.statLabel)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(subtitle)
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .cardStyle()
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Recent Achievements")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            if user.achievements.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "trophy")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("No achievements yet")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Complete more cards to unlock achievements")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(DesignSystem.Spacing.xl)
                .cardStyle()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                    ForEach(user.achievements.suffix(6)) { achievement in
                        achievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
    
    private func achievementCard(achievement: Achievement) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 32))
                .foregroundColor(achievement.isUnlocked ? DesignSystem.Colors.premium : DesignSystem.Colors.textTertiary)
            
            Text(achievement.title)
                .font(DesignSystem.Typography.headline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .cardStyle()
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Analytics ViewModel
class AnalyticsViewModel: ObservableObject {
    @Published var lifeScoreData: [LifeScoreDataPoint] = []
    @Published var domainPerformanceData: [DomainDataPoint] = []
    @Published var completionRate: Int = 0
    
    init() {
        loadData()
    }
    
    func refreshData() {
        loadData()
    }
    
    private func loadData() {
        generateLifeScoreData()
        generateDomainPerformanceData()
        calculateCompletionRate()
    }
    
    private func generateLifeScoreData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        var dataPoints: [LifeScoreDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let score = Double.random(in: 45...85)
            let dataPoint = LifeScoreDataPoint(date: currentDate, score: score)
            dataPoints.append(dataPoint)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        lifeScoreData = dataPoints
    }
    
    private func generateDomainPerformanceData() {
        domainPerformanceData = LifeDomain.allCases.map { domain in
            DomainDataPoint(
                domain: domain,
                score: Double.random(in: 30...85)
            )
        }
    }
    
    private func calculateCompletionRate() {
        completionRate = Int.random(in: 60...95)
    }
}

// MARK: - Data Models
struct LifeScoreDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct DomainDataPoint: Identifiable {
    let id = UUID()
    let domain: LifeDomain
    let score: Double
}

enum Timeframe: CaseIterable {
    case week, month, quarter, year
    
    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .quarter: return "Quarter"
        case .year: return "Year"
        }
    }
}