//
//  DragAndDrop.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol DragAndDropOperation {
    func drag()
    func drop()
}

class DragAppOnFolder: DragAndDropOperation {
    let rootViewModel: RootViewModel
    let appViewModel: AppViewModel
    let folderViewModel: FolderViewModel
    
    init(rootViewModel initRoot: RootViewModel, appViewModel initApp: AppViewModel, folderViewModel initFolder: FolderViewModel) {
        rootViewModel = initRoot
        appViewModel = initApp
        folderViewModel = initFolder
    }
    
    func drag() {
        println("Drag!")
    }
    
    func drop() {
        println("Drop!")
    }
}