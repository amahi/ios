//
//  ServerFile.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 07/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import EVReflection

@objc(ServerFile)
public class ServerFile: EVNetworkingObject {
    
    public var name: String? =              nil
    public var mime_type: String? =         nil
    public var size: CLongLong? =           0
    public var mtime: Date? =               nil
    
    public var parentFile: ServerFile? =    nil
    public var parentShare: ServerShare? =  nil
    
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "size" {
            self.size = value as? CLongLong
        }
    }
    
    public func getPath() -> String {
        var path: String = ""
        
        if parentFile != nil {
            path.append(parentFile!.getPath())
        }
    
        path.append("/\(name!)");
    
        return path;
    }
    
    public func getExtension() -> String {
        let splitString: [String.SubSequence] = name!.split(separator: ".")
        if (splitString.count > 1) {
            return String(describing: splitString.last)
        } else {
            return ""
        }
    }
    
    public func getNameOnly() -> String {
        return name!.replacingOccurrences(of: "." + getExtension(), with: "");
    }
    
    public func getFileSize() -> String {
        return ByteCountFormatter().string(fromByteCount: size!)
    }
    
    public func getLastModifiedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d yyyy"
        return dateFormatter.string(from: mtime!)
    }
    
    public func getLastModifiedEpoch() -> Int {
        return Int(mtime!.timeIntervalSince1970)
    }
    
    public func isDirectory() -> Bool {
        return Mimes.shared.match(mime_type!) == MimeType.DIRECTORY
    }
}

extension ServerFile {
    static let nameSorter: (ServerFile, ServerFile) -> Bool = { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending }
    static let lastModifiedSorter: (ServerFile, ServerFile) -> Bool = { $0.mtime! > $1.mtime! }
}
