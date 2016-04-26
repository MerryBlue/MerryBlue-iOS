//
//  AssetService.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/29.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation

class AssetSertvice {
    static let IconSize = 26
    static let sharedInstance = AssetSertvice()

    let iconSortByTime = UIImage(named: "icon-sort-time")
    let iconSortByCount = UIImage(named: "icon-sort-count")
    let iconSortByCountRev = UIImage(named: "icon-sort-count-rev")

    let loadingImage = UIImage(named: "twttr-icn-tweet-place-holder-photo-error@3x.png")
    let iconIndicator = UIImage(named: "icon-indicator")
    let iconRecentFollow = UIImage(named: "icon-recent-follow")
    let iconRecentFollower = UIImage(named: "icon-recent-follower")

    // let loadingImage = UIImage(named: "icon-indicator")

}
