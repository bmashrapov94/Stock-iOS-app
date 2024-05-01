//
//  StocksAppApp.swift
//  StocksApp
//
//  Created by Bek Mashrapov on 2024-04-22.
//

import SwiftUI

@main
struct StocksAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
