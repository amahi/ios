//
//  VideoPlayerSettings.swift
//  AmahiAnywhere
//
//  Created by Abhishek Sansanwal on 30/05/19.
//  Copyright © 2019 Amahi. All rights reserved.
//

import UIKit

class Options: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String){
        self.name = name
        self.imageName = imageName
    }
}

class VideoPlayerSettings: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // darkView is to darken the background when moreButton is pressed
    let darkView = UIView()
    public var videoPlayer: VLCMediaPlayer?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor(red:28/255, green:28/255, blue:27/255, alpha:1)
        return view
    }()
    
    let cellID = "cellID"
    let cellHeight: CGFloat = 50
    static var currentSubtitleIndex = 0
    static var currentTrackIndex: Int32 = 0
    
    var captionsArray: [Options] = {
        return[Options(name: "No captions", imageName: "tick")]
    }()
    
    var tracksArray: [Options] = {
        return[Options(name: "No track", imageName: "tick")]
    }()
    
    var captionsIndexArray: [Int] = [0]
    var tracksIndexArray: [Int] = [0]
    
    func addTracksInArray(array: [String]) {
        if !tracksArray.isEmpty {
            tracksArray.removeAll()
        }
        var i = 1
        for _ in array {
            tracksArray.append(Options(name: "Track \(i)", imageName: ""))
            i = i + 1
        }
    }

    func addTrackIndexes(array: [Int]) {
        if !tracksIndexArray.isEmpty {
            tracksIndexArray.removeFirst()
        }
        for index in array {
            tracksIndexArray.append(index)
        }
    }
    
    
    func addCaptionsInArray(array: [String]) {
        for x in array {
            captionsArray.append(Options(name: "\(x)", imageName: ""))
        }
    }
    
    func addCaptionIndexes(array: [Int]) {
        for index in array {
            captionsIndexArray.append(index)
        }
    }
    
    func addCancelOption() {
        captionsArray.append(Options(name: "Cancel", imageName: "whiteCross"))
        tracksArray.append(Options(name: "Cancel", imageName: "whiteCross"))
    }
    
    var currentArray: [Options] = []
    
    let options: [Options] = {
        return[Options(name: "Captions", imageName: "captions"), Options(name: "Audio Track", imageName: "audioTrack"), Options(name: "Cancel", imageName: "whiteCross")]
    }()
    
    func setupVideoScreenOptions(currentArray: [Options]) {
        self.collectionView.reloadData()
        
        if let screen = UIApplication.shared.keyWindow {
            darkView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDarkView)))
            screen.addSubview(darkView)
            screen.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(currentArray.count) * cellHeight
            let y = screen.frame.height - height
            collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: screen.frame.width, height: height)
            
            darkView.frame = screen.frame
            darkView.alpha = 0
            
            if captionsArray.count == 1 && currentArray == captionsArray {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.darkView.alpha = 1
                    self.collectionView.alpha = 1
                    self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }, completion: nil)
            }
            else {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.darkView.alpha = 1
                    self.collectionView.alpha = 1
                    self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }, completion: nil)
            }
        }
    }
    
    func setupVideoScreen()  {
        setupVideoScreenOptions(currentArray: options)
        currentArray = options
    }
    
    @objc func dismissDarkView() {
        defaultOption.removeFromSuperview()
        AppUtility.lockOrientation(.all)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.darkView.alpha = 0
            self.collectionView.alpha = 0
            if let screen = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        })
        captionsArray = [Options(name: "No captions", imageName: "")]
        captionsIndexArray = [0]
        tracksArray.removeAll()
        tracksIndexArray.removeAll()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if captionsArray.count == 1 && currentArray == captionsArray {
            return 1
        }
        return currentArray.count
    }
    
    let defaultOption: UILabel = {
        let label = UILabel()
        label.text = "No captions are available"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        return label
    }()
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        defaultOption.removeFromSuperview()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! VideoMenuCellSettings
        cell.setupViews()
        
        if captionsArray.count == 1 && currentArray == captionsArray {
            cell.addSubview(defaultOption)
            cell.removeViews()
            cell.updateConstraints()
            cell.addConstraintsWithFormat(format: "H:|-8-[v0]|", views: defaultOption)
            cell.addConstraintsWithFormat(format: "V:|[v0]|", views: defaultOption)
            return cell
        }
        else {
            let option = currentArray[indexPath.item]
            cell.option = option
            if currentArray == captionsArray && cell.optionName.text != "Cancel" {
                if indexPath.last! == VideoPlayerSettings.currentSubtitleIndex {
                    cell.iconImageView.image = UIImage(named: "tick")
                }
                else {
                    cell.iconImageView.image = UIImage(named: "")
                }
            }
            if currentArray == tracksArray && cell.optionName.text != "Cancel" {
                if tracksIndexArray[indexPath.last!] == VideoPlayerSettings.currentTrackIndex {
                    cell.iconImageView.image = UIImage(named: "tick")
                }
                else {
                    cell.iconImageView.image = UIImage(named: "")
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! VideoMenuCellSettings
        cell.backgroundColor = UIColor.darkGray
        UIView.animate(withDuration: 0.5) {
            cell.backgroundColor = UIColor(red:28/255, green:28/255, blue:27/255, alpha:1)
        }
        
        
        let cancel = "Cancel"
        
        if cell.optionName.text == cancel {
            AppUtility.lockOrientation(.all)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.darkView.alpha = 0
                self.collectionView.alpha = 0
                if let screen = UIApplication.shared.keyWindow {
                    self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }
            })
            captionsArray = [Options(name: "No captions", imageName: "")]
            captionsIndexArray = [0]
            tracksArray.removeAll()
            tracksIndexArray.removeAll()
            collectionView.reloadData()
            return
        }
        
        let captions = "Captions"
        let audioTrack = "Audio Track"
        
        switch cell.optionName.text {
            
        case captions:
            AppUtility.lockOrientation(.all)
            if captionsArray.count != 1 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                               options: .curveEaseOut, animations: {
                                self.darkView.alpha = 0
                                self.collectionView.alpha = 0
                                if let screen = UIApplication.shared.keyWindow {
                                    self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                                }
                }) { (success) in
                    
                    self.addCancelOption()
                    self.currentArray = self.captionsArray
                    collectionView.reloadData()
                    self.setupVideoScreenOptions(currentArray: self.captionsArray)
                }
            }
            else {
                currentArray = captionsArray
                self.darkView.alpha = 0
                setupVideoScreenOptions(currentArray: captionsArray)
                UIView.animate(withDuration: 0.5, delay: 2, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.darkView.alpha = 0
                    self.collectionView.alpha = 0
                    if let screen = UIApplication.shared.keyWindow {
                        self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                    }
                })
            }
            return
            
        case audioTrack:
            AppUtility.lockOrientation(.all)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                               options: .curveEaseOut, animations: {
                            self.darkView.alpha = 0
                            self.collectionView.alpha = 0
                            if let screen = UIApplication.shared.keyWindow {
                                self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                            }
            }) { (success) in
                    
                self.addCancelOption()
                self.currentArray = self.tracksArray
                collectionView.reloadData()
                self.setupVideoScreenOptions(currentArray: self.tracksArray)
                }
            return
            
        default:
            break
        }
        
        if currentArray == tracksArray {
            AppUtility.lockOrientation(.all)
            videoPlayer?.currentAudioTrackIndex = Int32(tracksIndexArray[indexPath.last!])
            cell.iconImageView.image = UIImage(named: "tick")
            VideoPlayerSettings.currentTrackIndex = Int32(indexPath.last!)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.darkView.alpha = 0
                self.collectionView.alpha = 0
                if let screen = UIApplication.shared.keyWindow {
                    self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }
            })
            captionsArray = [Options(name: "No captions", imageName: "")]
            captionsIndexArray = [0]
            tracksArray.removeAll()
            tracksIndexArray.removeAll()
            collectionView.reloadData()
            return
        }
        
        if currentArray == captionsArray {
            AppUtility.lockOrientation(.all)
            if indexPath.last! == 0 {
                videoPlayer?.currentVideoSubTitleIndex = -1
                VideoPlayerSettings.currentSubtitleIndex = 0
            }
            else {
                videoPlayer?.currentVideoSubTitleIndex = Int32(captionsIndexArray[indexPath.last!])
                cell.iconImageView.image = UIImage(named: "tick")
                VideoPlayerSettings.currentSubtitleIndex = indexPath.last!
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.darkView.alpha = 0
                self.collectionView.alpha = 0
                if let screen = UIApplication.shared.keyWindow {
                    self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }
            })
            captionsArray = [Options(name: "No captions", imageName: "")]
            captionsIndexArray = [0]
            tracksArray.removeAll()
            tracksIndexArray.removeAll()
            collectionView.reloadData()
            return
        }
    }
    
    override init() {
        super.init()
        
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoMenuCellSettings.self, forCellWithReuseIdentifier: cellID)
        
    }
    
}

// To control orientation of the screen
struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
}

