//
//  aApp.swift
//  a
//
//  Created by Leonid Perlin on 2/24/24.
//

import SwiftUI

@main
struct aApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
