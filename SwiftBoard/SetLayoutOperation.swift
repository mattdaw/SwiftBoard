//
//  SetLayoutOperation.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-12-02.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class SetLayoutOperation: AsyncOperation {
    let collectionView: UICollectionView
    let layout: UICollectionViewLayout
    
    init(collectionView initCV: UICollectionView, layout initLayout: UICollectionViewLayout) {
        collectionView = initCV
        layout = initLayout
    }
    
    override func start() {
        executing = true
        
        collectionView.setCollectionViewLayout(layout, animated: true) { (didComplete: Bool) -> Void in
            self.finished = true
        }
    }
}