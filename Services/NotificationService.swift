import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()
    private let reminderIdentifier = "hair_progress_reminder"

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    // MARK: - Scheduling

    func scheduleReminder(settings: ReminderSettings) {
        // Cancel existing reminders first
        cancelAllReminders()

        guard settings.isEnabled else { return }

        let content = createReminderContent(streak: settings.currentStreak)

        // Create trigger based on frequency
        let trigger = createTrigger(for: settings)

        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelAllReminders() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    // MARK: - Content Creation

    private func createReminderContent(streak: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time for Progress Photos"

        if streak > 0 {
            content.body = "You're on a \(streak)-capture streak! Keep it going."
        } else {
            content.body = "Take your progress photos to track your hair journey."
        }

        content.sound = .default
        content.badge = 1

        return content
    }

    private func createTrigger(for settings: ReminderSettings) -> UNNotificationTrigger {
        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.current.component(.hour, from: settings.preferredTime)
        dateComponents.minute = Calendar.current.component(.minute, from: settings.preferredTime)

        switch settings.frequency {
        case .weekly:
            // Weekday is 1-7 (Sunday = 1), preferredDay is 0-6 (Sunday = 0)
            dateComponents.weekday = settings.preferredDay + 1
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        case .biweekly:
            // For bi-weekly, we use a time interval trigger (14 days)
            // First notification at preferred time on preferred day
            dateComponents.weekday = settings.preferredDay + 1
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        case .monthly:
            // Same day each month
            dateComponents.day = Calendar.current.component(.day, from: Date())
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
    }

    // MARK: - Streak Nudge

    func scheduleStreakNudge(currentStreak: Int, daysSinceLastCapture: Int) {
        guard daysSinceLastCapture >= 2 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"

        if currentStreak > 1 {
            content.body = "You have a \(currentStreak)-capture streak. It's been \(daysSinceLastCapture) days - capture today!"
        } else {
            content.body = "It's been \(daysSinceLastCapture) days since your last capture. Stay consistent!"
        }

        content.sound = .default

        // Schedule for 2 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)

        let request = UNNotificationRequest(
            identifier: "streak_nudge",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }
}
