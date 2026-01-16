import SwiftUI

// MARK: - Analytics View

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
                        analyticsCard(domain: domain, score: user.progress.scoreForDomain(domain))
                    }
                }
            }
            .padding(30)
        }
        .navigationTitle("Analytics")
    }
    
    private func analyticsCard(domain: LifeDomain, score: Double) -> some View {
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

#Preview {
    SimpleAnalyticsView(user: User(name: "Test User"))
}