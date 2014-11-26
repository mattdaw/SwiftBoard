//
//  MoveAppFromFolder.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class MoveAppFromFolder: DragAndDropOperation {    
    let rootViewModel: RootViewModel
    let appViewModel: AppViewModel
    let folderViewModel: FolderViewModel
    
    init(rootViewModel initRoot: RootViewModel, appViewModel initApp: AppViewModel, folderViewModel initFolder: FolderViewModel) {
        rootViewModel = initRoot
        appViewModel = initApp
        folderViewModel = initFolder
    }
    
    func dragStart() {
        rootViewModel.closeFolder(folderViewModel)
        rootViewModel.moveAppFromFolder(appViewModel, folderViewModel: folderViewModel)
    }
    
    func dragEnd() {}
    func drop() {}
}