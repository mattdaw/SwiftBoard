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
    var dropIndexPath: NSIndexPath
    
    mutating func setDragIndexPath(indexPath:NSIndexPath) {
        dragIndexPath = indexPath
    }
    
    mutating func setDropIndexPath(indexPath:NSIndexPath) {
        dropIndexPath = indexPath
    }
}

private struct ZoomState {
    let indexPath: NSIndexPath
    let collectionView: UICollectionView
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var rootCollectionView: UICollectionView!
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    var items: NSMutableArray = []
    var dataSource:CollectionViewDataSource = CollectionViewDataSource()
    var zoomedLayout = CollectionViewLayout()
    var regularLayout = CollectionViewLayout()
    
    private var currentDragState: DragState?
    private var currentZoomState: ZoomState?
    private var dropOperation: (() -> ())?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seedData()
        
        dataSource.items = items
        rootCollectionView.dataSource = dataSource
        rootCollectionView.delegate = dataSource
        
        rootCollectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        rootCollectionView.registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        rootCollectionView.backgroundColor = UIColor.clearColor()
        rootCollectionView.setCollectionViewLayout(regularLayout, animated: false)
        rootCollectionView.scrollEnabled = false
        
        panAndStopGestureRecognizer = PanAndStopGestureRecognizer(target: self, action: "handlePan:", stopAfterSecondsWithoutMovement: 0.2) {
            (gesture:UIPanGestureRecognizer) in self.panGestureStopped(gesture)
        }
        rootCollectionView.addGestureRecognizer(panAndStopGestureRecognizer)
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
            App(name: "App 24", color: UIColor.redColor())
        ]
    }
    
    // Not sure this is right, but try to get the layout to assume its new size early so that in the animated rotation we don't
    // see neighbour items animating off-screen.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if let layout = rootCollectionView.collectionViewLayout as? CollectionViewLayout {
            layout.overrideSize = size
            rootCollectionView.reloadData()
        }
    }
    
    func startDrag(gesture:UIGestureRecognizer) {
        let collectionView = collectionViewForGesture(gesture)
        let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
        let location = gesture.locationInView(collectionView)
        
        if let indexPath = collectionView.indexPathForItemAtPoint(location) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                let dragProxyView = cell.snapshotViewAfterScreenUpdates(true)
                dragProxyView.frame = rootCollectionView.convertRect(cell.frame, fromView: cell.superview)
                rootCollectionView.addSubview(dragProxyView)
                
                let startLocation = gesture.locationInView(rootCollectionView)
                let originalCenter = dragProxyView.center
                let addTranslation = CGPoint(x: startLocation.x - originalCenter.x, y: startLocation.y - originalCenter.y)
                
                currentDragState = DragState(originalCenter:originalCenter,
                    addTranslation:addTranslation,
                    dragProxyView:dragProxyView,
                    dragIndexPath:indexPath,
                    dropIndexPath:indexPath)
                
                UIView.animateWithDuration(0.2) {
                    dragProxyView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                    dragProxyView.alpha = 0.8
                }
                
                //layout.editingModeEnabled = true
                layout.hideIndexPath = indexPath
                layout.invalidateLayout()
            }
        }
    }
    
    func endDrag(collectionView:UICollectionView) {
        let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
        
        if let dragState = currentDragState {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                    let attrs = layout.layoutAttributesForItemAtIndexPath(dragState.dropIndexPath)
                
                    dragState.dragProxyView.frame = self.rootCollectionView.convertRect(attrs.frame, fromView:collectionView)
                    dragState.dragProxyView.transform = CGAffineTransformIdentity
                    dragState.dragProxyView.alpha = 1
                }, completion: { (Bool) -> Void in
                    layout.hideIndexPath = nil
                    layout.invalidateLayout()
                    
                    dragState.dragProxyView.removeFromSuperview()
                    self.currentDragState = nil
                })
        }
    }

    func zoomFolder() {
        if let zoomState = currentZoomState {
            zoomedLayout.zoomToIndexPath = zoomState.indexPath
            rootCollectionView.setCollectionViewLayout(zoomedLayout, animated: true)
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
        if rootCollectionView.collectionViewLayout === regularLayout {
            let point = recognizer.locationInView(rootCollectionView)
            
            if let indexPath = rootCollectionView.indexPathForItemAtPoint(point) {
                let item: AnyObject = items[indexPath.item]
                
                if let folder = item as? Folder {
                    if let folderCell = rootCollectionView.cellForItemAtIndexPath(indexPath) as? FolderCollectionViewCell {
                        currentZoomState = ZoomState(indexPath:indexPath, collectionView:folderCell.collectionView)
                        zoomFolder()
                        return
                    }
                }
            }
        }
        
        currentZoomState = nil
        rootCollectionView.setCollectionViewLayout(regularLayout, animated: true)
    }

    @IBAction func handleLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            startDrag(gesture)
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            if let dropBlock = dropOperation {
                dropBlock()
            }
        default:
            break
        }
    }
    
    @IBAction func handlePan(gesture: PanAndStopGestureRecognizer) {
        if gesture.state == .Began || gesture.state == .Changed {
            if let dragState = currentDragState {
                let translation = gesture.translationInView(rootCollectionView)
                
                // TODO: I don't think this is right yet... Re-check this math, do we really need both originalCenter and addTranslation
                // saved too?
                dragState.dragProxyView.center = CGPoint(x: dragState.originalCenter.x + translation.x + dragState.addTranslation.x,
                    y: dragState.originalCenter.y + translation.y + dragState.addTranslation.y)
            }
        }
    }
    
    func panGestureStopped(gesture: UIPanGestureRecognizer) {
        let collectionView = collectionViewForGesture(gesture)
        let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
        let location = gesture.locationInView(collectionView)
        
        dropOperation = {
            self.endDrag(collectionView)
        }
        
        if let dropIndexPath = collectionView.indexPathForItemAtPoint(location) {
            if let dropCell = collectionView.cellForItemAtIndexPath(dropIndexPath) as? SwiftBoardCell {
                let locationInCell = collectionView.convertPoint(location, toView: dropCell)
                
                if dropCell.pointInsideIcon(locationInCell) {
                    if let folderCell = dropCell as? FolderCollectionViewCell {
                        let dragIndexPath = currentDragState!.dragIndexPath
                        
                        folderCell.expand()
                        dropOperation = {
                            self.dropAppOnFolder(dragIndexPath, folderIndexPath: dropIndexPath, folderCell: folderCell)
                        }
                    }
                } else if locationInCell.x < (dropCell.bounds.width / 2) {
                    let newPath = layout.indexPathToMoveSourceIndexPathLeftOfDestIndexPath(currentDragState!.dragIndexPath, destIndexPath: dropIndexPath)
                    currentDragState?.setDropIndexPath(newPath)
                    reorderCells(collectionView)
                } else {
                    let newPath = layout.indexPathToMoveSourceIndexPathRightOfDestIndexPath(currentDragState!.dragIndexPath, destIndexPath: dropIndexPath)
                    currentDragState?.setDropIndexPath(newPath)
                    reorderCells(collectionView)
                }
            }
        }
    }
    
    func collectionViewForGesture(gesture:UIGestureRecognizer) -> UICollectionView {
        if let zoomState = currentZoomState {
            return zoomState.collectionView
        } else {
            return rootCollectionView
        }
    }
    
    func reorderCells(collectionView:UICollectionView) {
        if let dragState = currentDragState {
            if dragState.dragIndexPath == dragState.dropIndexPath {
                return
            }
            
            // Update data source
            let dataSource = collectionView.dataSource as CollectionViewDataSource
            let dataItems = dataSource.items
            let originalIndexPath = dragState.dragIndexPath
            
            var item: AnyObject = dataItems[originalIndexPath.item]
            dataItems.removeObjectAtIndex(originalIndexPath.item)
            
            if dragState.dropIndexPath.item >= dataItems.count {
                dataItems.addObject(item)
            } else {
                dataItems.insertObject(item, atIndex: dragState.dropIndexPath.item)
            }
            
            // Update collection view
            let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
            layout.hideIndexPath = dragState.dropIndexPath
            
            collectionView.performBatchUpdates({ () -> Void in
                    collectionView.moveItemAtIndexPath(dragState.dragIndexPath, toIndexPath:dragState.dropIndexPath)
                }, completion: nil)
            
            // Update drag state
            currentDragState!.setDragIndexPath(dragState.dropIndexPath)
        }
    }
    
    func dropAppOnFolder(appIndexPath: NSIndexPath, folderIndexPath: NSIndexPath, folderCell: FolderCollectionViewCell) {
        var folder: Folder = items.objectAtIndex(folderIndexPath.item) as Folder
        var app: AnyObject = items.objectAtIndex(appIndexPath.item)
        
        // Update root data source
        items.removeObjectAtIndex(appIndexPath.item)
        
        // Update folder's data source
        folder.apps.addObject(app)
        
        // Update root collection view
        let rootLayout = rootCollectionView.collectionViewLayout as DroppableCollectionViewLayout
        rootLayout.hideIndexPath = nil
        
        rootCollectionView.performBatchUpdates({ () -> Void in
                self.rootCollectionView.deleteItemsAtIndexPaths([appIndexPath])
            }, completion: nil)
        
        // Update folder's collection view
        let newIndexPath = NSIndexPath(forItem: folder.apps.count - 1, inSection: 0)
        let folderCollectionView = folderCell.collectionView
        let folderLayout = folderCollectionView.collectionViewLayout as DroppableCollectionViewLayout
        
        folderCollectionView.performBatchUpdates({ () -> Void in
            folderCell.collapse()
            folderCollectionView.insertItemsAtIndexPaths([newIndexPath])
        }, completion: nil)
        
        // Update drag state - not right, temp
        currentDragState!.dragProxyView.removeFromSuperview()
        currentDragState = nil
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














