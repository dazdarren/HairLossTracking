import Foundation

struct ReminderSettings: Codable {
    var isEnabled: Bool
    var frequency: ReminderFrequency
    var preferredDay: Int  // 0-6 for day of week (Sunday = 0)
    var preferredTime: Date
    var currentStreak: Int
    var longestStreak: Int

    static let `default` = ReminderSettings(
        isEnabled: false,
        frequency: .weekly,
        preferredDay: 0,
        preferredTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        currentStreak: 0,
        longestStreak: 0
    )
}

enum ReminderFrequency: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"

    var days: Int {
        switch self {
        case .weekly: return 7
        case .biweekly: return 14
        case .monthly: return 30
        }
    }

    var displayName: String {
        rawValue
    }
}
