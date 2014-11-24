//
//  ListViewModelDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-10-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ListViewModelDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var listViewModel: SwiftBoardListViewModel
    
    init(_ initViewModel: SwiftBoardListViewModel) {
        listViewModel = initViewModel
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listViewModel.numberOfItems()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        var itemViewModel = listViewModel.itemAtIndex(indexPath.item)
        
        switch itemViewModel {
        case let appViewModel as AppViewModel:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as AppCollectionViewCell
            myCell.appViewModel = appViewModel
                        
            cell = myCell
        case let folderViewModel as FolderViewModel:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("Folder", forIndexPath: indexPath) as FolderCollectionViewCell
            myCell.configureForFolderViewModel(folderViewModel)
            
            cell = myCell
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
}