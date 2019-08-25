//
//  RecentsDatabaseHelper.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 12/08/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RecentsDatabaseHelper {
    
    static var shareInstance = RecentsDatabaseHelper()
    let context = RecentsPersistenceService.persistentContainer.viewContext
    
    func save(object:[String:Any]) {
        
        let tempArray = getData()
        for index in 0..<(tempArray.count) {
            if tempArray[index].fileURL == object["fileURL"] as? String {
                deleteData(index: index)
            }
        }
        if  tempArray.count >= 50 {
            deleteData(index: 0)
        }
        
        let recentFile = NSEntityDescription.insertNewObject(forEntityName: "RecentFile", into: context) as! RecentFile
        recentFile.day = object["day"] as! NSNumber
        recentFile.month = object["month"] as! NSNumber
        recentFile.year = object["year"] as! NSNumber
        recentFile.authToken = object["authToken"] as? String
        recentFile.fileName = object["fileName"] as? String
        recentFile.fileURL = object["fileURL"] as? String
        recentFile.serverName = object["serverName"] as? String
        recentFile.size = object["size"] as? String
        recentFile.mimeType = object["mimeType"] as? String
        recentFile.mtimeDate = (object["mtimeDate"] as? Date)!
        recentFile.path = object["path"] as? String
        recentFile.sizeNumber = object["sizeNumber"] as! Int64
        
        do{
            try context.save()
        } catch {
            print("Data couldn't be saved!")
        }
    }
    
    func getData() -> [RecentFile] {
        var recentFile = [RecentFile]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecentFile")
        do {
            recentFile = try context.fetch(fetchRequest) as! [RecentFile]
        } catch {
            print("Cannot get data!")
        }
        return recentFile
    }
    
    func deleteData(index: Int) {
        var recentFile = getData()
        context.delete(recentFile[index])
        recentFile.remove(at: index)
        do {
            try context.save()
        } catch {
            print("Cannot delete data!")
        }
    }
    
}
