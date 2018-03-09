//
//  Mimes.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 09/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

public class Mimes {
    
    public static var shared = Mimes()
    
    private var types: [String: Int]
    
    private init() {
        types = [String: Int]()
        
        types.updateValue(MimeType.UNDEFINED, forKey: "application/octet-stream")
        
        types.updateValue(MimeType.ARCHIVE, forKey: "application/gzip")
        types.updateValue(MimeType.ARCHIVE, forKey: "application/rar")
        types.updateValue(MimeType.ARCHIVE, forKey: "application/zip")
        types.updateValue(MimeType.ARCHIVE, forKey: "application/x-gtar")
        types.updateValue(MimeType.ARCHIVE, forKey: "application/x-tar")
        types.updateValue(MimeType.ARCHIVE, forKey: "application/x-rar-compressed")
        
        types.updateValue(MimeType.AUDIO, forKey: "application/ogg")
        types.updateValue(MimeType.AUDIO, forKey: "application/x-flac")
        
        types.updateValue(MimeType.CODE, forKey: "text/css")
        types.updateValue(MimeType.CODE, forKey: "text/xml")
        types.updateValue(MimeType.CODE, forKey: "application/json")
        types.updateValue(MimeType.CODE, forKey: "application/javascript")
        types.updateValue(MimeType.CODE, forKey: "application/xml")
        
        types.updateValue(MimeType.DOCUMENT, forKey: "application/pdf")
        types.updateValue(MimeType.DOCUMENT, forKey: "application/msword")
        types.updateValue(MimeType.DOCUMENT, forKey: "application/vnd.oasis.opendocument.text")
        types.updateValue(MimeType.DOCUMENT, forKey: "application/x-abiword")
        types.updateValue(MimeType.DOCUMENT, forKey: "application/x-kword")
        types.updateValue(MimeType.DOCUMENT, forKey: "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
        
        types.updateValue(MimeType.DIRECTORY, forKey: "text/directory")
        
        types.updateValue(MimeType.IMAGE, forKey: "application/vnd.oasis.opendocument.graphics")
        types.updateValue(MimeType.IMAGE, forKey: "application/vnd.oasis.opendocument.graphics-template")
        
        types.updateValue(MimeType.PRESENTATION, forKey: "application/vnd.ms-powerpoint")
        types.updateValue(MimeType.PRESENTATION, forKey: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
        types.updateValue(MimeType.PRESENTATION, forKey: "application/vnd.openxmlformats-officedocument.presentationml.slideshow")
        
        types.updateValue(MimeType.SPREADSHEET, forKey: "application/vnd.ms-excel")
        types.updateValue(MimeType.SPREADSHEET, forKey: "application/vnd.oasis.opendocument.spreadsheet")
        types.updateValue(MimeType.SPREADSHEET, forKey: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
        
        types.updateValue(MimeType.VIDEO, forKey: "application/x-quicktimeplayer")
        
        types.updateValue(MimeType.SUBTITLE, forKey: "application/x-subrip")
        types.updateValue(MimeType.SUBTITLE, forKey: "image/vnd.dvb.subtitle")
        types.updateValue(MimeType.SUBTITLE, forKey: "application/x-subtitle")
    }
    
    public func match(_ mime: String) -> Int {
        let type = matchKnown(mime);
    
    if type != MimeType.UNDEFINED {
        return type;
    } else {
        return matchCategory(mime)
    }
    }
    
    private func matchKnown(_ mime: String) -> Int {
        guard let mimeType = types[mime] else {
            return MimeType.UNDEFINED
        }
        return mimeType
    }
    
    private func matchCategory(_ mime: String) -> Int {
        let type = mime.split(separator: "/")[0]
    
        switch type {
        case "audio":
            return MimeType.AUDIO
        case "image":
            return MimeType.IMAGE
        case "text":
            return MimeType.DOCUMENT
        case "video":
            return MimeType.VIDEO
        default:
            return MimeType.UNDEFINED
        }
    }

}

public struct MimeType {
    public static let UNDEFINED = 0
    public static let ARCHIVE = 1
    public static let AUDIO = 2
    public static let CODE = 3
    public static let DOCUMENT = 4
    public static let DIRECTORY = 5
    public static let IMAGE = 6
    public static let PRESENTATION = 7
    public static let SPREADSHEET = 8
    public static let VIDEO = 9
    public static let SUBTITLE = 10
}
