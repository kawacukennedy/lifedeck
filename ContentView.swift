import SwiftUI

// MARK: - Content View with iPad Optimizations

struct ContentView: View {
    @State private var selectedSection: SidebarSection = .dashboard
    @State private var user: User = loadUser()

    var body: some View {
        AdaptiveNavigationView {
            // Main content area - switches based on selection
            Group {
                switch selectedSection {
                case .dashboard:
                    SimpleDashboardView(user: user)
                case .deck:
                    DeckView(user: user)
                case .analytics:
                    SimpleAnalyticsView(user: user)
                case .profile:
                    SimpleProfileView(user: user)
                }
            }
            .onChange(of: selectedSection) { _ in
                // Refresh user data when switching sections
                user = loadUser()
            }
        }
    }
}

// MARK: - Sidebar Sections

enum SidebarSection: String, CaseIterable {
    case dashboard = "Dashboard"
    case deck = "Daily Deck"
    case analytics = "Analytics"
    case profile = "Profile"
    
    var systemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .deck: return "rectangle.stack.fill"
        case .analytics: return "chart.bar.fill"
        case .profile: return "person.fill"
        }
    }
    
    var destination: some View {
        switch self {
        case .dashboard:
            return SimpleDashboardView(user: loadUser())
        case .deck:
            return DeckView(user: loadUser())
        case .analytics:
            return SimpleAnalyticsView(user: loadUser())
        case .profile:
            return SimpleProfileView(user: loadUser())
        }
    }
}

// MARK: - Simple Dashboard View

struct SimpleDashboardView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 15) {
                    Text("Welcome back, \(user.name)")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                    
                    Text("Here's your progress overview")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Life Score
                lifeScoreSection
                
                // Domain Breakdown
                domainProgressSection
                
                // Stats
                statsSection
            }
            .padding(30)
        }
        .navigationTitle("Dashboard")
    }
    
    private var lifeScoreSection: some View {
        VStack(spacing: 20) {
            Text("Life Score")
                .font(.title2)
                .foregroundColor(.primary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: CGFloat(user.progress.lifeScore / 100))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 5) {
                    Text("\(Int(user.progress.lifeScore))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("LIFE SCORE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tracking(1.2)
                }
            }
            
            Text(getLifeScoreDescription())
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var domainProgressSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Domain Progress")
                .font(.title2)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                ForEach(LifeDomain.allCases) { domain in
                    domainCard(domain: domain, score: user.progress.scoreForDomain(domain))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Progress")
                .font(.title2)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                statCard(icon: "flame.fill", title: "Current Streak", value: "\(user.progress.currentStreak)", unit: "days", color: .green)
                statCard(icon: "star.fill", title: "Life Points", value: "\(user.progress.lifePoints)", unit: "points", color: .orange)
                statCard(icon: "checkmark.circle.fill", title: "Cards Done", value: "\(user.progress.totalCardsCompleted)", unit: "total", color: .blue)
            }
        }
        .padding(.horizontal)
    }
    
    private func domainCard(domain: LifeDomain, score: Double) -> some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: domain.icon)
                    .font(.title2)
                    .foregroundColor(Color.forDomain(domain))
                
                Spacer()
                
                Text("\(Int(score))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.forDomain(domain))
            }
            
            Text(domain.displayName)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func statCard(icon: String, title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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

// MARK: - Simple Analytics View

struct SimpleAnalyticsView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Analytics")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                
                Text("Track your progress across all life domains")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Domain breakdown
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                    ForEach(LifeDomain.allCases) { domain in
                        analyticsDomainCard(domain: domain, score: user.progress.scoreForDomain(domain))
                    }
                }
            }
            .padding(30)
        }
        .navigationTitle("Analytics")
    }
    
    private func analyticsDomainCard(domain: LifeDomain, score: Double) -> some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: domain.icon)
                    .font(.title2)
                    .foregroundColor(Color.forDomain(domain))
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(score))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.forDomain(domain))
                    
                    Text("+5% this week")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(domain.displayName)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Simple Profile View

struct SimpleProfileView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Profile")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                
                Text("Manage your account and preferences")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // User info
                VStack(spacing: 20) {
                    HStack {
                        Text("Name:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(user.name)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Cards Completed:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(user.progress.totalCardsCompleted)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Current Streak:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(user.progress.currentStreak) days")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(30)
        }
        .navigationTitle("Profile")
    }
}

// MARK: - User Loading

private func loadUser() -> User {
    // Simple fallback user loading
    return User(name: "User")
}

#Preview {
    ContentView()
}