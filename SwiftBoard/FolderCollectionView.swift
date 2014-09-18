//
//  FolderCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-18.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionView : UICollectionView {
    
    var itemIndex: Int?
    
    override func awakeFromNib() {
        registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
    }
    
}
