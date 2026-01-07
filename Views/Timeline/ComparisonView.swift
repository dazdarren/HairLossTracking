import SwiftUI

struct ComparisonView: View {
    let session1: CaptureSession
    let session2: CaptureSession

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

    var body: some View {
        NavigationStack {
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

                // Swipe hint
                Text("Swipe photos to compare")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
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
