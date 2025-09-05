import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var user: User
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Life Score Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Life Score Overview
                    VStack {
                        Text("Life Score")
                            .font(.headline)
                            .foregroundColor(.lifeDeckTextSecondary)
                        
                        Text("\(Int(user.progress.lifeScore))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.lifeDeckPrimary)
                        
                        Text("Overall wellness score")
                            .font(.caption)
                            .foregroundColor(.lifeDeckTextTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.lifeDeckCardBackground)
                    .cornerRadius(16)
                    .lifeDeckCardShadow()
                    .padding(.horizontal)
                    
                    // Domain Scores
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(LifeDomain.allCases) { domain in
                            DomainScoreCard(domain: domain, score: user.progress.scoreForDomain(domain))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    VStack(alignment: .leading) {
                        Text("Progress")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            StatCard(title: "Current Streak", value: "\(user.progress.currentStreak)", unit: "days")
                            StatCard(title: "Life Points", value: "\(user.progress.lifePoints)", unit: "points")
                            StatCard(title: "Cards Completed", value: "\(user.progress.totalCardsCompleted)", unit: "total")
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.lifeDeckBackground.ignoresSafeArea())
        }
    }
}

struct DomainScoreCard: View {
    let domain: LifeDomain
    let score: Double
    
    var body: some View {
        VStack {
            Image(systemName: domain.icon)
                .font(.title2)
                .foregroundColor(Color.forDomain(domain))
            
            Text(domain.displayName)
                .font(.caption)
                .foregroundColor(.lifeDeckTextSecondary)
            
            Text("\(Int(score))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.forDomain(domain))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.lifeDeckCardBackground)
        .cornerRadius(12)
        .lifeDeckSubtleShadow()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.lifeDeckPrimary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.lifeDeckTextTertiary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.lifeDeckTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.lifeDeckCardBackground)
        .cornerRadius(8)
        .lifeDeckSubtleShadow()
    }
}
