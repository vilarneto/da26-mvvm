//
//  ToDoDemoApp.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 05/11/26.
//

import SwiftUI

@main
struct ToDoDemoApp: App {
    private let store = SomeStrangeToDoStore()

    var body: some Scene {
        WindowGroup {
            ToDoListView()
        }
        .environment(\.toDoStore, store)
    }
}
