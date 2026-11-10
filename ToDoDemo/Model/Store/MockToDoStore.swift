//
//  MockToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 08/11/26.
//

import Foundation

final class MockToDoStore: ToDoStore {
    /// Itens fixos, com ids conhecidos para que as previews possam referenciá-los.
    private let sampleItems: [ToDoItem] = {
        let day: TimeInterval = 24 * 60 * 60
        return [
            ToDoItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                title: "Comprar café",
                notes: "Sem açúcar",
                priority: .high,
                dueDate: .now.addingTimeInterval(3 * day),
            ),
            ToDoItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                title: "Pagar a conta de luz",
                notes: "",
                priority: .medium,
                dueDate: .now.addingTimeInterval(-2 * day),
            ),
            ToDoItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                title: "Estudar protocolos e async/await",
                notes: "Capítulos 3 e 4, com os exercícios do final de cada capítulo",
                isCompleted: true,
                priority: .low,
                dueDate: .now.addingTimeInterval(-5 * day),
            ),
            ToDoItem(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                title: "Só o título",
                notes: "",
            ),
        ]
    }()

    func listToDoItems() async throws(ToDoStoreError) -> [ToDoItem] {
        sampleItems
    }

    func readToDoItem(id: UUID) async throws(ToDoStoreError) -> ToDoItem {
        guard let item = sampleItems.first(where: { $0.id == id }) else {
            throw .notFound
        }
        return item
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
