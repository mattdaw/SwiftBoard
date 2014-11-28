//
//  DraggingItemViewModel.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-11-28.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import Foundation

enum DraggingItemViewModelSide { case Left, Right }

enum DraggingItemViewModelState: Equatable {
    case Init
    case Dragging
    case HoveringOnApp(AppViewModel)
    case HoveringOnFolder(FolderViewModel)
    case HoveringOnList(ListViewModel, Int, DraggingItemViewModelSide)
    case Done
}

func ==(lhs: DraggingItemViewModelState, rhs: DraggingItemViewModelState) -> Bool {
    switch (lhs, rhs) {
    case (.Init, .Init):
        return true
    case (.Dragging, .Dragging):
        return true
    case (.HoveringOnApp(let lhsApp), .HoveringOnApp(let rhsApp)):
        return lhsApp === rhsApp
    default:
        return false
    }
}


class DraggingItemViewModel {
    var itemViewModel: ItemViewModel
    
    init(_ initItem: ItemViewModel) {
        itemViewModel = initItem
    }
    
    func transition(fromState: DraggingItemViewModelState, toState: DraggingItemViewModelState) -> Bool {
        return false
    }
    
    /*
    func dragStart() {
        itemViewModel.dragging = true
    }
    
    func dragEnd() {
        itemViewModel.dragging = false
    }
    
    func hoverOn(appViewModel: AppViewModel) {
        
    }
    
    func hoverOn(folderViewModel: FolderViewModel) {
        // do all the transitions in here?
        // set state here to be hoverFolder or something which has valid transitions to hoverCancelled, drop, etc?
    }
    
    func hoverOn(listViewModel: ListViewModel, index: Int, side: DraggingItemViewModelSide) {
        let myIndex = listViewModel.indexOfItem(itemViewModel)
        if index == myIndex {
            // nothing
        }
        
        // go to waiting state
    }
    
    func hoverCancel() {
        
    }
    
    func drop() {
        
    }
    */
}

class DraggingItemViewModelTransition {
    let fromState: DraggingItemViewModelState
    let toState: DraggingItemViewModelState
    
    init(fromState initFromState:DraggingItemViewModelState, toState initToState:DraggingItemViewModelState) {
        fromState = initFromState
        toState = initToState
    }
    
    func action(itemViewModel: ItemViewModel) {

    }
}