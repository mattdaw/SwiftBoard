//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    let sectionSize = CGFloat(128)
    var sectionFrames: [CGRect] = []
    
    override func collectionViewContentSize() -> CGSize {
        if let cv = collectionView {
            return cv.frame.size
        } else {
            return CGSizeZero
        }
    }
    
    override func prepareLayout() {
        if collectionView == nil {
            return
        }
        
        let myCollectionView = collectionView!
        let numberOfSections = myCollectionView.numberOfSections()
        let availableWidth = myCollectionView.bounds.size.width
        let itemsPerRow = Int(floor(availableWidth / sectionSize))
        var top = CGFloat(0)
        var left = CGFloat(0)
        var column = 0
        
        sectionFrames = []
        for sectionIndex in 0..<numberOfSections {
            let sectionFrame = CGRect(x: left, y: top, width: sectionSize, height: sectionSize)
            sectionFrames.append(sectionFrame)
            
            column += 1
            if column > itemsPerRow {
                column = 0
                left = CGFloat(0)
                top += sectionSize
            } else {
                left += sectionSize
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return []
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return UICollectionViewLayoutAttributes()
    }
    
}
