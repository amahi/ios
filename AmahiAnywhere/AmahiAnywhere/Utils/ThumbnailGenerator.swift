//
//  ThumbnailGenerator.swift
//  AmahiAnywhere
//
//  Created by Kanyinsola Fapohunda on 30/03/2019.
//  Copyright © 2019 Amahi. All rights reserved.
//

import AVFoundation
import UIKit
import SDWebImage

protocol ThumbnailGenerator {
    func getThumbnail(_ url: URL) -> UIImage
}

extension ThumbnailGenerator {
    
    func saveImage(url: URL, toCache: UIImage?, completion: @escaping SDWebImageNoParamsBlock) {
        guard let toCache = toCache else { return }
        let manager = SDWebImageManager.shared
        if let key = manager.cacheKey(for: url) {
            manager.imageCache.store(toCache, imageData: toCache.sd_imageData(), forKey: key, cacheType: .all, completion: completion)
        }
    }

    
    static func imageFromMemory(for url: URL) -> UIImage? {
        let manager = SDWebImageManager.shared
        guard let key = manager.cacheKey(for: url) else { return nil }
        return SDImageCache.shared.imageFromCache(forKey: key)
    }
    
}
