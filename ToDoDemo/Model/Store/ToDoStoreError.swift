//
//  ToDoStoreError.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import Foundation

enum ToDoStoreError: Error {
    /// O item pedido não existe.
    case notFound
    /// Esta implementação não suporta a operação.
    case notImplemented
    /// A requisição não pôde ser completada (por exemplo, os dados não chegaram).
    case requestFailed
}
