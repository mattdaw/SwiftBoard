//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    let kPauseBeforeDrag = 0.2
    
    var items: [AnyObject] = [];
    var folderDataSource = FolderDataSource()
    var zoomedLayout = CollectionViewLayout()
    var regularLayout = CollectionViewLayout()
    var dragOriginalCenter: CGPoint?
    var dragAddTranslation: CGPoint?
    var draggingIndexPath: NSIndexPath?
    var draggingView: UIView?
    var panRecognizer: UIPanGestureRecognizer?
    var longPressRecognizer: UILongPressGestureRecognizer?
    var lastPanGesture: UIPanGestureRecognizer?
    var moveCellsTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let myCollectionView = collectionView? {
            myCollectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
            myCollectionView.registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
            
            myCollectionView.setCollectionViewLayout(regularLayout, animated: false)
            myCollectionView.scrollEnabled = false
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "zoomLayout:")
            myCollectionView.addGestureRecognizer(tapRecognizer)
            
            longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            longPressRecognizer!.delegate = self
            myCollectionView.addGestureRecognizer(longPressRecognizer!)

            panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
            panRecognizer!.delegate = self
            myCollectionView.addGestureRecognizer(panRecognizer!)
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
            App(name: "App 20", color: UIColor.redColor()),
            App(name: "App 21", color: UIColor.redColor()),
            App(name: "App 22", color: UIColor.redColor()),
            App(name: "App 23", color: UIColor.redColor()),
            App(name: "App 24", color: UIColor.redColor()),
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
    
    // I'm not sure this is right yet, but it's seeming better to me to have two instantiated layouts. The layout's state
    // can be confusing (to me) when the initial/final attributes methods are called on a single layout instance.
    func zoomLayout(recognizer: UITapGestureRecognizer) {
        if collectionView?.collectionViewLayout === regularLayout {
            let point = recognizer.locationInView(collectionView)
            
            if let indexPath = collectionView?.indexPathForItemAtPoint(point) {
                let item: AnyObject = items[indexPath.item]
                
                if let folder = item as? Folder {
                    zoomedLayout.zoomToIndexPath = indexPath
                    collectionView?.setCollectionViewLayout(zoomedLayout, animated: true)
                    return
                }
            }
        }
        
        collectionView?.setCollectionViewLayout(regularLayout, animated: true)
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            let (cell, indexPath) = cellAndIndexPathForGesture(gesture)
            
            if cell != nil {
                draggingIndexPath = indexPath
                grabCell(cell!, gesture:gesture)
                
                regularLayout.hideIndexPath = indexPath
                regularLayout.invalidateLayout()
            }
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            if let dv = draggingView {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    dv.transform = CGAffineTransformIdentity
                    dv.alpha = 1
                }, completion: { (Bool) -> Void in
                    self.regularLayout.hideIndexPath = nil
                    self.regularLayout.invalidateLayout()
                    
                    dv.removeFromSuperview()
                    self.draggingIndexPath = nil
                    self.draggingView = nil
                    self.dragOriginalCenter = nil
                    self.dragAddTranslation = nil
                })
            }
        default:
            break
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began, UIGestureRecognizerState.Changed:
            if let dv = draggingView {
                let translation = gesture.translationInView(view)
                dv.center = CGPoint(x: dragOriginalCenter!.x + translation.x + dragAddTranslation!.x,
                                    y: dragOriginalCenter!.y + translation.y + dragAddTranslation!.y)
                
                lastPanGesture = gesture
                
                moveCellsTimer?.invalidate();
                moveCellsTimer = NSTimer.scheduledTimerWithTimeInterval(kPauseBeforeDrag, target: self, selector: "moveCells", userInfo: nil, repeats: false)
            }
        case UIGestureRecognizerState.Ended:
            moveCellsTimer?.invalidate()
        default:
            break
        }
    }
    
    func moveCells() {
        if lastPanGesture == nil {
            return
        }
        
        let (myCell, indexPath) = cellAndIndexPathForGesture(lastPanGesture!)
        
        if let myCollectionView = collectionView {
            if let sbCell = myCell as? SwiftBoardCell {
                let location = lastPanGesture!.locationInView(myCell)

                // TODO: bug when moving far cell (0,2) to cell (0,1) and (1,1) to (0,1)
                // And bug dragging secon
                if sbCell.pointInsideIcon(location) {
                    //println("Icon!")
                } else if location.x < (myCell!.bounds.width / 2) {
                    let newPath = regularLayout.indexPathToInsertLeftOfIndexPath(indexPath!)
                    moveDraggingCellToIndexPath(newPath)
                } else {
                    // TODO: The "minus one" logic should be in the layout? Better name for methods?
                    let newPath = regularLayout.indexPathToInsertRightOfIndexPath(indexPath!)
                    moveDraggingCellToIndexPath(newPath)
                }
            }
        }
    }
    
    func cellAndIndexPathForGesture(gesture: UIGestureRecognizer) -> (UICollectionViewCell?, NSIndexPath?) {
        if let myCollectionView = collectionView {
            let point = gesture.locationInView(myCollectionView)
            
            if let indexPath = myCollectionView.indexPathForItemAtPoint(point) {
                let cell = myCollectionView.cellForItemAtIndexPath(indexPath)
                return (cell, indexPath)
            }
        }
        
        return (nil, nil)
    }
    
    func grabCell(cell:UICollectionViewCell, gesture:UIGestureRecognizer) {
        draggingView = cell.snapshotViewAfterScreenUpdates(true)
        if let dv = draggingView {
            dv.frame = cell.frame
            dragOriginalCenter = dv.center
            
            let startLocation = gesture.locationInView(view)
            dragAddTranslation = CGPoint(x: startLocation.x - dragOriginalCenter!.x,
                y: startLocation.y - dragOriginalCenter!.y)
            
            view.addSubview(dv)
            
            UIView.animateWithDuration(0.2) {
                dv.transform = CGAffineTransformMakeScale(1.1, 1.1)
                dv.alpha = 0.6
            }
        }
    }
    
    func moveDraggingCellToIndexPath(indexPath:NSIndexPath) {
        if draggingIndexPath == nil || draggingIndexPath == indexPath {
            return
        }
        
        // Update data source
        let originalIndexPath = draggingIndexPath!
        
        var newIndexPath = indexPath
        if originalIndexPath.item < indexPath.item {
            newIndexPath = NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)
        }
        
        var item: AnyObject = items[originalIndexPath.item]
        items.removeAtIndex(originalIndexPath.item)
        
        if newIndexPath.item >= items.count {
            items.append(item)
        } else {
            items.insert(item, atIndex:newIndexPath.item)
        }
        
        draggingIndexPath = newIndexPath
        regularLayout.hideIndexPath = newIndexPath
        
        // Update collection view
        if let myCollectionView = collectionView {
            myCollectionView.performBatchUpdates({ () -> Void in
                myCollectionView.moveItemAtIndexPath(originalIndexPath, toIndexPath: newIndexPath)
            }, completion: nil)
        }
    }
    
    // UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer!:
            let (cell, indexPath) = cellAndIndexPathForGesture(gesture)
            return cell != nil
        case panRecognizer!:
            return dragOriginalCenter != nil
        default:
            return false
        }
    }
    
    func gestureRecognizer(gesture: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer!:
            return otherGesture === panRecognizer!
        case panRecognizer!:
            return otherGesture === longPressRecognizer!
        default:
            return false
        }
    }
}














