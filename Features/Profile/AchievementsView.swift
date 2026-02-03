import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var user: User
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: DesignSystem.Spacing.md)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Summary stats
                    summaryHeader
                    
                    // Achievement Categories
                    ForEach(LifeDomain.allCases) { domain in
                        achievementCategorySection(for: domain)
                    }
                    
                    // General Achievements
                    achievementCategorySection(for: nil)
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .background(DesignSystem.Gradients.background)
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
    
    private var summaryHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(user.achievements.filter { $0.isUnlocked }.count) / \(user.achievements.count)")
                    .font(DesignSystem.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Achievements Unlocked")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                let progress = Double(user.achievements.filter { $0.isUnlocked }.count) / max(Double(user.achievements.count), 1)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(DesignSystem.Colors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding()
        .background(.white.opacity(0.05))
        .cornerRadius(DesignSystem.Spacing.cornerRadius)
    }
    
    private func achievementCategorySection(for domain: LifeDomain?) -> some View {
        let domainAchievements = user.achievements.filter { $0.category == domain }
        
        guard !domainAchievements.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    if let domain = domain {
                        Image(systemName: domain.icon)
                            .foregroundColor(Color.forDomain(domain))
                        Text(domain.displayName)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "star.fill")
                            .foregroundColor(DesignSystem.Colors.premium)
                        Text("General")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.white)
                    }
                }
                
                LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                    ForEach(domainAchievements) { achievement in
                        achievementCell(achievement)
                    }
                }
            }
        )
    }
    
    private func achievementCell(_ achievement: Achievement) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? .white.opacity(0.12) : .white.opacity(0.05))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? (achievement.category != nil ? Color.forDomain(achievement.category!) : DesignSystem.Colors.premium) : .gray)
            }
            
            Text(achievement.title)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.bold)
                .foregroundColor(achievement.isUnlocked ? .white : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if !achievement.isUnlocked {
                Text("Locked")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(achievement.isUnlocked ? .white.opacity(0.05) : .clear)
        .cornerRadius(DesignSystem.Spacing.smallCornerRadius)
        .onTapGesture {
            // Show achievement detail?
        }
    }
}
