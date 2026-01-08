import Foundation

struct ProgressInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let subtitle: String
    let beforeSession: CaptureSession?
    let afterSession: CaptureSession?

    enum InsightType {
        case oneMonthComparison
        case threeMonthComparison
        case firstCapture
        case streak
        case consistency
    }
}
