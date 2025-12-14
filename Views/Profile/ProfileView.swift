import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var showPaywall = false

    init(user: User) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: DesignSystem.xl) {
                    // Profile Header
                    VStack(spacing: DesignSystem.md) {
                        ZStack {
                            Circle()
                                .fill(Color.primary.opacity(0.2))
                                .frame(width: 100, height: 100)

                            Text(String(viewModel.user.name.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color.primary)
                        }

                        Text(viewModel.user.name)
                            .font(DesignSystem.h1)
                            .foregroundColor(.white)

                        Text("Joined \(viewModel.user.joinedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Subscription Status
                    SubscriptionStatusCard()

                    // Settings Sections
                    VStack(spacing: DesignSystem.lg) {
                        SettingsSection(title: "Preferences") {
                            ToggleRow(
                                title: "Notifications",
                                isOn: $viewModel.user.preferences.notificationsEnabled
                            ) { enabled in
                                viewModel.updatePreferences(notificationsEnabled: enabled)
                            }

                            NavigationLink(destination: FocusAreasView(selectedAreas: $viewModel.user.preferences.focusAreas)) {
                                SettingsRow(title: "Focus Areas", value: "\(viewModel.user.preferences.focusAreas.count) selected")
                            }
                        }

                        SettingsSection(title: "Account") {
                            SettingsRow(title: "Life Points", value: "\(viewModel.user.lifePoints)")
                            SettingsRow(title: "Current Streak", value: "\(viewModel.user.streaks.currentStreak) days")
                            SettingsRow(title: "Longest Streak", value: "\(viewModel.user.streaks.longestStreak) days")
                        }

                        SettingsSection(title: "Support") {
                            SettingsRow(title: "Version", value: "1.0.0")
                            Button(action: {}) {
                                SettingsRow(title: "Contact Support", showChevron: false)
                            }
                            Button(action: {}) {
                                SettingsRow(title: "Privacy Policy", showChevron: false)
                            }
                            Button(action: {}) {
                                SettingsRow(title: "Terms of Service", showChevron: false)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func SubscriptionStatusCard() -> some View {
        VStack(spacing: DesignSystem.md) {
            HStack {
                Text("Subscription")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if subscriptionManager.subscription.tier == .premium {
                    Text("PREMIUM")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color.premiumGold)
                        .padding(.horizontal, DesignSystem.sm)
                        .padding(.vertical, 4)
                        .background(Color.premiumGold.opacity(0.2))
                        .cornerRadius(DesignSystem.cornerRadius / 2)
                } else {
                    Button(action: { showPaywall = true }) {
                        Text("UPGRADE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                            .padding(.horizontal, DesignSystem.sm)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.2))
                            .cornerRadius(DesignSystem.cornerRadius / 2)
                    }
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(subscriptionManager.subscription.tier.rawValue.capitalized)
                        .font(.title2)
                        .foregroundColor(.white)

                    if let expiration = subscriptionManager.subscription.expirationDate {
                        Text("Expires: \(expiration.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                if subscriptionManager.subscription.tier == .free {
                    VStack(alignment: .trailing) {
                        Text("5/5")
                            .font(.title3)
                            .foregroundColor(.white)
                        Text("Cards today")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
        .padding(.horizontal)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.sm) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            content
        }
    }
}

struct SettingsRow: View {
    let title: String
    var value: String? = nil
    var showChevron = true

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)

            Spacer()

            if let value = value {
                Text(value)
                    .foregroundColor(.white.opacity(0.6))
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { newValue in
                    onChange(newValue)
                }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(DesignSystem.cornerRadius)
    }
}

struct FocusAreasView: View {
    @Binding var selectedAreas: [LifeDomainType]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)

            VStack {
                Text("Focus Areas")
                    .font(DesignSystem.h1)
                    .foregroundColor(.white)
                    .padding()

                List {
                    ForEach(LifeDomainType.allCases, id: \.self) { domain in
                        Button(action: { toggleArea(domain) }) {
                            HStack {
                                Text(domain.rawValue.capitalized)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedAreas.contains(domain) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.primary)
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Done")
                }
                .buttonStyle(.primary)
                .padding()
            }
        }
    }

    private func toggleArea(_ domain: LifeDomainType) {
        if selectedAreas.contains(domain) {
            selectedAreas.removeAll { $0 == domain }
        } else {
            selectedAreas.append(domain)
        }
    }
}