//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class RootViewModel: SwiftBoardListViewModel {
    var zoomedFolderIndex: Int?
    private var viewModels: [SwiftBoardItemViewModel]
    
    init(viewModels rootViewModels:[SwiftBoardItemViewModel]) {
        viewModels = rootViewModels
    }
    
    func numberOfChildren() -> Int {
        return viewModels.count
    }
    
    func childAtIndex(index: Int) -> SwiftBoardItemViewModel {
        return viewModels[index]
    }
    
    func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        var item: SwiftBoardItemViewModel = viewModels[fromIndex]
        viewModels.removeAtIndex(fromIndex)
        viewModels.insert(item, atIndex: toIndex)
        
        //delegate?.folderViewModelAppDidMove(fromIndex, toIndex: toIndex)
    }
}