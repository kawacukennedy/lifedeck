import SwiftUI
import Foundation

// MARK: - Coaching Card View
struct CoachingCardView: View {
    @ObservedObject var card: CoachingCard
    @State private var isShowingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: card.domainIcon)
                            .font(.title3)
                            .foregroundColor(card.domainColor)
                        
                        Text(card.domain.displayName)
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(card.domainColor)
                            .textCase(.uppercase)
                    }
                    
                    Text(card.title)
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.text)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if card.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.premium)
                        
                        Text("PREMIUM")
                            .font(DesignSystem.Typography.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.premium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.premium.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
            
            Divider()
                .background(DesignSystem.Colors.secondaryBackground)
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                Text(card.description)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                // Action Box
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("ACTION")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .textCase(.uppercase)
                        
                        Text(card.actionText)
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.medium)
            }
            .padding(DesignSystem.Spacing.cardPadding)
            
            Divider()
                .background(DesignSystem.Colors.secondaryBackground)
            
            // Footer
            HStack(spacing: 20) {
                // Difficulty
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(card.difficultyStars)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Duration
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(card.estimatedDuration.color)
                    Text(card.timeEstimateDisplay)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Points
                HStack(spacing: 4) {
                    Image(systemName: "star.circle.fill")
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.premium)
                    Text("\(card.points)")
                        .font(DesignSystem.Typography.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.text)
                }
            }
            .padding(DesignSystem.Spacing.cardPadding)
        }
        .background(DesignSystem.Colors.surface)
                .cornerRadius(DesignSystem.CornerRadius.lg)
        .shadow(color: DesignSystem.Shadows.medium.color, radius: DesignSystem.Shadows.medium.radius, x: DesignSystem.Shadows.medium.x, y: DesignSystem.Shadows.medium.y)
        .onTapGesture {
            withAnimation(DesignSystem.Animation.spring) {
                isShowingDetails.toggle()
            }
        }
        .sheet(isPresented: $isShowingDetails) {
            CardDetailView(card: card)
        }
    }
}

// MARK: - Card Detail View
struct CardDetailView: View {
    @ObservedObject var card: CoachingCard
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: card.domainIcon)
                                    .font(.title2)
                                    .foregroundColor(card.domainColor)
                                
                                Text(card.domain.displayName)
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(card.domainColor)
                                    .textCase(.uppercase)
                            }
                            
                            Text(card.title)
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(DesignSystem.Colors.text)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        if card.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption)
                                    .foregroundColor(DesignSystem.Colors.premium)
                                
                                Text("PREMIUM")
                                    .font(DesignSystem.Typography.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.premium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.premium.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal, DesignSystem.Spacing.contentPadding)
                    
                    // Content
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text(card.description)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.text)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)
                        
                        // Action Box
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("ACTION")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .textCase(.uppercase)
                                
                                Text(card.actionText)
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.primary.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .cardStyle()
                    .padding(.horizontal, DesignSystem.Spacing.contentPadding)
                    
                    // Details Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                        detailCard(
                            icon: "star.fill",
                            iconColor: .yellow,
                            title: "Difficulty",
                            value: card.difficultyStars
                        )
                        
                        detailCard(
                            icon: "clock",
                            iconColor: card.estimatedDuration.color,
                            title: "Duration",
                            value: card.timeEstimateDisplay
                        )
                        
                        detailCard(
                            icon: "star.circle.fill",
                            iconColor: DesignSystem.Colors.premium,
                            title: "Points",
                            value: "\(card.points)"
                        )
                        
                        detailCard(
                            icon: "flag.fill",
                            iconColor: card.priority.color,
                            title: "Priority",
                            value: card.priority.displayName
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.contentPadding)
                    
                    // Tags
                    if !card.tags.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Tags")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            HStack(spacing: 8) {
                                ForEach(card.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(DesignSystem.Typography.caption1)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(DesignSystem.Colors.secondaryBackground)
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal, DesignSystem.Spacing.contentPadding)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .navigationTitle("Card Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func detailCard(icon: String, iconColor: Color, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Text(value)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
}

// Simple FlowLayout for tags
// Simple FlowLayout removed - using simpler approach
