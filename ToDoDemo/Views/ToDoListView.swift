//
//  ToDoListView.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import SwiftUI

/// A tela da lista de to-dos.
struct ToDoListView: View {
    @Environment(\.toDoStore) private var store
    @State private var vm = ViewModel()
    @State private var isPresentingNew = false
    /// O item tocado na lista; não nulo enquanto o sheet de edição está aberto.
    @State private var editingItem: ToDoItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.items) { item in
                    ToDoItemView(item: item) {
                        Task { await vm.performToggle(item) }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        editingItem = item
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            Task { await vm.performDelete(item) }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
            .listStyle(.plain)
            // [m3c03]
            // [m4c06: substituir — switch sobre vm.state com os três casos]
            .overlay {
                if vm.items.isEmpty {
                    ContentUnavailableView("No to-dos", systemImage: "checklist")
                }
            }
            // [/m4c06]
            .navigationTitle("To-dos")
            .toolbar {
                Button("New to-do", systemImage: "plus") {
                    isPresentingNew = true
                }
            }
        }
        .sheet(isPresented: $isPresentingNew) {
            ToDoEditView(itemID: nil)
        }
        .sheet(item: $editingItem) { item in
            ToDoEditView(itemID: item.id)
        }
        .task {
            guard let store else { fatalError("Missing .environment(\\.toDoStore, ...)") }
            await vm.setupIfNeeded(store: store)
            // [m3c05]
        }
        // [m3c01]
    }
}

extension ToDoListView {
    @Observable fileprivate final class ViewModel {
        @ObservationIgnored
        private var store: (any ToDoStore)? = nil
        // [m4c03: substituir — acrescentar state; items passa a private(set)]
        var items: [ToDoItem] = []
        // [/m4c03]

        /// Código de inicialização.
        /// A lógica roda uma única vez, mesmo que o `.task` execute de novo quando a View reaparecer.
        func setupIfNeeded(store: any ToDoStore) async {
            guard self.store == nil else { return }

            self.store = store
            await refresh()
        }

        func refresh() async {
            guard let store else { return }
            // [m4c04: substituir — atribuir state: .ready ou .failed]
            do {
                items = try await store.listToDoItems()
            } catch {
                // FIXME: JAMAIS faça isso num projeto real, pois mascara erros reais! (A gente vai corrigir isso depois.)
                items = []
            }
            // [/m4c04]
        }

        // [m4c05]

        // [m3c04]

        func performToggle(_ item: ToDoItem) async {
            guard let store, let id = item.id else { return }
            do {
                let updated = try await store.toggleCompleted(id)
                if let index = items.firstIndex(where: { $0.id == id }) {
                    items[index] = updated
                }
            } catch {
                // FIXME: O erro é ignorado. A produção desta demo nunca falha uma escrita; num projeto real, trate-o.
            }
        }

        func performDelete(_ item: ToDoItem) async {
            guard let store, let id = item.id else { return }
            do {
                try await store.deleteToDoItem(id: id)
                items.removeAll { $0.id == id }
            } catch {
                // FIXME: O erro é ignorado. A produção desta demo nunca falha uma escrita; num projeto real, trate-o.
            }
        }
    }
}

#Preview("Common") {
    ToDoListView()
        .environment(\.toDoStore, MockToDoStore())
}

#Preview("Empty") {
    ToDoListView()
        .environment(\.toDoStore, MockEmptyToDoStore())
}

// [m4c09]
