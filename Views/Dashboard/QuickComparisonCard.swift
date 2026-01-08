import SwiftUI

struct QuickComparisonCard: View {
    let beforeSession: CaptureSession
    let afterSession: CaptureSession
    let title: String
    let onTap: () -> Void

    private var daysBetween: Int {
        Calendar.current.dateComponents([.day], from: beforeSession.date, to: afterSession.date).day ?? 0
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Text("\(daysBetween) days")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                HStack(spacing: 12) {
                    // Before thumbnail
                    VStack(spacing: 4) {
                        photoThumbnail(for: beforeSession)
                        Text("Before")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    // Arrow
                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    // After thumbnail
                    VStack(spacing: 4) {
                        photoThumbnail(for: afterSession)
                        Text("After")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func photoThumbnail(for session: CaptureSession) -> some View {
        if let photo = session.photo(for: .front),
           let image = PhotoStorageService.shared.loadPhoto(fileName: photo.fileName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 80, height: 100)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

#Preview {
    QuickComparisonCard(
        beforeSession: CaptureSession(date: Date().addingTimeInterval(-86400 * 30)),
        afterSession: CaptureSession(),
        title: "1 Month Progress",
        onTap: {}
    )
    .padding()
}
