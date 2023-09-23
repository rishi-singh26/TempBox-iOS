//
//  TempBoxApp.swift
//  TempBox
//
//  Created by Rishi Singh on 23/09/23.
//

import SwiftUI

@main
struct TempBoxApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
