//
//  SwiftBoardCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class SwiftBoardCollectionView: UICollectionView, SwiftBoardListViewModelDelegate {
    var listViewModel: SwiftBoardListViewModel? { return nil }
    
    // MARK: SwiftBoardListViewModelDelegate
    
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int) {
        let fromIndexPath = NSIndexPath(forItem: fromIndex, inSection: 0)
        let toIndexPath = NSIndexPath(forItem: toIndex, inSection: 0)
        
        performBatchUpdates({ () -> Void in
            self.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            }, completion: nil)
    }
    
    func listViewModelItemAddedAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        
        performBatchUpdates({ () -> Void in
            self.insertItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }
    
    func listViewModelItemRemovedAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        
        performBatchUpdates({ () -> Void in
            self.deleteItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }
}
