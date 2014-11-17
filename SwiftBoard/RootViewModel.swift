//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol RootViewModelDelegate: SwiftBoardListViewModelDelegate {
    
}

class RootViewModel: SwiftBoardListViewModel {
    var indexOfOpenFolder: Int?
    private var viewModels: [SwiftBoardItemViewModel]
    
    private weak var delegate: RootViewModelDelegate?
    
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
        
    }
}