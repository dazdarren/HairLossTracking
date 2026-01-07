import Foundation

enum PhotoAngle: String, CaseIterable, Codable {
    case front = "Front"
    case crown = "Crown"
    case back = "Back"

    var displayName: String {
        rawValue
    }

    var instruction: String {
        switch self {
        case .front:
            return "Position your hairline in the guide"
        case .crown:
            return "Hold phone above your head, looking down"
        case .back:
            return "Use a mirror or ask someone to help"
        }
    }

    var iconName: String {
        switch self {
        case .front:
            return "face.smiling"
        case .crown:
            return "arrow.down.circle"
        case .back:
            return "arrow.uturn.backward.circle"
        }
    }
}
