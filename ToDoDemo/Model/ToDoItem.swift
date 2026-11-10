//
//  ToDoItem.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 05/11/26.
//

import Foundation

struct ToDoItem: Identifiable, Codable {
    /// `nil` até o store criar o item e atribuir o id.
    var id: UUID?
    var title: String
    var notes: String
    var isCompleted: Bool = false
    var priority: ToDoItemPriority = .medium
    var dueDate: Date?
}
