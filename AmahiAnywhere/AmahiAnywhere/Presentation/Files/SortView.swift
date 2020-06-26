//
//  SortView.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 06. 15..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

class SortView: UIView, UITableViewDelegate, UITableViewDataSource{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(SortViewTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var tableData = [
        sortViewData(iconImageName: "sortNameIcon", title: StringLiterals.sortByName, sortingMethod: .name),
        sortViewData(iconImageName: "sortModifiedIcon", title: StringLiterals.sortByDate, sortingMethod: .date),
        sortViewData(iconImageName: "sortSizeIcon", title: StringLiterals.sortBySize, sortingMethod: .size),
        sortViewData(iconImageName: "sortTypeIcon", title: StringLiterals.sortByType, sortingMethod: .type),
    ]
    
    var serverFilesMode: Bool = true {
        didSet{
            if !serverFilesMode{
                tableData.removeLast()
                tableView.reloadData()
            }
        }
    }
    
    weak var sortViewDelegate: SortViewDelegate?
    var selectedFilter: FileSort!
    
    func setupViews(){
       // backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1607843137, blue: 0.1803921569, alpha: 1)
        if #available(iOS 13.0, *) {

            backgroundColor = UIColor.secondarySystemBackground

        } else {
            backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.1607843137, blue: 0.1803921569, alpha: 1)
            
        }
        addSubview(tableView)
        
        tableView.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, topConstant: 0, leadingConstant: 0, trailingConstant: 0, bottomConstant: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SortViewTableViewCell else {
            return UITableViewCell()
        }
        
        let data = tableData[indexPath.row]
        
        cell.setData(imageName: data.iconImageName, text: data.title)
        
        if data.sortingMethod == selectedFilter{
            cell.backgroundColor = #colorLiteral(red: 0.2337833491, green: 0.601263787, blue: 0.7718512056, alpha: 1)
        }else{
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(tableData.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sorting = tableData[indexPath.row].sortingMethod
        selectedFilter = sorting
        sortViewDelegate?.sortingSelected(sortingMethod: sorting)
    }
}

struct sortViewData{
    var iconImageName: String
    var title: String
    var sortingMethod: FileSort
}

protocol SortViewDelegate: class{
    func sortingSelected(sortingMethod: FileSort)
}

