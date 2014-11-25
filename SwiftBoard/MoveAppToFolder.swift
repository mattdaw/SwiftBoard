//
//  MoveAppToFolder.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-24.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

class MoveAppToFolder: NSObject, DragAndDropOperation {
    let prepareToOpenFolderAfterSeconds = 2.0
    let openFolderAfterSeconds = 5.0
    
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
    
    // TODO: Figure out how to get this called at the right moments
    func dragEnd() {
        cancelTimer()
        resetFolderState()
    }
    
    func drop() {
        cancelTimer()
        rootViewModel.moveAppToFolder(appViewModel, folderViewModel: folderViewModel)
        resetFolderState()
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
    
    private func cancelTimer() {
        openFolderTimer?.invalidate()
        openFolderTimer = nil
    }
    
    private func resetFolderState() {
        folderViewModel.state = .Normal
    }
}
