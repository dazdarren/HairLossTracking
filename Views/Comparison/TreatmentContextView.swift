import SwiftUI

struct TreatmentContextView: View {
    let treatments: [Treatment]
    let olderDate: Date
    let newerDate: Date

    private var contextItems: [TreatmentContextItem] {
        var items: [TreatmentContextItem] = []

        for treatment in treatments {
            let startedBefore = treatment.startDate < olderDate
            let startedDuring = treatment.startDate >= olderDate && treatment.startDate <= newerDate
            let stillActive = treatment.isActive || (treatment.endDate ?? Date()) > newerDate

            if startedDuring {
                items.append(TreatmentContextItem(
                    treatment: treatment,
                    type: .startedDuring,
                    description: "Started \(treatment.durationDescription) ago"
                ))
            } else if startedBefore && stillActive {
                items.append(TreatmentContextItem(
                    treatment: treatment,
                    type: .activeThroughout,
                    description: "Active throughout (\(treatment.durationDescription))"
                ))
            }
        }

        return items
    }

    var body: some View {
        if !contextItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Treatments")
                    .font(.headline)

                VStack(spacing: 8) {
                    ForEach(contextItems) { item in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(item.type == .startedDuring ? Color.green : Color.blue)
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.treatment.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(item.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct TreatmentContextItem: Identifiable {
    let id = UUID()
    let treatment: Treatment
    let type: ContextType
    let description: String

    enum ContextType {
        case startedDuring
        case activeThroughout
    }
}

#Preview {
    TreatmentContextView(
        treatments: [
            Treatment(name: "Minoxidil 5%", startDate: Date().addingTimeInterval(-86400 * 60)),
            Treatment(name: "Finasteride 1mg", startDate: Date().addingTimeInterval(-86400 * 15))
        ],
        olderDate: Date().addingTimeInterval(-86400 * 30),
        newerDate: Date()
    )
    .padding()
}
