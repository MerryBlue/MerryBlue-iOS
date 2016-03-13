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
    }
    
}

