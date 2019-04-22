//
//  OfflineFile+CoreDataClass.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/15/18.
//  Copyright © 2018 Amahi. All rights reserved.
//
//

import Foundation
import CoreData

public class OfflineFile: NSManagedObject {

    // MARK: Initializer
    
    convenience init(name: String,
                     mime: String,
                     size: Int64,
                     mtime: Date,
                     fileUri: String,
                     localPath: String,
                     progress: Float,
                     state: OfflineFileState,
                     context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "OfflineFile", in: context) {
            self.init(entity: ent, insertInto: context)
            self.name = name
            self.mime = mime
            self.size = size
            self.mtime = mtime
            self.remoteFileUri = fileUri
            self.localPath = localPath
            self.progress = progress
            self.downloadDate = Date()
            self.stateEnum = state
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    var stateEnum: OfflineFileState {                   //  ↓ If self.state is invalid.
        get { return OfflineFileState(rawValue: self.state) ?? .none }
        set { self.state = newValue.rawValue }
    }
    
    public func getFileSize() -> String {
        return ByteCountFormatter().string(fromByteCount: size)
    }
    
    public func remoteFileURL() -> URL? {
        return URL(string: remoteFileUri ?? "")
    }
}
