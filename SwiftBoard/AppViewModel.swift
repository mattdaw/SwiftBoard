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
    var parentListViewModel: ListViewModel?
    
    weak var delegate: AppViewModelDelegate?
    
    var dragging: Bool = false {
        didSet {
            if dragging != oldValue {
                delegate?.appViewModelDraggingDidChange(dragging)
            }
        }
    }
    
    var deleting: Bool = false {
        didSet {
            if deleting != oldValue {
                delegate?.appViewModelDeletingDidChange(deleting)
            }
        }
    }
    
    var editing: Bool = false {
        didSet {
            if editing != oldValue {
                delegate?.appViewModelEditingDidChange(editing)
            }
        }
    }
    
    var zoomed: Bool = false {
        didSet {
            if zoomed != oldValue {
                delegate?.appViewModelZoomedDidChange(zoomed)
            }
        }
    }
    
    init(name appName:String, color appColor:UIColor) {
        name = appName
        color = appColor
    }
    
    func delete() {
        if let index = parentListViewModel?.indexOfItem(self) {
            deleting = true
            parentListViewModel?.removeItemAtIndex(index)
        }
    }
}
