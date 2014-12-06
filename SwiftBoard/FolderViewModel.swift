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
    func folderViewModelEditingDidChange(Bool)
    func folderViewModelZoomedDidChange(Bool)
    func folderViewModelStateDidChange(FolderViewModelState)
}

class FolderViewModel: ListViewModel, ItemViewModel {
    var name: String
    var parentListViewModel: ListViewModel?
    
    weak var folderViewModelDelegate: FolderViewModelDelegate?
    
    var dragging: Bool = false {
        didSet {
            folderViewModelDelegate?.folderViewModelDraggingDidChange(dragging)
        }
    }
    
    var editing: Bool = false {
        didSet {
            folderViewModelDelegate?.folderViewModelEditingDidChange(editing)
        
            for var i=0; i < numberOfItems(); i++ {
                let item = itemAtIndex(i)
                item.editing = editing
            }
        }
    }
    
    var zoomed: Bool = false {
        didSet {
            folderViewModelDelegate?.folderViewModelZoomedDidChange(zoomed)
        }
    }
    
    var state: FolderViewModelState {
        didSet {
            folderViewModelDelegate?.folderViewModelStateDidChange(state)
        }
    }
    
    init(name folderName: String, viewModels initViewModels: [ItemViewModel]) {
        name = folderName
        state = .Closed
        super.init(viewModels: initViewModels)
    }
}
