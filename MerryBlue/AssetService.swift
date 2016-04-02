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

    let iconSortByTime = UIImage(named: "icon-sort-time")?.resize(CGSize(width: IconSize, height: IconSize))
    let iconSortByCount = UIImage(named: "icon-sort-count")?.resize(CGSize(width: IconSize, height: IconSize))

}