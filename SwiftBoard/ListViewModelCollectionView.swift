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
    
    // MARK: ListViewModelDelegate
    
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int) {
        performBatchUpdates({ () -> Void in
            self.moveItemAtIndexPath(fromIndex.toIndexPath(), toIndexPath: toIndex.toIndexPath())
        }, completion: nil)
    }
    
    func listViewModelItemAddedAtIndex(index: Int) {
        performBatchUpdates({ () -> Void in
            self.insertItemsAtIndexPaths([index.toIndexPath()])
        }, completion: nil)
    }
    
    func listViewModelItemRemovedAtIndex(index: Int) {
        performBatchUpdates({ () -> Void in
            self.deleteItemsAtIndexPaths([index.toIndexPath()])
        }, completion: nil)
    }
}
