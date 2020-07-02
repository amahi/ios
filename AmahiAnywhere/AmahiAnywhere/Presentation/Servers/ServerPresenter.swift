//
//  ServerPresenter.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

protocol ServerView : BaseView {
    func updateServerList(_ activeServers: [Server])
    func updateRefreshing(isRefreshing: Bool)
}

class ServerPresenter: BasePresenter {
    
    weak private var view: ServerView?
    
    init(_ view: ServerView) {
        self.view = view
    }
    
    
    func detachView() {
        self.view = nil
    }
    
    func fetchServers() {
        
        ServerApi.destroySharedManager()
        
        self.view?.updateRefreshing(isRefreshing: true)
        
        // cleanup temp files in background
        DispatchQueue.global(qos: .background).async {
            FileManager.default.cleanUpFiles(in: FileManager.default.temporaryDirectory,
                                             folderName: "cache")
        }
        
        AmahiApi.shared.getServers() { (serverResponse) in
            self.view?.updateRefreshing(isRefreshing: false)

            guard var servers = serverResponse else {
                self.view?.showError(message: StringLiterals.genericNetworkError)
                return
            }
            
            // Uncomment these lines to test your local hda running from the terminal
//            let myServer = Server()
//            myServer.name = "My Server"
//            myServer.session_token = "abc"
//            myServer.active = true
//            servers.append(myServer)
            
            self.view?.updateServerList(servers)
        }
    }

}
