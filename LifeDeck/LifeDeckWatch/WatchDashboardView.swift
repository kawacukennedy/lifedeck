import SwiftUI

struct WatchDashboardView: View {
    @EnvironmentObject var watchManager: WatchDataManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Life Score
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: CGFloat(watchManager.lifeScore / 100))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text("\(Int(watchManager.lifeScore))")
                                .font(.system(size: 20, weight: .bold))
                            Text("SCORE")
                                .font(.system(size: 8))
                                .opacity(0.7)
                        }
                    }

                    Text("Life Score")
                        .font(.system(size: 12))
                }

                // Stats Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatCard(
                        icon: "🔥",
                        value: "\(watchManager.currentStreak)",
                        label: "Streak"
                    )

                    StatCard(
                        icon: "🎯",
                        value: "\(watchManager.todaysCards)",
                        label: "Cards"
                    )

                    StatCard(
                        icon: "👣",
                        value: "\(watchManager.stepCount)",
                        label: "Steps"
                    )

                    StatCard(
                        icon: watchManager.isConnected ? "📱" : "📵",
                        value: watchManager.isConnected ? "Yes" : "No",
                        label: "Phone"
                    )
                }

                // Quick Actions
                VStack(spacing: 8) {
                    Button(action: {
                        // Quick log a card completion
                        WKInterfaceDevice.current().play(.click)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Card")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                    }

                    Button(action: {
                        // Refresh data from phone
                        watchManager.fetchTodaySteps()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("LifeDeck")
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 20))

            Text(value)
                .font(.system(size: 16, weight: .bold))

            Text(label)
                .font(.system(size: 10))
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}