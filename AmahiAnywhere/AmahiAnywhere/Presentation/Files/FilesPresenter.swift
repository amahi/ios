//
//  FilesPresenter.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Lightbox

protocol FilesView : BaseView {
    func initFiles(_ files: [ServerFile])
    func updateFiles(_ files: [ServerFile])
    func updateRefreshing(isRefreshing: Bool)
    func present(_ controller: UIViewController)
    func playMedia(at url: URL)
}

class FilesPresenter: BasePresenter {
    
    weak private var view: FilesView?
    
    init(_ view: FilesView) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getFiles(_ share: ServerShare, directory: ServerFile? = nil) {
        
        self.view?.updateRefreshing(isRefreshing: true)
        
        ServerApi.shared?.getFiles(share: share, directory: directory) { (serverFilesResponse) in
            
            self.view?.updateRefreshing(isRefreshing: false)
            
            guard let serverFiles = serverFilesResponse else {
                self.view?.showError(message: StringLiterals.GENERIC_NETWORK_ERROR)
                return
            }
            
            self.view?.initFiles(serverFiles)
            self.view?.updateFiles(serverFiles.sorted(by: ServerFile.lastModifiedSorter))
        }
    }
    
    func filterFiles(_ searchText: String, files: [ServerFile]) {
        if searchText.count > 0 {
            let filteredFiles = files.filter { file in
                return file.name!.localizedCaseInsensitiveContains(searchText)
            }
            self.view?.updateFiles(filteredFiles)
        } else {
            self.view?.updateFiles(files)
        }
    }
    
    func reorderFiles(files: [ServerFile], sortOrder: FileSort) {
        let sortedFiles = files.sorted(by: getSorter(sortOrder))
        self.view?.updateFiles(sortedFiles)
    }
    
    private func getSorter(_ sortOrder: FileSort) -> ((ServerFile, ServerFile) -> Bool) {
        switch sortOrder {
        case .ModifiedTime:
            return ServerFile.lastModifiedSorter
        case .Name:
            return ServerFile.nameSorter
        }
    }
    
    func handleFileOpening(fileIndex: Int, files: [ServerFile]) {
        let file = files[fileIndex]
        switch Mimes.shared.match(file.mime_type!) {
            
        case MimeType.IMAGE:
            // prepare ImageViewer
            let controller = LightboxController(images: prepareImageArray(files), startIndex: fileIndex)
            controller.dynamicBackground = true
            self.view?.present(controller)
            break
            
        case MimeType.VIDEO, MimeType.AUDIO:
            // TODO: open VideoPlayer and play the file
            let url = ServerApi.shared!.getFileUri(file)
            self.view?.playMedia(at: url)
            
            return
            
        default:
            // TODO: show list of apps that can open the file
            return
        }
    }
    
    private func prepareImageArray(_ files: [ServerFile]) -> [LightboxImage] {
        var images: [LightboxImage] = [LightboxImage] ()
        for file in files {
            if (Mimes.shared.match(file.mime_type!) == MimeType.IMAGE) {
                images.append(LightboxImage(imageURL: ServerApi.shared!.getFileUri(file), text: file.name!))
            }
        }
        return images
    }
}


