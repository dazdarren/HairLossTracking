import SwiftUI

struct TimelineSliderView: View {
    let sessions: [CaptureSession]
    @State private var selectedIndex: Int = 0
    @State private var selectedAngle: PhotoAngle = .front
    @Environment(\.dismiss) private var dismiss

    private var sortedSessions: [CaptureSession] {
        sessions.sorted { $0.date < $1.date }
    }

    private var selectedSession: CaptureSession? {
        guard selectedIndex >= 0, selectedIndex < sortedSessions.count else { return nil }
        return sortedSessions[selectedIndex]
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Photo display
                photoDisplay
                    .frame(maxHeight: .infinity)

                // Controls
                VStack(spacing: 16) {
                    // Date label
                    if let session = selectedSession {
                        Text(session.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)
                    }

                    // Slider
                    if sortedSessions.count > 1 {
                        VStack(spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { Double(selectedIndex) },
                                    set: { selectedIndex = Int($0) }
                                ),
                                in: 0...Double(sortedSessions.count - 1),
                                step: 1
                            )

                            HStack {
                                if let first = sortedSessions.first {
                                    Text(first.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(selectedIndex + 1) of \(sortedSessions.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if let last = sortedSessions.last {
                                    Text(last.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    // Angle picker
                    Picker("Angle", selection: $selectedAngle) {
                        ForEach(PhotoAngle.allCases, id: \.self) { angle in
                            Text(angle.displayName).tag(angle)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .background(Color.black)
            .navigationTitle("Timeline Scrub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Start at the most recent photo
                selectedIndex = sortedSessions.count - 1
            }
        }
    }

    @ViewBuilder
    private var photoDisplay: some View {
        if let session = selectedSession,
           let photo = session.photo(for: selectedAngle),
           let image = PhotoStorageService.shared.loadPhoto(fileName: photo.fileName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                .animation(.easeInOut(duration: 0.2), value: selectedAngle)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No photo available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    TimelineSliderView(sessions: [
        CaptureSession(date: Date().addingTimeInterval(-86400 * 30)),
        CaptureSession(date: Date().addingTimeInterval(-86400 * 14)),
        CaptureSession()
    ])
}
