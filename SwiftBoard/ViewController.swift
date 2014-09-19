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
    var folderDataSource = FolderDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let myCollectionView = collectionView? {
            myCollectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
            myCollectionView.registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "zoomMe:")
            myCollectionView.addGestureRecognizer(tapRecognizer)
            myCollectionView.scrollEnabled = false
        }
        
        seedData();
        folderDataSource.items = items;
    }
    
    func seedData() {
        items = [
            App(name: "App 1", color: UIColor.greenColor()),
            App(name: "App 2", color: UIColor.blueColor()),
            Folder(name: "Folder 1", apps: [
                App(name: "App 5", color: UIColor.purpleColor()),
                App(name: "App 6", color: UIColor.grayColor()),
                App(name: "App 7", color: UIColor.yellowColor()),
                App(name: "App 8", color: UIColor.yellowColor()),
                App(name: "App 9", color: UIColor.redColor()),
                App(name: "App 10", color: UIColor.purpleColor()),
                App(name: "App 11", color: UIColor.blueColor()),
            ]),
            Folder(name: "Folder 2", apps: [
                App(name: "App 4", color: UIColor.darkGrayColor())
            ]),
            App(name: "App 3", color: UIColor.redColor()),
        ]
    }
    
    // Not sure this is right, but try to get the layout to assume its new size early so that in the animated rotation we don't
    // see neighbour items animating off-screen.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let layout = collectionView?.collectionViewLayout as? CollectionViewLayout {
            layout.overrideSize = size
            collectionView?.reloadData()
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        
        var item: AnyObject = items[indexPath.item]
        switch item {
        case let app as App:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as UICollectionViewCell
            let myCell = cell as AppCollectionViewCell
            myCell.label.text = app.name
            myCell.containerView.backgroundColor = app.color
        case let folder as Folder:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("Folder", forIndexPath: indexPath) as UICollectionViewCell
            let myCell = cell as FolderCollectionViewCell
            myCell.collectionView.itemIndex = indexPath.item
            myCell.collectionView.dataSource = folderDataSource
            myCell.collectionView.delegate = folderDataSource
            
            myCell.label.text = folder.name
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
    func zoomMe(recognizer:UITapGestureRecognizer) {
        if let layout = collectionView?.collectionViewLayout as? CollectionViewLayout {
            if (layout.zoomToIndexPath == nil) {
                let point = recognizer.locationInView(collectionView)
                if let indexPath = collectionView?.indexPathForItemAtPoint(point) {
                    let item: AnyObject = items[indexPath.item]
                    if let folder = item as? Folder {
                        layout.zoomToIndexPath = indexPath
                    } else {
                        layout.zoomToIndexPath = nil
                    }
                }
            } else {
                layout.zoomToIndexPath = nil
            }
            
            collectionView?.performBatchUpdates(nil, completion:nil)
        }
    }
}














