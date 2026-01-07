import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var dataController: DataController
    @State private var selectedSession: CaptureSession?
    @State private var compareMode = false
    @State private var sessionsToCompare: [CaptureSession] = []

    var body: some View {
        NavigationStack {
            Group {
                if dataController.sessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .navigationTitle("Timeline")
            .toolbar {
                if dataController.sessions.count >= 2 {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            compareMode.toggle()
                            if !compareMode {
                                sessionsToCompare.removeAll()
                            }
                        } label: {
                            Text(compareMode ? "Done" : "Compare")
                        }
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session)
            }
            .sheet(isPresented: .init(
                get: { sessionsToCompare.count == 2 },
                set: { if !$0 { sessionsToCompare.removeAll() } }
            )) {
                if sessionsToCompare.count == 2 {
                    ComparisonView(
                        session1: sessionsToCompare[0],
                        session2: sessionsToCompare[1]
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Photos Yet", systemImage: "camera")
        } description: {
            Text("Start tracking your progress by taking your first photos.")
        }
    }

    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if compareMode {
                    Text("Select 2 sessions to compare")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }

                ForEach(dataController.sessions) { session in
                    SessionCard(
                        session: session,
                        isSelected: sessionsToCompare.contains { $0.id == session.id },
                        compareMode: compareMode
                    )
                    .onTapGesture {
                        if compareMode {
                            toggleSessionSelection(session)
                        } else {
                            selectedSession = session
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func toggleSessionSelection(_ session: CaptureSession) {
        if let index = sessionsToCompare.firstIndex(where: { $0.id == session.id }) {
            sessionsToCompare.remove(at: index)
        } else if sessionsToCompare.count < 2 {
            sessionsToCompare.append(session)
        }
    }
}

struct SessionCard: View {
    let session: CaptureSession
    var isSelected: Bool = false
    var compareMode: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)

                Spacer()

                if compareMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
            }

            // Photo thumbnails
            HStack(spacing: 8) {
                ForEach(PhotoAngle.allCases, id: \.self) { angle in
                    if let photo = session.photo(for: angle),
                       let image = PhotoStorageService.shared.loadPhoto(fileName: photo.fileName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 100, height: 80)
                            .overlay {
                                Image(systemName: angle.iconName)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue, lineWidth: 3)
            }
        }
    }
}

struct SessionDetailView: View {
    @EnvironmentObject private var dataController: DataController
    @Environment(\.dismiss) private var dismiss

    let session: CaptureSession
    @State private var selectedAngle: PhotoAngle = .front

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main photo
                if let photo = session.photo(for: selectedAngle),
                   let image = PhotoStorageService.shared.loadPhoto(fileName: photo.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 400)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 400)
                        .overlay {
                            Text("No photo")
                                .foregroundStyle(.secondary)
                        }
                }

                // Angle selector
                Picker("Angle", selection: $selectedAngle) {
                    ForEach(PhotoAngle.allCases, id: \.self) { angle in
                        Text(angle.displayName).tag(angle)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Spacer()
            }
            .navigationTitle(session.date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", role: .destructive) {
                        dataController.deleteSession(session)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TimelineView()
        .environmentObject(DataController.shared)
}
