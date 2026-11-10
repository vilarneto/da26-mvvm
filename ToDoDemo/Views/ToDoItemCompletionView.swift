//
//  ToDoItemCompletionView.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import SwiftUI

/// Mostra só o estado de conclusão: círculo vazio ou círculo com check.
/// É apenas um ícone; quem decide o que acontece ao tocá-lo é quem o usa.
struct ToDoItemCompletionView: View {
    let isCompleted: Bool

    var body: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isCompleted ? Color.accentColor : Color.secondary)
            .accessibilityLabel(isCompleted ? "Completed" : "Not completed")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        LabeledContent("isCompleted = false") {
            ToDoItemCompletionView(isCompleted: false)
        }
        LabeledContent("isCompleted = true") {
            ToDoItemCompletionView(isCompleted: true)
        }
    }
    .padding()
}
