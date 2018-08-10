//
//  OfflineFilesTableViewController+UISearchBarDelegate.swift
//  AmahiAnywhere
//
//  Created by codedentwickler on 6/18/18.
//  Copyright © 2018 Amahi. All rights reserved.
//

import Foundation

extension OfflineFilesTableViewController: UISearchBarDelegate {
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refetch(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    private func refetch(with text: String) {
        var predicate : NSPredicate? = nil
        if !text.trim().isEmpty {
            predicate = NSPredicate(format: "name CONTAINS %@", text)
        }
        fetchedResultsController?.fetchRequest.predicate = predicate
        
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch let error as NSError {
            AmahiLogger.log("Error while fetchedResultsController is performing fetch on search text changed \(error.localizedDescription)")
        }
    }
    
    @IBAction func onSortChange(_ sender: UISegmentedControl) {
        fileSort = sender.selectedSegmentIndex == 0 ? OfflineFileSort.dateAdded : OfflineFileSort.name
        
        let sortKey = (fileSort == .name) ? "name" : "downloadDate"
        let sortOrderAscending = (fileSort == .name) ? true : false
        
        let sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortOrderAscending)]
        fetchedResultsController?.fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch let error as NSError {
            AmahiLogger.log("Error while fetchedResultsController is performing fetch on sort order changed  \(error.localizedDescription)")
        }
    }
}
