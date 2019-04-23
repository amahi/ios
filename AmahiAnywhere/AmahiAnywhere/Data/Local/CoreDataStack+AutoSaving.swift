//
//  CoreDataStack+AutoSaving.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 14/04/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import CoreData

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack {
    
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveContext()
                AmahiLogger.log("Autosaving only if new changes exist")
            } catch let error as NSError {
                AmahiLogger.log("Error while autosaving  \(error.localizedDescription)")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}
