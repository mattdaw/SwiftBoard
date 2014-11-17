//
//  SwiftBoardListViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol SwiftBoardListViewModel: class {
    func numberOfItems() -> Int
    func itemAtIndex(index: Int) -> SwiftBoardItemViewModel
    func openItemAtIndex(index: Int)
}

protocol SwiftBoardListViewModelDelegate: class {
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int)
}