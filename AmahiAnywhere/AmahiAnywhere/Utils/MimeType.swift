//
//  MimeType.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 09/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

enum MimeType: Int {
    case undefined = 1, archive, audio, code, sharedFile, document, directory, image, presentation, spreadsheet, video, subtitle, flacMedia

    init(_ mime: String?) {
        if let mime = mime {
            self = MimeType.types[mime] ?? MimeType.matchCategory(mime)
        } else {
            self = .undefined
        }
    }

    private static func matchCategory(_ mime: String) -> MimeType {
        let type = mime.split(separator: "/")[0]

        if isFlacMedia(mime) {
            return .flacMedia
        }

        switch type {
        case "audio":
            return .audio
        case "image":
            return .image
        case "text":
            return .document
        case "video":
            return .video
        case "code":
            return .code
        case "sharedFile":
            return .sharedFile
        case "document":
            return .document
        case "directory":
            return .directory
        case "presentation":
            return .presentation
        case "spreadsheet":
            return .spreadsheet
        case "subtitle":
            return .subtitle
        case "flacMedia":
            return .flacMedia
        default:
            return .undefined
        }
    }

    private static let types: [String: MimeType] = {
        var types = [String: MimeType]()

        types.updateValue(.undefined, forKey: "application/octet-stream")

        types.updateValue(.archive, forKey: "application/gzip")
        types.updateValue(.archive, forKey: "application/rar")
        types.updateValue(.archive, forKey: "application/zip")
        types.updateValue(.archive, forKey: "application/x-gtar")
        types.updateValue(.archive, forKey: "application/x-tar")
        types.updateValue(.archive, forKey: "application/x-rar-compressed")

        types.updateValue(.audio, forKey: "application/ogg")
        // breaking out flac on its own type because of https://github.com/amahi/ios/issues/172
        types.updateValue(.flacMedia, forKey: "application/x-flac")

        types.updateValue(.code, forKey: "text/css")
        types.updateValue(.code, forKey: "text/html")
        types.updateValue(.code, forKey: "text/xml")
        types.updateValue(.code, forKey: "application/json")
        types.updateValue(.code, forKey: "application/javascript")
        types.updateValue(.code, forKey: "application/xml")

        types.updateValue(.document, forKey: "application/pdf")
        types.updateValue(.document, forKey: "text/csv")
        types.updateValue(.document, forKey: "text/plain")
        types.updateValue(.document, forKey: "application/msword")
        types.updateValue(.document, forKey: "application/vnd.oasis.opendocument.text")
        types.updateValue(.document, forKey: "application/x-abiword")
        types.updateValue(.document, forKey: "application/x-kword")
        types.updateValue(.document, forKey: "application/vnd.openxmlformats-officedocument.wordprocessingml.document")

        types.updateValue(.sharedFile, forKey: "application/epub+zip")
        types.updateValue(.sharedFile, forKey: "application/x-mobipocket")

        types.updateValue(.directory, forKey: "text/directory")

        types.updateValue(.image, forKey: "application/vnd.oasis.opendocument.graphics")
        types.updateValue(.image, forKey: "application/vnd.oasis.opendocument.graphics-template")

        types.updateValue(.presentation, forKey: "application/vnd.ms-powerpoint")
        types.updateValue(.presentation, forKey: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
        types.updateValue(.presentation, forKey: "application/vnd.openxmlformats-officedocument.presentationml.slideshow")

        types.updateValue(.spreadsheet, forKey: "application/vnd.ms-excel")
        types.updateValue(.spreadsheet, forKey: "application/vnd.oasis.opendocument.spreadsheet")
        types.updateValue(.spreadsheet, forKey: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

        types.updateValue(.video, forKey: "application/x-quicktimeplayer")

        types.updateValue(.subtitle, forKey: "application/x-subrip")
        types.updateValue(.subtitle, forKey: "image/vnd.dvb.subtitle")
        types.updateValue(.subtitle, forKey: "application/x-subtitle")

        return types
    }()

    private static func isFlacMedia(_ mime: String) -> Bool {
        let mimeComponents = mime.split(separator: "/")
        if mimeComponents.indices.contains(1) {
            let fileExtensionType = mime.split(separator: "/")[1]
            return fileExtensionType == "flac"
        }
        return false
    }
}
