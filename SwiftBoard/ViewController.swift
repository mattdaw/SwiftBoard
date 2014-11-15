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
    
    var viewModel: SwiftBoardViewModel
    
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
    let folderViewModel: FolderViewModel
}

private struct GestureInfo {
    let collectionView: UICollectionView
    let collectionViewCell: UICollectionViewCell
    let indexPath: NSIndexPath
    let viewModel: SwiftBoardViewModel
    let locationInCollectionView: CGPoint
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var rootCollectionView: UICollectionView!
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    var rootViewModel: RootViewModel?
    var rootDataSource: RootDataSource?
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
        
        // TODO: Move to AppDelegate and pass in
        seedViewModel()
        
        rootDataSource = RootDataSource(rootViewModel: rootViewModel!)
        rootCollectionView.dataSource = rootDataSource
        rootCollectionView.delegate = rootDataSource
        
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
    
    func seedViewModel() {
        var viewModels: [SwiftBoardViewModel] = [
            AppViewModel(name: "App 1", color: UIColor.greenColor()),
            AppViewModel(name: "App 2", color: UIColor.blueColor()),
            FolderViewModel(name: "Folder 1", appViewModels: [
                AppViewModel(name: "App 5", color: UIColor.purpleColor()),
                AppViewModel(name: "App 6", color: UIColor.grayColor()),
                AppViewModel(name: "App 7", color: UIColor.yellowColor()),
                AppViewModel(name: "App 8", color: UIColor.yellowColor()),
                AppViewModel(name: "App 9", color: UIColor.redColor()),
                AppViewModel(name: "App 10", color: UIColor.purpleColor()),
                AppViewModel(name: "App 11", color: UIColor.blueColor()),
                ]),
            FolderViewModel(name: "Folder 2", appViewModels: [
                AppViewModel(name: "App 4", color: UIColor.darkGrayColor())
                ]),
            AppViewModel(name: "App 3", color: UIColor.redColor()),
            AppViewModel(name: "App 20", color: UIColor.redColor()),
            AppViewModel(name: "App 21", color: UIColor.redColor()),
            AppViewModel(name: "App 22", color: UIColor.redColor()),
            AppViewModel(name: "App 23", color: UIColor.redColor()),
            AppViewModel(name: "App 24", color: UIColor.redColor())
        ]
        
        rootViewModel = RootViewModel(viewModels: viewModels)
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
        if let gestureInfo = infoForGesture(gesture) {
            let cell = gestureInfo.collectionViewCell
            let indexPath = gestureInfo.indexPath
            
            let dragProxyView = cell.snapshotViewAfterScreenUpdates(true)
            dragProxyView.frame = rootCollectionView.convertRect(cell.frame, fromView: cell.superview)
            rootCollectionView.addSubview(dragProxyView)
            
            let startLocation = gesture.locationInView(rootCollectionView)
            let originalCenter = dragProxyView.center
            let addTranslation = CGPoint(x: startLocation.x - originalCenter.x, y: startLocation.y - originalCenter.y)
            
            currentDragState = DragState(originalCenter:originalCenter,
                addTranslation:addTranslation,
                dragProxyView:dragProxyView,
                viewModel:gestureInfo.viewModel,
                dragIndexPath:indexPath,
                dropIndexPath:indexPath)
            
            UIView.animateWithDuration(0.2) {
                dragProxyView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                dragProxyView.alpha = 0.8
            }
            
            gestureInfo.viewModel.dragging = true
        }
    }
    
    private func endDrag(gestureInfo: GestureInfo) {
        let collectionView = gestureInfo.collectionView
        
        if let dragState = currentDragState {
            if let cell = collectionView.cellForItemAtIndexPath(dragState.dropIndexPath) {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                        dragState.dragProxyView.frame = self.rootCollectionView.convertRect(cell.frame, fromView:collectionView)
                        dragState.dragProxyView.transform = CGAffineTransformIdentity
                        dragState.dragProxyView.alpha = 1
                    }, completion: { (Bool) -> Void in
                        dragState.viewModel.dragging = false
                    
                        dragState.dragProxyView.removeFromSuperview()
                        self.currentDragState = nil
                })
            }
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
        /*
        if rootCollectionView.collectionViewLayout === regularLayout {
            let point = recognizer.locationInView(rootCollectionView)
            
            if let indexPath = rootCollectionView.indexPathForItemAtPoint(point) {
                let viewModel: AnyObject = items[indexPath.item]
                
                if let folder = item as? Folder {
                    if let folderCell = rootCollectionView.cellForItemAtIndexPath(indexPath) as? FolderCollectionViewCell {
                        if let folderViewModel = rootViewModel!.childAtIndex(Int(indexPath.item)) as? FolderViewModel {
                            currentZoomState = ZoomState(indexPath:indexPath, collectionView:folderCell.collectionView, folderViewModel: folderViewModel)
                            zoomFolder()
                            return
                        }
                    }
                }
            }
        }
        
        currentZoomState = nil
        rootCollectionView.setCollectionViewLayout(regularLayout, animated: true)
        */
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
        if let gestureInfo = infoForGesture(gesture) {
            let collectionView = gestureInfo.collectionView
            let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
            let dropCell = gestureInfo.collectionViewCell as SwiftBoardCell
            let dropIndexPath = gestureInfo.indexPath
            let location = gestureInfo.locationInCollectionView
            
            dropOperation = {
                self.endDrag(gestureInfo)
            }
                
            let locationInCell = collectionView.convertPoint(location, toView: dropCell)
            
            if dropCell.pointInsideIcon(locationInCell) {
                /*
                if let folderCell = dropCell as? FolderCollectionViewCell {
                    let dragIndexPath = currentDragState!.dragIndexPath
                    
                    folderCell.expand()
                    dropOperation = {
                        self.dropAppOnFolder(dragIndexPath, folderIndexPath: dropIndexPath, folderCell: folderCell)
                    }
                }
                */
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
    
    func collectionViewForGesture(gesture:UIGestureRecognizer) -> UICollectionView {
        if let zoomState = currentZoomState {
            return zoomState.collectionView
        } else {
            return rootCollectionView
        }
    }
    
    private func infoForGesture(gesture:UIGestureRecognizer) -> GestureInfo? {
        var collectionView: UICollectionView
        var folderViewModel: FolderViewModel?
        var viewModel: SwiftBoardViewModel
        
        if let zoomState = currentZoomState {
            collectionView = zoomState.collectionView
            folderViewModel = zoomState.folderViewModel
        } else {
            collectionView = rootCollectionView
        }
        
        let location = gesture.locationInView(collectionView)
        
        if let indexPath = collectionView.indexPathForItemAtPoint(location) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? SwiftBoardCell {
                if folderViewModel != nil {
                    viewModel = folderViewModel!.appViewModelAtIndex(indexPath.item)
                } else {
                    viewModel = rootViewModel!.childAtIndex(indexPath.item)
                }
                
                return GestureInfo(collectionView: collectionView, collectionViewCell: cell, indexPath: indexPath, viewModel: viewModel, locationInCollectionView: location)
            }
        }
            
        return nil;
    }
    
    func reorderCells(collectionView:UICollectionView) {
        if let dragState = currentDragState {
            if dragState.dragIndexPath == dragState.dropIndexPath {
                return
            }
            
            if let zoomState = currentZoomState {
                zoomState.folderViewModel.moveAppAtIndex(dragState.dragIndexPath.item, toIndex: dragState.dropIndexPath.item)
            } else {
                rootViewModel!.moveItemAtIndex(dragState.dragIndexPath.item, toIndex: dragState.dropIndexPath.item)
            }
            
            // Update collection view
            collectionView.performBatchUpdates({ () -> Void in
                collectionView.moveItemAtIndexPath(dragState.dragIndexPath, toIndexPath:dragState.dropIndexPath)
            }, completion: nil)
            
            
            // Update drag state
            currentDragState!.setDragIndexPath(dragState.dropIndexPath)
        }
    }
    
    func dropAppOnFolder(appIndexPath: NSIndexPath, folderIndexPath: NSIndexPath, folderCell: FolderCollectionViewCell) {
        /*
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
        */
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return true
        case panAndStopGestureRecognizer:
            return currentDragState != nil
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














