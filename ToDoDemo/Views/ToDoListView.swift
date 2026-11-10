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
            .refreshable {
                await vm.refresh()
            }
            .overlay {
                switch vm.state {
                case .transitioning:
                    ProgressView("Loading…")
                case .ready:
                    if vm.items.isEmpty {
                        ContentUnavailableView("No to-dos", systemImage: "checklist")
                    }
                case .failed:
                    ContentUnavailableView {
                        Label("Couldn't load the to-dos", systemImage: "exclamationmark.triangle")
                    } actions: {
                        Button("Try again") {
                            Task { await vm.retry() }
                        }
                    }
                }
            }
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
            await vm.observeUpdates()
        }
    }
}

extension ToDoListView {
    @Observable fileprivate final class ViewModel {
        @ObservationIgnored
        private var store: (any ToDoStore)? = nil
        private(set) var state = AsyncState.transitioning(.loading)
        private(set) var items: [ToDoItem] = []

        /// Código de inicialização.
        /// A lógica roda uma única vez, mesmo que o `.task` execute de novo quando a View reaparecer.
        func setupIfNeeded(store: any ToDoStore) async {
            guard self.store == nil else { return }

            self.store = store
            await refresh()
        }

        func refresh() async {
            guard let store else { return }
            do {
                items = try await store.listToDoItems()
                state = .ready
            } catch {
                items = []
                state = .failed(error)
            }
        }

        /// "Tentar de novo" a partir de `.failed`.
        func retry() async {
            state = .transitioning(.loading)
            await refresh()
        }

        /// Recarrega a lista a cada aviso do store. Roda até o `.task` ser cancelado.
        func observeUpdates() async {
            guard let store else { return }
            for await _ in store.updates() {
                await refresh()
            }
        }

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

#Preview("Loading") {
    ToDoListView()
        .environment(\.toDoStore, MockNeverRespondingToDoStore())
}

#Preview("Error") {
    ToDoListView()
        .environment(\.toDoStore, MockFailingToDoStore())
}
