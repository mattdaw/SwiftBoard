//
//  RootCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

struct GestureInfo {
    let listViewModel:SwiftBoardListViewModel
    let itemViewModel:SwiftBoardItemViewModel
    let itemIndexInList: Int
    
    let collectionView: UICollectionView
    let cell: SwiftBoardCell
    let locationInCollectionView: CGPoint
}

struct DragState {
    let gestureInfo: GestureInfo
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
    
    private var openFolderCollectionView: SwiftBoardCollectionView?
    private var dragProxyState: DragProxyState?
    private var currentDragState: DragState?
    
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
        if let gestureInfo = infoForGesture(gesture) {
            if let folderViewModel = gestureInfo.itemViewModel as? FolderViewModel {
                rootViewModel?.openFolder(folderViewModel)
            }
            
        } else if openFolderCollectionView != nil {
            if let folderViewModel = openFolderCollectionView!.listViewModel as? FolderViewModel {
                rootViewModel?.closeFolder(folderViewModel)
            }
        }
    }
    
    func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            startDrag(gesture)
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            if let dropFn = dropOperation {
                dropFn()
                dropOperation = nil
            }
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
        if let gestureInfo = infoForGesture(gesture) {
            let collectionView = gestureInfo.collectionView
            let layout = collectionView.collectionViewLayout as DroppableCollectionViewLayout
            let dropCell = gestureInfo.cell
            let dragIndex = currentDragState!.gestureInfo.itemIndexInList
            let dropIndex = gestureInfo.itemIndexInList
            let location = gestureInfo.locationInCollectionView
            
            let locationInCell = collectionView.convertPoint(location, toView: dropCell)
            
            dropOperation = { self.endDrag() }
            
            if dropCell.pointInsideIcon(locationInCell) && dropCell is FolderCollectionViewCell {
                if let appViewModel = currentDragState?.gestureInfo.itemViewModel as? AppViewModel {
                    if let folderViewModel = rootViewModel?.itemAtIndex(dropIndex) as? FolderViewModel {
                        dropOperation = {
                            self.rootViewModel!.moveAppToFolder(appViewModel, folderViewModel: folderViewModel)
                            appViewModel.dragging = false
                            
                            self.dragProxyState!.view.removeFromSuperview()
                            self.currentDragState = nil
                        }
                    }
                }
            } else if locationInCell.x < (dropCell.bounds.width / 2) {
                // TODO: Switch to asking the layout for the current number of rows... and move the fancy logic
                // inside the drag (or drop) operation?
                let newIndex = layout.indexToMoveSourceIndexLeftOfDestIndex(dragIndex, destIndex: dropIndex)
                currentDragState?.gestureInfo.listViewModel.moveItemAtIndex(dragIndex, toIndex: newIndex)
            } else {
                let newIndex = layout.indexToMoveSourceIndexRightOfDestIndex(dragIndex, destIndex: dropIndex)
                currentDragState?.gestureInfo.listViewModel.moveItemAtIndex(dragIndex, toIndex: newIndex)
            }
        }
    }
    
    // TODO: Not happy with "info", come up with a better name
    func infoForGesture(gesture: UIGestureRecognizer) -> GestureInfo? {
        var destCollectionView:SwiftBoardCollectionView
        var indexPath:NSIndexPath?
        
        if let folderCollectionView = openFolderCollectionView {
            destCollectionView = folderCollectionView
        } else {
            destCollectionView = self
        }
        
        let location = gesture.locationInView(destCollectionView)
        
        if let indexPath = destCollectionView.indexPathForItemAtPoint(location) {
            if let cell = destCollectionView.cellForItemAtIndexPath(indexPath) as? SwiftBoardCell {
                if let listViewModel = destCollectionView.listViewModel {
                    let itemViewModel = listViewModel.itemAtIndex(indexPath.item)
                    let gestureInfo = GestureInfo(listViewModel: listViewModel,
                        itemViewModel: itemViewModel,
                        itemIndexInList: indexPath.item,
                        collectionView: destCollectionView,
                        cell: cell,
                        locationInCollectionView: location)
                    
                    return gestureInfo
                }
            }
        }
        
        return nil
    }
    
    func startDrag(gesture: UIGestureRecognizer) {
        if let gestureInfo = infoForGesture(gesture) {
            let cell = gestureInfo.cell
            
            let dragProxyView = cell.snapshotViewAfterScreenUpdates(true)
            dragProxyView.frame = convertRect(cell.frame, fromView: cell.superview)
            addSubview(dragProxyView)
            
            dragProxyState = DragProxyState(view: dragProxyView, originalCenter: dragProxyView.center)
            
            currentDragState = DragState(gestureInfo: gestureInfo)
            gestureInfo.itemViewModel.dragging = true
            
            UIView.animateWithDuration(0.2) {
                dragProxyView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                dragProxyView.alpha = 0.8
            }
        }
    }
    
    private func endDrag() {
        if let dragState = currentDragState {
            let proxyState = dragProxyState!
            let cell = dragState.gestureInfo.cell
            let collectionView = self
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                proxyState.view.transform = CGAffineTransformIdentity
                proxyState.view.alpha = 1
                proxyState.view.frame = collectionView.convertRect(cell.frame, fromView: cell.superview)
            }, completion: { (Bool) -> Void in
                dragState.gestureInfo.itemViewModel.dragging = false
                
                proxyState.view.removeFromSuperview()
                self.currentDragState = nil
            })
        }
    }

    // MARK: RootViewModelDelegate
    
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel) {
        if let index = rootViewModel?.indexOfItem(folderViewModel) {
            if let cell = cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? FolderCollectionViewCell {
                openFolderCollectionView = cell.collectionView
                zoomedLayout.zoomToIndex = index
                setCollectionViewLayout(zoomedLayout, animated: true)
            }
        }
    }
    
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel) {
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
            return currentDragState != nil
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
