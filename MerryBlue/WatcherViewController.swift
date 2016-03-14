//
//  FirstViewController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/12.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import UIKit
import TwitterKit

class WatcherViewController: TWTRTimelineViewController {
    
    convenience init() {
        let client = TWTRAPIClient()
        let dataSource = TWTRListTimelineDataSource(listSlug: "cps-lab", listOwnerScreenName: "arzzup", APIClient: client)
        self.init(dataSource: dataSource)
        self.setNavigationBar()
        
        self.title = "WatchBoard"
    }
    
    private func setNavigationBar() {
        let switchListButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "onClickSwitchList:")
        
        self.navigationController?.navigationBar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor.blueColor()
        self.navigationItem
        self.navigationItem.title = "WatchBoard"
        self.navigationItem.setRightBarButtonItem(switchListButton, animated: true)
    }
    
    private func onClickSwitchList() {
        NSLog("on click switch")
    }
}

