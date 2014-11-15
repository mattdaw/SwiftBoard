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
    
    func indexPathToMoveSourceIndexPathLeftOfDestIndexPath(sourceIndexPath:NSIndexPath, destIndexPath:NSIndexPath) -> NSIndexPath {
        let column = destIndexPath.item % itemsPerRow
        var offset = 0
        if sourceIndexPath.item < destIndexPath.item && column != 0 {
            offset = -1
        }
        
        return NSIndexPath(forItem:destIndexPath.item + offset, inSection:destIndexPath.section)
    }
    
    func indexPathToMoveSourceIndexPathRightOfDestIndexPath(sourceIndexPath:NSIndexPath, destIndexPath:NSIndexPath) -> NSIndexPath {
        var offset = 1
        if sourceIndexPath.item < destIndexPath.item {
            offset = 0
        }
        
        return NSIndexPath(forItem:destIndexPath.item + offset, inSection:destIndexPath.section)
    }
}