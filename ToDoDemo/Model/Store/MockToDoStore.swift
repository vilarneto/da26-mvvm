//
//  MockToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 08/11/26.
//

import Foundation

final class MockToDoStore: ToDoStore {
    // [m1c12]

    func listToDoItems() async throws(ToDoStoreError) -> [ToDoItem] {
        // [m1c13: substituir]
        throw .notImplemented
        // [/m1c13]
    }

    func readToDoItem(id: UUID) async throws(ToDoStoreError) -> ToDoItem {
        // [m1c14: substituir]
        throw .notImplemented
        // [/m1c14]
    }

    func createToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem {
        throw .notImplemented
    }

    func updateToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem {
        throw .notImplemented
    }

    func deleteToDoItem(id: UUID) async throws(ToDoStoreError) {
        throw .notImplemented
    }

    func updates() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }
}
