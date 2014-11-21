//
//  DragAndDrop.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-21.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol DragAndDropOperation {
    func dragStart()
    func dragEnd()
    func drop()
}

class DragAppOnFolder: NSObject, DragAndDropOperation {
    let prepareToOpenFolderAfterSeconds = 2.0
    let openFolderAfterSeconds = 2.0
    
    let rootViewModel: RootViewModel
    let appViewModel: AppViewModel
    let folderViewModel: FolderViewModel
    
    private var openFolderTimer: NSTimer?
    
    init(rootViewModel initRoot: RootViewModel, appViewModel initApp: AppViewModel, folderViewModel initFolder: FolderViewModel) {
        rootViewModel = initRoot
        appViewModel = initApp
        folderViewModel = initFolder
    }
    
    func dragStart() {
        folderViewModel.state = .AppHovering
        openFolderTimer = NSTimer.scheduledTimerWithTimeInterval(prepareToOpenFolderAfterSeconds, target: self, selector: "prepareToOpenFolder", userInfo: nil, repeats: false)
    }
    
    func dragEnd() {
        cancelTimer()
        resetFolderState()
    }
    
    func drop() {
        cancelTimer()
        rootViewModel.moveAppToFolder(appViewModel, folderViewModel: folderViewModel)
        resetFolderState()
    }
    
    func cancelTimer() {
        openFolderTimer?.invalidate()
        openFolderTimer = nil
    }
    
    func prepareToOpenFolder() {
        cancelTimer()
        
        folderViewModel.state = .PreparingToOpen
        openFolderTimer = NSTimer.scheduledTimerWithTimeInterval(openFolderAfterSeconds, target: self, selector: "openFolder", userInfo: nil, repeats: false)
    }
    
    func openFolder() {
        cancelTimer()
        
        rootViewModel.moveAppToFolder(appViewModel, folderViewModel: folderViewModel)
        rootViewModel.openFolder(folderViewModel)
        resetFolderState()
    }
    
    func resetFolderState() {
        folderViewModel.state = .Normal
    }
}

class MoveItem: DragAndDropOperation {
    let listViewModel: SwiftBoardListViewModel
    let fromIndex: Int
    let toIndex: Int
    
    init(listViewModel initList: SwiftBoardListViewModel, fromIndex initFrom: Int, toIndex initTo: Int) {
        listViewModel = initList
        fromIndex = initFrom
        toIndex = initTo
    }
    
    func dragStart() {
        listViewModel.moveItemAtIndex(fromIndex, toIndex: toIndex)
    }
    
    func dragEnd() {
    
    }
    
    func drop() {
        
    }
}