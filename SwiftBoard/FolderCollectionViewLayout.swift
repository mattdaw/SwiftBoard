//
//  FolderCollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-22.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewLayout: UICollectionViewLayout {

    var itemFrames: [CGRect] = []    
    var numberOfItems = 0
    
    override func collectionViewContentSize() -> CGSize {
        if let myCollectionView = collectionView {
            return myCollectionView.bounds.size
        } else {
            return CGSizeZero
        }
    }
    
    override func prepareLayout() {
        if collectionView == nil {
            return
        }
        
        let myCollectionView = collectionView!
        numberOfItems = myCollectionView.numberOfItemsInSection(0)
        
        let itemsToLayout = numberOfItems > 8 ? 8 : numberOfItems
        let availableWidth = myCollectionView.bounds.width
        let itemSize = availableWidth / 3
        
        itemFrames = []
        
        for i in 0..<itemsToLayout {
            var row = CGFloat(i / 3)
            var column = CGFloat(i % 3)
            
            var rect = CGRect(x: column*itemSize, y: row*itemSize, width: itemSize, height: itemSize)
            itemFrames.append(rect)
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if let myCollectionView = collectionView {
            for itemIndex in 0..<numberOfItems {
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: 0)
                attributes.append(layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        if indexPath.item < 9 {
            itemAttributes.frame = itemFrames[indexPath.item]
        } else {
            itemAttributes.hidden = true
        }
        
        return itemAttributes
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return nil;
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        if indexPath.item < 9 {
            itemAttributes.frame = itemFrames[indexPath.item]
        } else {
            itemAttributes.hidden = true
        }
        
        return itemAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}