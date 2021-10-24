//
//  Task+Ext.swift.swift
//  YATDA
//
//  Created by Scott Bolin on 25-Oct-21.
//

import Foundation

extension Task {

    @discardableResult
    static func makePreview() -> [Task] {
        var tasks = [Task]()
        let viewContext = CoreDataManager.preview.container.viewContext
        let newTask = Task(context: viewContext)
        newTask.title = "Trial Task"
        newTask.completed = false
        newTask.isFavorite = true
        newTask.dateCreated = Date()
        tasks.append(newTask)
        return tasks
    }
}
