import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var dataController: DataController
    @State private var showingCaptureFlow = false
    @State private var showingComparison = false
    @State private var comparisonSessions: (CaptureSession, CaptureSession)?

    private var isNewUser: Bool {
        dataController.sessions.isEmpty
    }

    private var oneMonthAgoSession: CaptureSession? {
        dataController.sessionFromDaysAgo(30, tolerance: 10)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if isNewUser {
                        emptyStateView
                    } else {
                        // Quick capture button
                        captureButton

                        // Streak card (if reminders enabled and has captures)
                        if dataController.reminderSettings.isEnabled || dataController.reminderSettings.currentStreak > 0 {
                            StreakCard(
                                currentStreak: dataController.reminderSettings.currentStreak,
                                longestStreak: dataController.reminderSettings.longestStreak,
                                lastCaptureDate: dataController.sessions.first?.date
                            )
                        }

                        // Quick comparison card (if sufficient history)
                        if let beforeSession = oneMonthAgoSession,
                           let afterSession = dataController.sessions.first {
                            QuickComparisonCard(
                                beforeSession: beforeSession,
                                afterSession: afterSession,
                                title: "1 Month Progress"
                            ) {
                                comparisonSessions = (beforeSession, afterSession)
                                showingComparison = true
                            }
                        }

                        // Progress stats
                        ProgressStatsSection()

                        // Recent capture
                        if let latestSession = dataController.sessions.first {
                            recentCaptureSection(session: latestSession)
                        }

                        // Active treatments summary
                        if !dataController.activeTreatments.isEmpty {
                            treatmentsSummary
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Hair Loss Tracking")
            .fullScreenCover(isPresented: $showingCaptureFlow) {
                CaptureFlowView()
            }
            .sheet(isPresented: $showingComparison) {
                if let sessions = comparisonSessions {
                    ComparisonView(session1: sessions.0, session2: sessions.1)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 40)

            // Icon
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 72))
                .foregroundStyle(Color.accentColor)

            // Welcome text
            VStack(spacing: 12) {
                Text("Track Your Progress")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Take consistent photos to monitor your hair over time. We'll help you capture the same angles each session for accurate comparisons.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // How it works
            VStack(alignment: .leading, spacing: 16) {
                Text("How it works")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HowItWorksRow(
                    icon: "camera.fill",
                    title: "Take photos from 3 angles",
                    description: "Front, crown, and back views"
                )

                HowItWorksRow(
                    icon: "calendar",
                    title: "Capture regularly",
                    description: "Weekly or monthly for best results"
                )

                HowItWorksRow(
                    icon: "arrow.left.arrow.right",
                    title: "Compare over time",
                    description: "See your progress side by side"
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // CTA button
            Button {
                showingCaptureFlow = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                    Text("Take Your First Photos")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Spacer()
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

struct HowItWorksRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataController.shared)
}
