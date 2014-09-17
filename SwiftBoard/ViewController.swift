//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, CollectionViewLayoutDelegate {

    var items: [AnyObject] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let layout = CollectionViewLayout();
        layout.delegate = self
        collectionView?.collectionViewLayout = layout;
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "zoomMe:")
        collectionView?.addGestureRecognizer(tapRecognizer)
        collectionView?.scrollEnabled = false
        */
        
        if let myCollectionView = collectionView? {
            myCollectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
            myCollectionView.registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        }
        
        seedData();
    }
    
    func seedData() {
        items = [
            App(name: "App 1", color: UIColor.greenColor()),
            App(name: "App 2", color: UIColor.blueColor()),
            App(name: "App 3", color: UIColor.redColor()),
            Folder(name: "Folder 2", apps: [
                App(name: "App 4", color: UIColor.darkGrayColor())
            ]),
            Folder(name: "Folder 1", apps: [
                App(name: "App 5", color: UIColor.purpleColor()),
                App(name: "App 6", color: UIColor.grayColor()),
                App(name: "App 7", color: UIColor.yellowColor()),
                App(name: "App 8", color: UIColor.yellowColor()),
                App(name: "App 9", color: UIColor.redColor()),
                App(name: "App 10", color: UIColor.purpleColor()),
                App(name: "App 11", color: UIColor.blueColor()),
            ])
        ]
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
        
        if let app = item as? App {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as UICollectionViewCell
            cell.backgroundColor = app.color
        } else if let folder = item as? Folder {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("Folder", forIndexPath: indexPath) as UICollectionViewCell
            cell.backgroundColor = folder.apps[0].color
        } else {
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
    func sectionAtIndex(section: Int) -> AnyObject? {
        return items[section]
    }
    
    func zoomMe(recognizer:UITapGestureRecognizer) {
        if let layout = collectionView?.collectionViewLayout as? CollectionViewLayout {
            if (layout.zoomToSectionIndex == nil) {
                let point = recognizer.locationInView(collectionView)
                if let indexPath = collectionView?.indexPathForItemAtPoint(point) {
                    layout.zoomToSectionIndex = indexPath.section
                }
            } else {
                layout.zoomToSectionIndex = nil
            }
            
            collectionView?.performBatchUpdates(nil, completion: nil)
        }
    }
}














