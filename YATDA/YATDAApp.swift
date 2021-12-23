//
//  YATDAApp.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

@main
struct YATDAApp: App {

    // shim to allow for rounded text in NavigationView titles. Thanks to Peter Friese

    init() {
        let navBarAppearance = UINavigationBarAppearance()

        navBarAppearance.largeTitleTextAttributes[.font] = UIFont.roundedLargeTitle()
        navBarAppearance.largeTitleTextAttributes[.foregroundColor] = UIColor(Color.accentColor)
        navBarAppearance.titleTextAttributes[.font] = UIFont.roundedBody()

        // Purposefully don't set the foreground color for normal text nav bar -
        // in Reminders.app, this isn't tinted as well!
        // navBarAppearance.titleTextAttributes[.foregroundColor] = foregroundColor

        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(.system(.body, design: .rounded))
                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
        }
    }
}
