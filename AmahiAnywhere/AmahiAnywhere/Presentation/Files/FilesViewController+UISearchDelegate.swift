//
//  FilesViewController+UISearchBarDelegate.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

// Mark - UISearchBarDelegate and Sorting Implementations

extension FilesViewController : UISearchBarDelegate, UISearchControllerDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterFiles(searchText, files: serverFiles, sortOrder: fileSort)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.searchController = nil
        self.navigationController?.view.setNeedsLayout()
        self.navigationController?.view.layoutIfNeeded()
        presenter.filterFiles("", files: serverFiles, sortOrder: fileSort)
    }
}
