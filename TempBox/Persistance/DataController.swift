//
//  DataController.swift
//  TempBox
//
//  Created by Rishi Singh on 20/09/23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "TempBox")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core data failed to load \(error.localizedDescription)")
            }
            return
        }
        
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
}
