//
//  FolderViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol FolderViewModelDelegate: SwiftBoardListViewModelDelegate {
    func folderViewModelDraggingDidChange(dragging: Bool)
}

class FolderViewModel: SwiftBoardListViewModel, SwiftBoardItemViewModel {
    var name: String
    var appViewModels: [AppViewModel]
    
    var dragging: Bool = false {
        didSet {
            delegate?.folderViewModelDraggingDidChange(dragging)
        }
    }
    
    weak var listModelDelegate: SwiftBoardListViewModelDelegate?
    weak var delegate: FolderViewModelDelegate?
    
    init(name folderName: String, appViewModels apps: [AppViewModel]) {
        name = folderName
        appViewModels = apps
    }
    
    func appViewModelAtIndex(index: Int) -> AppViewModel {
        return appViewModels[index]
    }
    
    func numberOfItems() -> Int {
        return appViewModels.count
    }
    
    func itemAtIndex(index: Int) -> SwiftBoardItemViewModel {
        return appViewModels[index]
    }
    
    func indexOfItem(item: SwiftBoardItemViewModel) -> Int? {
        for (index, compareItem) in enumerate(appViewModels) {
            if item === compareItem {
                return index
            }
        }
        
        return nil
    }

    func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        var app: AppViewModel = appViewModels[fromIndex]
        appViewModels.removeAtIndex(fromIndex)
        appViewModels.insert(app, atIndex: toIndex)
        
        listModelDelegate?.listViewModelItemMoved(fromIndex, toIndex: toIndex)
    }
    
    func openItemAtIndex(index: Int) {
        println("Opened in folder")
    }
}
