//
//  RemoveItemOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-12-02.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class RemoveItemOperation: AsyncOperation {
    let collectionView: UICollectionView
    let index: Int
    
    init(collectionView initCV: UICollectionView, index initIndex: Int) {
        collectionView = initCV
        index = initIndex
    }
    
    override func start() {
        executing = true
        
        collectionView.performBatchUpdates({ () -> Void in
            self.collectionView.deleteItemsAtIndexPaths([self.index.toIndexPath()])
        }, completion: { (didComplete: Bool) -> Void in
            self.finished = true
        })
    }
}