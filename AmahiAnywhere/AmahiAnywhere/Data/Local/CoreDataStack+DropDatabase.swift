//
//  CoreDataStack+DropDatabase.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 14/04/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import CoreData

// MARK: - CoreDataStack (Removing Data)

internal extension CoreDataStack  {
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
    
    var isDownloadsEmpty : Bool {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineFile")
            let count  = try context.count(for: fetchRequest)
            return count == 0 ? true : false
        } catch{
            return true
        }
    }
}
