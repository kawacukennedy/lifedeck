import SwiftUI

struct IntegrationSettingsView: View {
    @State private var healthKitConnected = false
    @State private var calendarConnected = false
    @State private var plaidConnected = false
    @State private var showingHealthKitPermission = false
    @State private var showingCalendarPermission = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // HealthKit Integration
                VStack(alignment: .leading, spacing: 16) {
                    Text("Health & Fitness")
                        .font(.headline)
                        .foregroundColor(.lifeDeckTextPrimary)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Apple Health")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.lifeDeckTextPrimary)
                                if healthKitConnected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                }
                            }
                            Text("Sync health and fitness data for personalized insights")
                                .font(.system(size: 14))
                                .foregroundColor(.lifeDeckTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Button(action: {
                            if healthKitConnected {
                                disconnectHealthKit()
                            } else {
                                connectHealthKit()
                            }
                        }) {
                            Text(healthKitConnected ? "Disconnect" : "Connect")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(healthKitConnected ? .red : .lifeDeckPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(healthKitConnected ? Color.red.opacity(0.1) : Color.lifeDeckPrimary.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)

                // Calendar Integration
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calendar")
                        .font(.headline)
                        .foregroundColor(.lifeDeckTextPrimary)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Calendar Access")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.lifeDeckTextPrimary)
                                if calendarConnected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                }
                            }
                            Text("Sync habits and schedule reminders in your calendar")
                                .font(.system(size: 14))
                                .foregroundColor(.lifeDeckTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Button(action: {
                            if calendarConnected {
                                disconnectCalendar()
                            } else {
                                connectCalendar()
                            }
                        }) {
                            Text(calendarConnected ? "Disconnect" : "Connect")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(calendarConnected ? .red : .lifeDeckPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(calendarConnected ? Color.red.opacity(0.1) : Color.lifeDeckPrimary.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)

                // Finance Integration
                VStack(alignment: .leading, spacing: 16) {
                    Text("Finance")
                        .font(.headline)
                        .foregroundColor(.lifeDeckTextPrimary)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Bank Accounts")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.lifeDeckTextPrimary)
                                if plaidConnected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                }
                            }
                            Text("Connect bank accounts for spending insights and budgeting")
                                .font(.system(size: 14))
                                .foregroundColor(.lifeDeckTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        Button(action: {
                            if plaidConnected {
                                disconnectPlaid()
                            } else {
                                connectPlaid()
                            }
                        }) {
                            Text(plaidConnected ? "Disconnect" : "Connect")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(plaidConnected ? .red : .lifeDeckPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(plaidConnected ? Color.red.opacity(0.1) : Color.lifeDeckPrimary.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color.lifeDeckBackground.ignoresSafeArea())
        .navigationTitle("Integrations")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingHealthKitPermission) {
            Alert(
                title: Text("HealthKit Permission"),
                message: Text("LifeDeck needs access to your health data to provide personalized insights. You can change this in Settings."),
                primaryButton: .default(Text("Go to Settings")) {
                    // Open iOS Settings
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showingCalendarPermission) {
            Alert(
                title: Text("Calendar Permission"),
                message: Text("LifeDeck needs access to your calendar to schedule reminders. You can change this in Settings."),
                primaryButton: .default(Text("Go to Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func connectHealthKit() {
        // In a real implementation, this would request HealthKit permissions
        // For now, just simulate connection
        showingHealthKitPermission = true
        // After permission granted: healthKitConnected = true
    }

    private func disconnectHealthKit() {
        healthKitConnected = false
        // In real implementation, revoke permissions and clear data
    }

    private func connectCalendar() {
        // In a real implementation, this would request Calendar permissions
        showingCalendarPermission = true
        // After permission granted: calendarConnected = true
    }

    private func disconnectCalendar() {
        calendarConnected = false
        // In real implementation, revoke permissions
    }

    private func connectPlaid() {
        // In a real implementation, this would open Plaid Link
        // For now, simulate connection
        plaidConnected = true
    }

    private func disconnectPlaid() {
        plaidConnected = false
        // In real implementation, revoke access tokens
    }
}