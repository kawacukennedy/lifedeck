import SwiftUI

struct NotificationSettingsView: View {
    @State private var dailyReminders = true
    @State private var streakMilestones = true
    @State private var progressUpdates = false
    @State private var motivationalMessages = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)

            VStack {
                Text("Notification Settings")
                    .font(DesignSystem.h1)
                    .foregroundColor(.white)
                    .padding()

                Form {
                    Section(header: Text("Daily Coaching").foregroundColor(.white)) {
                        Toggle("Daily Reminders", isOn: $dailyReminders)
                        Toggle("Motivational Messages", isOn: $motivationalMessages)
                    }

                    Section(header: Text("Progress Tracking").foregroundColor(.white)) {
                        Toggle("Streak Milestones", isOn: $streakMilestones)
                        Toggle("Weekly Progress Updates", isOn: $progressUpdates)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.background)

                Button(action: saveSettings) {
                    Text("Save Settings")
                }
                .buttonStyle(.primary)
                .padding()
            }
        }
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        // Load from UserDefaults or user preferences
        dailyReminders = UserDefaults.standard.bool(forKey: "dailyReminders")
        streakMilestones = UserDefaults.standard.bool(forKey: "streakMilestones")
        progressUpdates = UserDefaults.standard.bool(forKey: "progressUpdates")
        motivationalMessages = UserDefaults.standard.bool(forKey: "motivationalMessages")
    }

    private func saveSettings() {
        UserDefaults.standard.set(dailyReminders, forKey: "dailyReminders")
        UserDefaults.standard.set(streakMilestones, forKey: "streakMilestones")
        UserDefaults.standard.set(progressUpdates, forKey: "progressUpdates")
        UserDefaults.standard.set(motivationalMessages, forKey: "motivationalMessages")
        presentationMode.wrappedValue.dismiss()
    }
}