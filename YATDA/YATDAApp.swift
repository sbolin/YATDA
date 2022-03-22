//
//  YATDAApp.swift
//  YATDA
//
//  Created by Scott Bolin on 22-Oct-21.
//

import SwiftUI

@main
struct YATDAApp: App {

    @Environment(\.scenePhase) var scenePhase

    // shim to allow for rounded text in NavigationView titles. Thanks to Peter Friese
    // Change background color of all views, and altern nav bar to match. Must set background color in each view (don't forget!)

    init() {
        let navBarAppearance = UINavigationBarAppearance()

        navBarAppearance.largeTitleTextAttributes[.font] = UIFont.roundedLargeTitle()
        navBarAppearance.largeTitleTextAttributes[.foregroundColor] = UIColor(Color.accentColor)
        navBarAppearance.titleTextAttributes[.font] = UIFont.roundedBody()

        navBarAppearance.backgroundColor = UIColor(Color.blue.opacity(0.1))
        navBarAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance

        // clear background from view
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            MainTodoView()
                .font(.system(.body, design: .rounded))
                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
        }
    }
}
