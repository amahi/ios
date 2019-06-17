//
//  OfflineFile+MimeType.swift
//  AmahiAnywhere
//
//  Created by Alexey Salangin on 16/04/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

extension OfflineFile {
    var mimeType: MimeType {
        return MimeType(mime)
    }
}
