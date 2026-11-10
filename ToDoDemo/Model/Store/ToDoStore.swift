//
//  ToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 05/11/26.
//

import Foundation

/// Contrato entre View/ViewModel e a persistência. Nada aqui revela *como* os dados são guardados.
protocol ToDoStore {
    /// Todos os itens, na ordem de criação. Ordenar e filtrar é com quem chama.
    func listToDoItems() async throws(ToDoStoreError) -> [ToDoItem]

    func readToDoItem(id: UUID) async throws(ToDoStoreError) -> ToDoItem

    /// O `id` do argumento deve ser `nil`: quem decide o id é o store. Devolve o item como foi criado.
    func createToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem

    /// Devolve o item como foi guardado.
    func updateToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem

    func deleteToDoItem(id: UUID) async throws(ToDoStoreError)

    /// Cada chamada devolve um stream novo. Emite depois de qualquer mutação bem-sucedida.
    func updates() -> AsyncStream<Void>
}

extension ToDoStore {
    /// Lê o item, inverte `isCompleted` e o atualiza. Vale para qualquer conformante.
    func toggleCompleted(_ id: UUID) async throws(ToDoStoreError) -> ToDoItem {
        var item = try await readToDoItem(id: id)
        item.isCompleted.toggle()
        return try await updateToDoItem(item)
    }
}
