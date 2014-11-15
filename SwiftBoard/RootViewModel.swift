//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class RootViewModel {
    private var viewModels: [SwiftBoardViewModel]
    
    init(viewModels rootViewModels:[SwiftBoardViewModel]) {
        viewModels = rootViewModels
    }
    
    func numberOfChildren() -> Int {
        return viewModels.count
    }
    
    func childAtIndex(index: Int) -> SwiftBoardViewModel {
        return viewModels[index]
    }
}