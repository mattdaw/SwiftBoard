//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

private struct DragState {
    let originalCenter: CGPoint
    let addTranslation: CGPoint
    let dragProxyView: UIView
    
    var dragIndexPath: NSIndexPath
    var dropIndexPath: NSIndexPath?
    
    mutating func setDragIndexPath(indexPath:NSIndexPath) {
        dragIndexPath = indexPath
    }
    
    mutating func setDropIndexPath(indexPath:NSIndexPath?) {
        dropIndexPath = indexPath
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {

    let kPauseBeforeDrag = 0.2
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items: [Any] = [];
    var zoomedLayout = CollectionViewLayout()
    var regularLayout = CollectionViewLayout()

    var panRecognizer: UIPanGestureRecognizer?
    var longPressRecognizer: UILongPressGestureRecognizer?
    var lastPanGesture: UIPanGestureRecognizer?
    var moveCellsTimer: NSTimer?
    
    private var currentDragState: DragState?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        collectionView.registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.setCollectionViewLayout(regularLayout, animated: false)
        collectionView.scrollEnabled = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "zoomLayout:")
        collectionView.addGestureRecognizer(tapRecognizer)
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecognizer!.delegate = self
        collectionView.addGestureRecognizer(longPressRecognizer!)

        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecognizer!.delegate = self
        collectionView.addGestureRecognizer(panRecognizer!)
        
        seedData();
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
        if let layout = collectionView.collectionViewLayout as? CollectionViewLayout {
            layout.overrideSize = size
            collectionView.reloadData()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        var item: Any = items[indexPath.item]
        
        switch item {
        case let app as App:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("App", forIndexPath: indexPath) as AppCollectionViewCell
            myCell.label.text = app.name
            myCell.containerView.backgroundColor = app.color
            
            cell = myCell
        case let folder as Folder:
            let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("Folder", forIndexPath: indexPath) as FolderCollectionViewCell
            myCell.folderDataSource = FolderDataSource(apps:folder.apps)
            myCell.label.text = folder.name
            
            cell = myCell
        default:
            cell = UICollectionViewCell()
        }
        
        return cell
    }
    
    // I'm not sure this is right yet, but it's seeming better to me to have two instantiated layouts. The layout's state
    // can be confusing (to me) when the initial/final attributes methods are called on a single layout instance.
    func zoomLayout(recognizer: UITapGestureRecognizer) {
        if collectionView.collectionViewLayout === regularLayout {
            let point = recognizer.locationInView(collectionView)
            
            if let indexPath = collectionView.indexPathForItemAtPoint(point) {
                let item: Any = items[indexPath.item]
                
                if let folder = item as? Folder {
                    zoomedLayout.zoomToIndexPath = indexPath
                    collectionView.setCollectionViewLayout(zoomedLayout, animated: true)
                    return
                }
            }
        }
        
        collectionView.setCollectionViewLayout(regularLayout, animated: true)
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            assert(currentDragState == nil)
            startDrag(gesture)
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            endDrag()
        default:
            break
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began, UIGestureRecognizerState.Changed:
            if let dragState = currentDragState {
                let translation = gesture.translationInView(collectionView)
                dragState.dragProxyView.center = CGPoint(x: dragState.originalCenter.x + translation.x + dragState.addTranslation.x,
                                                         y: dragState.originalCenter.y + translation.y + dragState.addTranslation.y)
                
                let dropPoint = gesture.locationInView(collectionView)
                if let dropIndexPath = collectionView.indexPathForItemAtPoint(dropPoint) {
                    if let dropCell = collectionView.cellForItemAtIndexPath(dropIndexPath) as? SwiftBoardCell {
                        let location = gesture.locationInView(dropCell)
                        
                        if dropCell.pointInsideIcon(location) {
                            //println("Icon!")
                        } else if location.x < (dropCell.bounds.width / 2) {
                            let newPath = regularLayout.indexPathToMoveSourceIndexPathLeftOfDestIndexPath(dragState.dragIndexPath, destIndexPath: dropIndexPath)
                            if (newPath != dragState.dragIndexPath) {
                                currentDragState!.setDropIndexPath(newPath)
                            }
                        } else {
                            let newPath = regularLayout.indexPathToMoveSourceIndexPathRightOfDestIndexPath(dragState.dragIndexPath, destIndexPath: dropIndexPath)
                            if (newPath != dragState.dragIndexPath) {
                                currentDragState!.setDropIndexPath(newPath)
                            }
                        }
                    }
                }
                
                moveCellsTimer?.invalidate();
                moveCellsTimer = NSTimer.scheduledTimerWithTimeInterval(kPauseBeforeDrag, target: self, selector: "moveCells", userInfo: nil, repeats: false)
            }
        case UIGestureRecognizerState.Ended:
            moveCellsTimer?.invalidate()
        default:
            break
        }
    }

    func startDrag(gesture:UIGestureRecognizer) {
        if let indexPath = collectionView.indexPathForItemAtPoint(gesture.locationInView(collectionView)) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                let dragProxyView = cell.snapshotViewAfterScreenUpdates(true)
                dragProxyView.frame = cell.frame
                collectionView.addSubview(dragProxyView)
                
                let startLocation = gesture.locationInView(collectionView)
                let originalCenter = dragProxyView.center
                let addTranslation = CGPoint(x: startLocation.x - originalCenter.x, y: startLocation.y - originalCenter.y)
                
                currentDragState = DragState(originalCenter:originalCenter,
                                             addTranslation:addTranslation,
                                              dragProxyView:dragProxyView,
                                              dragIndexPath:indexPath,
                                              dropIndexPath:nil)
                
                UIView.animateWithDuration(0.2) {
                    dragProxyView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                    dragProxyView.alpha = 0.8
                }
                
                regularLayout.editingModeEnabled = true
                regularLayout.hideIndexPath = indexPath
                regularLayout.invalidateLayout()
            }
        }
    }
    
    func endDrag() {
        if let dragState = currentDragState {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                dragState.dragProxyView.transform = CGAffineTransformIdentity
                dragState.dragProxyView.alpha = 1
            }, completion: { (Bool) -> Void in
                    self.regularLayout.hideIndexPath = nil
                    self.regularLayout.invalidateLayout()
                    
                    dragState.dragProxyView.removeFromSuperview()
                    self.currentDragState = nil
            })
        }
    }
    
    func moveCells() {
        if let dragState = currentDragState {
            if let dropIndexPath = dragState.dropIndexPath {
                // Update data source
                let originalIndexPath = dragState.dragIndexPath
                
                var item: Any = items[originalIndexPath.item]
                items.removeAtIndex(originalIndexPath.item)
                
                if dropIndexPath.item >= items.count {
                    items.append(item)
                } else {
                    items.insert(item, atIndex:dropIndexPath.item)
                }
                
                // Update drag state
                currentDragState!.setDragIndexPath(dropIndexPath)
                currentDragState!.setDropIndexPath(nil)
                
                // Update collection view
                regularLayout.hideIndexPath = dropIndexPath
                
                if let myCollectionView = collectionView {
                    myCollectionView.performBatchUpdates({ () -> Void in
                        myCollectionView.moveItemAtIndexPath(dragState.dragIndexPath, toIndexPath:dropIndexPath)
                    }, completion: nil)
                }
            }
        }
    }
    
    @IBAction func handleHomeButton(sender: AnyObject) {
        if regularLayout.editingModeEnabled {
            regularLayout.editingModeEnabled = false
            regularLayout.invalidateLayout()
        }
    }
    
    // UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer!:
            return true
        case panRecognizer!:
            return currentDragState != nil
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














