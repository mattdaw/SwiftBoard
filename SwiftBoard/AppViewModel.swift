//
//  AppViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

protocol AppViewModelDelegate: class {
    func appViewModelDraggingDidChange(Bool)
    func appViewModelDeletingDidChange(Bool)
    func appViewModelEditingDidChange(Bool)
    func appViewModelZoomedDidChange(Bool)
}

class AppViewModel: ItemViewModel {
    var name: String
    var color: UIColor
    var listViewModel: ListViewModel?
    weak var delegate: AppViewModelDelegate?
    
    var dragging: Bool = false {
        didSet {
            delegate?.appViewModelDraggingDidChange(dragging)
        }
    }
    
    var deleting: Bool = false {
        didSet {
            delegate?.appViewModelDeletingDidChange(deleting)
        }
    }
    
    var editing: Bool = false {
        didSet {
            if oldValue != editing {
                delegate?.appViewModelEditingDidChange(editing)
            }
        }
    }
    
    var zoomed: Bool = false {
        didSet {
            delegate?.appViewModelZoomedDidChange(zoomed)
        }
    }
    
    init(name appName:String, color appColor:UIColor) {
        name = appName
        color = appColor
    }
    
    func delete() {
        if let index = listViewModel?.indexOfItem(self) {
            deleting = true
            listViewModel?.removeItemAtIndex(index)
        }
    }
}
