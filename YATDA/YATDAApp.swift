//
//  YATDAApp.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

@main
struct YATDAApp: App {
    let persistentContainer = CoreDataManager.shared.container
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
        }
    }
}
