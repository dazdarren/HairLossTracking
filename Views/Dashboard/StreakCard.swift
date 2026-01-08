import SwiftUI

struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let lastCaptureDate: Date?

    private var daysSinceLastCapture: Int? {
        guard let lastDate = lastCaptureDate else { return nil }
        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day
    }

    private var isStreakAtRisk: Bool {
        guard let days = daysSinceLastCapture else { return false }
        return days >= 5 // Warning after 5 days
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Current streak
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundStyle(currentStreak > 0 ? .orange : .gray)

                        Text("\(currentStreak)")
                            .font(.system(size: 32, weight: .bold))
                    }

                    Text("Current Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Best streak
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("\(longestStreak)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.secondary)

                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundStyle(.yellow)
                    }

                    Text("Best Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Warning if streak at risk
            if isStreakAtRisk, let days = daysSinceLastCapture {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("It's been \(days) days - capture today to keep your streak!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakCard(
            currentStreak: 5,
            longestStreak: 8,
            lastCaptureDate: Date()
        )

        StreakCard(
            currentStreak: 3,
            longestStreak: 5,
            lastCaptureDate: Calendar.current.date(byAdding: .day, value: -6, to: Date())
        )
    }
    .padding()
}
