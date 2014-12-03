//
//  ListViewModelCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ListViewModelCollectionView: UICollectionView, ListViewModelDelegate {
    var listViewModel: ListViewModel? { return nil }
    var deferAnimations: Bool = true
    
    // MARK: ListViewModelDelegate
    
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int) {
        let op = MoveItemOperation(collectionView: self, fromIndex: fromIndex, toIndex: toIndex)
        
        if deferAnimations {
            NSOperationQueue.mainQueue().addOperation(op)
        } else {
            op.start()
        }
    }
    
    func listViewModelItemAddedAtIndex(index: Int) {
        let op = AddItemOperation(collectionView: self, index: index)
        
        if deferAnimations {
            NSOperationQueue.mainQueue().addOperation(op)
        } else {
            op.start()
        }
    }
    
    func listViewModelItemRemovedAtIndex(index: Int) {
        let op = RemoveItemOperation(collectionView: self, index: index)
        
        if deferAnimations {
            NSOperationQueue.mainQueue().addOperation(op)
        } else {
            op.start()
        }
    }
}
