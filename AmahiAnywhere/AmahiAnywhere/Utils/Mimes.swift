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
    
    private var types: [String: MimeType]
    
    private init() {
        types = [String: MimeType]()
        
        types.updateValue(MimeType.undefined, forKey: "application/octet-stream")
        
        types.updateValue(MimeType.archive, forKey: "application/gzip")
        types.updateValue(MimeType.archive, forKey: "application/rar")
        types.updateValue(MimeType.archive, forKey: "application/zip")
        types.updateValue(MimeType.archive, forKey: "application/x-gtar")
        types.updateValue(MimeType.archive, forKey: "application/x-tar")
        types.updateValue(MimeType.archive, forKey: "application/x-rar-compressed")
        
        types.updateValue(MimeType.audio, forKey: "application/ogg")
        // breaking out flac on its own type because of https://github.com/amahi/ios/issues/172
        types.updateValue(MimeType.flacMedia, forKey: "application/x-flac")
        
        types.updateValue(MimeType.code, forKey: "text/css")
        types.updateValue(MimeType.code, forKey: "text/html")
        types.updateValue(MimeType.code, forKey: "text/xml")
        types.updateValue(MimeType.code, forKey: "application/json")
        types.updateValue(MimeType.code, forKey: "application/javascript")
        types.updateValue(MimeType.code, forKey: "application/xml")
        
        types.updateValue(MimeType.document, forKey: "application/pdf")
        types.updateValue(MimeType.document, forKey: "text/csv")
        types.updateValue(MimeType.document, forKey: "text/plain")
        types.updateValue(MimeType.document, forKey: "application/msword")
        types.updateValue(MimeType.document, forKey: "application/vnd.oasis.opendocument.text")
        types.updateValue(MimeType.document, forKey: "application/x-abiword")
        types.updateValue(MimeType.document, forKey: "application/x-kword")
        types.updateValue(MimeType.document, forKey: "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
        
        types.updateValue(MimeType.sharedFile, forKey: "application/epub+zip")
        types.updateValue(MimeType.sharedFile, forKey: "application/x-mobipocket")
        
        types.updateValue(MimeType.directory, forKey: "text/directory")
        
        types.updateValue(MimeType.image, forKey: "application/vnd.oasis.opendocument.graphics")
        types.updateValue(MimeType.image, forKey: "application/vnd.oasis.opendocument.graphics-template")
        
        types.updateValue(MimeType.presentation, forKey: "application/vnd.ms-powerpoint")
        types.updateValue(MimeType.presentation, forKey: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
        types.updateValue(MimeType.presentation, forKey: "application/vnd.openxmlformats-officedocument.presentationml.slideshow")
        
        types.updateValue(MimeType.spreadsheet, forKey: "application/vnd.ms-excel")
        types.updateValue(MimeType.spreadsheet, forKey: "application/vnd.oasis.opendocument.spreadsheet")
        types.updateValue(MimeType.spreadsheet, forKey: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
        
        types.updateValue(MimeType.video, forKey: "application/x-quicktimeplayer")
        
        types.updateValue(MimeType.subtitle, forKey: "application/x-subrip")
        types.updateValue(MimeType.subtitle, forKey: "image/vnd.dvb.subtitle")
        types.updateValue(MimeType.subtitle, forKey: "application/x-subtitle")
    }
    
    public func match(_ mime: String) -> MimeType {
        
        let type = matchKnown(mime);
        
        if type != MimeType.undefined {
            return type;
        } else {
            
            return matchCategory(mime)
        }
    }
    
    private func isFlacMedia(_ mime: String) -> Bool {
        let fileExtensionType = mime.split(separator: "/")[1]
        
        return fileExtensionType == "flac"
    }
    
    private func matchKnown(_ mime: String) -> MimeType {
        guard let mimeType = types[mime] else {
            return MimeType.undefined
        }
        return mimeType
    }
    
    private func matchCategory(_ mime: String) -> MimeType {
        let type = mime.split(separator: "/")[0]
        
        if isFlacMedia(mime) {
            return .flacMedia
        }
        
        switch type {
        case "audio":
            return MimeType.audio
        case "image":
            return MimeType.image
        case "text":
            return MimeType.document
        case "video":
            return MimeType.video
        default:
            return MimeType.undefined
        }
    }
}

public enum MimeType: Int {
    case undefined = 1, archive, audio, code, sharedFile, document, directory, image, presentation, spreadsheet, video, subtitle , flacMedia
}
