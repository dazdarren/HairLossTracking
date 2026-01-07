import Foundation
import SwiftUI

@MainActor
final class DataController: ObservableObject {
    static let shared = DataController()

    @Published var sessions: [CaptureSession] = []
    @Published var treatments: [Treatment] = []

    private let sessionsKey = "capture_sessions"
    private let treatmentsKey = "treatments"

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
}
