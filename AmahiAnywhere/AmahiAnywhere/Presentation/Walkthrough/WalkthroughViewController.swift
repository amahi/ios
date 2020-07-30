//
//  WalkthroughViewController.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 05. 23..
//  Copyright © 2019. Amahi. All rights reserved.
//

import UIKit

class WalkthroughViewController: BaseUIViewController {

    @IBOutlet var arrowButton: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionView: UICollectionView!
    
    let titles = ["Access your HDA", "Browse your photos", "Play Your Music", "Play your Movies and Video Library", "Ready"]
    let icons = ["network", "photos", "music", "movies", "tick"]
    let descriptions = ["Amahi lets you play your videos, view your photos, listen to your music and more!", "Browse your photo library easily, upload photos directly from your phone.", "Listen to your music library, at home or on the road.", "Watch your video and movie library on your phone any time anywhere.", "You're all set to go. Thanks for using Amahi."]
    let colors = [UIColor(named: "3949AB"), UIColor(named: "444444"), UIColor(named: "26A59A"), UIColor(named: "FFAC00"), UIColor(named: "303E9F")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(UINib(nibName: "WalkthroughCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.register(UINib(nibName: "WalkthroughAmahiCell", bundle: nil), forCellWithReuseIdentifier: "amahiCell")
        arrowButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.frame.size = size
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        showLogin()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        let newPageIndex = pageControl.currentPage + 1
        if newPageIndex == pageControl.numberOfPages{
            showLogin()
        }else{
            collectionView.scrollToItem(at: IndexPath(item: newPageIndex, section: 0), at: .centeredHorizontally, animated: true)
            pageControl.currentPage = newPageIndex
        }
    }
    
    func showLogin(){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: StoryBoardIdentifiers.main, bundle: nil)
        let loginVC = mainStoryboard.instantiateViewController(withIdentifier: StoryBoardIdentifiers.loginViewController)
        
        LocalStorage.shared.persistString(string: "completed", key: "walkthrough")
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }
}

extension WalkthroughViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            return collectionView.dequeueReusableCell(withReuseIdentifier: "amahiCell", for: indexPath)
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WalkthroughCollectionCell else {
                return UICollectionViewCell()
            }
            
            let index = indexPath.item - 1
            cell.setupData(title: titles[index], icon: icons[index], description: descriptions[index], color: colors[index]!)
            return cell
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset:    UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        pageControl.currentPage = pageNumber
        
        if pageNumber == pageControl.numberOfPages-1{
            collectionView.backgroundColor = UIColor(named: "303E9F")
        }else{
            collectionView.backgroundColor = .clear
        }
    }
}

