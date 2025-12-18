import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var user: User
    @State private var notificationsEnabled = true
    @State private var dailyReminderTime = Date()
    @State private var contextAwareEnabled = false
    @State private var morningReminders = false
    @State private var workBreakReminders = false
    @State private var commuteReminders = false
    @State private var locationBasedReminders = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Basic Notifications
                VStack(alignment: .leading, spacing: 16) {
                    Text("Basic Notifications")
                        .font(.headline)
                        .foregroundColor(.lifeDeckTextPrimary)

                    VStack(spacing: 16) {
                        // Push Notifications Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Push Notifications")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.lifeDeckTextPrimary)
                                Text("Receive notifications about your cards and progress")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lifeDeckTextSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                        }

                        // Daily Reminder Time
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Reminders")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.lifeDeckTextPrimary)
                                Text("Get reminded to complete your daily cards")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lifeDeckTextSecondary)
                            }
                            Spacer()
                            DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                }
                .padding(.horizontal)

                // Smart Notifications
                VStack(alignment: .leading, spacing: 16) {
                    Text("Smart Notifications")
                        .font(.headline)
                        .foregroundColor(.lifeDeckTextPrimary)

                    VStack(spacing: 16) {
                        // Context-Aware Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Context-Aware Reminders")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.lifeDeckTextPrimary)
                                Text("Get personalized notifications based on your location, time, and activity")
                                    .font(.system(size: 14))
                                    .foregroundColor(.lifeDeckTextSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            Toggle("", isOn: $contextAwareEnabled)
                                .labelsHidden()
                        }

                        if contextAwareEnabled {
                            VStack(spacing: 16) {
                                Divider()

                                // Morning Reminders
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Morning Motivation")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.lifeDeckTextPrimary)
                                        Text("Remind me to start my day with a mindful activity when it's sunny")
                                            .font(.system(size: 14))
                                            .foregroundColor(.lifeDeckTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $morningReminders)
                                        .labelsHidden()
                                }

                                // Work Break Reminders
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Work Break Reminders")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.lifeDeckTextPrimary)
                                        Text("Suggest quick mindfulness exercises during work hours")
                                            .font(.system(size: 14))
                                            .foregroundColor(.lifeDeckTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $workBreakReminders)
                                        .labelsHidden()
                                }

                                // Commute Reminders
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Commute Time")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.lifeDeckTextPrimary)
                                        Text("Use travel time for breathing exercises or reflection")
                                            .font(.system(size: 14))
                                            .foregroundColor(.lifeDeckTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $commuteReminders)
                                        .labelsHidden()
                                }

                                // Location-Based Reminders
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Location-Based")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.lifeDeckTextPrimary)
                                        Text("Contextual reminders based on your current location")
                                            .font(.system(size: 14))
                                            .foregroundColor(.lifeDeckTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $locationBasedReminders)
                                        .labelsHidden()
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color.lifeDeckBackground.ignoresSafeArea())
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}</content>
</xai:function_call">Now commit this. 

<xai:function_call name="bash">
<parameter name="command">git add LifeDeck/Views/Profile/NotificationSettingsView.swift LifeDeck/Views/Profile/ProfileView.swift