//
//  WatchDeckView.swift
//  LifeDeckWatch Watch App
//
//  Created on 2024
//

import SwiftUI

struct WatchDeckView: View {
    @StateObject private var viewModel = WatchDeckViewModel()
    @State private var currentCardIndex = 0

    var body: some View {
        VStack {
            if viewModel.dailyCards.isEmpty {
                VStack {
                    Text("No cards available")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Button(action: viewModel.loadCards) {
                        Text("Load Cards")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            } else {
                ZStack {
                    ForEach(0..<min(viewModel.dailyCards.count, 3), id: \.self) { index in
                        WatchCardView(card: viewModel.dailyCards[index])
                            .offset(x: CGFloat(index - currentCardIndex) * 20)
                            .scaleEffect(index == currentCardIndex ? 1.0 : 0.9)
                            .opacity(index == currentCardIndex ? 1.0 : 0.7)
                            .gesture(
                                DragGesture()
                                    .onEnded { gesture in
                                        let threshold: CGFloat = 50
                                        if gesture.translation.width > threshold {
                                            // Swipe right - complete
                                            viewModel.completeCard(viewModel.dailyCards[index].id)
                                        } else if gesture.translation.width < -threshold {
                                            // Swipe left - dismiss
                                            viewModel.dismissCard(viewModel.dailyCards[index].id)
                                        }
                                    }
                            )
                    }
                }

                // Card indicators
                HStack(spacing: 4) {
                    ForEach(0..<min(viewModel.dailyCards.count, 3), id: \.self) { index in
                        Circle()
                            .fill(index == currentCardIndex ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.top, 8)

                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.dismissCard(viewModel.dailyCards[currentCardIndex].id)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .font(.title2)
                    }

                    Button(action: {
                        viewModel.completeCard(viewModel.dailyCards[currentCardIndex].id)
                    }) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            viewModel.loadCards()
        }
        .onReceive(NotificationCenter.default.publisher(for: .watchDataReceived)) { notification in
            if let data = notification.object as? [String: Any],
               let cards = data["dailyCards"] as? [[String: Any]] {
                viewModel.dailyCards = cards.compactMap { WatchCard.fromDict($0) }
            }
        }
    }
}

struct WatchCardView: View {
    let card: WatchCard

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(card.domainColor))
                .frame(height: 120)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(card.actionText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3)

                Spacer()

                HStack {
                    Text(card.domain)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Text(card.priority)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(12)
        }
        .frame(height: 120)
    }
}