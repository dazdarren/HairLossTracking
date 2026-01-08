import Foundation

@MainActor
final class InsightsService {
    static let shared = InsightsService()

    private init() {}

    /// Generate all available progress insights based on current data
    func generateInsights(sessions: [CaptureSession], treatments: [Treatment], settings: ReminderSettings) -> [ProgressInsight] {
        var insights: [ProgressInsight] = []

        // 1-month comparison
        if let recentSession = sessions.first,
           let monthAgoSession = findSession(daysAgo: 30, from: sessions) {
            insights.append(ProgressInsight(
                type: .oneMonthComparison,
                title: "1 Month Progress",
                subtitle: "Compare your progress over the last month",
                beforeSession: monthAgoSession,
                afterSession: recentSession
            ))
        }

        // 3-month comparison
        if let recentSession = sessions.first,
           let threeMonthsAgoSession = findSession(daysAgo: 90, from: sessions) {
            insights.append(ProgressInsight(
                type: .threeMonthComparison,
                title: "3 Month Progress",
                subtitle: "See how far you've come in 3 months",
                beforeSession: threeMonthsAgoSession,
                afterSession: recentSession
            ))
        }

        // First capture comparison (if more than 2 weeks of data)
        if sessions.count >= 2,
           let firstSession = sessions.last,
           let latestSession = sessions.first {
            let daysBetween = Calendar.current.dateComponents([.day], from: firstSession.date, to: latestSession.date).day ?? 0
            if daysBetween >= 14 {
                insights.append(ProgressInsight(
                    type: .firstCapture,
                    title: "Since Day 1",
                    subtitle: "\(daysBetween) days of progress",
                    beforeSession: firstSession,
                    afterSession: latestSession
                ))
            }
        }

        // Streak insight
        if settings.currentStreak >= 2 {
            insights.append(ProgressInsight(
                type: .streak,
                title: "\(settings.currentStreak) Captures in a Row",
                subtitle: "Keep the streak going!",
                beforeSession: nil,
                afterSession: nil
            ))
        }

        return insights
    }

    /// Find session closest to N days ago
    func findSession(daysAgo: Int, from sessions: [CaptureSession], tolerance: Int = 10) -> CaptureSession? {
        guard let targetDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else {
            return nil
        }

        return sessions
            .filter { session in
                let days = abs(Calendar.current.dateComponents([.day], from: session.date, to: targetDate).day ?? 0)
                return days <= tolerance
            }
            .min { session1, session2 in
                let days1 = abs(Calendar.current.dateComponents([.day], from: session1.date, to: targetDate).day ?? 0)
                let days2 = abs(Calendar.current.dateComponents([.day], from: session2.date, to: targetDate).day ?? 0)
                return days1 < days2
            }
    }

    /// Get treatments active during a specific session
    func activeTreatments(during session: CaptureSession, allTreatments: [Treatment]) -> [Treatment] {
        allTreatments.filter { treatment in
            let startedBefore = treatment.startDate <= session.date
            let stillActive = treatment.endDate == nil || treatment.endDate! >= session.date
            return startedBefore && stillActive
        }
    }

    /// Get treatments started between two sessions
    func treatmentsStartedBetween(older: CaptureSession, newer: CaptureSession, allTreatments: [Treatment]) -> [Treatment] {
        allTreatments.filter { treatment in
            treatment.startDate > older.date && treatment.startDate <= newer.date
        }
    }

    /// Generate treatment context strings for comparison view
    func treatmentContextStrings(olderSession: CaptureSession, newerSession: CaptureSession, treatments: [Treatment]) -> [String] {
        var context: [String] = []

        for treatment in treatments {
            let startedBefore = treatment.startDate < olderSession.date
            let startedDuring = treatment.startDate >= olderSession.date && treatment.startDate <= newerSession.date
            let stillActive = treatment.isActive || (treatment.endDate ?? Date()) > newerSession.date

            if startedDuring {
                context.append("Started \(treatment.name) \(treatment.durationDescription) ago")
            } else if startedBefore && stillActive {
                context.append("Using \(treatment.name) throughout (\(treatment.durationDescription))")
            }
        }

        return context
    }
}
