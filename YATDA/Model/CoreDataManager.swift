//
//  CoreDataManager.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import Foundation
import CoreData
import WidgetKit

class CoreDataManager {
    // Singleton for whole app to use
    static let shared = CoreDataManager()

    private let inMemory: Bool
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }

    lazy var container: NSPersistentContainer = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.tukgaesoft.YATDA")!.appendingPathComponent("SimpleTodoModel.sqlite")

        let container = NSPersistentContainer(name: "SimpleTodoModel")
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: containerURL)]

        /// Not sure if below works or is needed...
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
        /// end not sure zone...

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
                WidgetCenter.shared.reloadAllTimelines()
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
