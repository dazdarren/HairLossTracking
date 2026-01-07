import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var dataController: DataController
    @State private var showingCaptureFlow = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick capture button
                    captureButton

                    // Stats cards
                    statsSection

                    // Recent capture
                    if let latestSession = dataController.sessions.first {
                        recentCaptureSection(session: latestSession)
                    }

                    // Active treatments summary
                    if !dataController.activeTreatments.isEmpty {
                        treatmentsSummary
                    }
                }
                .padding()
            }
            .navigationTitle("Hair Loss Tracking")
            .fullScreenCover(isPresented: $showingCaptureFlow) {
                CaptureFlowView()
            }
        }
    }

    private var captureButton: some View {
        Button {
            showingCaptureFlow = true
        } label: {
            HStack {
                Image(systemName: "camera.fill")
                    .font(.title2)
                Text("Take Progress Photos")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Days Tracking",
                value: dataController.daysSinceFirstCapture.map { "\($0)" } ?? "-",
                icon: "calendar"
            )

            StatCard(
                title: "Total Captures",
                value: "\(dataController.sessions.count)",
                icon: "photo.stack"
            )

            StatCard(
                title: "Treatments",
                value: "\(dataController.activeTreatments.count)",
                icon: "pills"
            )
        }
    }

    private func recentCaptureSection(session: CaptureSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest Capture")
                    .font(.headline)
                Spacer()
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                ForEach(PhotoAngle.allCases, id: \.self) { angle in
                    if let photo = session.photo(for: angle),
                       let image = PhotoStorageService.shared.loadPhoto(fileName: photo.fileName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var treatmentsSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Treatments")
                .font(.headline)

            ForEach(dataController.activeTreatments.prefix(3)) { treatment in
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text(treatment.name)
                        .font(.subheadline)
                    Spacer()
                    Text("\(treatment.durationDays)d")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if dataController.activeTreatments.count > 3 {
                Text("+\(dataController.activeTreatments.count - 3) more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataController.shared)
}
