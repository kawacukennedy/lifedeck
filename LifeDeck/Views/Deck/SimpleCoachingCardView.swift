import SwiftUI

// MARK: - Deck View
struct DeckView: View {
    @StateObject private var viewModel = DeckViewModel()
    @State private var showingPaywall = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Daily Cards")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading cards...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                } else {
                    ForEach(viewModel.cards.indices, id: \.self) { index in
                        if index >= viewModel.currentCardIndex && index < viewModel.currentCardIndex + 3 {
                            SimpleCoachingCardView(card: viewModel.cards[index])
                                .zIndex(Double(viewModel.cards.count - index - index + 1))
                                .offset(
                                    viewModel.dragOffset
                                )
                                .rotation(
                                    viewModel.dragRotation
                                )
                                .scaleEffect(
                                    index == viewModel.currentCardIndex ? 1.0 : 0.8
                                )
                            }
                        }
                    }
                    
                    if viewModel.currentCardIndex >= viewModel.cards.count {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                            
                            Text("All caught up!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Great job completing today's cards!")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Refresh Cards") {
                            viewModel.loadCards()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCards()
        }
        .refreshable {
            viewModel.loadCards()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Card View
struct SimpleCoachingCardView: View {
    let card: SimpleCoachingCard
    @State private var isShowingDetails = false
    
    var body: some View {
        cardView
            .onTapGesture {
                withAnimation(.spring()) {
                    isShowingDetails.toggle()
                }
            }
            .sheet(isPresented: isShowingDetails) {
                CardDetailView(card: card)
            }
    }
    
    private var cardView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: card.domain.icon)
                            .font(.title3)
                            .foregroundColor(Color(card.domain.color))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.domain.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(card.domain.color))
                            
                            Text(card.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer()
                    
                    if card.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(Color.orange))
                            
                            Text("PREMIUM")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.orange))
                        }
                        .padding(4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(card.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    VStack {
                        Text("Action")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        }
                        
                        Text(card.actionText)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Footer
            HStack {
                // Difficulty
                VStack {
                    HStack(spacing: 2) {
                        ForEach(0..<Int(card.difficulty.rounded())) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(Color.yellow))
                                Text("Difficulty")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(card.difficulty, specifier: "%.0f")")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(card.estimatedDuration.color)
                            Text("Duration")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(card.timeEstimateDisplay)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.circle")
                                .font(.caption2)
                                .font(.caption2)
                                .foregroundColor(Color.orange))
                            Text("Points")
                                .font(.caption2)
                                .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(card.points)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "flag")
                                .font(.caption2)
                                .font(.caption2)
                                .foregroundColor(card.priority.color))
                            Text("Priority")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(card.priority.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Card Detail View
struct CardDetailView: View {
    let card: SimpleCoachingCard
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: card.domain.icon)
                            .font(.title3)
                            .foregroundColor(Color(card.domain.color))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.domain.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(card.domain.color))
                            
                            Text(card.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer()
                    
                    if card.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .font(.caption)
                                .foregroundColor(Color.orange))
                            
                            Text("PREMIUM")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.orange))
                        }
                        .padding(4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(card.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Action")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        }
                        
                        Text(card.actionText)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Details Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), spacing: 12) {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                                .foregroundColor(Color.yellow)
                            Text("Difficulty")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(card.difficultyStars)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(card.estimatedDuration.color)
                            Text("Duration")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(card.timeEstimateDisplay)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.circle")
                                .font(.caption2)
                                .font(.caption2)
                                .foregroundColor(Color.orange))
                            Text("Points")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(card.points)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "flag")
                                .font(.caption2)
                                .font(.caption2)
                                .foregroundColor(card.priority.color))
                            Text("Priority")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(card.priority.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Tags
            if !card.tags.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        }
                        
                        Spacer()
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), spacing: 8) {
                            ForEach(card.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Notes
                VStack(spacing: 12) {
                    HStack {
                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        }
                        
                        Spacer()
                        
                        if let note = card.userNote {
                            Text(note)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Text("Add your notes here...")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            }
            
            .padding(16)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}