//
//  FolderCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewCell : SwiftBoardCell, FolderViewModelDelegate {
    
    @IBOutlet weak var collectionView: FolderCollectionView!
    @IBOutlet weak var label: UILabel!
    
    var listDataSource: SwiftBoardListViewModelDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hidden = false
        listDataSource = nil
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
    
    func configureForFolderViewModel(folderViewModel: FolderViewModel) {
        hidden = folderViewModel.dragging
        label.text = folderViewModel.name
        collectionView.folderViewModel = folderViewModel
        
        folderViewModel.delegate = self
    }
    
    // FolderViewModelDelegate
    
    func folderViewModelDraggingDidChange(dragging: Bool) {
        hidden = dragging
    }
}
