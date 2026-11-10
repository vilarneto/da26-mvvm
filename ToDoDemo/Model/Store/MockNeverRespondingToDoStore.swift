//
//  MockNeverRespondingToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 10/11/26.
//

import Foundation

final class MockNeverRespondingToDoStore: ToDoStore {
    func listToDoItems() async throws(ToDoStoreError) -> [ToDoItem] {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(60 * 60 * 24))
        }
        throw .requestFailed
    }

    func readToDoItem(id: UUID) async throws(ToDoStoreError) -> ToDoItem {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(60 * 60 * 24))
        }
        throw .requestFailed
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
