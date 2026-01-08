import SwiftUI

struct TreatmentMarkerView: View {
    let treatment: Treatment
    let isStart: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isStart ? "play.circle.fill" : "stop.circle.fill")
                .font(.caption)
                .foregroundStyle(isStart ? .green : .gray)

            Text(isStart ? "Started" : "Stopped")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(treatment.name)
                .font(.caption)
                .fontWeight(.medium)

            Spacer()

            Text(treatment.startDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isStart ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isStart ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TreatmentEventRow: View {
    let treatments: [Treatment]
    let referenceDate: Date
    let previousDate: Date?

    var treatmentsStartedInPeriod: [Treatment] {
        guard let prevDate = previousDate else {
            // First session - show treatments that started before or on this date
            return treatments.filter { $0.startDate <= referenceDate }
        }
        // Show treatments that started between previous session and this one
        return treatments.filter { $0.startDate > prevDate && $0.startDate <= referenceDate }
    }

    var body: some View {
        if !treatmentsStartedInPeriod.isEmpty {
            VStack(spacing: 6) {
                ForEach(treatmentsStartedInPeriod) { treatment in
                    TreatmentMarkerView(treatment: treatment, isStart: true)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TreatmentMarkerView(
            treatment: Treatment(name: "Minoxidil 5%", startDate: Date()),
            isStart: true
        )

        TreatmentMarkerView(
            treatment: Treatment(name: "Finasteride 1mg", startDate: Date(), isActive: false),
            isStart: false
        )
    }
    .padding()
}
