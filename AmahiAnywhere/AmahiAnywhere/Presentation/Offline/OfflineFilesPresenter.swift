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
        
        let type = Mimes.shared.match(file.mime!)
        
        switch type {
            
        case MimeType.image:
            // prepare ImageViewer
            let controller = LightboxController(images: prepareImageArray(files), startIndex: fileIndex)
            controller.dynamicBackground = false
            self.view?.present(controller)
            break
            
        case MimeType.video:
             self.view?.playMedia(at: url)
            break
            
        case MimeType.audio:
            let audioURLs = prepareAudioItems(files)
            var arrangedURLs = [URL]()
            
            for (index, url) in audioURLs.enumerated() {
                arrangedURLs.insert(url, at: arrangedURLs.endIndex)
            }
            
            var playerItems = [AVPlayerItem]()
            
            arrangedURLs.forEach({playerItems.append(AVPlayerItem(url: $0))})
            
            self.view?.playAudio(playerItems, startIndex: 0, currentIndex: fileIndex, arrangedURLs)
            break
            
        case MimeType.code, MimeType.presentation, MimeType.sharedFile, MimeType.document, MimeType.spreadsheet:
            if type == MimeType.sharedFile {
                self.view?.shareFile(at: url, from: sender)
            } else {
                self.view?.webViewOpenContent(at: url, mimeType: type)
            }
            break
            
        default:
            // TODO: show list of apps that can open the file
            return
        }
    }
    
    private func prepareAudioItems(_ files: [OfflineFile]) -> [URL] {
        var audioURLs = [URL]()
        
        for file in files {
            if (Mimes.shared.match(file.mime!) == MimeType.audio) {
                let url = FileManager.default.localFilePathInDownloads(for: file)!
                audioURLs.append(url)
            }
        }
        return audioURLs
    }
    
    private func prepareImageArray(_ files: [OfflineFile]) -> [LightboxImage] {
        var images: [LightboxImage] = [LightboxImage] ()
        for file in files {
            if (Mimes.shared.match(file.mime!) == MimeType.image) {
                let path = FileManager.default.localFilePathInDownloads(for: file)!
                let data = NSData(contentsOf: path)
                images.append(LightboxImage(image: UIImage(data: data! as Data)!, text: file.name!))
            }
        }
        return images
    }
}
