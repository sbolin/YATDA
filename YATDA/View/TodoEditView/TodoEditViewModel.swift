//
//  TodoEditViewModel.swift
//  YATDA
//
//  Created by Scott Bolin on 14-Jan-22.
//

import CoreData
import Foundation
import WidgetKit

class TodoEditViewModel: ObservableObject {
    let coreDataManager: CoreDataManager = .shared

    func fetchTodo(for taskID: NSManagedObjectID, context: NSManagedObjectContext) -> TaskEntity? {
        guard let todo = context.object(with: taskID) as? TaskEntity else { return nil }
        return todo
    }

    func saveTodo(taskID: NSManagedObjectID?, with todoValues: TodoValues, in context: NSManagedObjectContext) {
        let todo: TaskEntity
        if let objectID = taskID, let fetchedRequest = fetchTodo(for: objectID, context: context) {
            todo = fetchedRequest
        } else {
            todo = TaskEntity(context: context)
        }
        todo.completed = todoValues.completed
        todo.dateCompleted = todoValues.dateCompleted
        todo.dateCreated = todoValues.dateCreated
        todo.dateDue = todoValues.dateDue
        todo.focused = todoValues.focused
        todo.id = todoValues.id
        todo.note = todoValues.note
        todo.notifiable = todoValues.notifiable
        todo.notifyTime = todoValues.notifyTime
        todo.order = todoValues.order
        todo.priority = todoValues.priority
        todo.priorityID = todoValues.priorityID
        todo.title = todoValues.title

        coreDataManager.save()
    }
}

