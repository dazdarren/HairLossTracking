import SwiftUI

struct TreatmentsListView: View {
    @EnvironmentObject private var dataController: DataController
    @State private var showingAddSheet = false
    @State private var selectedTreatment: Treatment?

    var body: some View {
        NavigationStack {
            Group {
                if dataController.treatments.isEmpty {
                    emptyState
                } else {
                    treatmentsList
                }
            }
            .navigationTitle("Treatments")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                TreatmentEditView(treatment: nil)
            }
            .sheet(item: $selectedTreatment) { treatment in
                TreatmentEditView(treatment: treatment)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Treatments", systemImage: "pills")
        } description: {
            Text("Add treatments you're using to track your regimen.")
        } actions: {
            Button("Add Treatment") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var treatmentsList: some View {
        List {
            if !dataController.activeTreatments.isEmpty {
                Section("Active") {
                    ForEach(dataController.activeTreatments) { treatment in
                        TreatmentRow(treatment: treatment)
                            .onTapGesture {
                                selectedTreatment = treatment
                            }
                    }
                    .onDelete(perform: deleteActiveTreatments)
                }
            }

            let inactive = dataController.treatments.filter { !$0.isActive }
            if !inactive.isEmpty {
                Section("Stopped") {
                    ForEach(inactive) { treatment in
                        TreatmentRow(treatment: treatment)
                            .onTapGesture {
                                selectedTreatment = treatment
                            }
                    }
                    .onDelete(perform: deleteInactiveTreatments)
                }
            }
        }
    }

    private func deleteActiveTreatments(at offsets: IndexSet) {
        for index in offsets {
            let treatment = dataController.activeTreatments[index]
            dataController.deleteTreatment(treatment)
        }
    }

    private func deleteInactiveTreatments(at offsets: IndexSet) {
        let inactive = dataController.treatments.filter { !$0.isActive }
        for index in offsets {
            let treatment = inactive[index]
            dataController.deleteTreatment(treatment)
        }
    }
}

struct TreatmentRow: View {
    let treatment: Treatment

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(treatment.name)
                    .font(.headline)

                if let dosage = treatment.dosage, !dosage.isEmpty {
                    Text(dosage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(treatment.durationDays) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if treatment.isActive {
                    Text("Active")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TreatmentsListView()
        .environmentObject(DataController.shared)
}
