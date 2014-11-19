//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol RootViewModelDelegate: SwiftBoardListViewModelDelegate {
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel)
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel)
}

class RootViewModel: SwiftBoardListViewModel {
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
        
        delegate?.listViewModelItemMoved(fromIndex, toIndex: toIndex)
    }
    
    func moveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let index = indexOfItem(appViewModel) {
            let addIndex = folderViewModel.numberOfItems()
            
            viewModels.removeAtIndex(index)
            folderViewModel.appViewModels.append(appViewModel)
            
            // TODO: call into folder view model rather than manipulating it directly
            delegate?.listViewModelItemRemovedAtIndex(index)
            folderViewModel.listModelDelegate?.listViewModelItemAddedAtIndex(addIndex)
        } else {
            assertionFailure("moveAppToFolder: AppViewModel isn't in the RootViewModel")
        }
        
    }
    
    func openFolder(folderViewModel: FolderViewModel) {
        delegate?.rootViewModelFolderOpened(folderViewModel)
    }
    
    func closeFolder(folderViewModel: FolderViewModel) {
        delegate?.rootViewModelFolderClosed(folderViewModel)
    }
}