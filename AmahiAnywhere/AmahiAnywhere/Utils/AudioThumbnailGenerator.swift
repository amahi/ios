//
//  AudioThumbnailGenerator.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 30/03/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import AVFoundation

class AudioThumbnailGenerator: ThumbnailGenerator {
    
    func getThumbnail(_ url: URL) -> UIImage {
        
        let asset:AVAsset = AVAsset(url:url)
        
        for metaDataItems in asset.commonMetadata {
            //getting the title of the song
            //getting the thumbnail image associated with file
            if metaDataItems.commonKey == AVMetadataKey.commonKeyArtwork {
                let imageData = metaDataItems.value as! Data
                let image: UIImage = UIImage(data: imageData)!
                
                saveImage(url: url, toCache: image) {
                    AmahiLogger.log("Audio Thumbnail for \(url) was stored")
                }
                
                return image
            }
        }
        return UIImage(named: "audio")!
    }
}
