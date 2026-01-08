import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var dataController: DataController

    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    NavigationLink {
                        ReminderSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            Text("Photo Reminders")
                        }
                    }
                }

                Section("Stats") {
                    HStack {
                        Text("Total Captures")
                        Spacer()
                        Text("\(dataController.sessions.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Weeks Tracking")
                        Spacer()
                        Text("\(dataController.weeksTracked)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Current Streak")
                        Spacer()
                        Text("\(dataController.reminderSettings.currentStreak)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Longest Streak")
                        Spacer()
                        Text("\(dataController.reminderSettings.longestStreak)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataController.shared)
}
