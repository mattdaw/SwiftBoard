//
//  FolderDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items: [AnyObject] = [];
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let folderCollectionView = collectionView as? FolderCollectionView {
            if let folder = items[folderCollectionView.itemIndex!] as? Folder {
                return folder.apps.count
            }
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as UICollectionViewCell
        let myCell = cell as AppCollectionViewCell
        
        if let folderCollectionView = collectionView as? FolderCollectionView {
            if let folder = items[folderCollectionView.itemIndex!] as? Folder {
                let app = folder.apps[indexPath.item]
                
                myCell.label.text = app.name
                myCell.containerView.backgroundColor = app.color
            }
        }

        return cell
    }

}