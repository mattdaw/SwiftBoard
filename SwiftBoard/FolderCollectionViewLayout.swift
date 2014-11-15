//
//  FolderCollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-22.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionViewLayout: DroppableCollectionViewLayout {

    var itemFrames: [CGRect] = []
    var previousItemFrames: [CGRect] = []
    var numberOfItems = 0
    var updating = false
    
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
        
        previousItemFrames = itemFrames
        itemsPerRow = 3
        
        let myCollectionView = collectionView!
        numberOfItems = myCollectionView.numberOfItemsInSection(0)
        
        let itemsToLayout = numberOfItems > 9 ? 9 : numberOfItems
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
    
    // Set a flag to indicate we're adding/removing items. The initial/final layout attribute methods need to use
    // the default behaviour in this case... and has special code for animating a bounds change.
    override func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
        updating = true
    }
    
    override func finalizeCollectionViewUpdates() {
        updating = false
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if (updating) {
            return super.initialLayoutAttributesForAppearingItemAtIndexPath(indexPath)
        } else {
            // When the bounds change, all items are "removed" from view then re-"added" if they're still visible. Provide their
            // original frame so the change will be animated.
            let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            
            if indexPath.item < 9 {
                itemAttributes.frame = previousItemFrames[indexPath.item]
            } else {
                itemAttributes.hidden = true
            }
            
            return itemAttributes
        }
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if (updating) {
            return super.finalLayoutAttributesForDisappearingItemAtIndexPath(indexPath)
        } else {
            return nil
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}