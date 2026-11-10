//
//  ChangeBroadcaster.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 05/11/26.
//

import Foundation

/// Entrega um `AsyncStream` independente a cada assinante.
/// (Um único `AsyncStream` não suporta vários consumidores de forma confiável.)
final class ChangeBroadcaster {
    private var continuations: [UUID: AsyncStream<Void>.Continuation] = [:]

    func makeStream() -> AsyncStream<Void> {
        let id = UUID()
        let (stream, continuation) = AsyncStream.makeStream(
            of: Void.self, bufferingPolicy: .bufferingNewest(1))
        continuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func notify() {
        for continuation in continuations.values {
            continuation.yield()
        }
    }
}
