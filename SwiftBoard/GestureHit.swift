//
//  GestureHit.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

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
    let itemViewModel: SwiftBoardItemViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: SwiftBoardCell, locationInCell initCellLocation: CGPoint, itemViewModel initItem: SwiftBoardItemViewModel) {
        collectionViewHit = initHit
        cell = initCell
        locationInCell = initCellLocation
        itemViewModel = initItem
    }
}

class AppGestureHit: CellGestureHit, GestureHit {
    let appViewModel: AppViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: SwiftBoardCell, locationInCell initCellLocation: CGPoint, appViewModel initApp: AppViewModel) {
        appViewModel = initApp
        super.init(collectionViewHit: initHit, cell: initCell, locationInCell: initCellLocation, itemViewModel: initApp)
    }
}

class FolderGestureHit: CellGestureHit, GestureHit {
    let folderViewModel: FolderViewModel
    
    init(collectionViewHit initHit: CollectionViewGestureHit, cell initCell: SwiftBoardCell, locationInCell initCellLocation: CGPoint, folderViewModel initFolder: FolderViewModel) {
        folderViewModel = initFolder
        super.init(collectionViewHit: initHit, cell: initCell, locationInCell: initCellLocation, itemViewModel: initFolder)
    }
}
