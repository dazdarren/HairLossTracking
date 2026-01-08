import SwiftUI

struct ReminderSettingsView: View {
    @EnvironmentObject private var dataController: DataController
    @StateObject private var notificationService = NotificationService.shared

    private let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        List {
            Section {
                Toggle("Enable Reminders", isOn: $dataController.reminderSettings.isEnabled)
                    .onChange(of: dataController.reminderSettings.isEnabled) { _, newValue in
                        handleReminderToggle(enabled: newValue)
                    }
            } footer: {
                Text("Get notified when it's time to take your progress photos.")
            }

            if dataController.reminderSettings.isEnabled {
                Section("Schedule") {
                    Picker("Frequency", selection: $dataController.reminderSettings.frequency) {
                        ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .onChange(of: dataController.reminderSettings.frequency) { _, _ in
                        updateReminder()
                    }

                    if dataController.reminderSettings.frequency == .weekly ||
                       dataController.reminderSettings.frequency == .biweekly {
                        Picker("Day", selection: $dataController.reminderSettings.preferredDay) {
                            ForEach(0..<7, id: \.self) { index in
                                Text(daysOfWeek[index]).tag(index)
                            }
                        }
                        .onChange(of: dataController.reminderSettings.preferredDay) { _, _ in
                            updateReminder()
                        }
                    }

                    DatePicker(
                        "Time",
                        selection: $dataController.reminderSettings.preferredTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: dataController.reminderSettings.preferredTime) { _, _ in
                        updateReminder()
                    }
                }

                Section("Your Streak") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("\(dataController.reminderSettings.currentStreak)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Best Streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(.yellow)
                                Text("\(dataController.reminderSettings.longestStreak)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            if notificationService.authorizationStatus == .denied {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Notifications Disabled", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)

                        Text("Enable notifications in Settings to receive reminders.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Photo Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleReminderToggle(enabled: Bool) {
        if enabled {
            Task {
                let granted = await notificationService.requestAuthorization()
                if granted {
                    notificationService.scheduleReminder(settings: dataController.reminderSettings)
                } else {
                    dataController.reminderSettings.isEnabled = false
                }
                dataController.saveReminderSettings()
            }
        } else {
            notificationService.cancelAllReminders()
            dataController.saveReminderSettings()
        }
    }

    private func updateReminder() {
        notificationService.scheduleReminder(settings: dataController.reminderSettings)
        dataController.saveReminderSettings()
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView()
            .environmentObject(DataController.shared)
    }
}
