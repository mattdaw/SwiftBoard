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

private struct ZoomState {
    let indexPath: NSIndexPath
    let collectionView: UICollectionView
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    var items: [Any] = [];
    var dataSource:CollectionViewDataSource = CollectionViewDataSource()
    var zoomedLayout = CollectionViewLayout()
    var regularLayout = CollectionViewLayout()
    
    private var currentDragState: DragState?
    private var currentZoomState: ZoomState?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seedData()
        
        dataSource.items = items
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        collectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        collectionView.registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.setCollectionViewLayout(regularLayout, animated: false)
        collectionView.scrollEnabled = false
        
        panAndStopGestureRecognizer = PanAndStopGestureRecognizer(target:self, action:"handlePan:", stopAfterSecondsWithoutMovement:0.2) {
            (translation:CGPoint) in self.panGestureStopped(translation)
        }
        collectionView.addGestureRecognizer(panAndStopGestureRecognizer)
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
                if dragState.dragIndexPath == dropIndexPath {
                    return
                }
                
                // Update data source
                let originalIndexPath = dragState.dragIndexPath
                
                var item: Any = items[originalIndexPath.item]
                items.removeAtIndex(originalIndexPath.item)
                
                if dropIndexPath.item >= items.count {
                    items.append(item)
                } else {
                    items.insert(item, atIndex:dropIndexPath.item)
                }
                
                dataSource.items = items
                
                // Update collection view
                regularLayout.hideIndexPath = dropIndexPath
                
                collectionView.performBatchUpdates({ () -> Void in
                    self.collectionView.moveItemAtIndexPath(dragState.dragIndexPath, toIndexPath:dropIndexPath)
                }, completion: nil)
                
                // Update drag state
                currentDragState!.setDragIndexPath(dropIndexPath)
                currentDragState!.setDropIndexPath(nil)
            }
        }
    }
    
    func zoomFolder() {
        if let zoomState = currentZoomState {
            zoomedLayout.zoomToIndexPath = zoomState.indexPath
            collectionView.setCollectionViewLayout(zoomedLayout, animated: true)
        }
    }
    
    @IBAction func handleHomeButton(sender: AnyObject) {
        if regularLayout.editingModeEnabled {
            regularLayout.editingModeEnabled = false
            regularLayout.invalidateLayout()
        }
    }
    
    // MARK: Gesture Recognizer Actions
    
    // I'm not sure this is right yet, but it's seeming better to me to have two instantiated layouts. The layout's state
    // can be confusing (to me) when the initial/final attributes methods are called on a single layout instance.
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
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
        
        currentZoomState = nil
        collectionView.setCollectionViewLayout(regularLayout, animated: true)
    }

    @IBAction func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            startDrag(gesture)
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            endDrag()
        default:
            break
        }
    }
    
    @IBAction func handlePan(gesture: PanAndStopGestureRecognizer) {
        if gesture.state == .Began || gesture.state == .Changed {
            if let dragState = currentDragState {
                let translation = gesture.translationInView(collectionView)
                
                // TODO: I don't think this is right yet... Re-check this math, do we really need both originalCenter and addTranslation
                // saved too?
                dragState.dragProxyView.center = CGPoint(x: dragState.originalCenter.x + translation.x + dragState.addTranslation.x,
                    y: dragState.originalCenter.y + translation.y + dragState.addTranslation.y)
            }
        }
    }
    
    func panGestureStopped(location: CGPoint) {
        if let dropIndexPath = collectionView.indexPathForItemAtPoint(location) {
            if let dropCell = collectionView.cellForItemAtIndexPath(dropIndexPath) as? SwiftBoardCell {
                let cellLocation = collectionView.convertPoint(location, toView: dropCell)
                
                if dropCell.pointInsideIcon(cellLocation) {
                    currentDragState!.setDropIndexPath(nil)
                    
                    if let folderCell = dropCell as? FolderCollectionViewCell {
                        // Something like:
                        /*
                        dataSource.items.removeAtIndex(currentDragState!.dragIndexPath.item)
                        collectionView.deleteItemsAtIndexPaths([currentDragState!.dragIndexPath])
                        regularLayout.hideIndexPath = nil
                        */

                        currentZoomState = ZoomState(indexPath: dropIndexPath, collectionView: folderCell.collectionView)
                        zoomFolder()
                    }
                } else if cellLocation.x < (dropCell.bounds.width / 2) {
                    let newPath = regularLayout.indexPathToMoveSourceIndexPathLeftOfDestIndexPath(currentDragState!.dragIndexPath, destIndexPath: dropIndexPath)
                    currentDragState!.setDropIndexPath(newPath)
                    moveCells()
                } else {
                    let newPath = regularLayout.indexPathToMoveSourceIndexPathRightOfDestIndexPath(currentDragState!.dragIndexPath, destIndexPath: dropIndexPath)
                    currentDragState!.setDropIndexPath(newPath)
                    moveCells()
                }
            }
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return true
        case panAndStopGestureRecognizer:
            return true //currentDragState != nil
        default:
            return false
        }
    }
    
    func gestureRecognizer(gesture: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return otherGesture === panAndStopGestureRecognizer
        case panAndStopGestureRecognizer:
            return otherGesture === longPressRecognizer
        default:
            return false
        }
    }
}














