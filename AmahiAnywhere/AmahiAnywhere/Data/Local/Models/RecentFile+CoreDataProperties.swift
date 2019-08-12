//
//  RecentFile+CoreDataProperties.swift
//  
//
//  Created by Abhishek Sansanwal on 13/08/19.
//
//

import Foundation
import CoreData


extension RecentFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentFile> {
        return NSFetchRequest<RecentFile>(entityName: "RecentFile")
    }

    @NSManaged public var fileURL: String?
    @NSManaged public var serverName: String?
    @NSManaged public var size: NSNumber
    @NSManaged public var day: NSNumber
    @NSManaged public var month: NSNumber
    @NSManaged public var year: NSNumber

}
