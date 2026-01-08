import SwiftUI

struct ProgressStatsSection: View {
    @EnvironmentObject private var dataController: DataController

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ProgressStatCard(
                    title: "Weeks Tracking",
                    value: "\(dataController.weeksTracked)",
                    icon: "calendar",
                    color: .blue
                )

                ProgressStatCard(
                    title: "Total Captures",
                    value: "\(dataController.sessions.count)",
                    icon: "camera.fill",
                    color: .green
                )

                ProgressStatCard(
                    title: "Consistency",
                    value: "\(dataController.consistencyPercentage)%",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )

                ProgressStatCard(
                    title: "Treatments",
                    value: "\(dataController.activeTreatments.count)",
                    icon: "pills.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
        .padding(.horizontal, -16) // Offset to allow edge-to-edge scroll
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 90)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProgressStatsSection()
        .environmentObject(DataController.shared)
}
