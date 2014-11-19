//
//  ViewController.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

private struct OldDragState {
    let originalCenter: CGPoint
    let addTranslation: CGPoint
    let dragProxyView: UIView
    
    var viewModel: SwiftBoardItemViewModel
    
    var dragIndexPath: NSIndexPath
    var dropIndexPath: NSIndexPath
    
    mutating func setDragIndexPath(indexPath:NSIndexPath) {
        dragIndexPath = indexPath
    }
    
    mutating func setDropIndexPath(indexPath:NSIndexPath) {
        dropIndexPath = indexPath
    }
}

private struct ZoomState {
    let indexPath: NSIndexPath
    let collectionView: UICollectionView
    let folderViewModel: FolderViewModel
}

private struct OldGestureInfo {
    let collectionView: UICollectionView
    let collectionViewCell: UICollectionViewCell
    let indexPath: NSIndexPath
    let viewModel: SwiftBoardItemViewModel
    let locationInCollectionView: CGPoint
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var rootCollectionView: RootCollectionView!
    
    private var rootViewModel: RootViewModel?
    private var dropOperation: (() -> ())?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Move to AppDelegate and pass in
        var viewModels: [SwiftBoardItemViewModel] = [
            AppViewModel(name: "App 1", color: UIColor.greenColor()),
            AppViewModel(name: "App 2", color: UIColor.blueColor()),
            FolderViewModel(name: "Folder 1", viewModels: [
                AppViewModel(name: "App 5", color: UIColor.purpleColor()),
                AppViewModel(name: "App 6", color: UIColor.grayColor()),
                AppViewModel(name: "App 7", color: UIColor.yellowColor()),
                AppViewModel(name: "App 8", color: UIColor.yellowColor()),
                AppViewModel(name: "App 9", color: UIColor.redColor()),
                AppViewModel(name: "App 10", color: UIColor.purpleColor()),
                AppViewModel(name: "App 11", color: UIColor.blueColor()),
                ]),
            FolderViewModel(name: "Folder 2", viewModels: [
                AppViewModel(name: "App 4", color: UIColor.darkGrayColor())
                ]),
            AppViewModel(name: "App 3", color: UIColor.redColor()),
            AppViewModel(name: "App 20", color: UIColor.redColor()),
            AppViewModel(name: "App 21", color: UIColor.redColor()),
            AppViewModel(name: "App 22", color: UIColor.redColor()),
            AppViewModel(name: "App 23", color: UIColor.redColor()),
            AppViewModel(name: "App 24", color: UIColor.redColor())
        ]
        
        rootViewModel = RootViewModel(viewModels: viewModels)
        rootCollectionView.rootViewModel = rootViewModel
    }    
}














