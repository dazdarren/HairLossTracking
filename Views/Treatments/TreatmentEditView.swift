import SwiftUI

struct TreatmentEditView: View {
    @EnvironmentObject private var dataController: DataController
    @Environment(\.dismiss) private var dismiss

    let treatment: Treatment?

    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: String = ""
    @State private var startDate: Date = Date()
    @State private var notes: String = ""
    @State private var isActive: Bool = true
    @State private var showingPresets = false

    private var isEditing: Bool {
        treatment != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Treatment") {
                    HStack {
                        TextField("Name", text: $name)
                        Button {
                            showingPresets = true
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                        .buttonStyle(.borderless)
                    }
                    TextField("Dosage (e.g., 1mg, 5%)", text: $dosage)
                    TextField("Frequency (e.g., Daily, Twice daily)", text: $frequency)
                }

                Section("Duration") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Currently Active", isOn: $isActive)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section {
                        Button("Delete Treatment", role: .destructive) {
                            if let treatment = treatment {
                                dataController.deleteTreatment(treatment)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Treatment" : "Add Treatment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let treatment = treatment {
                    name = treatment.name
                    dosage = treatment.dosage ?? ""
                    frequency = treatment.frequency ?? ""
                    startDate = treatment.startDate
                    notes = treatment.notes ?? ""
                    isActive = treatment.isActive
                }
            }
            .confirmationDialog("Select Treatment", isPresented: $showingPresets) {
                ForEach(Treatment.presets, id: \.self) { preset in
                    Button(preset) {
                        if preset != "Custom" {
                            name = preset
                        }
                    }
                }
            }
        }
    }

    private func save() {
        if var existingTreatment = treatment {
            existingTreatment.name = name
            existingTreatment.dosage = dosage.isEmpty ? nil : dosage
            existingTreatment.frequency = frequency.isEmpty ? nil : frequency
            existingTreatment.startDate = startDate
            existingTreatment.notes = notes.isEmpty ? nil : notes
            existingTreatment.isActive = isActive
            dataController.updateTreatment(existingTreatment)
        } else {
            let newTreatment = Treatment(
                name: name,
                dosage: dosage.isEmpty ? nil : dosage,
                frequency: frequency.isEmpty ? nil : frequency,
                startDate: startDate,
                notes: notes.isEmpty ? nil : notes,
                isActive: isActive
            )
            dataController.addTreatment(newTreatment)
        }
        dismiss()
    }
}

#Preview {
    TreatmentEditView(treatment: nil)
        .environmentObject(DataController.shared)
}
