//
//  TodoEditViewModel.swift
//  YATDA
//
//  Created by Scott Bolin on 14-Jan-22.
//

import CoreData
import Foundation
import WidgetKit

struct TodoEditViewModel {
    let coreDataManager: CoreDataManager = .shared

    func fetchTodo(for taskID: NSManagedObjectID, context: NSManagedObjectContext) -> TaskEntity? {
        guard let todo = context.object(with: taskID) as? TaskEntity else { return nil }
        return todo
    }

    func saveTodo(taskID: NSManagedObjectID?, with todoValues: TodoValues, in context: NSManagedObjectContext) {
        let todo: TaskEntity
        if let objectID = taskID, let fetchedRequest = fetchTodo(for: objectID, context: context) {
            todo = fetchedRequest
            print("Fetched existing todo to update")
        } else {
            todo = TaskEntity(context: context)
            print("Create new todo to save")
        }
        todo.title = todoValues.title
        todo.dateCreated = todoValues.dateCreated
        todo.dateDue = todoValues.dateDue
        todo.dateCompleted = todoValues.dateCompleted
        todo.completed = todoValues.completed
        todo.focused = todoValues.focused
        todo.priority = todoValues.priority
        todo.priorityID = todoValues.priorityID
        todo.id = todoValues.id

        coreDataManager.save()
    }
}

