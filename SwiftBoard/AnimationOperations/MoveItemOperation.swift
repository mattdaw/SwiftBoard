//
//  MoveItemOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-12-02.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class MoveItemOperation: AsyncOperation {
    let collectionView: UICollectionView
    let fromIndex: Int
    let toIndex: Int
    
    init(collectionView initCV: UICollectionView, fromIndex initFromIndex: Int, toIndex initToIndex: Int) {
        collectionView = initCV
        fromIndex = initFromIndex
        toIndex = initToIndex
    }
    
    override func start() {
        executing = true
        
        collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.moveItemAtIndexPath(self.fromIndex.toIndexPath(), toIndexPath: self.toIndex.toIndexPath())
        }, completion: { (didComplete: Bool) -> Void in
            self.finished = true
        })
    }
}