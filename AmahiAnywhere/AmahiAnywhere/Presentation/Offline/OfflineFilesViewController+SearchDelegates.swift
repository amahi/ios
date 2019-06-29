//
//  OfflineFilesViewController+SearchDelegates.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 28..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

extension OfflineFilesViewController: UISearchBarDelegate, UISearchControllerDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFiles(searchText, files: offlineFiles)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.searchController = nil
        self.navigationController?.view.setNeedsLayout()
        self.navigationController?.view.layoutIfNeeded()
    }
    
    func filterFiles(_ searchText: String, files: [OfflineFile]) {
        if searchText.count > 0 {
            let filteredFiles = files.filter { file in
                return file.name!.localizedCaseInsensitiveContains(searchText)
            }
            organiseFilesSections(filteredFiles)
        } else {
            organiseFilesSections(offlineFiles)
        }
    }
}
