//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayout: DroppableCollectionViewLayout {
    
    let itemSize = CGFloat(96)
    var itemFrames: [CGRect] = []
    var numberOfItems = 0
    var zoomToIndex: Int?
    var overrideSize: CGSize?
    var editingModeEnabled = false
    
    override class func layoutAttributesClass() -> AnyClass {
        return CollectionViewLayoutAttributes.self
    }
    
    func getSize() -> CGSize {
        if let mySize = overrideSize {
            return mySize
        } else if let cv = collectionView {
            return cv.bounds.size
        }
        
        return CGSizeZero
    }
    
    override func collectionViewContentSize() -> CGSize {
        return getSize()
    }
    
    override func prepareLayout() {
        if collectionView == nil {
            return
        }
        
        let myCollectionView = collectionView!
        let mySize = getSize()
        let availableHeight = mySize.height
        let availableWidth = mySize.width
        var myItemSize = CGFloat(itemSize)
        
        itemsPerRow = Int(floor(availableWidth / itemSize))
        let floatItems = Float(availableWidth) / Float(itemsPerRow)
        myItemSize = CGFloat(floor(floatItems))
        
        var top = CGFloat(0)
        var left = CGFloat(0)
        var column = 1
        var zoomedSize = myItemSize
        var rowOffset = myItemSize
        var columnOffset = myItemSize
        
        if let zoomIndex = zoomToIndex {
            if availableWidth < availableHeight {
                zoomedSize = availableWidth - 10
                rowOffset = zoomedSize + (availableHeight - zoomedSize) / 2
                columnOffset = zoomedSize
            } else {
                zoomedSize = availableHeight - 10
                rowOffset = zoomedSize
                columnOffset = zoomedSize + (availableWidth - zoomedSize) / 2
            }
        }

        itemFrames = []
        numberOfItems = myCollectionView.numberOfItemsInSection(0)
        
        for itemIndex in 0..<numberOfItems {
            let itemFrame = CGRect(x: left, y: top, width: zoomedSize, height: zoomedSize)
            itemFrames.append(itemFrame)
            
            column += 1
            if column > itemsPerRow {
                column = 1
                left = CGFloat(0)
                top += rowOffset
            } else {
                left += columnOffset
            }
        }
        
        if let zoomIndex = zoomToIndex {
            var frame = itemFrames[zoomIndex]
            var transform = CGAffineTransformMakeTranslation(-frame.origin.x, -frame.origin.y)
            transform = CGAffineTransformTranslate(transform, (availableWidth - zoomedSize) / 2, (availableHeight - zoomedSize) / 2)
            
            for itemIndex in 0..<numberOfItems {
                itemFrames[itemIndex] = CGRectApplyAffineTransform(itemFrames[itemIndex], transform)
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        if let myCollectionView = collectionView {
            for itemIndex in 0..<numberOfItems {
                attributes.append(layoutAttributesForItemAtIndexPath(itemIndex.toIndexPath()))
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let itemAttributes = CollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        itemAttributes.frame = itemFrames[indexPath.item]
        itemAttributes.editingModeEnabled = editingModeEnabled
        
        return itemAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }    
}
