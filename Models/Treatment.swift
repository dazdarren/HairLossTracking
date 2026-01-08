import Foundation

struct Treatment: Identifiable, Codable {
    let id: UUID
    var name: String
    var dosage: String?
    var frequency: String?
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        dosage: String? = nil,
        frequency: String? = nil,
        startDate: Date = Date(),
        endDate: Date? = nil,
        notes: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.isActive = isActive
    }

    var durationDays: Int {
        let end = endDate ?? Date()
        return Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 0
    }

    var durationDescription: String {
        let days = durationDays
        if days >= 365 {
            let years = days / 365
            let months = (days % 365) / 30
            if months > 0 {
                return "\(years)y \(months)mo"
            }
            return "\(years) year\(years > 1 ? "s" : "")"
        } else if days >= 30 {
            let months = days / 30
            return "\(months) month\(months > 1 ? "s" : "")"
        } else if days >= 7 {
            let weeks = days / 7
            return "\(weeks) week\(weeks > 1 ? "s" : "")"
        } else {
            return "\(days) day\(days != 1 ? "s" : "")"
        }
    }
}

// Common treatment presets
extension Treatment {
    static let presets: [String] = [
        "Minoxidil 5%",
        "Finasteride 1mg",
        "Dutasteride 0.5mg",
        "Ketoconazole Shampoo",
        "Derma Roller",
        "PRP Treatment",
        "Biotin",
        "Saw Palmetto",
        "Nizoral Shampoo",
        "Custom"
    ]
}
