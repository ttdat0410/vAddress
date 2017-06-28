//
//  LoginPage.swift
//  BLEAddress
//
//  Created by DatTran on 4/21/29 H.
//  Copyright © 29 Heisei ANSV. All rights reserved.
//

import Foundation
import UIKit


class LoginPage: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let login_cell = "login_cell"
    
    override func viewDidLoad() {
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.redColor()
        collectionView?.registerClass(LoginCell.self, forCellWithReuseIdentifier: login_cell)
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: LoginCell = collectionView.dequeueReusableCellWithReuseIdentifier(login_cell, forIndexPath: indexPath) as! LoginCell
        
        cell.backgroundColor = UIColor.greenColor()
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.redColor().CGColor
        return cell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(view.frame.width, view.frame.height)
    }
    
    
}