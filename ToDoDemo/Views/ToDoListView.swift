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
                    // [m2c08: substituir — closure do toggle depois de ToDoItemView(item: item); Task de performDelete no lugar do TODO; reindentar]
                    ToDoItemView(item: item)
                        .contentShape(.rect)
                        .onTapGesture {
                            editingItem = item
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                // TODO: Implementar exclusão
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    // [/m2c08]
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

        // [m2c02]
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
