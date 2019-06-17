//
//  OfflineFilesPresenter.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/15/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Lightbox
import AVFoundation

protocol OfflineFilesView : BaseView {    
    func present(_ controller: UIViewController)
    
    func playMedia(at url: URL)
    
    func playAudio(_ items: [AVPlayerItem], startIndex: Int, currentIndex: Int,_ URLs: [URL])
    
    func webViewOpenContent(at url: URL, mimeType: MimeType)
    
    func shareFile(at url: URL, from sender : UIView?)
}

class OfflineFilesPresenter: BasePresenter {

    weak private var view: OfflineFilesView?
    
    init(_ view: OfflineFilesView) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func handleOfflineFile(fileIndex: Int, files: [OfflineFile], from sender : UIView?) {

        let file = files[fileIndex]
        let fileManager = FileManager.default
        
        if !fileManager.fileExistsInDownloads(file) {
            AmahiLogger.log("OFFLINE FILE DOES NOT EXIST IN EXPECTED LOCATION !!!")
            return
        }
        
        let url = fileManager.localFilePathInDownloads(for: file)!
        AmahiLogger.log("Path to Offline folder is \(url)")

        let type = file.mimeType

        switch type {

        case .image:
            // prepare ImageViewer
            let controller = LightboxController(images: prepareImageArray(files), startIndex: fileIndex)
            controller.dynamicBackground = false
            self.view?.present(controller)

        case .video:
             self.view?.playMedia(at: url)

        case .audio:
            let audioURLs = prepareAudioItems(files)
            var arrangedURLs = [URL]()
            
            for (index, url) in audioURLs.enumerated() {
                arrangedURLs.insert(url, at: arrangedURLs.endIndex)
            }
            
            var playerItems = [AVPlayerItem]()
            
            arrangedURLs.forEach({playerItems.append(AVPlayerItem(url: $0))})
            
            self.view?.playAudio(playerItems, startIndex: 0, currentIndex: fileIndex, arrangedURLs)

        case .sharedFile:
            self.view?.shareFile(at: url, from: sender)

        case .code, .presentation, .document, .spreadsheet:
            self.view?.webViewOpenContent(at: url, mimeType: type)

        default:
            // TODO: show list of apps that can open the file
            return
        }
    }
    
    private func prepareAudioItems(_ files: [OfflineFile]) -> [URL] {
        var audioURLs = [URL]()
        
        for file in files where file.mimeType == .audio {
            let url = FileManager.default.localFilePathInDownloads(for: file)!
            audioURLs.append(url)
        }
        return audioURLs
    }
    
    private func prepareImageArray(_ files: [OfflineFile]) -> [LightboxImage] {
        var images = [LightboxImage]()
        for file in files where file.mimeType == .image {
            guard let fileURL = FileManager.default.localFilePathInDownloads(for: file),
                let image = UIImage(contentsOfFile: fileURL.path)
                else { continue }
            images.append(LightboxImage(image: image, text: file.name ?? ""))
        }
        return images
    }
}
