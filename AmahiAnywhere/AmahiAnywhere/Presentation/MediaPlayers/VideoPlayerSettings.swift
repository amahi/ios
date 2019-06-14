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
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor(red:28/255, green:28/255, blue:27/255, alpha:1)
        return view
    }()
    
    let cellID = "cellID"
    let cellHeight: CGFloat = 50
    
    let options: [Options] = {
        return[Options(name: "Captions", imageName: "captions"), Options(name: "Audio Track", imageName: "audioTrack"), Options(name: "Cancel", imageName: "whiteCross")]
    }()
    
    func setupVideoScreen(){
        self.collectionView.reloadData()
        if let screen = UIApplication.shared.keyWindow {
            darkView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            darkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDarkView)))
            screen.addSubview(darkView)
            screen.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(options.count) * cellHeight
            let y = screen.frame.height - height
            collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: screen.frame.width, height: height)
            
            darkView.frame = screen.frame
            darkView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.darkView.alpha = 1
                self.collectionView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func dismissDarkView() {
        AppUtility.lockOrientation(.all)
        collectionView.reloadData()
        UIView.animate(withDuration: 0.5) {
            self.darkView.alpha = 0
            self.collectionView.alpha = 0
            if let screen = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! VideoMenuCellSettings
        let option = options[indexPath.item]
        cell.option = option
        return cell
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
        
        let captions = "Captions"
        let audioTrack = "Audio Track"
        let cancel = "Cancel"
        switch cell.optionName.text {
        case captions:
            print(captions)
        case audioTrack:
            print(audioTrack)
        case cancel:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.darkView.alpha = 0
                self.collectionView.alpha = 0
                if let screen = UIApplication.shared.keyWindow {
                    self.collectionView.frame = CGRect(x: 0, y: screen.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }
            })
        default:
            break
        }
    }
    
    override init() {
        super.init()
        
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

