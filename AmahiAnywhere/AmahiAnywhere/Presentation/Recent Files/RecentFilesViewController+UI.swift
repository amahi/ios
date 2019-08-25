//
//  File.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 08. 25..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

extension RecentFilesViewController{
    
    func updateDownloadProgress(recentFile: Recent, downloadJustStarted: Bool, progress: Float){
        if downloadJustStarted{
            setupDownloadProgressIndicator()
            downloadTitleLabel?.text = String(format: StringLiterals.downloadingFile, recentFile.fileName)
            if let url = URL(string: recentFile.fileURL){
                downloadImageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "image"))
            }
        }
        
        if !isAlertShowing{
            isAlertShowing = true
            present(downloadProgressAlertController!, animated: true, completion: nil)
        }
        
        progressView?.setProgress(progress, animated: true)
    }
    
    func dismissProgressIndicator(completion: @escaping () -> Void) {
        downloadProgressAlertController?.dismiss(animated: true, completion: {
            completion()
        })
        downloadProgressAlertController = nil
        progressView = nil
        isAlertShowing = false
    }
    
    func setupDownloadProgressIndicator(){
        downloadProgressAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        downloadProgressAlertController?.view.setAnchorSize(width: nil, height: 190)
        
        
        downloadTitleLabel = UILabel()
        downloadTitleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        downloadTitleLabel?.numberOfLines = 2
        downloadTitleLabel?.textAlignment = .center
        downloadProgressAlertController?.view.addSubview(downloadTitleLabel!)
        
        
        downloadImageView = UIImageView(image: nil)
        downloadImageView?.contentMode = .scaleAspectFit
        downloadImageView?.setAnchorSize(width: 80, height: 80)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView?.trackTintColor = .white
        progressView?.setProgress(0.0, animated: true)
        progressView?.setAnchorSize(width: nil, height: 2)
        
        let stackView = UIStackView(arrangedSubviews: [downloadTitleLabel!, downloadImageView!, progressView!])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.alignment = .fill
        
        downloadProgressAlertController?.view.addSubview(stackView)
        stackView.setAnchors(top: downloadProgressAlertController?.view.topAnchor, leading: downloadProgressAlertController?.view.leadingAnchor, trailing: downloadProgressAlertController?.view.trailingAnchor, bottom: downloadProgressAlertController?.view.bottomAnchor, topConstant: 20, leadingConstant: 20, trailingConstant: 20, bottomConstant: 20)
    }
    
}
