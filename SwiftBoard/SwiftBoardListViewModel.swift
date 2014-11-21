//
//  SwiftBoardListViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol SwiftBoardListViewModelDelegate: class {
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int)
    func listViewModelItemAddedAtIndex(index: Int)
    func listViewModelItemRemovedAtIndex(index: Int)
}

class SwiftBoardListViewModel {
    var numberOfRows: Int = 1
    private var viewModels: [SwiftBoardItemViewModel]
    weak var listViewModelDelegate: SwiftBoardListViewModelDelegate?
    
    init(viewModels initViewModels:[SwiftBoardItemViewModel]) {
        viewModels = initViewModels
        
        for itemViewModel in viewModels {
            itemViewModel.listViewModel = self
        }
    }
    
    func numberOfItems() -> Int {
        return viewModels.count
    }
    
    func itemAtIndex(index: Int) -> SwiftBoardItemViewModel {
        return viewModels[index]
    }
    
    func indexOfItem(item: SwiftBoardItemViewModel) -> Int? {
        for (index, compareItem) in enumerate(viewModels) {
            if item === compareItem {
                return index
            }
        }
        
        return nil
    }
    
    func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        var item: SwiftBoardItemViewModel = viewModels[fromIndex]
        viewModels.removeAtIndex(fromIndex)
        viewModels.insert(item, atIndex: toIndex)
        
        listViewModelDelegate?.listViewModelItemMoved(fromIndex, toIndex: toIndex)
    }
    
    func removeItemAtIndex(index: Int)  {
        viewModels.removeAtIndex(index)
        listViewModelDelegate?.listViewModelItemRemovedAtIndex(index)
    }
    
    func appendItem(itemViewModel: SwiftBoardItemViewModel) {
        let index = viewModels.count
        viewModels.append(itemViewModel)
        listViewModelDelegate?.listViewModelItemAddedAtIndex(index)
    }
}