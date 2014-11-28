//
//  RootCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

struct DragProxyState {
    let view: UIView
    let originalCenter: CGPoint
}

class RootCollectionView: ListViewModelCollectionView, UIGestureRecognizerDelegate, ListViewModelDelegate, RootViewModelDelegate {
    private var listDataSource: ListViewModelDataSource?
    private var regularLayout = CollectionViewLayout()
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    private var openFolderCollectionView: FolderCollectionView?
    private var dragProxyState: DragProxyState?
    private var draggingItemViewModel: ItemViewModel?

    private var lastCollectionView: UICollectionView?
    private var dragAndDropOperation: DragAndDropOperation?
    private var cancelDragAndDropOperationWhenExitsRect: CGRect?
    
    var rootViewModel: RootViewModel? {
        didSet {
            if rootViewModel != nil {
                rootViewModel!.listViewModelDelegate = self
                rootViewModel!.rootViewModelDelegate = self
                
                listDataSource = ListViewModelDataSource(rootViewModel!)
                dataSource = listDataSource
                delegate = listDataSource
            }
        }
    }
    
    override var listViewModel: ListViewModel? {
        return rootViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        backgroundColor = UIColor.clearColor()
        scrollEnabled = false
        setCollectionViewLayout(regularLayout, animated: false)
        
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        addGestureRecognizer(tapGestureRecognizer)
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
        
        panAndStopGestureRecognizer = PanAndStopGestureRecognizer(target: self, action: "handlePanGesture:", stopAfterSecondsWithoutMovement: 0.2) {
            (gesture:PanAndStopGestureRecognizer) in self.handlePanGestureStopped(gesture)
        }
        panAndStopGestureRecognizer.delegate = self
        addGestureRecognizer(panAndStopGestureRecognizer)
    }

    func handleTapGesture(gesture: UITapGestureRecognizer) {
        let gestureHit = gestureHitForGesture(gesture)
        
        if let folderHit = gestureHit as? FolderGestureHit {
            rootViewModel?.openFolder(folderHit.folderViewModel)
        } else if let viewHit = gestureHit as? CollectionViewGestureHit {
            if openFolderCollectionView != nil {
                rootViewModel?.closeFolder(openFolderCollectionView!.folderViewModel!)
            }
        }
    }
    
    func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            startDrag(gesture)
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            endDrag(gesture)
        default:
            break
        }
    }
    
    func handlePanGesture(gesture: PanAndStopGestureRecognizer) {
        if gesture.state == .Began || gesture.state == .Changed {
            updateDragProxyPosition(gesture)
            dragAppOutOfFolder(gesture)
            cancelDragAndDropOperationIfExitsRect(gesture)
        }
    }
    
    func handlePanGestureStopped(gesture: PanAndStopGestureRecognizer) {
        // Don't start a new operation if one is already in progress.
        if dragAndDropOperation != nil {
            return
        }

        if let dragOp = dragOperationForGesture(gesture) {
            dragOp.dragStart()
            
            if let dropOp = dragOp as? DragAndDropOperation {
                dragAndDropOperation = dropOp
            }
        }
    }
    
    func collectionViewForGesture(gesture: UIGestureRecognizer) -> ListViewModelCollectionView {
        var destCollectionView: ListViewModelCollectionView = self
        if let folderCollectionView = openFolderCollectionView {
            if folderCollectionView.pointInside(gesture.locationInView(folderCollectionView), withEvent: nil) {
                destCollectionView = folderCollectionView
            }
        }
        
        return destCollectionView
    }
    
    func gestureHitForGesture(gesture: UIGestureRecognizer) -> GestureHit {
        let destCollectionView = collectionViewForGesture(gesture)
        let locationInCollectionView = gesture.locationInView(destCollectionView)
        let collectionViewHit = CollectionViewGestureHit(collectionView: destCollectionView, locationInCollectionView: locationInCollectionView)
        
        if let indexPath = destCollectionView.indexPathForItemAtPoint(locationInCollectionView) {
            if let cell = destCollectionView.cellForItemAtIndexPath(indexPath) as? SwiftBoardCell {
                if let listViewModel = destCollectionView.listViewModel {
                    let itemViewModel = listViewModel.itemAtIndex(indexPath.item)
                    let locationInCell = destCollectionView.convertPoint(locationInCollectionView, toView: cell)
                    
                    if let appViewModel = itemViewModel as? AppViewModel {
                        return AppGestureHit(collectionViewHit: collectionViewHit,
                                             cell: cell,
                                             locationInCell: locationInCell,
                                             appViewModel: appViewModel)
                    } else if let folderViewModel = itemViewModel as? FolderViewModel {
                        return FolderGestureHit(collectionViewHit: collectionViewHit,
                                                cell: cell,
                                                locationInCell: locationInCell,
                                                folderViewModel: folderViewModel)
                    }
                }
            }
        }
        
        return collectionViewHit
    }
    
    func dragOperationForGesture(gesture: UIGestureRecognizer) -> DragOperation? {
        let gestureHit = gestureHitForGesture(gesture)
        
        if let dragOperation = dragOperationForAppOnFolder(gestureHit) {
            return dragOperation
        }
        
        if let dragOperation = dragOperationForMoveItem(gestureHit) {
            return dragOperation
        }
        
        // TODO: Handle dragging an app on top of an app, creating a folder.
        
        return nil
    }
    
    func dragOperationForAppOnFolder(gestureHit: GestureHit) -> DragOperation? {
        if let appViewModel = draggingItemViewModel as? AppViewModel {
            if let folderHit = gestureHit as? FolderGestureHit {
                if let iconRect = folderHit.cell.iconRect() {
                    if CGRectContainsPoint(iconRect, folderHit.locationInCell) {
                        cancelDragAndDropOperationWhenExitsRect = convertRect(iconRect, fromView: folderHit.cell)
                        return MoveAppToFolder(rootViewModel: rootViewModel!, appViewModel: appViewModel, folderViewModel: folderHit.folderViewModel)
                    }
                }
            }
        }
        
        return nil
    }
    
    func dragOperationForMoveItem(gestureHit: GestureHit) -> DragOperation? {
        if let itemViewModel = draggingItemViewModel {
            if let listViewModel = itemViewModel.listViewModel {
                if let cellHit = gestureHit as? CellGestureHit {
                    if itemViewModel === cellHit.itemViewModel {
                        return nil
                    }
                    
                    let layout = cellHit.collectionViewHit.collectionView.collectionViewLayout as DroppableCollectionViewLayout
                    var dragIndex = listViewModel.indexOfItem(itemViewModel)
                    var dropIndex = listViewModel.indexOfItem(cellHit.itemViewModel)
                    var newIndex: Int
                    
                    if dragIndex != nil && dropIndex != nil {
                        if cellHit.locationInCell.x < (cellHit.cell.bounds.width / 2) {
                            newIndex = layout.indexToMoveSourceIndexLeftOfDestIndex(dragIndex!, destIndex: dropIndex!)
                        } else {
                            newIndex = layout.indexToMoveSourceIndexRightOfDestIndex(dragIndex!, destIndex: dropIndex!)
                        }
                        
                        return MoveItemInList(listViewModel: listViewModel, fromIndex: dragIndex!, toIndex: newIndex)
                    }
                }
            }
        }

        return nil
    }
    
    private func startDrag(gesture: UIGestureRecognizer) {
        if let cellHit = gestureHitForGesture(gesture) as? CellGestureHit {
            let cell = cellHit.cell
            
            let dragProxyView = cell.snapshotViewAfterScreenUpdates(true)
            dragProxyView.frame = convertRect(cell.frame, fromView: cell.superview)
            addSubview(dragProxyView)
            
            dragProxyState = DragProxyState(view: dragProxyView, originalCenter: dragProxyView.center)
            UIView.animateWithDuration(0.2) {
                dragProxyView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                dragProxyView.alpha = 0.9
            }
            
            draggingItemViewModel = cellHit.itemViewModel
            draggingItemViewModel!.dragging = true
        }
    }
    
    private func endDrag(gesture: UIGestureRecognizer) {
        dragAndDropOperation?.drop()
        dragAndDropOperation = nil
        
        if let proxyState = dragProxyState {
            if let returnToCenter = dragProxyReturnToCenter() {
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    proxyState.view.transform = CGAffineTransformIdentity
                    proxyState.view.alpha = 1
                    proxyState.view.center = returnToCenter
                }, completion: { (Bool) -> Void in
                    self.resetDrag()
                })
            } else {
                resetDrag()
            }
        }
    }
    
    private func resetDrag() {
        if let itemViewModel = draggingItemViewModel {
            itemViewModel.dragging = false
            
            if let proxyState = dragProxyState {
                proxyState.view.removeFromSuperview()
            }
        
            draggingItemViewModel = nil
        }
    }
    
    private func updateDragProxyPosition(gesture: UIPanGestureRecognizer) {
        if let proxyState = dragProxyState {
            let translation = gesture.translationInView(self)
            dragProxyState!.view.center = CGPoint(x: proxyState.originalCenter.x + translation.x, y: proxyState.originalCenter.y + translation.y)
        }
    }
    
    private func dragAppOutOfFolder(gesture: UIPanGestureRecognizer) {
        let gestureCollectionView = collectionViewForGesture(gesture)
        
        if lastCollectionView != nil && lastCollectionView === openFolderCollectionView && lastCollectionView !== gestureCollectionView {
            if let folderViewModel = openFolderCollectionView?.folderViewModel {
                if let appViewModel = draggingItemViewModel as? AppViewModel {
                    rootViewModel?.closeFolder(folderViewModel)
                    rootViewModel?.moveAppFromFolder(appViewModel, folderViewModel: folderViewModel)
                }
            }
        }
        
        lastCollectionView = gestureCollectionView
    }
    
    private func cancelDragAndDropOperationIfExitsRect(gesture: UIPanGestureRecognizer) {
        if let dragOp = dragAndDropOperation {
            if let exitRect = cancelDragAndDropOperationWhenExitsRect {
                let location = gesture.locationInView(self)
                
                if !CGRectContainsPoint(exitRect, location) {
                    dragOp.dragCancel()
                    dragAndDropOperation = nil
                }
            }
        }
    }
    
    private func dragProxyReturnToCenter() -> CGPoint? {
        var cell: UICollectionViewCell?
        
        if let itemViewModel = draggingItemViewModel {
            if let rootViewModel = itemViewModel.listViewModel as? RootViewModel {
                if let index = rootViewModel.indexOfItem(itemViewModel) {
                    cell = cellForItemAtIndexPath(index.toIndexPath())
                }
            } else if let folderViewModel = itemViewModel.listViewModel as? FolderViewModel {
                if let indexOfFolder = rootViewModel?.indexOfItem(folderViewModel) {
                    if let folderCell = cellForItemAtIndexPath(indexOfFolder.toIndexPath()) as? FolderCollectionViewCell {
                        if let indexOfItem = itemViewModel.listViewModel?.indexOfItem(itemViewModel) {
                            cell = folderCell.collectionView.cellForItemAtIndexPath(indexOfItem.toIndexPath())
                        }
                    }
                }
                
            }
        }
        
        if cell != nil {
            return convertPoint(cell!.center, fromView: cell!.superview)
        }
        
        return nil
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        switch gesture {
        case longPressRecognizer:
            return true
        case panAndStopGestureRecognizer:
            return draggingItemViewModel != nil
        default:
            return super.gestureRecognizerShouldBegin(gesture)
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
    
    // MARK: RootViewModelDelegate
    
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel) {
        // Opening a folder terminates the current drag operation
        dragAndDropOperation = nil
        
        if let index = rootViewModel?.indexOfItem(folderViewModel) {
            if let cell = cellForItemAtIndexPath(index.toIndexPath()) as? FolderCollectionViewCell {
                openFolderCollectionView = cell.collectionView
                
                let zoomedLayout = CollectionViewLayout()
                zoomedLayout.zoomToIndex = index
                
                setCollectionViewLayout(zoomedLayout, animated: true)
            }
        }
    }
    
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel) {
        // Closing a folder terminates the current drag operation
        dragAndDropOperation = nil
        
        if let index = rootViewModel?.indexOfItem(folderViewModel) {
            openFolderCollectionView = nil
            setCollectionViewLayout(regularLayout, animated: true)
        }
    }
}
