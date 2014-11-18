//
//  DroppableCollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-12.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class DroppableCollectionViewLayout: UICollectionViewLayout {
    var itemsPerRow = 1
    
    func indexToMoveSourceIndexLeftOfDestIndex(sourceIndex: Int, destIndex: Int) -> Int {
        let column = destIndex % itemsPerRow
        var offset = 0
        if sourceIndex < destIndex && column != 0 {
            offset = -1
        }
        
        return destIndex + offset
    }
    
    func indexToMoveSourceIndexRightOfDestIndex(sourceIndex: Int, destIndex: Int) -> Int {
        var offset = 1
        if sourceIndex < destIndex {
            offset = 0
        }
        
        return destIndex + offset
    }
}