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
    
    func webViewOpenContent(at url: URL, mimeType: MimeType)
    
    func shareFile(at url: URL)
    
    func updateDownloadProgress(for row: Int, downloadJustStarted: Bool, progress: Float)
    
    func dismissProgressIndicator(at url: URL, completion: @escaping () -> Void)
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
    
    func filterFiles(_ searchText: String, files: [ServerFile], sortOrder: FileSort) {
        if searchText.count > 0 {
            let filteredFiles = files.filter { file in
                return file.name!.localizedCaseInsensitiveContains(searchText)
            }
            self.reorderFiles(files: filteredFiles, sortOrder: sortOrder)
        } else {
            self.reorderFiles(files: files, sortOrder: sortOrder)
        }
    }
    
    func reorderFiles(files: [ServerFile], sortOrder: FileSort) {
        let sortedFiles = files.sorted(by: getSorter(sortOrder))
        self.view?.updateFiles(sortedFiles)
    }
    
    private func getSorter(_ sortOrder: FileSort) -> ((ServerFile, ServerFile) -> Bool) {
        switch sortOrder {
        case .modifiedTime:
            return ServerFile.lastModifiedSorter
        case .name:
            return ServerFile.nameSorter
        }
    }
    
    func handleFileOpening(fileIndex: Int, files: [ServerFile]) {
        let file = files[fileIndex]
        
        let type = Mimes.shared.match(file.mime_type!)
        
        switch type {
            
        case MimeType.image:
            // prepare ImageViewer
            let controller = LightboxController(images: prepareImageArray(files), startIndex: fileIndex)
            controller.dynamicBackground = true
            self.view?.present(controller)
            break
            
        case MimeType.video, MimeType.audio:
            // TODO: open VideoPlayer and play the file
            let url = ServerApi.shared!.getFileUri(file)
            self.view?.playMedia(at: url)
            return
            
        case MimeType.code, MimeType.presentation, MimeType.sharedFile, MimeType.document, MimeType.spreadsheet:
            if fileExists(fileName: file.getPath()) {
                if type == MimeType.sharedFile {
                    self.view?.shareFile(at: localPath(for: file))
                } else {
                    self.view?.webViewOpenContent(at: localPath(for: file), mimeType: type)
                }
            } else {
                downloadAndOpenFile(fileIndex: fileIndex, serverFile: file, mimeType: type)
            }
            break
            
        default:
            // TODO: show list of apps that can open the file
            return
        }
    }
    
    private func downloadAndOpenFile(fileIndex: Int , serverFile: ServerFile, mimeType: MimeType) {
        
        self.view?.updateDownloadProgress(for: fileIndex, downloadJustStarted: true, progress: 0.0)
        
        // cleanup temp files in background
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanUpFilesInCache(folderName: "cache")
        }
        
        Network.shared.downloadFileToStorage(file: serverFile, progressCompletion: { progress in
            self.view?.updateDownloadProgress(for: fileIndex, downloadJustStarted: false, progress: progress)
        }, completion: { (wasSuccessful) in
            
            if !wasSuccessful  {
                self.view?.showError(message: StringLiterals.ERROR_DOWNLOADING_FILE)
                return
            }
            
            let filePath = self.localPath(for: serverFile)
            
            self.view?.dismissProgressIndicator(at: filePath, completion: {
                
                if mimeType == MimeType.sharedFile {
                    self.view?.shareFile(at: filePath)
                } else {
                    self.view?.webViewOpenContent(at: filePath, mimeType: mimeType)
                }
            })
        })
    }
    
    private func localPath(for file: ServerFile) -> URL {
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let cacheFolderPath = tempDirectory.appendingPathComponent("cache")
        
        return cacheFolderPath.appendingPathComponent(file.getPath())
    }
    
    private func fileExists(fileName: String) -> Bool {
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let cacheFolderPath = tempDirectory.appendingPathComponent("cache")
        
        let pathComponent = cacheFolderPath.appendingPathComponent(fileName)
        let filePath = pathComponent.path
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    private func prepareImageArray(_ files: [ServerFile]) -> [LightboxImage] {
        var images: [LightboxImage] = [LightboxImage] ()
        for file in files {
            if (Mimes.shared.match(file.mime_type!) == MimeType.image) {
                images.append(LightboxImage(imageURL: ServerApi.shared!.getFileUri(file), text: file.name!))
            }
        }
        return images
    }
}
