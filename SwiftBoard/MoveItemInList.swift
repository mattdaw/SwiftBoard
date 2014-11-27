//
//  MoveItemInList.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class MoveItemInList: DragOperation {
    let listViewModel: SwiftBoardListViewModel
    let fromIndex: Int
    let toIndex: Int
    
    init(listViewModel initList: SwiftBoardListViewModel, fromIndex initFrom: Int, toIndex initTo: Int) {
        listViewModel = initList
        fromIndex = initFrom
        toIndex = initTo
    }
    
    func dragStart() {
        listViewModel.moveItemAtIndex(fromIndex, toIndex: toIndex)
    }
}