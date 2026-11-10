//
//  MockFailingToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 10/11/26.
//

import Foundation

final class MockFailingToDoStore: ToDoStore {
    func listToDoItems() async throws(ToDoStoreError) -> [ToDoItem] {
        throw .requestFailed
    }

    func readToDoItem(id: UUID) async throws(ToDoStoreError) -> ToDoItem {
        throw .requestFailed
    }

    func createToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem {
        throw .requestFailed
    }

    func updateToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem {
        throw .requestFailed
    }

    func deleteToDoItem(id: UUID) async throws(ToDoStoreError) {
        throw .requestFailed
    }

    func updates() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }
}
