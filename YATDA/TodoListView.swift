//
//  TodoListView.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

struct TodoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var task: Task


    var body: some View {
        HStack {
            Circle()
                .fill(Priority.styleForPriority(task.priority ?? "Medium"))
                .frame(width: 15, height: 15)
            Spacer().frame(width: 12)
            Text(task.title ?? "")
            Spacer()
            Image(systemName: task.isFavorite ? "target": "scope")
                .foregroundColor(.red)
                .onTapGesture {
                    updateTask()
                }
            Image(systemName: task.completed ? "checkmark.circle.fill": "checkmark.circle")
                .foregroundColor(.green)
                .onTapGesture {
                    updateCompletion()
                }
        }
    }

    private func updateTask() {
//       $task.isFavorite.toggle
        let oldValue = task.isFavorite
        task.isFavorite = !oldValue
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func updateCompletion() {
        let oldValue = task.completed
        task.completed = !oldValue
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataManager.preview.container.viewContext
        TodoListView(task: Task(context: context))
            .environment(\.managedObjectContext, context)
    }
}
