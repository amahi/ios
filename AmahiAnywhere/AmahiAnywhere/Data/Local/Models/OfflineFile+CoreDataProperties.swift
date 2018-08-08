//
//  OfflineFile+CoreDataProperties.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/15/18.
//  Copyright © 2018 Amahi. All rights reserved.
//
//

import Foundation
import CoreData

extension OfflineFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OfflineFile> {
        return NSFetchRequest<OfflineFile>(entityName: "OfflineFile")
    }

    @NSManaged public var downloadDate: Date?
    @NSManaged public var progress: Float
    @NSManaged public var localPath: String?
    @NSManaged public var mime: String?
    @NSManaged public var mtime: Date?
    @NSManaged public var name: String?
    @NSManaged public var remoteFileUri: String?
    @NSManaged public var size: Int64
    @NSManaged public var state: Int16
}
