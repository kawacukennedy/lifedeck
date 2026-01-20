import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingSettings = false
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Overview
                    statsOverview
                    
                    // Settings
                    settingsSection
                    
                    // Subscription Status
                    subscriptionSection
                    
                    // About
                    aboutSection
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(user)
                    .environmentObject(notificationManager)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Avatar and name
            HStack(spacing: DesignSystem.Spacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(DesignSystem.Gradients.primary)
                        .frame(width: 80, height: 80)
                    
                    Text(user.name.prefix(2).uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(user.name)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    if let email = user.email {
                        Text(email)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        if user.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.premium)
                                Text("PREMIUM")
                                    .font(DesignSystem.Typography.caption1)
                                    .fontWeight(.bold)
                                    .foregroundColor(DesignSystem.Colors.premium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.premium.opacity(0.2))
                            .cornerRadius(6)
                        }
                        
                        Text("Member since \(user.joinDate.formatted(date: .abbreviated))")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .cardStyle()
    }
    
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Your Progress")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                statItem(icon: "flame.fill", value: "\(user.progress.currentStreak)", label: "Current Streak", color: DesignSystem.Colors.success)
                statItem(icon: "star.fill", value: "\(user.lifePoints)", label: "Life Points", color: DesignSystem.Colors.premium)
                statItem(icon: "checkmark.circle.fill", value: "\(user.progress.totalCardsCompleted)", label: "Cards Done", color: DesignSystem.Colors.primary)
                statItem(icon: "chart.bar.fill", value: "\(Int(user.progress.lifeScore))", label: "Life Score", color: DesignSystem.Colors.info)
            }
        }
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(label)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
        }
        .cardStyle()
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Settings")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                settingsToggle(
                    title: "Notifications",
                    subtitle: "Daily reminders and updates",
                    isOn: user.settings.notificationsEnabled
                ) {
                    user.settings.notificationsEnabled.toggle()
                }
                
                settingsToggle(
                    title: "Weekly Reports",
                    subtitle: "Progress summaries every Sunday",
                    isOn: user.settings.weeklyReportsEnabled
                ) {
                    user.settings.weeklyReportsEnabled.toggle()
                }
                
                settingsToggle(
                    title: "Haptic Feedback",
                    subtitle: "Vibrations for interactions",
                    isOn: user.settings.hapticsEnabled
                ) {
                    user.settings.hapticsEnabled.toggle()
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func settingsToggle(title: String, subtitle: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(isOn))
                .disabled(true)
                .opacity(0.6)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Subscription")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                if !user.isPremium {
                    Button(action: {
                        showingPaywall = true
                    }) {
                        Text("Upgrade to Premium")
                            .font(DesignSystem.Typography.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            
            HStack(spacing: DesignSystem.Spacing.md) {
                if user.isPremium {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.premium)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Premium")
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Text(user.subscription.expiryDate?.formatted(date: .abbreviated) ?? "Active")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Free")
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.text)
                            
                            Text("\(subscriptionManager.getDailyCardLimit()) cards per day")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("About LifeDeck")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                aboutRow(icon: "info.circle", title: "Version", value: "1.0.0")
                aboutRow(icon: "doc.text", title: "Terms of Service", value: "", isLink: true)
                aboutRow(icon: "shield", title: "Privacy Policy", value: "", isLink: true)
                aboutRow(icon: "envelope", title: "Support", value: "support@lifedeck.app", isLink: true)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func aboutRow(icon: String, title: String, value: String, isLink: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(isLink ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
            
            if isLink {
                Image(systemName: "arrow.up.right")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            } else {
                Text(value)
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var user: User
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Notifications Settings
                    notificationsSection
                    
                    // Appearance Settings
                    appearanceSection
                    
                    // Focus Areas
                    focusAreasSection
                    
                    // Data & Privacy
                    dataPrivacySection
                }
                .padding(DesignSystem.Spacing.contentPadding)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Notifications")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                settingsRow(
                    title: "Daily Reminders",
                    subtitle: "Get reminded to complete your cards",
                    toggle: $user.settings.notificationsEnabled
                )
                
                if user.settings.notificationsEnabled {
                    settingsRow(
                        title: "Reminder Time",
                        subtitle: "When to send daily reminders",
                        value: user.settings.dailyReminderTime.formatted(date: .omitted, time: .shortened),
                        isDatePicker: true,
                        dateBinding: $user.settings.dailyReminderTime
                    )
                    
                    settingsRow(
                        title: "Weekly Reports",
                        subtitle: "Receive weekly progress summaries",
                        toggle: $user.settings.weeklyReportsEnabled
                    )
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Appearance")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                settingsRow(
                    title: "Haptic Feedback",
                    subtitle: "Vibrations for card interactions",
                    toggle: $user.settings.hapticsEnabled
                )
                
                settingsRow(
                    title: "Sound Effects",
                    subtitle: "Sounds for actions and completions",
                    toggle: $user.settings.soundEnabled
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private var focusAreasSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Focus Areas")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text("Select the life domains you want to focus on:")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .padding(.bottom, DesignSystem.Spacing.sm)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.sm) {
                ForEach(LifeDomain.allCases) { domain in
                    focusAreaToggle(domain: domain)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func focusAreaToggle(domain: LifeDomain) -> some View {
        HStack {
            Image(systemName: domain.icon)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(Color.forDomain(domain))
                .frame(width: 24)
            
            Text(domain.displayName)
                .font(DesignSystem.Typography.callout)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { user.settings.focusAreas.contains(domain) },
                set: { isOn in
                    if isOn {
                        user.settings.focusAreas.append(domain)
                    } else {
                        user.settings.focusAreas.removeAll { $0 == domain }
                    }
                }
            ))
        }
    }
    
    private var dataPrivacySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Data & Privacy")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.text)
            
            VStack(spacing: 0) {
                settingsRow(
                    title: "Export Data",
                    subtitle: "Download all your data",
                    value: "",
                    isLink: true
                )
                
                settingsRow(
                    title: "Delete Account",
                    subtitle: "Permanently delete your account and data",
                    value: "",
                    isLink: true,
                    isDestructive: true
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .cardStyle()
    }
    
    private func settingsRow(
        title: String,
        subtitle: String,
        toggle: Binding<Bool>? = nil,
        value: String = "",
        isDatePicker: Bool = false,
        dateBinding: Binding<Date>? = nil,
        isLink: Bool = false,
        isDestructive: Bool = false
    ) -> some View {
        HStack {
            if isLink {
                Button(action: {}) {
                    HStack {
                        Image(systemName: isDestructive ? "trash" : "arrow.up.right")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(isDestructive ? DesignSystem.Colors.error : DesignSystem.Colors.textSecondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(isDestructive ? DesignSystem.Colors.error : DesignSystem.Colors.text)
                            
                            Text(subtitle)
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } else if isDatePicker, let dateBinding = dateBinding {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    DatePicker("", selection: dateBinding, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                }
            } else if let toggle = toggle {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: toggle)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Text(value.isEmpty ? subtitle : value)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}