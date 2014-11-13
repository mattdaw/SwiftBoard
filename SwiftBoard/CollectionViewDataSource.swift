//
//  CollectionViewDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-10-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items: NSMutableArray = []
        
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        var item: AnyObject = items[indexPath.item]
        
        switch item {
        case let app as App:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as AppCollectionViewCell
            myCell.label.text = app.name
            myCell.containerView.backgroundColor = app.color
            
            cell = myCell
        case let folder as Folder:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("Folder", forIndexPath: indexPath) as FolderCollectionViewCell
            
            let dataSource = CollectionViewDataSource()
            dataSource.items = folder.apps
            
            myCell.dataSource = dataSource
            myCell.label.text = folder.name
            
            cell = myCell
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
}