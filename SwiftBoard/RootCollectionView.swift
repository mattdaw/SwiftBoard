//
//  RootCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

protocol GestureHit {}

class CollectionViewGestureHit: GestureHit {
    let collectionView: UICollectionView
    let locationInCollectionView: CGPoint
    
    init(collectionView initCollectionView: UICollectionView, locationInCollectionView initViewLocation: CGPoint) {
        collectionView = initCollectionView
        locationInCollectionView = initViewLocation
    }
}

class CellGestureHit: GestureHit {
    let collectionViewHit: CollectionViewGestureHit
    let cell: SwiftBoardCell
    let locationInCell: CGPoint
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: SwiftBoardCell, locationInCell initCellLocation: CGPoint) {
        collectionViewHit = initHit
        cell = initCell
        locationInCell = initCellLocation
    }
}

class AppGestureHit: CellGestureHit, GestureHit {
    let appViewModel: AppViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: SwiftBoardCell, locationInCell initCellLocation: CGPoint, appViewModel initApp: AppViewModel) {
        appViewModel = initApp
        super.init(collectionViewHit: initHit, cell: initCell, locationInCell: initCellLocation)
    }
}

class FolderGestureHit: CellGestureHit, GestureHit {
    let folderViewModel: FolderViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: SwiftBoardCell, locationInCell initCellLocation: CGPoint, folderViewModel initFolder: FolderViewModel) {
        folderViewModel = initFolder
        super.init(collectionViewHit: initHit, cell: initCell, locationInCell: initCellLocation)
    }
}

struct DropState {
    let index: Int
    let cell: SwiftBoardCell
}

struct DragProxyState {
    let view: UIView
    let originalCenter: CGPoint
}

class RootCollectionView: SwiftBoardCollectionView, UIGestureRecognizerDelegate, SwiftBoardListViewModelDelegate, RootViewModelDelegate {
    private var listDataSource: SwiftBoardListViewModelDataSource?
    private var zoomedLayout = CollectionViewLayout()
    private var regularLayout = CollectionViewLayout()
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    private var openFolderCollectionView: FolderCollectionView?
    private var dragProxyState: DragProxyState?
    private var dragProxyReturnToRect: CGRect?
    private var draggingItemViewModel: SwiftBoardItemViewModel?
    private var currentDropState: DropState?
    
    private var dragAndDropOperation: DragAndDropOperation?
    private var dropOperation: (() -> ())?
    
    var rootViewModel: RootViewModel? {
        didSet {
            if rootViewModel != nil {
                rootViewModel!.listViewModelDelegate = self
                rootViewModel!.rootViewModelDelegate = self
                
                listDataSource = SwiftBoardListViewModelDataSource(rootViewModel!)
                dataSource = listDataSource
                delegate = listDataSource
            }
        }
    }
    
    override var listViewModel: SwiftBoardListViewModel? {
        return rootViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
        registerNib(UINib(nibName: "FolderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Folder")
        
        backgroundColor = UIColor.clearColor()
        scrollEnabled = false
        setCollectionViewLayout(regularLayout, animated: false)
        
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
    
    func viewModelAtIndexPath(indexPath: NSIndexPath) -> SwiftBoardItemViewModel? {
        return nil
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
            if let dragAndDropOp = dragAndDropOperation {
                dragAndDropOp.drop()
            }
            
            endDrag()
        default:
            break
        }
    }
    
    func handlePanGesture(gesture: PanAndStopGestureRecognizer) {
        if gesture.state == .Began || gesture.state == .Changed {
            if dragProxyState != nil {
                let translation = gesture.translationInView(self)
                dragProxyState!.view.center = CGPoint(x: dragProxyState!.originalCenter.x + translation.x,
                    y: dragProxyState!.originalCenter.y + translation.y)
            }
        }
    }
    
    func handlePanGestureStopped(gesture: PanAndStopGestureRecognizer) {
        if let dragAndDropOp = dragAndDropOperationForGesture(gesture) {
            dragAndDropOperation = dragAndDropOp
            dragAndDropOperation!.drag()
        }
    }
    
    /*
    func handlePanGestureStopped(gesture: PanAndStopGestureRecognizer) {
        // Idea -> classes for gesture "hits", different for hit on folder, app, collection view.
        // Then something like "drop operation for" drag hit + drop hit
        //
        // How should the two states be differentiated? Is this a hover vs a drop?
        if let gestureInfo = infoForGesture(gesture) {
            let collectionView = gestureInfo.collectionView
            let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
            let dropCell = gestureInfo.cell
            // EW, but temp
            let dragIndex = draggingItemViewModel!.listViewModel!.indexOfItem(draggingItemViewModel!)
            let dropIndex = gestureInfo.itemIndexInList
            let location = gestureInfo.locationInCollectionView
            let locationInCell = gestureInfo.locationInCell
            
            currentDropState = DropState(index: dropIndex, cell: dropCell)
            
            if draggingItemViewModel is AppViewModel && dropCell.pointInsideIcon(locationInCell) && dropCell is FolderCollectionViewCell {
                if let folderViewModel = gestureInfo.itemViewModel as? FolderViewModel {
                    if let appViewModel = draggingItemViewModel as? AppViewModel {
                        rootViewModel?.appDragEnter(appViewModel, folderViewModel: folderViewModel)
                        
                        dropOperation = {
                            self.rootViewModel?.appDragDrop()
                            self.endDrag()
                        }
                    }
                }
            } else if dragIndex != dropIndex {
                // Drag: App -> Drop: Cell? It's not really "on" the app/folder
                var newIndex: Int
                
                if locationInCell.x < (dropCell.bounds.width / 2) {
                    newIndex = layout.indexToMoveSourceIndexLeftOfDestIndex(dragIndex!, destIndex: dropIndex)
                } else {
                    newIndex = layout.indexToMoveSourceIndexRightOfDestIndex(dragIndex!, destIndex: dropIndex)
                }
                
                draggingItemViewModel!.listViewModel!.moveItemAtIndex(dragIndex!, toIndex: newIndex)
                
                if let newCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: newIndex, inSection: 0)) {
                    dragProxyReturnToRect = convertRect(newCell.frame, fromView: newCell.superview)
                }
            }
        } else {
            // Drag: App Inside Folder -> Drop: Root Collection View (outside its folders collection view)
            if openFolderCollectionView != nil {
                if let folderViewModel = openFolderCollectionView!.listViewModel as? FolderViewModel {
                    // "Promote to root"
                    if let appViewModel = draggingItemViewModel as? AppViewModel {
                        rootViewModel?.closeFolder(folderViewModel)
                        rootViewModel?.moveAppFromFolder(appViewModel, folderViewModel: folderViewModel)
                        
                        if let newIndex = rootViewModel?.indexOfItem(appViewModel) {
                            if let newCell = cellForItemAtIndexPath(NSIndexPath(forItem: newIndex, inSection: 0)) {
                                dragProxyReturnToRect = convertRect(newCell.frame, fromView: newCell.superview)
                            }
                        }
                    }
                }
            }
        }
    }
*/
    
    func gestureHitForGesture(gesture: UIGestureRecognizer) -> GestureHit {
        var destCollectionView: SwiftBoardCollectionView = self
        if let folderCollectionView = openFolderCollectionView {
            destCollectionView = folderCollectionView
        }
        
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
    
    func dragAndDropOperationForGesture(gesture: UIGestureRecognizer) -> DragAndDropOperation? {
        let gestureHit = gestureHitForGesture(gesture)
        
        if let appViewModel = draggingItemViewModel as? AppViewModel {
            if let folderHit = gestureHit as? FolderGestureHit {
                return DragAppOnFolder()
            }
        }
        
        return nil
    }
    
    func startDrag(gesture: UIGestureRecognizer) {
        if let cellHit = gestureHitForGesture(gesture) as? CellGestureHit {
            let cell = cellHit.cell
            
            let dragProxyView = cell.snapshotViewAfterScreenUpdates(true)
            dragProxyView.frame = convertRect(cell.frame, fromView: cell.superview)
            addSubview(dragProxyView)
            
            dragProxyState = DragProxyState(view: dragProxyView, originalCenter: dragProxyView.center)
            dragProxyReturnToRect = dragProxyView.frame
            UIView.animateWithDuration(0.2) {
                dragProxyView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                dragProxyView.alpha = 0.8
            }
            
            dropOperation = endDrag
            
            if let appHit = cellHit as? AppGestureHit {
                draggingItemViewModel = appHit.appViewModel
            } else if let folderHit = cellHit as? FolderGestureHit {
                draggingItemViewModel = folderHit.folderViewModel
            }
            
            draggingItemViewModel!.dragging = true
        }
    }
    
    private func endDrag() {
        if let proxyState = dragProxyState {
            if let returnToRect = dragProxyReturnToRect {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    proxyState.view.transform = CGAffineTransformIdentity
                    proxyState.view.alpha = 1
                    proxyState.view.frame = returnToRect
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
            currentDropState = nil
        }
    }
    
    private func moveAppIntoFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel, folderCell: FolderCollectionViewCell) {
        rootViewModel!.moveAppToFolder(appViewModel, folderViewModel: folderViewModel)
        
        if let newIndex = folderViewModel.indexOfItem(appViewModel) {
            let newIndexPath = NSIndexPath(forItem: newIndex, inSection: 0)
            if let newAppCell = folderCell.collectionView.cellForItemAtIndexPath(newIndexPath) {
                dragProxyReturnToRect = convertRect(newAppCell.frame, fromView: newAppCell.superview)
                //endDrag()
            }
        }
    }

    // MARK: RootViewModelDelegate
    
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel) {
        // ?
        dragAndDropOperation = nil
        
        if let index = rootViewModel?.indexOfItem(folderViewModel) {
            if let cell = cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? FolderCollectionViewCell {
                openFolderCollectionView = cell.collectionView
                zoomedLayout.zoomToIndex = index
                setCollectionViewLayout(zoomedLayout, animated: true)
            }
        }
    }
    
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel) {
        // ?
        dragAndDropOperation = nil
        
        if let index = rootViewModel?.indexOfItem(folderViewModel) {
            openFolderCollectionView = nil
            zoomedLayout.zoomToIndex = nil
            setCollectionViewLayout(regularLayout, animated: true)
        }
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

}
