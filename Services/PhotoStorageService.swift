import Foundation
import UIKit

final class PhotoStorageService {
    static let shared = PhotoStorageService()

    private let fileManager = FileManager.default

    private var photosDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDir = documentsDirectory.appendingPathComponent("Photos", isDirectory: true)

        if !fileManager.fileExists(atPath: photosDir.path) {
            try? fileManager.createDirectory(at: photosDir, withIntermediateDirectories: true)
        }

        return photosDir
    }

    private init() {}

    // MARK: - Save Photo

    func savePhoto(_ image: UIImage, for angle: PhotoAngle) -> String? {
        let fileName = "\(UUID().uuidString)_\(angle.rawValue).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }

        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }

    // MARK: - Load Photo

    func loadPhoto(fileName: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    // MARK: - Delete Photo

    func deletePhoto(fileName: String) {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }

    // MARK: - Delete All Photos for Session

    func deletePhotos(for session: CaptureSession) {
        for photo in session.photos {
            deletePhoto(fileName: photo.fileName)
        }
    }
}
