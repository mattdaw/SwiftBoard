//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol RootViewModelDelegate: class {
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel)
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel)
}

class RootViewModel: SwiftBoardListViewModel {
    weak var rootViewModelDelegate: RootViewModelDelegate?
        
    func moveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let index = indexOfItem(appViewModel) {
            let addIndex = folderViewModel.numberOfItems()
            
            removeItemAtIndex(index)
            folderViewModel.appendItem(appViewModel)
            
            /*
            folderViewModel.appViewModels.append(appViewModel)
            
            // TODO: call into folder view model rather than manipulating it directly
            delegate?.listViewModelItemRemovedAtIndex(index)
            folderViewModel.listModelDelegate?.listViewModelItemAddedAtIndex(addIndex)
            */
        } else {
            assertionFailure("moveAppToFolder: AppViewModel isn't in the RootViewModel")
        }
        
    }
    
    func openFolder(folderViewModel: FolderViewModel) {
        rootViewModelDelegate?.rootViewModelFolderOpened(folderViewModel)
    }
    
    func closeFolder(folderViewModel: FolderViewModel) {
        rootViewModelDelegate?.rootViewModelFolderClosed(folderViewModel)
    }
}