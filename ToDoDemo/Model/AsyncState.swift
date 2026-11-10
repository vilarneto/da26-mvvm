//
//  AsyncState.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 10/11/26.
//

/// O estado de uma operação assíncrona de uma tela. Os dados ficam na ViewModel, fora do estado.
enum AsyncState {
    /// Há uma operação em andamento.
    case transitioning(AsyncTransition)
    /// Nada em andamento.
    case ready
    /// A última operação falhou.
    case failed(ToDoStoreError)
}

/// A operação em andamento.
enum AsyncTransition {
    case loading
    case saving
}
