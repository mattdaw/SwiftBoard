//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol RootViewModelDelegate: SwiftBoardListViewModelDelegate {
    func rootViewModelFolderOpenedAtIndex(index: Int)
}

class RootViewModel: SwiftBoardListViewModel {
    // TODO: probably can go? Root collection view can keep the current collection view instead?
    var indexOfOpenFolder: Int?
    weak var delegate: RootViewModelDelegate?

    private var viewModels: [SwiftBoardItemViewModel]
    
    init(viewModels rootViewModels:[SwiftBoardItemViewModel]) {
        viewModels = rootViewModels
    }
    
    func numberOfItems() -> Int {
        return viewModels.count
    }
    
    func itemAtIndex(index: Int) -> SwiftBoardItemViewModel {
        return viewModels[index]
    }
    
    func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        var item: SwiftBoardItemViewModel = viewModels[fromIndex]
        viewModels.removeAtIndex(fromIndex)
        viewModels.insert(item, atIndex: toIndex)
        
        delegate?.listViewModelItemMoved(fromIndex, toIndex: toIndex)
    }
    
    func openItemAtIndex(index: Int) {
        var item = viewModels[index]
        item.open()
        
        if let folder = item as? FolderViewModel {
            delegate?.rootViewModelFolderOpenedAtIndex(index)
        }
    }
}