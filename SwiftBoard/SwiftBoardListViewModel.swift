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

// TODO: Question, would moving numberOfRows onto each list be really dirty? It does take the layout out
// of any further calculations? Or should the layout itself actually happen in the view model, since it's not UIKit
// specific, I just need the "available" width?

class SwiftBoardListViewModel {
    private var viewModels: [SwiftBoardItemViewModel]
    weak var listViewModelDelegate: SwiftBoardListViewModelDelegate?
    
    init(viewModels initViewModels:[SwiftBoardItemViewModel]) {
        viewModels = initViewModels
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