//
//  ToDoEditView.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import SwiftUI

/// Formulário para criar (`itemID == nil`) ou editar um to-do.
struct ToDoEditView: View {
    let itemID: UUID?

    // [m2c10: substituir — apagar os quatro @State; incluir @Environment(\.toDoStore) store e @State vm]
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var priority = ToDoItemPriority.medium
    @State private var dueDate: Date?
    // [/m2c10]

    var body: some View {
        NavigationStack {
            // [m2c15: substituir — prefixar com vm.item. ou $vm.item. em cada linha com erro]
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Picker("Priority", selection: $priority) {
                        ForEach(ToDoItemPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    if let dueDate = Binding($dueDate) {
                        DatePicker("Due date", selection: dueDate, displayedComponents: .date)
                        Button("Remove due date", role: .destructive) {
                            self.dueDate = nil
                        }
                    } else {
                        Button("Add due date", systemImage: "plus.circle") {
                            dueDate = .now
                        }
                    }
                }
            }
            // [/m2c15]
            .navigationTitle(itemID == nil ? "New to-do" : "Edit to-do")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    // [m2c16: substituir — chamar performSave e dismiss numa Task; trocar a validação por !vm.canSave]
                    Button("Save") {
                        // TODO: Implementar salvar (create ou update) e fechar a tela
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    // [/m2c16]
                }
            }
        }
        // [m2c17]
    }
}

// [m2c09]

// [m2c18: substituir]
#Preview("New") {
    ToDoEditView(itemID: nil)
}

#Preview("Edit") {
    ToDoEditView(itemID: UUID())
}
// [/m2c18]
