//
//  YATDAApp.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

@main
struct YATDAApp: App {
//    let persistentContainer = CoreDataManager.shared.persistentContainer
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
        }
    }
}
