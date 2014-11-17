//
//  FolderCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionView: SwiftBoardCollectionView {
    var folderDataSource: FolderDataSource?
    
    var folderViewModel: FolderViewModel? {
        didSet {
            println("Gotcha!")
            
            if folderViewModel != nil {
                folderDataSource = FolderDataSource(folderViewModel: folderViewModel!)
                dataSource = folderDataSource
                delegate = folderDataSource
            }
        }
    }
    
    override var listViewModel: SwiftBoardListViewModel? {
        return folderViewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        registerNib(UINib(nibName: "AppCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "App")
    }
}
