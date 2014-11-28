//
//  FolderCollectionView.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-17.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

class FolderCollectionView: ListViewModelCollectionView {
    var listDataSource: ListViewModelDataSource?
    
    var folderViewModel: FolderViewModel? {
        didSet {
            if folderViewModel != nil {
                listDataSource = ListViewModelDataSource(folderViewModel!)
                dataSource = listDataSource
                delegate = listDataSource
                
                folderViewModel!.listViewModelDelegate = self
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
