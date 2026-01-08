import SwiftUI

struct ComparisonView: View {
    let session1: CaptureSession
    let session2: CaptureSession

    @EnvironmentObject private var dataController: DataController
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAngle: PhotoAngle = .front

    private var olderSession: CaptureSession {
        session1.date < session2.date ? session1 : session2
    }

    private var newerSession: CaptureSession {
        session1.date < session2.date ? session2 : session1
    }

    private var daysBetween: Int {
        Calendar.current.dateComponents([.day], from: olderSession.date, to: newerSession.date).day ?? 0
    }

    private var relevantTreatments: [Treatment] {
        dataController.treatments.filter { treatment in
            let startedBefore = treatment.startDate < olderSession.date
            let startedDuring = treatment.startDate >= olderSession.date && treatment.startDate <= newerSession.date
            let stillActive = treatment.isActive || (treatment.endDate ?? Date()) > newerSession.date
            return (startedBefore && stillActive) || startedDuring
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Time difference
                    Text("\(daysBetween) days apart")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top)

                    // Side by side photos
                    HStack(spacing: 12) {
                        photoView(for: olderSession, label: "Before")
                        photoView(for: newerSession, label: "After")
                    }
                    .padding(.horizontal)

                    // Angle selector
                    Picker("Angle", selection: $selectedAngle) {
                        ForEach(PhotoAngle.allCases, id: \.self) { angle in
                            Text(angle.displayName).tag(angle)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Treatment context
                    if !relevantTreatments.isEmpty {
                        TreatmentContextView(
                            treatments: relevantTreatments,
                            olderDate: olderSession.date,
                            newerDate: newerSession.date
                        )
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Compare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func photoView(for session: CaptureSession, label: String) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            if let photo = session.photo(for: selectedAngle),
               let image = PhotoStorageService.shared.loadPhoto(fileName: photo.fileName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 300)
                    .overlay {
                        Text("No photo")
                            .foregroundStyle(.secondary)
                    }
            }

            Text(session.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ComparisonView(
        session1: CaptureSession(date: Date().addingTimeInterval(-86400 * 30)),
        session2: CaptureSession()
    )
}
