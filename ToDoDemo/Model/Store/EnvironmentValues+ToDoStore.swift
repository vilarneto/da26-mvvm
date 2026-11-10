//
//  EnvironmentValues+ToDoStore.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 08/11/26.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var toDoStore: (any ToDoStore)? = nil
}
