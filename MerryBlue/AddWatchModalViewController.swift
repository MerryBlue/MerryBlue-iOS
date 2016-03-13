//
//  AddWatchModalViewController.swift
//  MerryBlue
//
//  Created by Hiroto Takahashi on 2016/03/13.
//  Copyright © 2016年 Hiroto Takahashi. All rights reserved.
//

import Foundation
import UIKit

protocol ModalViewControllerDelegate {
    func modalDidFinished(modalText: String)
}

class AddWatchUserModalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: ModalViewControllerDelegate! = nil
    var followCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.orangeColor()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(50, 50)
        layout.sectionInset = UIEdgeInsetsMake(16, 16, 32, 16)
        layout.headerReferenceSize = CGSizeMake(100, 30)
        
        followCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        followCollectionView.registerClass(UserUICollectionViewCell.self, forCellWithReuseIdentifier: "UserCell")
        
        followCollectionView.delegate = self
        followCollectionView.dataSource = self
        self.view.addSubview(followCollectionView)

        let submitBtn = UIButton(frame: CGRectMake(0, 0, 300, 50))
        submitBtn.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        submitBtn.setTitle("Submit", forState: .Normal)
        submitBtn.addTarget(self, action: "submit:", forControlEvents: .TouchUpInside)
        self.view.addSubview(submitBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submit(sender: AnyObject) {
        // dismissViewControllerAnimated(true, completion: nil)
        // self.delegate.modalDidFinished(self.text1.text!)
    }
    
    /*
    Cellが選択された際に呼び出される
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // println("Num: \(indexPath.row)")
    }
    
    /*
    Cellの総数を返す
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    /*
    Cellに値を設定する
    */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : UserUICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserUICollectionViewCell
        cell.textLabel?.text = indexPath.row.description
        return cell
    }
}