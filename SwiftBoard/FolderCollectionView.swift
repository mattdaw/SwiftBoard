//
//  FolderCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionView: SwiftBoardCollectionView, SwiftBoardListViewModelDelegate {
    var listDataSource: SwiftBoardListViewModelDataSource?
    
    var folderViewModel: FolderViewModel? {
        didSet {
            if folderViewModel != nil {
                listDataSource = SwiftBoardListViewModelDataSource(folderViewModel!)
                dataSource = listDataSource
                delegate = listDataSource
                
                folderViewModel!.listModelDelegate = self
            }
        }
    }
    
    override var listViewModel: SwiftBoardListViewModel? {
        return folderViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
    }
    
    // MARK: SwiftBoardItemViewModelDelegate
    
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int) {
        let fromIndexPath = NSIndexPath(forItem: fromIndex, inSection: 0)
        let toIndexPath = NSIndexPath(forItem: toIndex, inSection: 0)
        
        performBatchUpdates({ () -> Void in
            self.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            }, completion: nil)
    }
}
