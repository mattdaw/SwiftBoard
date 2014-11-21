//
//  RootViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

protocol RootViewModelDelegate: class {
    func rootViewModelFolderOpened(folderViewModel: FolderViewModel)
    func rootViewModelFolderClosed(folderViewModel: FolderViewModel)
}

class RootViewModel: SwiftBoardListViewModel {
    let prepareToOpenFolderAfterSeconds = 2.0
    let openFolderAfterSeconds = 2.0
    
    weak var rootViewModelDelegate: RootViewModelDelegate?
    
    private var openFolderTimer: NSTimer?
    private var draggingApp: AppViewModel?
    private var draggingFolder: FolderViewModel?
    
    func moveAppToFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let index = indexOfItem(appViewModel) {
            let addIndex = folderViewModel.numberOfItems()
            
            removeItemAtIndex(index)
            folderViewModel.appendItem(appViewModel)
        } else {
            assertionFailure("moveAppToFolder: AppViewModel isn't in the RootViewModel")
        }
    }
    
    func moveAppFromFolder(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if let removeIndex = folderViewModel.indexOfItem(appViewModel) {
            let addIndex = numberOfItems()
            
            folderViewModel.removeItemAtIndex(removeIndex)
            appendItem(appViewModel)
        } else {
            assertionFailure("moveAppFromFolder: AppViewModel isn't in the FolderViewModel")
        }
    }
    
    func openFolder(folderViewModel: FolderViewModel) {
        rootViewModelDelegate?.rootViewModelFolderOpened(folderViewModel)
    }
    
    func closeFolder(folderViewModel: FolderViewModel) {
        rootViewModelDelegate?.rootViewModelFolderClosed(folderViewModel)
    }
    
    // Drag/drop for an app on a folder
    
    func appDragEnter(appViewModel: AppViewModel, folderViewModel: FolderViewModel) {
        if draggingApp != nil {
            assertionFailure("Tried to start a drag while another was in progress or not properly cleaned up.")
        }
        
        draggingFolder = folderViewModel
        draggingApp = appViewModel
        folderViewModel.state = .AppHovering
        
        openFolderTimer = NSTimer.scheduledTimerWithTimeInterval(prepareToOpenFolderAfterSeconds, target: self, selector: "appDragPrepareToOpenFolder", userInfo: nil, repeats: false)
    }
    
    func appDragExit() {
        appDragCancelTimer()
        appDragReset()
    }
    
    func appDragDrop() {
        if draggingApp == nil {
            assertionFailure("Tried to drop an app when there was no drag in progress.")
        }
        
        appDragCancelTimer()
        moveAppToFolder(draggingApp!, folderViewModel: draggingFolder!)
        appDragReset()
    }
    
    private func appDragCancelTimer() {
        openFolderTimer?.invalidate()
        openFolderTimer = nil
    }
    
    func appDragPrepareToOpenFolder() {
        appDragCancelTimer()
        
        draggingFolder!.state = .PreparingToOpen
        openFolderTimer = NSTimer.scheduledTimerWithTimeInterval(openFolderAfterSeconds, target: self, selector: "appDragOpenFolder", userInfo: nil, repeats: false)
    }
    
    func appDragOpenFolder() {
        appDragCancelTimer()
        
        moveAppToFolder(draggingApp!, folderViewModel: draggingFolder!)
        openFolder(draggingFolder!)
        
        appDragReset()
    }
    
    private func appDragReset () {
        draggingFolder!.state = .Normal
        
        draggingApp = nil
        draggingFolder = nil
    }

}