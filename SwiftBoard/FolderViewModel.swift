//
//  FolderViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

enum FolderViewModelState {
    case Normal, AppHovering, PreparingToOpen
}

protocol FolderViewModelDelegate: class {
    func folderViewModelDraggingDidChange(dragging: Bool)
    func folderViewModelStateDidChange(state: FolderViewModelState)
}

class FolderViewModel: SwiftBoardListViewModel, SwiftBoardItemViewModel {
    var name: String
    
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
    
    init(name folderName: String, viewModels initViewModels: [SwiftBoardItemViewModel]) {
        name = folderName
        state = .Normal
        super.init(viewModels: initViewModels)
    }
    
    func openItemAtIndex(index: Int) {
        println("Opened in folder")
    }
}
