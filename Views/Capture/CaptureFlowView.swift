import SwiftUI

struct CaptureFlowView: View {
    @EnvironmentObject private var dataController: DataController
    @Environment(\.dismiss) private var dismiss

    @State private var currentAngleIndex = 0
    @State private var capturedPhotos: [PhotoAngle: UIImage] = [:]
    @State private var showingPreview = false
    @State private var cameraController: CameraViewController?

    private var currentAngle: PhotoAngle {
        PhotoAngle.allCases[currentAngleIndex]
    }

    private var progress: Double {
        Double(capturedPhotos.count) / Double(PhotoAngle.allCases.count)
    }

    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private func createPlaceholderImage(for angle: PhotoAngle) -> UIImage {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background gradient
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Draw angle label
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]

            let text = "\(angle.displayName)\n(Test Photo)"
            let textRect = CGRect(x: 20, y: size.height / 2 - 30, width: size.width - 40, height: 80)
            text.draw(in: textRect, withAttributes: attrs)

            // Draw camera icon placeholder
            let iconRect = CGRect(x: size.width / 2 - 40, y: size.height / 2 - 120, width: 80, height: 60)
            UIColor.systemGray3.setFill()
            UIBezierPath(roundedRect: iconRect, cornerRadius: 8).fill()
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview
                CameraView { image in
                    capturedPhotos[currentAngle] = image
                    advanceToNext()
                }
                .ignoresSafeArea()
                .onAppear {
                    // Store reference to camera controller
                }

                // Guide overlay
                AngleGuideOverlay(angle: currentAngle)
                    .ignoresSafeArea()

                // Controls
                VStack {
                    // Progress bar
                    ProgressView(value: progress)
                        .tint(.white)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    HStack {
                        Text("\(currentAngleIndex + 1) of \(PhotoAngle.allCases.count)")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Simulator skip button
                    #if targetEnvironment(simulator)
                    Button {
                        capturedPhotos[currentAngle] = createPlaceholderImage(for: currentAngle)
                        advanceToNext()
                    } label: {
                        Text("Use Test Photo")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 12)
                    #endif

                    // Capture button
                    Button {
                        #if targetEnvironment(simulator)
                        capturedPhotos[currentAngle] = createPlaceholderImage(for: currentAngle)
                        advanceToNext()
                        #else
                        triggerCapture()
                        #endif
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .principal) {
                    Text(currentAngle.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingPreview) {
                CapturePreviewView(photos: capturedPhotos) {
                    saveSession()
                }
            }
        }
    }

    private func triggerCapture() {
        // Find the CameraViewController and trigger capture
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            findCameraController(in: rootVC)?.capturePhoto()
        }
    }

    private func findCameraController(in viewController: UIViewController) -> CameraViewController? {
        if let cameraVC = viewController as? CameraViewController {
            return cameraVC
        }

        for child in viewController.children {
            if let found = findCameraController(in: child) {
                return found
            }
        }

        if let presented = viewController.presentedViewController {
            return findCameraController(in: presented)
        }

        return nil
    }

    private func advanceToNext() {
        if currentAngleIndex < PhotoAngle.allCases.count - 1 {
            withAnimation {
                currentAngleIndex += 1
            }
        } else {
            // All photos captured
            showingPreview = true
        }
    }

    private func saveSession() {
        var photos: [Photo] = []

        for angle in PhotoAngle.allCases {
            if let image = capturedPhotos[angle],
               let fileName = PhotoStorageService.shared.savePhoto(image, for: angle) {
                let photo = Photo(angle: angle, fileName: fileName)
                photos.append(photo)
            }
        }

        let session = CaptureSession(photos: photos)
        dataController.addSession(session)

        // Update streak and reschedule reminder
        dataController.updateStreakOnCapture()
        NotificationService.shared.scheduleReminder(settings: dataController.reminderSettings)

        dismiss()
    }
}

struct CapturePreviewView: View {
    let photos: [PhotoAngle: UIImage]
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Review Your Photos")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)

                    ForEach(PhotoAngle.allCases, id: \.self) { angle in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(angle.displayName)
                                .font(.headline)

                            if let image = photos[angle] {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retake") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    CaptureFlowView()
        .environmentObject(DataController.shared)
}
