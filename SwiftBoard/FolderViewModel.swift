//
//  FolderViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

enum FolderViewModelState {
    case Closed, AppHovering, PreparingToOpen, Open
}

protocol FolderViewModelDelegate: class {
    func folderViewModelDraggingDidChange(Bool)
    func folderViewModelDeletingDidChange(Bool)
    func folderViewModelEditingDidChange(Bool)
    func folderViewModelZoomedDidChange(Bool)
    func folderViewModelStateDidChange(FolderViewModelState)
}

class FolderViewModel: ListViewModel, ItemViewModel {
    var name: String
    var parentListViewModel: ListViewModel?
    
    weak var itemViewModelDelegate: FolderViewModelDelegate?
    
    var dragging: Bool = false {
        didSet {
            if dragging != oldValue {
                itemViewModelDelegate?.folderViewModelDraggingDidChange(dragging)
            }
        }
    }
    
    var deleting: Bool = false {
        didSet {
            if deleting != oldValue {
                itemViewModelDelegate?.folderViewModelDeletingDidChange(deleting)
            }
        }
    }
    
    var editing: Bool = false {
        didSet {
            if editing != oldValue {
                itemViewModelDelegate?.folderViewModelEditingDidChange(editing)
            
                for var i=0; i < numberOfItems(); i++ {
                    let item = itemAtIndex(i)
                    item.editing = editing
                }
            }
        }
    }
    
    var zoomed: Bool = false {
        didSet {
            if zoomed != oldValue {
                itemViewModelDelegate?.folderViewModelZoomedDidChange(zoomed)
            }
        }
    }
    
    var state: FolderViewModelState {
        didSet {
            if state != oldValue {
                itemViewModelDelegate?.folderViewModelStateDidChange(state)
            }
        }
    }
    
    init(name folderName: String, viewModels initViewModels: [ItemViewModel]) {
        name = folderName
        state = .Closed
        super.init(viewModels: initViewModels)
    }
    
    func delete() {
        if let index = parentListViewModel?.indexOfItem(self) {
            deleting = true
            parentListViewModel?.removeItemAtIndex(index)
        }
    }
}
