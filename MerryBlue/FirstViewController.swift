//
//  FirstViewController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/12.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import UIKit
import TwitterKit

class FirstViewController: TWTRTimelineViewController {
    
    override func viewDidLoad() {
        let client = TWTRAPIClient()
        self.dataSource = TWTRListTimelineDataSource(listSlug: "cps-lab", listOwnerScreenName: "arzzup", APIClient: client)
        // self.showTweetActions = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

