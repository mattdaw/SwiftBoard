//
//  FolderCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewCell : SwiftBoardCell, FolderViewModelDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    var dataSource: FolderDataSource? {
        didSet {
            collectionView.registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
            collectionView.dataSource = dataSource
            collectionView.delegate = dataSource
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.layer.cornerRadius = 5
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
    
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
    
    override func pointInsideIcon(point:CGPoint) -> Bool {
        let converted = convertPoint(point, toView:collectionView)
        return collectionView.pointInside(converted, withEvent: nil)
    }
    
    func expand() {
        UIView.animateWithDuration(0.2) {
            self.transform = CGAffineTransformMakeScale(1.15, 1.15)
            self.label.alpha = 0
        }
    }
    
    func collapse() {
        UIView.animateWithDuration(0.2) {
            self.transform = CGAffineTransformIdentity
            self.label.alpha = 1
        }
    }
    
    // FolderViewModelDelegate
    
    func folderViewModelDraggingDidChange(dragging: Bool) {
        if dragging {
            alpha = 0
        } else {
            alpha = 1
        }
    }
    
    func folderViewModelAppDidMove(fromIndex: Int, toIndex: Int) {
        println("moved!")
    }
}
