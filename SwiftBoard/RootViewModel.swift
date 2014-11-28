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

class RootViewModel: ListViewModel {    
    weak var rootViewModelDelegate: RootViewModelDelegate?
    
    func moveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let index = indexOfItem(appViewModel) {
            let addIndex = folderViewModel.numberOfItems()
            
            appViewModel.listViewModel = folderViewModel
            removeItemAtIndex(index)
            folderViewModel.appendItem(appViewModel)
        } else {
            assertionFailure("moveAppToFolder: AppViewModel isn't in the RootViewModel")
        }
    }
    
    func moveAppFromFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let removeIndex = folderViewModel.indexOfItem(appViewModel) {
            let addIndex = numberOfItems()
            
            appViewModel.listViewModel = self
            folderViewModel.removeItemAtIndex(removeIndex)
            appendItem(appViewModel)
        } else {
            assertionFailure("moveAppFromFolder: AppViewModel isn't in the FolderViewModel")
        }
    }
    
    func openFolder(folderViewModel: FolderViewModel) {
        folderViewModel.state = .Open
        rootViewModelDelegate?.rootViewModelFolderOpened(folderViewModel)
    }
    
    func closeFolder(folderViewModel: FolderViewModel) {
        folderViewModel.state = .Closed
        rootViewModelDelegate?.rootViewModelFolderClosed(folderViewModel)
    }
}