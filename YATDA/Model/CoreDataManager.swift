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
    static let shared = CoreDataManager()

//    static let preview: CoreDataManager = {
//        let result = CoreDataManager(inMemory: true)
//        Task.makePreview()
//        return result
//    }()

    private let inMemory: Bool
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SimpleTodoModel")

        guard let description = container.persistentStoreDescriptions.first else
        {
            fatalError("Failed to retrieve a persistent store description")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

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

    func deleteTask(task: Task, context: NSManagedObjectContext) {
        context.delete(task)
//        CoreDataManager.shared.container.viewContext.delete(task)
        save()
    }
}
