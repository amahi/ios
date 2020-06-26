//
//  FilesPresenter.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 08/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation
import Lightbox
import CoreData
import AVFoundation
import GoogleCast

internal protocol FilesView : BaseView {
    func initFiles(_ files: [ServerFile])
    
    func updateFiles(_ files: [ServerFile])
    
    func updateRefreshing(isRefreshing: Bool)
    
    func present(_ controller: UIViewController)
    
    func playMedia(at url: URL, file: ServerFile)
    
    func playAudio(_ items: [AVPlayerItem], startIndex: Int, currentIndex: Int,_ URLs: [URL])
    
    func webViewOpenContent(at url: URL, mimeType: MimeType)
    
    func shareFile(at url: URL, from sender : UIView?)
    
    func updateDownloadProgress(for row: Int, section: Int, downloadJustStarted: Bool, progress: Float)
    
    func dismissProgressIndicator(at url: URL, completion: @escaping () -> Void)
}

class FilesPresenter: BasePresenter {
    
    enum PlaybackMode: Int {
        case none = 0
        case local
        case remote
    }
    
    private var playbackMode = PlaybackMode.none
    private var sessionManager: GCKSessionManager!
    
    weak private var view: FilesView?
    private var offlineFiles : [String: OfflineFile]?
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            executeSearch()
        }
    }
    
    init(_ view: FilesView) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getFiles(_ share: ServerShare, directory: ServerFile? = nil) {
        
        self.view?.updateRefreshing(isRefreshing: true)
        
        ServerApi.shared!.getFiles(share: share, directory: directory) { (serverFilesResponse) in
            
            self.view?.updateRefreshing(isRefreshing: false)
            
            guard let serverFiles = serverFilesResponse else {
                self.view?.showError(message: StringLiterals.genericNetworkError)
                return
            }
            
            self.view?.initFiles(serverFiles)
            self.view?.updateFiles(serverFiles)
        }
    }
    
    func filterFiles(_ searchText: String, files: [ServerFile], sortOrder: FileSort) {
        if searchText.count > 0 {
            let filteredFiles = files.filter { file in
                return file.name!.localizedCaseInsensitiveContains(searchText)
            }
            self.view?.updateFiles(filteredFiles)
        } else {
            self.view?.updateFiles(files)
        }
    }
    
    func handleFileOpening(selectedFile: ServerFile, indexPath: IndexPath, files: FilteredServerFiles, from sender: UIView?) {
        let type = selectedFile.mimeType
        AmahiLogger.log(": Matched type is (type), FILE MIMETYPE \(selectedFile.mime_type ?? "")")
        AmahiLogger.log(": Matched type is \(type) , File MIMETYPE \(selectedFile.mime_type ?? "")")
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year =  components.year
        let month = components.month
        let day = Int16(components.day!)
        
        let mimeType = "\(selectedFile.mimeType)"
        
        let path = selectedFile.getPath()
        
        /* When the server provides thumbnails for all types of files, add thumbnailURL attribute to the database */
        let fileURL = "\(ServerApi.shared!.getFileUri(selectedFile)!)"
        
        /* Storing file name to display the same in the table directly */
        let fileName = "\(selectedFile.name!)"
        
        /* File creation date */
        let mtimeDate = selectedFile.mtime
        
        /* Auth-token for HDA authorisation in PIN */
        let authToken = ServerApi.shared?.auth_token
        
        let dict = ["day":day, "month":month!, "year":year!, "fileName":fileName, "fileURL":fileURL, "serverName":ServerApi.shared!.getServer()!.name!, "size":selectedFile.getFileSize(), "mimeType":mimeType, "mtimeDate":mtimeDate!, "authToken":authToken!, "path": path, "sizeNumber": selectedFile.size!] as [String : Any]
        
        RecentsDatabaseHelper.shareInstance.save(object: dict)

        switch type {

        case .image:
            // prepare ImageViewer
            let results = files.getImageFiles(selectedFile: selectedFile)
            let controller = LightboxController(images: results.images, startIndex: results.startIndex)
            controller.dynamicBackground = true
            self.view?.present(controller)

        case .video, .flacMedia:
            // TODO: open VideoPlayer and play the file

            guard let url = ServerApi.shared!.getFileUri(selectedFile) else {
                AmahiLogger.log("Invalid file URL, file cannot be opened")
                return
            }
            self.view?.playMedia(at: url, file: selectedFile)

        case .audio:
            let results = files.getAudioFiles(selectedFile: selectedFile)
            self.view?.playAudio(results.playerItems, startIndex: 0, currentIndex: results.startIndex, results.urls)
            break

        case .code, .presentation, .sharedFile, .document, .spreadsheet:
            func handleFileOpening(with fileURL: URL) {
                weak var weakSelf = self
                if type == .sharedFile {
                    weakSelf?.view?.shareFile(at: fileURL, from: sender)
                } else {
                    weakSelf?.view?.webViewOpenContent(at: fileURL, mimeType: type)
                }
            }

            if FileManager.default.fileExistsInCache(selectedFile) {
                let fileURL = FileManager.default.localPathInCache(for: selectedFile)
                handleFileOpening(with: fileURL)
            } else {
                downloadFile(at: indexPath.item, section: indexPath.section, selectedFile, mimeType: type, from: sender) { fileURL in
                    handleFileOpening(with: fileURL)
                }
            }

        default:
            // TODO: show list of apps that can open the file
            return
        }
    }
    
    func shareFile(_ file: ServerFile, fileIndex: Int, section: Int, from sender: UIView?) {
        if FileManager.default.fileExistsInCache(file) {
            let path = FileManager.default.localPathInCache(for: file)
            self.view?.shareFile(at: path, from: sender)
        } else {
            downloadFile(at: fileIndex, section: section, file, mimeType: file.mimeType, from: sender) { [weak self] filePath in
                self?.view?.shareFile(at: filePath, from: sender)
            }
        }
    }
        
    public func makeFileAvailableOffline(_ serverFile: ServerFile, _ indexPath: IndexPath) {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        var path = serverFile.getPath().replacingOccurrences(of: "/", with: "-")
        if path.first == "-" {
            path.removeFirst()
        }
        
        guard let url = ServerApi.shared!.getFileUri(serverFile) else {
            AmahiLogger.log("Invalid file URL, file cannot be downloaded")
            return
        }
        
        let offlineFile = OfflineFile(name: serverFile.getNameOnly(),
                                      mime: serverFile.mime_type!,
                                      size: serverFile.size!,
                                      mtime: serverFile.mtime!,
                                      fileUri: url.absoluteString,
                                      localPath: path,
                                      progress: 0,
                                      state: OfflineFileState.downloading,
                                      context: stack.context)
        
        OfflineFileIndexes.offlineFilesIndexPaths[offlineFile] = indexPath
        OfflineFileIndexes.indexPathsForOfflineFiles[indexPath] = offlineFile
        
        try? stack.saveContext()
        
        DownloadService.shared.startDownload(offlineFile)
        loadOfflineFiles()
    }
    
    private func downloadFile(at fileIndex: Int ,
                              section: Int,
                              _ serverFile: ServerFile,
                              mimeType: MimeType,
                              from sender : UIView?,
                              completion: @escaping (_ filePath: URL) -> Void) {
        
        self.view?.updateDownloadProgress(for: fileIndex, section: section, downloadJustStarted: true, progress: 0.0)
        
        // cleanup temp files in background
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanUpFiles(in: FileManager.default.temporaryDirectory,
                                             folderName: "cache")
        }
        
        Network.shared.downloadFileToStorage(file: serverFile, progressCompletion: { progress in
            self.view?.updateDownloadProgress(for: fileIndex, section: section, downloadJustStarted: false, progress: progress)
        }, completion: { (wasSuccessful) in
            
            if !wasSuccessful  {
                self.view?.showError(message: StringLiterals.errorDownloadingFileMessage)
                return
            }
            
            let filePath = FileManager.default.localPathInCache(for: serverFile)
            
            self.view?.dismissProgressIndicator(at: filePath, completion: {
                completion(filePath)
            })
        })
    }
    
    func loadOfflineFiles() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OfflineFile")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "downloadDate", ascending: false)]
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: stack.context,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        if let files = fetchedResultsController?.fetchedObjects as! [OfflineFile]? {
            
            var dictionary = [String : OfflineFile]()
            
            for file in files {
                dictionary[file.name!] = file
            }
            AmahiLogger.log("Offline Files \(dictionary)")
            
            self.offlineFiles = dictionary
        } else {
            AmahiLogger.log("Detched Objects returned was nil")
            self.offlineFiles = [:]
        }
    }
    
    func checkFileOfflineState(_ file: ServerFile) -> OfflineFileState {
        
        if let offlineFile = offlineFiles![file.name!] {
            
            if file.mtime! != offlineFile.mtime! || file.size! != offlineFile.size {
                return .outdated
            }
            
            return offlineFile.stateEnum
        } else {
            return .none
        }
    }
    
    func getOfflineFileFromServerFile(_ file: ServerFile) -> OfflineFile?{
        return offlineFiles?[file.name!]
    }
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                AmahiLogger.log("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
}
