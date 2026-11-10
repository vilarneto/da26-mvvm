//
//  ToDoItemView.swift
//  ToDoDemo
//
//  Created by Vilar Fiuza da Camara Neto on 06/11/26.
//

import SwiftUI

/// Um item da lista, mostrado como um pequeno card.
struct ToDoItemView: View {
    let item: ToDoItem
    // [m2c05]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                // [m2c06: substituir — trocar o TODO por onToggle()]
                // TODO: Implementar alternar conclusão
                // [/m2c06]
            } label: {
                ToDoItemCompletionView(isCompleted: item.isCompleted)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isCompleted)

                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let dueDate = item.dueDate {
                    Text(dueDate, format: .dateTime.day().month(.abbreviated))
                        .font(.caption)
                        .foregroundStyle(isOverdue ? Color.red : Color.secondary)
                }
            }

            Spacer(minLength: 8)

            ToDoItemPriorityView(priority: item.priority)
        }
        .padding(12)
        .background(.background.secondary, in: .rect(cornerRadius: 12))
        .opacity(item.isCompleted ? 0.6 : 1)
        .accessibilityElement(children: .combine)
    }

    /// Prazo vencido: o dia do prazo já passou e o item ainda não foi concluído.
    private var isOverdue: Bool {
        guard let dueDate = item.dueDate, !item.isCompleted else { return false }
        return Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: .now)
    }
}

// [m2c07: substituir — acrescentar {} depois de cada ToDoItemView(...) que reclamar de onToggle]
#Preview {
    let day: TimeInterval = 24 * 60 * 60

    VStack(spacing: 12) {
        ToDoItemView(item: ToDoItem(
            title: "Comprar café", notes: "Sem açúcar", priority: .high,
            dueDate: .now.addingTimeInterval(3 * day)))
        ToDoItemView(item: ToDoItem(
            title: "Pagar a conta de luz", notes: "", priority: .medium,
            dueDate: .now.addingTimeInterval(-2 * day)))
        ToDoItemView(item: ToDoItem(
            title: "Estudar protocolos e async/await", notes: "Capítulos 3 e 4, com os exercícios do final de cada capítulo",
            isCompleted: true, priority: .low,
            dueDate: .now.addingTimeInterval(-5 * day)))
        ToDoItemView(item: ToDoItem(title: "Só o título", notes: ""))
    }
    .padding()
}
// [/m2c07]
