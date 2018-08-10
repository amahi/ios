//
//  FilesViewController+UISearchBarDelegate.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/17/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

// Mark - UISearchBarDelegate and Sorting Implementations

extension FilesViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterFiles(searchText, files: serverFiles, sortOrder: fileSort)
    }
    
    @IBAction func onSortChange(_ sender: UISegmentedControl) {
        fileSort = sender.selectedSegmentIndex == 0 ? FileSort.modifiedTime : FileSort.name
        presenter.reorderFiles(files: serverFiles, sortOrder: fileSort)
    }
}
