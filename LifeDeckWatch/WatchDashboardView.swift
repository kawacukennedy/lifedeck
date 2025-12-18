//
//  WatchDashboardView.swift
//  LifeDeckWatch Watch App
//
//  Created on 2024
//

import SwiftUI

struct WatchDashboardView: View {
    @StateObject private var viewModel = WatchDashboardViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            VStack(spacing: 8) {
                Text("LifeDeck")
                    .font(.headline)
                    .foregroundColor(.blue)

                HStack {
                    VStack {
                        Text("\(viewModel.lifeScore)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack {
                        Text("\(viewModel.currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Domain Scores
                VStack(spacing: 4) {
                    DomainScoreRow(domain: "Health", score: viewModel.healthScore, color: .green)
                    DomainScoreRow(domain: "Finance", score: viewModel.financeScore, color: .blue)
                    DomainScoreRow(domain: "Productivity", score: viewModel.productivityScore, color: .orange)
                    DomainScoreRow(domain: "Mindfulness", score: viewModel.mindfulnessScore, color: .purple)
                }

                Spacer()

                Button(action: viewModel.refreshData) {
                    Text("Refresh")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .tag(0)

            // Cards Tab
            VStack {
                Text("Daily Cards")
                    .font(.headline)

                if viewModel.dailyCards.isEmpty {
                    Text("No cards today")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ScrollView {
                        ForEach(viewModel.dailyCards) { card in
                            WatchCardRow(card: card)
                                .onTapGesture {
                                    viewModel.completeCard(card.id)
                                }
                        }
                    }
                }

                Spacer()

                Button(action: viewModel.loadNewCards) {
                    Text("Load Cards")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .tag(1)

            // Achievements Tab
            VStack {
                Text("Achievements")
                    .font(.headline)

                ScrollView {
                    ForEach(viewModel.recentAchievements) { achievement in
                        VStack(alignment: .leading) {
                            Text(achievement.title)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(achievement.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Spacer()
            }
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            viewModel.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dashboardDataUpdated)) { notification in
            if let data = notification.object as? [String: Any] {
                viewModel.updateFromNotification(data)
            }
        }
    }
}

struct DomainScoreRow: View {
    let domain: String
    let score: Int
    let color: Color

    var body: some View {
        HStack {
            Text(domain.prefix(1))
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 20)

            ProgressView(value: Double(score) / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .frame(height: 4)

            Text("\(score)")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 25)
        }
    }
}

struct WatchCardRow: View {
    let card: WatchCard

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(card.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(card.domain)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if card.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            } else {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}