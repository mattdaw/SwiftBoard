//
//  SwiftBoardItemViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol SwiftBoardItemViewModel: class {
    var dragging: Bool { get set }
    var listViewModel: SwiftBoardListViewModel? { get set }
}