//
//  CollectionViewDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-10-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class RootDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var rootViewModel: RootViewModel
    
    init(rootViewModel initViewModel: RootViewModel) {
        rootViewModel = initViewModel
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rootViewModel.numberOfChildren()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        var viewModel = rootViewModel.childAtIndex(indexPath.item)
        
        switch viewModel {
        case let appViewModel as AppViewModel:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as AppCollectionViewCell
            myCell.label.text = appViewModel.name
            myCell.containerView.backgroundColor = appViewModel.color
            
            cell = myCell
        case let folderViewModel as FolderViewModel:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("Folder", forIndexPath: indexPath) as FolderCollectionViewCell

            myCell.dataSource = FolderDataSource(folderViewModel: folderViewModel)
            myCell.label.text = folderViewModel.name
            
            cell = myCell
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
}