//
//  VideoThumbnailGenerator.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 30/03/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import AVFoundation

class VideoThumbnailGenerator: ThumbnailGenerator {
    
    func getThumbnail(_ url: URL) -> UIImage {
        
        let asset:AVAsset = AVAsset(url:url)
        
        // Fetch the duration of the video
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        guard !durationSeconds.isFinite || !durationSeconds.isNaN else {
            AmahiLogger.log("Weird, duration for video is not a valid number. Hence thumbnail cannot be generated, returning defailt thumbnail instead")
            return UIImage(named: "video")!
        }

        let time : CMTime = CMTimeMakeWithSeconds(600, preferredTimescale: Int32(durationSeconds/3.0))
        
        
        var img : CGImage
        do {
            img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: UIImage = UIImage(cgImage: img)
            
            saveImage(url: url, toCache: frameImg) {
                AmahiLogger.log("Video Thumbnail for \(url) was stored")
            }
            
            return frameImg
        } catch let error as NSError {
            AmahiLogger.log("ERROR: \(error)")
            return UIImage(named: "video")!
        }
    }
}
