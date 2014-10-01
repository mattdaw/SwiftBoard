//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    let itemSize = CGFloat(96)
    var itemFrames: [CGRect] = []
    var numberOfItems = 0
    var itemsPerRow = 0
    var zoomToIndexPath: NSIndexPath?
    var hideIndexPath: NSIndexPath?
    var overrideSize: CGSize?
    
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
        
        if let zoomIndex = zoomToIndexPath {
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
        
        if let zoomIndex = zoomToIndexPath {
            var frame = itemFrames[zoomIndex.item]
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
                let indexPath = NSIndexPath(forItem: itemIndex, inSection: 0)
                attributes.append(layoutAttributesForItemAtIndexPath(indexPath))
            }
        }
        
        return attributes;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let itemAttributes = CollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        itemAttributes.frame = itemFrames[indexPath.item]
        
        if let hideIndex = hideIndexPath {
            if hideIndex == indexPath {
                itemAttributes.hidden = true
            }
        }
        
        return itemAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func indexPathToMoveSourceIndexPathLeftOfDestIndexPath(sourceIndexPath:NSIndexPath, destIndexPath:NSIndexPath) -> NSIndexPath {
        let column = destIndexPath.item % itemsPerRow
        var offset = 0
        if sourceIndexPath.item < destIndexPath.item && column != 0 {
            offset = -1
        }
        
        return NSIndexPath(forItem:destIndexPath.item + offset, inSection:destIndexPath.section)
    }
    
    func indexPathToMoveSourceIndexPathRightOfDestIndexPath(sourceIndexPath:NSIndexPath, destIndexPath:NSIndexPath) -> NSIndexPath {
        var offset = 1
        if sourceIndexPath.item < destIndexPath.item {
            offset = 0
        }
        
        return NSIndexPath(forItem:destIndexPath.item + offset, inSection:destIndexPath.section)
    }
}
