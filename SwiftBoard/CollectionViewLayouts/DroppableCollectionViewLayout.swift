//
//  DroppableCollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-12.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

@objc protocol DroppableCollectionViewLayout {
    var itemsPerRow: Int { get }
    
    func indexToMoveSourceIndexLeftOfDestIndex(sourceIndex: Int, destIndex: Int) -> Int
    func indexToMoveSourceIndexRightOfDestIndex(sourceIndex: Int, destIndex: Int) -> Int
}
