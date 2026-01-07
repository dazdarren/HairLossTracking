import Foundation
import SwiftUI

struct Photo: Identifiable, Codable {
    let id: UUID
    let angle: PhotoAngle
    let fileName: String
    let capturedAt: Date

    init(id: UUID = UUID(), angle: PhotoAngle, fileName: String, capturedAt: Date = Date()) {
        self.id = id
        self.angle = angle
        self.fileName = fileName
        self.capturedAt = capturedAt
    }
}
