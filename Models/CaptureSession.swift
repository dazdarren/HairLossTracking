import Foundation

struct CaptureSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    var photos: [Photo]
    var notes: String?

    init(id: UUID = UUID(), date: Date = Date(), photos: [Photo] = [], notes: String? = nil) {
        self.id = id
        self.date = date
        self.photos = photos
        self.notes = notes
    }

    var isComplete: Bool {
        photos.count == PhotoAngle.allCases.count
    }

    func photo(for angle: PhotoAngle) -> Photo? {
        photos.first { $0.angle == angle }
    }
}
