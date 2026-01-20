import SwiftUI

// MARK: - Deck View
struct DeckView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = DeckViewModel()
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Card Stack
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.currentCardIndex >= viewModel.cards.count {
                        emptyStateView
                    } else {
                        cardStackView
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    if !viewModel.isLoading && viewModel.currentCardIndex < viewModel.cards.count {
                        actionButtonsView
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Daily Deck")
            .navigationBarTitleDisplayMode(.inline)
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
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.remainingCards) cards remaining")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Text("Today's Deck")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.text)
                }
                
                Spacer()
                
                if !subscriptionManager.isPremium {
                    Button(action: { showingPaywall = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                            Text("Premium")
                                .font(DesignSystem.Typography.caption1)
                        }
                        .foregroundColor(DesignSystem.Colors.premium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.premium.opacity(0.2))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.contentPadding)
            .padding(.top, 8)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading cards...")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(DesignSystem.Colors.success)
            
            Text("All caught up!")
                .font(DesignSystem.Typography.title1)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("Great job completing today's cards!")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Refresh Cards") {
                viewModel.currentCardIndex = 0
                viewModel.loadCards()
            }
            .primaryButtonStyle()
            .padding(.horizontal, DesignSystem.Spacing.contentPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var cardStackView: some View {
        ZStack {
            ForEach(Array(viewModel.visibleCards.enumerated()), id: \.element.id) { index, card in
                let cardIndex = viewModel.currentCardIndex + index
                let isTopCard = index == 0
                
                CoachingCardView(card: card)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 500)
                    .offset(
                        isTopCard ? viewModel.dragOffset : CGSize(width: 0, height: CGFloat(index * 10))
                    )
                    .rotationEffect(.degrees(isTopCard ? viewModel.dragRotation : 0))
                    .scaleEffect(isTopCard ? 1.0 : 0.95 - CGFloat(index) * 0.05)
                    .zIndex(Double(viewModel.cards.count - cardIndex))
                    .gesture(
                        isTopCard ? DragGesture()
                            .onChanged { value in
                                viewModel.updateDrag(offset: value.translation)
                            }
                            .onEnded { value in
                                viewModel.handleDragEnd(offset: value.translation)
                            } : nil
                    )
                    .opacity(isTopCard ? 1.0 : 0.7)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 16) {
            // Snooze Button
            Button(action: {
                viewModel.swipeCard(direction: .down)
            }) {
                Image(systemName: "moon.zzz.fill")
                    .font(.title3)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 56, height: 56)
                    .background(DesignSystem.Colors.secondaryBackground)
                    .clipShape(Circle())
            }
            
            // Skip Button
            Button(action: {
                withAnimation {
                    viewModel.swipeCard(direction: .left)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(DesignSystem.Colors.error)
                    .clipShape(Circle())
            }
            
            // Complete Button
            Button(action: {
                withAnimation {
                    viewModel.swipeCard(direction: .right)
                }
            }) {
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(DesignSystem.Colors.success)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.contentPadding)
    }
}