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

    @Environment(\.toDoStore) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var vm = ViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch vm.state {
                case .transitioning(.loading):
                    ProgressView("Loading…")
                case .ready, .transitioning(.saving):
                    Form {
                        Section {
                            TextField("Title", text: $vm.item.title)
                            TextField("Notes", text: $vm.item.notes, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        Section {
                            Picker("Priority", selection: $vm.item.priority) {
                                ForEach(ToDoItemPriority.allCases, id: \.self) { priority in
                                    Text(priority.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Section {
                            if let dueDate = Binding($vm.item.dueDate) {
                                DatePicker("Due date", selection: dueDate, displayedComponents: .date)
                                Button("Remove due date", role: .destructive) {
                                    vm.item.dueDate = nil
                                }
                            } else {
                                Button("Add due date", systemImage: "plus.circle") {
                                    vm.item.dueDate = .now
                                }
                            }
                        }
                    }
                case .failed:
                    ContentUnavailableView {
                        Label("Couldn't load the to-do", systemImage: "exclamationmark.triangle")
                    } actions: {
                        Button("Try again") {
                            Task { await vm.retry() }
                        }
                    }
                }
            }
            .navigationTitle(itemID == nil ? "New to-do" : "Edit to-do")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if case .transitioning(.saving) = vm.state {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await vm.performSave()
                                dismiss()
                            }
                        }
                        .disabled(!vm.canSave)
                    }
                }
            }
        }
        .task {
            guard let store else { fatalError("Missing .environment(\\.toDoStore, ...)") }
            await vm.setupIfNeeded(store: store, itemID: itemID)
        }
    }
}

extension ToDoEditView {
    @Observable fileprivate final class ViewModel {
        @ObservationIgnored
        private var store: (any ToDoStore)? = nil

        private var itemID: UUID?
        /// O item em edição. Ao criar, nasce vazio e com `id == nil`; ao editar, é substituído pelo item lido.
        /// O formulário não edita o `id` nem o `isCompleted`.
        var item = ToDoItem(title: "", notes: "")

        private(set) var state = AsyncState.transitioning(.loading)

        /// Só dá para salvar com um título que não seja só espaços.
        var canSave: Bool {
            !item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        /// Código de inicialização.
        /// A lógica roda uma única vez, mesmo que o `.task` execute de novo quando a View reaparecer.
        func setupIfNeeded(store: any ToDoStore, itemID: UUID?) async {
            guard self.store == nil else { return }

            self.store = store
            self.itemID = itemID
            if itemID != nil {
                await load()
            } else {
                state = .ready
            }
        }

        private func load() async {
            guard let store, let itemID else { return }
            state = .transitioning(.loading)
            do {
                item = try await store.readToDoItem(id: itemID)
                state = .ready
            } catch {
                state = .failed(error)
            }
        }

        /// "Tentar de novo" a partir de `.failed`.
        func retry() async {
            await load()
        }

        func performSave() async {
            guard let store else { return }
            state = .transitioning(.saving)
            defer { state = .ready }
            do {
                if item.id == nil {
                    _ = try await store.createToDoItem(item)
                } else {
                    _ = try await store.updateToDoItem(item)
                }
            } catch {
                // FIXME: O erro é ignorado. A produção desta demo nunca falha uma escrita; num projeto real, trate-o.
            }
        }
    }
}

#Preview("New") {
    ToDoEditView(itemID: nil)
        .environment(\.toDoStore, MockToDoStore())
}

#Preview("Edit") {
    // O id do primeiro item do `MockToDoStore`.
    ToDoEditView(itemID: UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
        .environment(\.toDoStore, MockToDoStore())
}

#Preview("Edit: Loading") {
    ToDoEditView(itemID: UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
        .environment(\.toDoStore, MockNeverRespondingToDoStore())
}

#Preview("Edit: Error") {
    ToDoEditView(itemID: UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
        .environment(\.toDoStore, MockFailingToDoStore())
}
