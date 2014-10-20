//
//  FolderDataSource.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderDataSource : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var apps: [App];
    
    init(apps inApps:[App]) {
        apps = inApps
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apps.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let app = apps[indexPath.item]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as AppCollectionViewCell
        
        cell.label.text = app.name
        cell.containerView.backgroundColor = app.color
        
        return cell
    }

}