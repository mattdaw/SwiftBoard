//
//  AppDelegate.swift
//  SwiftBoard
//
//  Created by Matt Daw on 2014-09-15.
//  Copyright (c) 2014 Matt Daw. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if let viewController = window?.rootViewController as? ViewController {
            var viewModels: [ItemViewModel] = [
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
            
            viewController.rootViewModel = RootViewModel(viewModels: viewModels)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

