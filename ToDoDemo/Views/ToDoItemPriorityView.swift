//
//  ToDoItemPriorityView.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import SwiftUI

/// Mostra só a prioridade: bandeira vermelha (alta), verde (baixa) ou nada (média).
struct ToDoItemPriorityView: View {
    let priority: ToDoItemPriority

    var body: some View {
        switch priority {
        case .high:
            Image(systemName: "flag.fill")
                .foregroundStyle(.red)
                .accessibilityLabel("High priority")
        case .low:
            Image(systemName: "flag.fill")
                .foregroundStyle(.green)
                .accessibilityLabel("Low priority")
        case .medium:
            EmptyView()
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        ForEach(ToDoItemPriority.allCases, id: \.self) { priority in
            LabeledContent(priority.rawValue) {
                ToDoItemPriorityView(priority: priority)
            }
        }
    }
    .padding()
}
