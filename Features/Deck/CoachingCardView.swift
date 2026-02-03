import SwiftUI

// MARK: - Coaching Card View
struct CoachingCardView: View {
    @ObservedObject var card: CoachingCard
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            cardHeader
            
            // Content
            cardContent
            
            // Footer
            cardFooter
        }
        .cardStyle()
        .if(card.isPremium) { view in
            view.premiumGlow()
        }
        .frame(maxWidth: 350)
        .onTapGesture {
            withAnimation(DesignSystem.Animation.standard) {
                showingDetails.toggle()
            }
        }
        .sheet(isPresented: $showingDetails) {
            CardDetailView(card: card)
        }
    }
    
    private var cardHeader: some View {
        HStack {
            // Domain icon and name
            HStack(spacing: 8) {
                Image(systemName: card.domainIcon)
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(card.domainColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.domain.displayName)
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(card.domainColor)
                    
                    Text(card.priority.displayName.uppercased())
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(card.priority.color)
                }
            }
            
            Spacer()
            
            // Premium badge
            if card.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.premium)
                    Text("PRO")
                        .font(DesignSystem.Typography.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.premium)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(DesignSystem.Colors.premium.opacity(0.2))
                .cornerRadius(6)
            }
            
            // Bookmark button
            Button(action: {
                withAnimation(DesignSystem.Animation.buttonPress) {
                    card.toggleBookmark()
                }
            }) {
                Image(systemName: card.isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(card.isBookmarked ? DesignSystem.Colors.premium : DesignSystem.Colors.textSecondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(DesignSystem.Spacing.md)
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Title
            Text(card.title)
                .font(DesignSystem.Typography.cardTitle)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.leading)
            
            // Description
            Text(card.description)
                .font(DesignSystem.Typography.cardSubtitle)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            
            // Action
            HStack(spacing: 8) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(card.actionText)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.primary)
                    .fontWeight(.medium)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .cornerRadius(DesignSystem.Spacing.smallCornerRadius)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
    
    private var cardFooter: some View {
        HStack {
            // Difficulty stars
            HStack(spacing: 2) {
                Text(card.difficultyStars)
                    .font(DesignSystem.Typography.caption2)
                
                Text("Difficulty")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Time estimate
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(card.estimatedDuration.color)
                
                Text(card.timeEstimateDisplay)
                    .font(DesignSystem.Typography.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Points
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.premium)
                
                Text("\(card.points) pts")
                    .font(DesignSystem.Typography.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.sm)
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
                    cardDetailHeader
                    
                    // Title and Description
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text(card.title)
                            .font(DesignSystem.Typography.title1)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text(card.description)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(nil)
                    }
                    
                    // Action Box
                    actionBox
                    
                    // Details
                    detailsGrid
                    
                    // Tags
                    if !card.tags.isEmpty {
                        tagsView
                    }
                    
                    // User Note
                    userNoteSection
                }
                .padding(DesignSystem.Spacing.md)
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
    
    private var cardDetailHeader: some View {
        HStack {
            // Domain info
            HStack(spacing: 12) {
                Image(systemName: card.domainIcon)
                    .font(.system(size: 24))
                    .foregroundColor(card.domainColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.domain.displayName)
                        .font(DesignSystem.Typography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(card.domainColor)
                    
                    Text(card.priority.displayName.uppercased())
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(card.priority.color)
                }
            }
            
            Spacer()
            
            // Premium badge
            if card.isPremium {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.premium)
                    Text("PREMIUM")
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.premium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DesignSystem.Colors.premium.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surfaceVariant)
        .cornerRadius(DesignSystem.Spacing.cornerRadius)
    }
    
    private var actionBox: some View {
        HStack(spacing: 12) {
            Image(systemName: "target")
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Action")
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .textCase(.uppercase)
                
                Text(card.actionText)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.text)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.primary.opacity(0.1))
        .cornerRadius(DesignSystem.Spacing.cornerRadius)
    }
    
    private var detailsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
            detailItem(icon: "star.fill", label: "Points", value: "\(card.points)", color: DesignSystem.Colors.premium)
            detailItem(icon: "clock.fill", label: "Duration", value: card.timeEstimateDisplay, color: card.estimatedDuration.color)
            detailItem(icon: "chart.bar.fill", label: "Difficulty", value: card.difficultyStars, color: DesignSystem.Colors.text)
            detailItem(icon: "flag.fill", label: "Priority", value: card.priority.displayName, color: card.priority.color)
        }
    }
    
    private func detailItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(color)
                
                Text(label)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Text(value)
                .font(DesignSystem.Typography.body)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.text)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surfaceVariant)
        .cornerRadius(DesignSystem.Spacing.smallCornerRadius)
    }
    
    private var tagsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Tags")
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                ForEach(card.tags, id: \.self) { tag in
                    Text(tag)
                        .font(DesignSystem.Typography.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.Colors.primary.opacity(0.1))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var userNoteSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Notes")
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
            
            if let note = card.userNote {
                Text(note)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.surfaceVariant)
                    .cornerRadius(DesignSystem.Spacing.smallCornerRadius)
            } else {
                Text("Add your notes here...")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.surfaceVariant)
                    .cornerRadius(DesignSystem.Spacing.smallCornerRadius)
            }
        }
    }
}