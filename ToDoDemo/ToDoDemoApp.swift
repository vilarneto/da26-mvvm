//
//  ToDoDemoApp.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 05/11/26.
//

import SwiftUI

@main
struct ToDoDemoApp: App {
    // [m2c01: substituir]
    private let store = MockToDoStore()
    // [/m2c01]

    var body: some Scene {
        WindowGroup {
            ToDoListView()
        }
        .environment(\.toDoStore, store)
    }
}
