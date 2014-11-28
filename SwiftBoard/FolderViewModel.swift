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
    func folderViewModelDraggingDidChange(dragging: Bool)
    func folderViewModelStateDidChange(state: FolderViewModelState)
}

class FolderViewModel: ListViewModel, ItemViewModel {
    var name: String
    var listViewModel: ListViewModel?
    
    var dragging: Bool = false {
        didSet {
            itemViewModelDelegate?.folderViewModelDraggingDidChange(dragging)
        }
    }
    
    var state: FolderViewModelState {
        didSet {
            itemViewModelDelegate?.folderViewModelStateDidChange(state)
        }
    }
    
    weak var itemViewModelDelegate: FolderViewModelDelegate?
    
    init(name folderName: String, viewModels initViewModels: [ItemViewModel]) {
        name = folderName
        state = .Closed
        super.init(viewModels: initViewModels)
    }
}
