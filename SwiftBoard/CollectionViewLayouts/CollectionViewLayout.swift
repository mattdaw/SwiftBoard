//
//  CollectionViewLayout.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout, DroppableCollectionViewLayout {
    let itemsPerRow: Int
    let heightPadding: CGFloat
    let zoomToIndex: Int?
    
    private var itemFrames: [CGRect] = []
    private var numberOfItems = 0
    
    init(itemsPerRow initItems: Int, heightPadding initPad: CGFloat, zoomToIndex initZoomIndex: Int?) {
        itemsPerRow = initItems
        heightPadding = initPad
        zoomToIndex = initZoomIndex
        
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        itemsPerRow = 3
        heightPadding = 20
        
        super.init(coder: aDecoder)
    }
    
    override func collectionViewContentSize() -> CGSize {
        return collectionView?.bounds.size ?? CGSizeZero
    }
    
    override func prepareLayout() {
        if let myCollectionView = collectionView {
            numberOfItems = myCollectionView.dataSource!.collectionView(myCollectionView, numberOfItemsInSection: 0)
            let availableSize = myCollectionView.bounds.size
            
            if let zoomIndex = zoomToIndex {
                let zoomedItemSize = CGSize(width: availableSize.width, height: availableSize.width + heightPadding)
                let zoomedFrames = layout(numberOfItems, itemsPerRow, zoomedItemSize, availableSize.height)
                let transform = zoomTransform(zoomedFrames[zoomIndex], availableSize)
                
                itemFrames = transformLayout(zoomedFrames, transform)
            } else {
                let itemWidth = floor(availableSize.width / CGFloat(itemsPerRow))
                let itemHeight = itemWidth + heightPadding
                let itemSize = CGSize(width: itemWidth, height: itemHeight)
                
                itemFrames = layout(numberOfItems, itemsPerRow, itemSize, itemHeight)
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

private func layout(numberOfItems: Int, itemsPerRow: Int, itemSize: CGSize, rowHeight: CGFloat) -> [CGRect] {
    let range = [Int](0..<numberOfItems)
    
    return range.map { itemIndex in
        let row = CGFloat(itemIndex / itemsPerRow)
        let column = CGFloat(itemIndex % itemsPerRow)
        
        let itemRect = CGRect(x: itemSize.width * column,
            y: rowHeight * row,
            width: itemSize.width,
            height: itemSize.height)
        
        return itemRect
    }
}

private func zoomTransform(itemFrame: CGRect, screenSize: CGSize) -> CGAffineTransform {
    var transform = CGAffineTransformMakeTranslation(-itemFrame.origin.x, -itemFrame.origin.y)
    transform = CGAffineTransformTranslate(transform, (screenSize.width - itemFrame.width) / 2, (screenSize.height - itemFrame.height) / 2)
    
    return transform
}

private func transformLayout(itemFrames: [CGRect], transform: CGAffineTransform) -> [CGRect] {
    return itemFrames.map { frame in
        CGRectApplyAffineTransform(frame, transform)
    }
}
