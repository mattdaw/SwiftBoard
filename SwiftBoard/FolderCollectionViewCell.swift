//
//  FolderCollectionViewCell.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var collectionView: FolderCollectionView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.layer.cornerRadius = 5
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
        super.applyLayoutAttributes(layoutAttributes)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if bounds.width > 100 {
                flowLayout.itemSize = CGSize(width: 96, height: 96)
            } else {
                flowLayout.itemSize = CGSize(width: 16, height: 16)
            }
        }
        
        // Trigger constraint re-evaluation, so the subview sizes get animated too
        // http://stackoverflow.com/questions/23564453/uicollectionview-layout-transitions
        layoutIfNeeded()
    }
}
