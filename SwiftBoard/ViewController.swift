//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    var apps: [App] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seedData();
    }
    
    func seedData() {
        apps = [
            App(name: "App 1", color: UIColor.greenColor()),
            App(name: "App 2", color: UIColor.blueColor()),
            App(name: "App 3", color: UIColor.redColor())
        ]
    }


    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return apps.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("SwiftBoardApp", forIndexPath: indexPath) as UICollectionViewCell
        
        var app = apps[indexPath.section]
        cell.backgroundColor = app.color
        
        return cell
    }
    
}

