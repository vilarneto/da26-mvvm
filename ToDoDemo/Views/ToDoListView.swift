//
//  ToDoListView.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import SwiftUI

/// A tela da lista de to-dos.
struct ToDoListView: View {
    // [m1c10]
    // [m1c02]
    @State private var isPresentingNew = false
    /// O item tocado na lista; não nulo enquanto o sheet de edição está aberto.
    @State private var editingItem: ToDoItem?

    // [m1c06: apagar]
    /// Ainda não há de onde ler os itens: a lista nasce vazia.
    private let items: [ToDoItem] = []

    // [/m1c06]
    var body: some View {
        NavigationStack {
            List {
                // [m1c04: substituir — trocar items por vm.items]
                ForEach(items) { item in
                // [/m1c04]
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
                // [m1c05: substituir — trocar items por vm.items]
                if items.isEmpty {
                // [/m1c05]
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
        // [m1c11]
        // [m3c01]
    }
}

// [m1c01]

// [m1c15: substituir]
#Preview {
    ToDoListView()
}
// [/m1c15]
