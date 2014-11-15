//
//  FolderDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var folderViewModel: FolderViewModel
    
    init(folderViewModel initViewModel: FolderViewModel) {
        folderViewModel = initViewModel
        
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderViewModel.numberOfAppViewModels()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let appViewModel = folderViewModel.appViewModelAtIndex(indexPath.item)
        let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as AppCollectionViewCell
        
        myCell.label.text = appViewModel.name
        myCell.containerView.backgroundColor = appViewModel.color
        
        return myCell
    }
}