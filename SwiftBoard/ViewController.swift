//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    var items: [AnyObject] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.collectionViewLayout = CollectionViewLayout();
        
        seedData();
    }
    
    func seedData() {
        items = [
            App(name: "App 1", color: UIColor.greenColor()),
            App(name: "App 2", color: UIColor.blueColor()),
            App(name: "App 3", color: UIColor.redColor()),
            Folder(name: "Folder 2", apps: []),
            Folder(name: "Folder 1", apps: [
                App(name: "App 4", color: UIColor.purpleColor()),
                App(name: "App 5", color: UIColor.grayColor()),
                App(name: "App 6", color: UIColor.yellowColor()),
            ])
        ]
    }


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var item: AnyObject = items[section]
        
        switch item {
        case let app as App:
            return 1
        case let folder as Folder:
            return folder.apps.count
        default:
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("SwiftBoardApp", forIndexPath: indexPath) as UICollectionViewCell
        
        var item: AnyObject = items[indexPath.section]
        switch item {
        case let app as App:
            cell.backgroundColor = app.color
        case let folder as Folder:
            cell.backgroundColor = folder.apps[indexPath.row].color
        default:
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
}

