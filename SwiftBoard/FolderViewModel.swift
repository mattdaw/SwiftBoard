//
//  FolderViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol FolderViewModelDelegate: class {
    func folderViewModelDraggingDidChange(dragging: Bool)
}

class FolderViewModel: SwiftBoardListViewModel, SwiftBoardItemViewModel {
    var name: String
    
    var dragging: Bool = false {
        didSet {
            itemViewModelDelegate?.folderViewModelDraggingDidChange(dragging)
        }
    }
    
    weak var itemViewModelDelegate: FolderViewModelDelegate?
    
    init(name folderName: String, viewModels initViewModels: [SwiftBoardItemViewModel]) {
        name = folderName
        super.init(viewModels: initViewModels)
    }
    
    func openItemAtIndex(index: Int) {
        println("Opened in folder")
    }
}
