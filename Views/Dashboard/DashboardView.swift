import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(user: user))
    }

    var body: some View {
        ScrollView {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: DesignSystem.xl) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Good \(greetingTime())")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))

                            Text(viewModel.user.name)
                                .font(DesignSystem.h1)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Life Score
                        ZStack {
                            Circle()
                                .stroke(Color.primary.opacity(0.3), lineWidth: 8)
                                .frame(width: 80, height: 80)

                            Circle()
                                .trim(from: 0, to: viewModel.lifeScore / 100)
                                .stroke(Color.primary, lineWidth: 8)
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))

                            VStack {
                                Text("\(Int(viewModel.lifeScore))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("Score")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .accessibilityLabel("Life Score: \(Int(viewModel.lifeScore)) out of 100")
                        .accessibilityValue("\(Int(viewModel.lifeScore))%")
                    }
                    .padding(.horizontal)

                    // Domain Progress
                    VStack(alignment: .leading, spacing: DesignSystem.md) {
                        Text("Life Domains")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ForEach(viewModel.user.lifeDomains, id: \.type) { domain in
                            DomainProgressRow(domain: domain)
                        }
                    }

                    // Recent Cards
                    VStack(alignment: .leading, spacing: DesignSystem.md) {
                        Text("Recent Activity")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ForEach(viewModel.recentCards.prefix(3), id: \.id) { card in
                            RecentCardRow(card: card)
                        }
                    }

                    // Streaks & Achievements
                    VStack(alignment: .leading, spacing: DesignSystem.md) {
                        Text("Streaks & Points")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        HStack(spacing: DesignSystem.md) {
                            StatCard(
                                title: "Current Streak",
                                value: "\(viewModel.user.streaks.currentStreak)",
                                icon: "flame.fill",
                                color: .orange
                            )

                            StatCard(
                                title: "Life Points",
                                value: "\(viewModel.user.lifePoints)",
                                icon: "star.fill",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }

    private func greetingTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }
}

struct DomainProgressRow: View {
    let domain: LifeDomain

    var body: some View {
        HStack(spacing: DesignSystem.md) {
            ZStack {
                Circle()
                    .fill(domainColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                domainIcon
                    .foregroundColor(domainColor)
            }

            VStack(alignment: .leading) {
                Text(domain.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(domain.completedCards) cards completed")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(Int(domain.score))%")
                    .font(.headline)
                    .foregroundColor(.white)

                ProgressView(value: domain.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: domainColor))
                    .frame(width: 80)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
        .padding(.horizontal)
    }

    private var domainColor: Color {
        switch domain.type {
        case .health: return .health
        case .finance: return .finance
        case .productivity: return .productivity
        case .mindfulness: return .mindfulness
        }
    }

    private var domainIcon: some View {
        switch domain.type {
        case .health: return Image(systemName: "heart.fill")
        case .finance: return Image(systemName: "dollarsign.circle.fill")
        case .productivity: return Image(systemName: "checkmark.circle.fill")
        case .mindfulness: return Image(systemName: "brain.head.profile")
        }
    }
}

struct RecentCardRow: View {
    let card: CoachingCard

    var body: some View {
        HStack(spacing: DesignSystem.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(domainColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                domainIcon
                    .foregroundColor(domainColor)
            }

            VStack(alignment: .leading) {
                Text(card.text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(card.domain.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            if let action = card.action {
                Image(systemName: actionIcon(action))
                    .foregroundColor(actionColor(action))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
        .padding(.horizontal)
    }

    private var domainColor: Color {
        switch card.domain {
        case .health: return .health
        case .finance: return .finance
        case .productivity: return .productivity
        case .mindfulness: return .mindfulness
        }
    }

    private var domainIcon: some View {
        switch card.domain {
        case .health: return Image(systemName: "heart.fill")
        case .finance: return Image(systemName: "dollarsign.circle.fill")
        case .productivity: return Image(systemName: "checkmark.circle.fill")
        case .mindfulness: return Image(systemName: "brain.head.profile")
        }
    }

    private func actionIcon(_ action: CardAction) -> String {
        switch action {
        case .complete: return "checkmark.circle.fill"
        case .dismiss: return "xmark.circle.fill"
        case .snooze: return "clock.fill"
        }
    }

    private func actionColor(_ action: CardAction) -> Color {
        switch action {
        case .complete: return .success
        case .dismiss: return .error
        case .snooze: return .warning
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
    }
}