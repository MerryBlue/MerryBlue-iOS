//
//  MainTabBarController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/13.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    var watcherView: WatcherViewController!
    var profileView: ProfileViewController!
    
    var watcherNavView: UINavigationController!
    var profileNavView: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        watcherView = WatcherViewController()
        profileView = ProfileViewController()
        
        let watcherTabBarItem = UITabBarItem()
        watcherTabBarItem.title = "watcher"
        watcherTabBarItem.image = FAKIonIcons.iosHomeIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        watcherTabBarItem.tag = 1
        let profileTabBarItem = UITabBarItem()
        profileTabBarItem.title = "account"
        profileTabBarItem.image = FAKIonIcons.androidPersonIconWithSize(26).imageWithSize(CGSize(width: 26, height: 26))
        watcherTabBarItem.tag = 2
        
        
        watcherView.tabBarItem = watcherTabBarItem
        profileView.tabBarItem = profileTabBarItem
        
        watcherNavView = UINavigationController(rootViewController: watcherView)
        profileNavView = UINavigationController(rootViewController: profileView)
        
        let tabs: Array<UINavigationController> = [watcherNavView, profileNavView]
        
        self.setViewControllers(tabs, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}