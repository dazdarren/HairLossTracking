import Foundation
import SwiftUI

@MainActor
final class DataController: ObservableObject {
    static let shared = DataController()

    @Published var sessions: [CaptureSession] = []
    @Published var treatments: [Treatment] = []
    @Published var reminderSettings: ReminderSettings = .default

    private let sessionsKey = "capture_sessions"
    private let treatmentsKey = "treatments"
    private let reminderSettingsKey = "reminder_settings"

    private init() {
        loadData()
    }

    // MARK: - Persistence

    private func loadData() {
        // Load sessions
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([CaptureSession].self, from: data) {
            sessions = decoded.sorted { $0.date > $1.date }
        }

        // Load treatments
        if let data = UserDefaults.standard.data(forKey: treatmentsKey),
           let decoded = try? JSONDecoder().decode([Treatment].self, from: data) {
            treatments = decoded.sorted { $0.startDate > $1.startDate }
        }

        // Load reminder settings
        if let data = UserDefaults.standard.data(forKey: reminderSettingsKey),
           let decoded = try? JSONDecoder().decode(ReminderSettings.self, from: data) {
            reminderSettings = decoded
        }
    }

    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }

    private func saveTreatments() {
        if let encoded = try? JSONEncoder().encode(treatments) {
            UserDefaults.standard.set(encoded, forKey: treatmentsKey)
        }
    }

    // MARK: - Capture Sessions

    func addSession(_ session: CaptureSession) {
        sessions.insert(session, at: 0)
        saveSessions()
    }

    func updateSession(_ session: CaptureSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }

    func deleteSession(_ session: CaptureSession) {
        PhotoStorageService.shared.deletePhotos(for: session)
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }

    var firstSessionDate: Date? {
        sessions.last?.date
    }

    var daysSinceFirstCapture: Int? {
        guard let firstDate = firstSessionDate else { return nil }
        return Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day
    }

    // MARK: - Treatments

    func addTreatment(_ treatment: Treatment) {
        treatments.insert(treatment, at: 0)
        saveTreatments()
    }

    func updateTreatment(_ treatment: Treatment) {
        if let index = treatments.firstIndex(where: { $0.id == treatment.id }) {
            treatments[index] = treatment
            saveTreatments()
        }
    }

    func deleteTreatment(_ treatment: Treatment) {
        treatments.removeAll { $0.id == treatment.id }
        saveTreatments()
    }

    var activeTreatments: [Treatment] {
        treatments.filter { $0.isActive }
    }

    // MARK: - Reminder Settings

    func saveReminderSettings() {
        if let encoded = try? JSONEncoder().encode(reminderSettings) {
            UserDefaults.standard.set(encoded, forKey: reminderSettingsKey)
        }
    }

    func updateStreakOnCapture() {
        let today = Calendar.current.startOfDay(for: Date())

        // Check if this continues a streak or starts a new one
        if let lastCapture = sessions.dropFirst().first?.date {
            let lastCaptureDay = Calendar.current.startOfDay(for: lastCapture)
            let daysSinceLast = Calendar.current.dateComponents([.day], from: lastCaptureDay, to: today).day ?? 0

            // Within frequency window (with 3 day grace period)
            let maxGap = reminderSettings.frequency.days + 3
            if daysSinceLast <= maxGap {
                reminderSettings.currentStreak += 1
            } else {
                reminderSettings.currentStreak = 1
            }
        } else {
            // First capture
            reminderSettings.currentStreak = 1
        }

        // Update longest streak
        if reminderSettings.currentStreak > reminderSettings.longestStreak {
            reminderSettings.longestStreak = reminderSettings.currentStreak
        }

        saveReminderSettings()
    }

    // MARK: - Session Queries

    var weeksTracked: Int {
        guard let firstDate = firstSessionDate else { return 0 }
        return (Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day ?? 0) / 7
    }

    var consistencyPercentage: Int {
        guard sessions.count >= 2 else { return 100 }

        let sortedSessions = sessions.sorted { $0.date < $1.date }
        var onScheduleCount = 0
        let expectedInterval = reminderSettings.frequency.days
        let tolerance = 3 // days grace period

        for i in 1..<sortedSessions.count {
            let daysBetween = Calendar.current.dateComponents(
                [.day],
                from: sortedSessions[i-1].date,
                to: sortedSessions[i].date
            ).day ?? 0

            if daysBetween <= expectedInterval + tolerance {
                onScheduleCount += 1
            }
        }

        return (onScheduleCount * 100) / (sortedSessions.count - 1)
    }

    func sessionClosestTo(date: Date, tolerance: Int = 7) -> CaptureSession? {
        sessions
            .filter { session in
                let days = abs(Calendar.current.dateComponents([.day], from: session.date, to: date).day ?? 0)
                return days <= tolerance
            }
            .min { session1, session2 in
                let days1 = abs(Calendar.current.dateComponents([.day], from: session1.date, to: date).day ?? 0)
                let days2 = abs(Calendar.current.dateComponents([.day], from: session2.date, to: date).day ?? 0)
                return days1 < days2
            }
    }

    func sessionFromDaysAgo(_ daysAgo: Int, tolerance: Int = 7) -> CaptureSession? {
        guard let targetDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else {
            return nil
        }
        return sessionClosestTo(date: targetDate, tolerance: tolerance)
    }

    func treatments(activeDuring session: CaptureSession) -> [Treatment] {
        treatments.filter { treatment in
            let startedBefore = treatment.startDate <= session.date
            let stillActive = treatment.endDate == nil || treatment.endDate! >= session.date
            return startedBefore && stillActive
        }
    }

    func treatmentsStartedBetween(older: CaptureSession, newer: CaptureSession) -> [Treatment] {
        treatments.filter { treatment in
            treatment.startDate > older.date && treatment.startDate <= newer.date
        }
    }
}
