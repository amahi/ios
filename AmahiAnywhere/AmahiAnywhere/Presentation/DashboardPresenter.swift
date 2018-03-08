//
//  DashboardPresenter.swift
//  AmahiAnywhere
//
//  Created by Chirag Maheshwari on 06/03/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

protocol DashboardView : BaseView {
    func updateServerList(_ activeServers: [Server])
    func updateRefreshing(isRefreshing: Bool)
}

class DashboardPresenter: BasePresenter {
    
    weak private var view: DashboardView?
    
    init(_ view: DashboardView) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func fetchServers() {
        
        self.view?.updateRefreshing(isRefreshing: true)
        AmahiApi.shared.getServers() { (serverResponse) in
            self.view?.updateRefreshing(isRefreshing: false)

            guard let servers = serverResponse else {
                self.view?.showError(message: StringLiterals.GENERIC_NETWORK_ERROR)
                return
            }
            self.view?.updateServerList(servers)
        }
    }

}
