//
//  RecentFiles.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 12/08/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct Recent: Equatable{
    var mtimeDate: Date
    var fileName: String
    var fileURL: String
    var serverName: String
    var mimeType: String
    var filesSize: String
    var fileDisplayText: String
    var authToken: String
    var path: String
    var sizeNumber: Int64
    
    public func getOfflineFile() -> OfflineFile?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineFile")
        let predicate = NSPredicate(format: "name == %@", fileName)
        fetchRequest.predicate = predicate
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        do{
            if let results = try stack.context.fetch(fetchRequest) as? [OfflineFile]{
                if results.count >= 1{
                    return results[0]
                }
            }
        }catch{
            return nil
        }
        
        return nil
    }
    
    public func getExtension() -> String {
        let splitString: [String.SubSequence] = fileName.split(separator: ".")
        if (splitString.count > 1) {
            return String(describing: splitString.last)
        } else {
            return ""
        }
    }
}

class RecentFiles {
    
    static var sharedInstance = RecentFiles()
    let context = RecentsPersistenceService.persistentContainer.viewContext
    
    var recentFiles: [Recent] = []

    func setupStruct() {
        let recents = RecentsDatabaseHelper.shareInstance.getData()
        recentFiles.removeAll()
        for index in 0..<(recents.count) {
            
            let displayText = displayTextGenerator(day: Int(recents[index].day), month: Int(recents[index].month), year: Int(recents[index].year))
            let recent: Recent = Recent(mtimeDate: recents[index].mtimeDate, fileName: recents[index].fileName!, fileURL: recents[index].fileURL!, serverName: recents[index].serverName!, mimeType: recents[index].mimeType!, filesSize: recents[index].size!, fileDisplayText: displayText, authToken: recents[index].authToken!, path: recents[index].path!, sizeNumber: recents[index].sizeNumber)
            recentFiles.append(recent)
        }
        do{
            try context.save()
        } catch {
            print("Data couldn't be saved!")
        }
    }
    
    func displayTextGenerator(day: Int, month: Int, year: Int) -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let presentYear =  components.year
        let presentMonth = components.month
        let presentDay = Int(components.day!)
        
        if presentYear == year {
            if presentMonth == month {
                if presentDay == day {
                    return "Today"
                }
                else {
                    if day - presentDay == 1 {
                        return "Yesterday"
                    }
                    else if day - presentDay <= 7 {
                        return "This Week"
                    }
                    else {
                        return "This Month"
                    }
                }
            }
            else {
                return "\(month) \(year)"
            }
        }
        else {
            return "\(year)"
        }
    }
    
    func getRecentFiles() -> [Recent] {
        setupStruct()
        return recentFiles
    }
}
