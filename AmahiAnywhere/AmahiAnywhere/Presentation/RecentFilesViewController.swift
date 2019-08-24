//
//  RecentFilesViewController.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 13/08/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit
import GoogleCast
import SDWebImage

class RecentFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
GCKSessionManagerListener, GCKRequestDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return RecentFiles.sharedInstance.getRecentFiles().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let recents = RecentFiles.sharedInstance.getRecentFiles()
        let fileIndex = recents.count - indexPath.row - 1
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath)
        
        let fileNameLabel: UILabel? = (cell.viewWithTag(1) as? UILabel)
        let fileDescriptionLabel: UILabel? = (cell.viewWithTag(2) as? UILabel)
        let imageView = (cell.contentView.viewWithTag(3) as? UIImageView)
        
        fileNameLabel?.text = recents[fileIndex].fileName
        fileDescriptionLabel?.text = "\(recents[fileIndex].fileDisplayText), \(recents[fileIndex].filesSize)"
        
        let url = URL(string: recents[fileIndex].fileURL)!
        let type = recents[fileIndex].mimeType
        
        switch type {
        case "image":
            imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "image"), options: .refreshCached)
            break
        case "video":
            if let image = VideoThumbnailGenerator.imageFromMemory(for: url) {
                imageView!.image = image
            } else {
                imageView!.image = UIImage(named: "video")
                DispatchQueue.global(qos: .background).async {
                    let image = VideoThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        imageView!.image = image
                    }
                }
            }
            break
        case "audio":
            if let image = AudioThumbnailGenerator.imageFromMemory(for: url) {
                imageView!.image = image
            } else {
                imageView!.image = UIImage(named: "audio")
                DispatchQueue.global(qos: .background).async {
                    let image = AudioThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        imageView!.image = image
                    }
                }
            }
            break
        case "presentation", "document", "spreadsheet":
            if let image = PDFThumbnailGenerator.imageFromMemory(for: url) {
                imageView!.image = image
            } else {
                imageView!.image = UIImage(named: "file")
                
                DispatchQueue.global(qos: .background).async {
                    let image = PDFThumbnailGenerator().getThumbnail(url)
                    DispatchQueue.main.async {
                        imageView!.image = image
                    }
                }
            }
        default:
            imageView!.image = UIImage(named: "file")
            break
        }
        return cell
    }
    private var castButton: GCKUICastButton!
    private var sessionManager: GCKSessionManager!
    private var queueButton: UIBarButtonItem!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
    }
    
    @IBOutlet private var _tableView: UITableView!
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _tableView.dataSource = self
        _tableView.delegate = self
        castButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                                          width: CGFloat(24), height: CGFloat(24)))
               castButton.tintColor = UIColor.white
               navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
               
               queueButton = UIBarButtonItem(image: UIImage(named: "queueIcon"),
                                             style: .plain, target: self, action: #selector(didTapQueueButton))
               NotificationCenter.default.addObserver(self, selector: #selector(castDeviceDidChange),
                                                      name: NSNotification.Name.gckCastStateDidChange,
                                                      object: GCKCastContext.sharedInstance())
               checkCastConnection()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCastConnection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionManager.remove(self)
    }

    @objc func castDeviceDidChange(_: Notification) {
        if GCKCastContext.sharedInstance().castState != .noDevicesAvailable {
            
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
        }
    }
    
    @objc func didTapQueueButton(){
        let queueVC = self.instantiateViewController (withIdentifier: StoryBoardIdentifiers.navigationBarController, from: StoryBoardIdentifiers.main)
        self.present(queueVC, animated: true, completion: nil)
    }
    
    func setQueueButtonVisible(_ visible: Bool) {
        var barItems = navigationItem.rightBarButtonItems
        if barItems!.count > 2 {
            return
        }
        if !visible {
            let index = barItems?.index(of: queueButton)
            if index == 1 {
                barItems?.remove(at: 1)
            }
            navigationItem.rightBarButtonItems = barItems
        }
        else {
            if barItems!.count >= 2 {
                return
            }
            barItems?.append(queueButton)
            navigationItem.rightBarButtonItems = barItems
        }
    }
    
    func checkCastConnection(){
        if(self.sessionManager.currentSession != nil){
            setQueueButtonVisible(true)
        }
        else {
            setQueueButtonVisible(false)
        }
    }
}

