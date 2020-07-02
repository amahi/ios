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
    
    func handleOfflineFile(selectedFile: OfflineFile, indexPath: IndexPath, files: FilteredOfflineFiles, from sender: UIView?){
        let type = selectedFile.mimeType
        let fileManager = FileManager.default
        
        if !fileManager.fileExistsInDownloads(selectedFile) {
            AmahiLogger.log("OFFLINE FILE DOES NOT EXIST IN EXPECTED LOCATION !!!")
            return
        }
        
        let url = fileManager.localFilePathInDownloads(for: selectedFile)!
        
        switch type {
        case .image:
            // prepare ImageViewer
            let results = files.getImageFiles(selectedFile: selectedFile)
            let controller = LightboxController(images: results.images, startIndex: results.startIndex)
            controller.dynamicBackground = true
            controller.modalPresentationStyle = .fullScreen
            self.view?.present(controller)
        case .video, .flacMedia:
            self.view?.playMedia(at: url)
        case .audio:
            let results = files.getAudioFiles(selectedFile: selectedFile)
            self.view?.playAudio(results.playerItems, startIndex: 0, currentIndex: results.startIndex, results.urls)
        case .sharedFile:
            self.view?.shareFile(at: url, from: sender)
        case .code, .presentation, .document, .spreadsheet:
            self.view?.webViewOpenContent(at: url, mimeType: type)
        default:
            // TODO: show list of apps that can open the file
            return
        }
    }
    
}
