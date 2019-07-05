//
//  GlobalLayoutView.swift
//  AmahiAnywhere
//
//  Created by Marton Zeisler on 2019. 07. 03..
//  Copyright © 2019. Amahi. All rights reserved.
//

import Foundation

enum LayoutView{
    case listView
    case gridView
}

struct GlobalLayoutView{
    static var layoutView = LayoutView.listView
    
    static func switchLayoutMode(){
        if layoutView == .listView{
            // Setting layout view to grid
            layoutView = .gridView
            UserDefaults.standard.set(false, forKey: "isLayoutList")
        }else{
            // Setting layout view to list
            layoutView = .listView
            UserDefaults.standard.set(true, forKey: "isLayoutList")
        }
    }
    
    static func setDefaultLayout(){
        let isLayoutList = UserDefaults.standard.value(forKey: "isLayoutList") as? Bool ?? true
        if isLayoutList{
            GlobalLayoutView.layoutView = .listView
        }else{
            GlobalLayoutView.layoutView = .gridView
        }
    }
}
