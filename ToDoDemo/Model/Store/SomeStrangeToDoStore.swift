//
//  SomeStrangeToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 05/11/26.
//

import Foundation

/// Guarda os itens em um arquivo JSON na sandbox do app.
/// Mantém a lista em memória e regrava o arquivo inteiro a cada mutação.
final class SomeStrangeToDoStore: ToDoStore {
    private let fileURL: URL
    private var items: [ToDoItem] = []
    private var isLoaded = false
    private let broadcaster = ChangeBroadcaster()

    init(fileURL: URL = .documentsDirectory.appending(path: "todos.json")) {
        self.fileURL = fileURL
    }

    func listToDoItems() async throws(ToDoStoreError) -> [ToDoItem] {
        await simulateLatency()
        try simulateRequestFailure()
        loadIfNeeded()
        return items
    }

    func readToDoItem(id: UUID) async throws(ToDoStoreError) -> ToDoItem {
        await simulateLatency()
        loadIfNeeded()
        guard let item = items.first(where: { $0.id == id }) else {
            throw .notFound
        }
        return item
    }

    func createToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem {
        await simulateLatency()
        loadIfNeeded()
        var created = item
        created.id = UUID()
        created.title = normalized(item.title)
        items.append(created)
        persist()
        return created
    }

    func updateToDoItem(_ item: ToDoItem) async throws(ToDoStoreError) -> ToDoItem {
        await simulateLatency()
        loadIfNeeded()
        guard let id = item.id, let index = items.firstIndex(where: { $0.id == id }) else {
            throw .notFound
        }
        var stored = item
        stored.title = normalized(item.title)
        items[index] = stored
        persist()
        return stored
    }

    func deleteToDoItem(id: UUID) async throws(ToDoStoreError) {
        await simulateLatency()
        loadIfNeeded()
        items.removeAll { $0.id == id }
        persist()
    }

    func updates() -> AsyncStream<Void> {
        broadcaster.makeStream()
    }

    // MARK: - Privado

    /// Arquivo ausente ou ilegível vira lista vazia. Em caso de erro de decode isso é uma
    /// perda catastrófica (a próxima gravação sobrescreve o arquivo), aceita por ser uma demo.
    private func loadIfNeeded() {
        guard !isLoaded else { return }
        isLoaded = true
        guard let data = try? Data(contentsOf: fileURL) else { return }
        items = (try? JSONDecoder().decode([ToDoItem].self, from: data)) ?? []
    }

    /// I/O síncrono na main thread: aceitável para um arquivo pequeno de demo.
    private func persist() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        // Falha de escrita ignorada nesta demo (como a perda no decode).
        try? encoder.encode(items).write(to: fileURL, options: .atomic)
        broadcaster.notify()
    }

    /// O "servidor" aparou os espaços do título: por isso criar e atualizar devolvem o item.
    private func normalized(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func simulateLatency() async {
        guard BehaviorFlags.enableFakeLatency else { return }
        try? await Task.sleep(for: .seconds(5))
    }

    /// Sorteia uma falha de requisição, antes de qualquer leitura. Só a listagem usa.
    private func simulateRequestFailure() throws(ToDoStoreError) {
        if Float.random(in: 0..<1) < BehaviorFlags.requestFailureProbability {
            throw .requestFailed
        }
    }
}
