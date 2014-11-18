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
}

class RootCollectionView: SwiftBoardCollectionView, UIGestureRecognizerDelegate, RootViewModelDelegate {
    private var listDataSource: SwiftBoardListViewModelDataSource?
    private var zoomedLayout = CollectionViewLayout()
    private var regularLayout = CollectionViewLayout()
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var panAndStopGestureRecognizer: PanAndStopGestureRecognizer!
    
    private var openFolderCollectionView: SwiftBoardCollectionView?
    
    var rootViewModel: RootViewModel? {
        didSet {
            if rootViewModel != nil {
                rootViewModel!.delegate = self
                
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
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        panAndStopGestureRecognizer = PanAndStopGestureRecognizer(target: self, action: "handlePanGesture:", stopAfterSecondsWithoutMovement: 0.2) {
            (gesture:PanAndStopGestureRecognizer) in self.handlePanGestureStopped(gesture)
        }
        
        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressRecognizer)
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
        
    }
    
    func handlePanGesture(gesture: PanAndStopGestureRecognizer) {
        
    }
    
    func handlePanGestureStopped(gesture: PanAndStopGestureRecognizer) {
        
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
            if let listViewModel = destCollectionView.listViewModel {
                let itemViewModel = listViewModel.itemAtIndex(indexPath.item)
                
                return GestureInfo(listViewModel: listViewModel, itemViewModel: itemViewModel, itemIndexInList: indexPath.item)
            }
        }
        
        return nil
    }
    
    // MARK: RootViewModelDelegate
    
    func listViewModelItemMoved(fromIndex: Int, toIndex: Int) {
        println("MOVED!!")
    }
    
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
            return true //currentDragState != nil
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
