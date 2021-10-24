//
//  CoreDataManager.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import Foundation
import CoreData

class CoreDataManager {
    // Singleton for whole app to use
    static let shared: CoreDataManager = CoreDataManager()

    // Storage for Core Data
    let container: NSPersistentContainer

    // Convenience
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    static var preview: CoreDataManager = {
        let result = CoreDataManager(inMemory: true)
        let viewContext = result.container.viewContext
        let newTask = Task(context: viewContext)
        newTask.title = "Trial Task"
        newTask.completed = false
        newTask.isFavorite = true
        newTask.dateCreated = Date()
        try? viewContext.save()
        return result
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SimpleTodoModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to initialize core data \(error)")

            }
        }
    }

    // utility functions
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // throw error
                print("Could not save, \(error.localizedDescription)")
            }
        }
    }

    func deleteTask(task: Task) {
        CoreDataManager.shared.container.viewContext.delete(task)
        save()
    }
}
