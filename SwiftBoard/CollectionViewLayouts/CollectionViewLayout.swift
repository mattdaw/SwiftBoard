//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout, DroppableCollectionViewLayout {
    let itemsPerRow = 4
    let heightPadding = 20
    
    var itemFrames: [CGRect] = []
    var numberOfItems = 0
    var zoomToIndex: Int?
    
    override func collectionViewContentSize() -> CGSize {
        return collectionView?.bounds.size ?? CGSizeZero
    }
    
    override func prepareLayout() {
        if let myCollectionView = collectionView {
            numberOfItems = myCollectionView.dataSource!.collectionView(myCollectionView, numberOfItemsInSection: 0)
            let availableSize = myCollectionView.bounds.size
            
            if let zoomIndex = zoomToIndex {
                let zoomedWidth = availableSize.width * CGFloat(itemsPerRow)
                let zoomedFrames = layout(numberOfItems, itemsPerRow, zoomedWidth, heightPadding)
                let transform = zoomTransform(zoomedFrames[zoomIndex], availableSize)
                
                itemFrames = zoomLayout(zoomedFrames, transform)
            } else {
                itemFrames = layout(numberOfItems, itemsPerRow, availableSize.width, heightPadding)
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
        let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        itemAttributes.frame = itemFrames[indexPath.item]
        
        return itemAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func indexToMoveSourceIndexLeftOfDestIndex(sourceIndex: Int, destIndex: Int) -> Int {
        let column = destIndex % itemsPerRow
        var offset = 0
        if sourceIndex < destIndex && column != 0 {
            offset = -1
        }
        
        return destIndex + offset
    }
    
    func indexToMoveSourceIndexRightOfDestIndex(sourceIndex: Int, destIndex: Int) -> Int {
        var offset = 1
        if sourceIndex < destIndex {
            offset = 0
        }
        
        return destIndex + offset
    }
}

private func layout(numberOfItems: Int, itemsPerRow: Int, totalWidth: CGFloat, heightPadding: Int) -> [CGRect] {
    let itemWidth = Int(totalWidth) / itemsPerRow
    let itemHeight = itemWidth + heightPadding
    let range = [Int](0..<numberOfItems)
    
    return range.map { itemIndex in
        let row = itemIndex / itemsPerRow
        let column = itemIndex % itemsPerRow
        let itemRect = CGRect(x: itemWidth * column,
            y: itemHeight * row,
            width: itemWidth,
            height: itemHeight)
        
        return itemRect
    }
}

private func zoomTransform(itemFrame: CGRect, screenSize: CGSize) -> CGAffineTransform {
    var transform = CGAffineTransformMakeTranslation(-itemFrame.origin.x, -itemFrame.origin.y)
    transform = CGAffineTransformTranslate(transform, (screenSize.width - itemFrame.width) / 2, (screenSize.height - itemFrame.height) / 2)
    
    return transform
}

private func zoomLayout(itemFrames: [CGRect], transform: CGAffineTransform) -> [CGRect] {
    return itemFrames.map { frame in
        CGRectApplyAffineTransform(frame, transform)
    }
}
