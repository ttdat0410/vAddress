//
//  LoginCell.swift
//  BLEAddress
//
//  Created by DatTran on 4/21/29 H.
//  Copyright © 29 Heisei ANSV. All rights reserved.
//

import Foundation
import UIKit

class LoginCell: BaseCell {
    
    
    let profile: UIImageView = {
    
        let img = UIImageView()
        img.image = UIImage(named: "")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .ScaleAspectFit
        
        return img
    
    }()
    
    let username: UITextField = {
        
        let textfield = UITextField()
        textfield.placeholder = "TEN DANG NHAP"
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.layer.cornerRadius = 10
        textfield.layer.masksToBounds = true
        textfield.layer.borderWidth = 2.5
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        textfield.textAlignment = .Center
        return textfield
    }()
    
    let password: UITextField = {
        
        let textfield = UITextField()
        textfield.placeholder = "MAT KHAU"
        textfield.backgroundColor = UIColor.whiteColor()
        textfield.layer.cornerRadius = 10
        textfield.layer.masksToBounds = true
        textfield.layer.borderWidth = 2.5
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        textfield.textAlignment = .Center
        return textfield
    }()
    
    let login: UIButton = {
        
        let btn = UIButton()
        btn.setTitle("DANG NHAP", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.backgroundColor = UIColor.redColor()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
    
        return btn
    }()
    
    override func setupViews() {
        
        addSubview(username)
        addSubview(password)
        addSubview(login)
        
        let sizeH = UIScreen.mainScreen().bounds.height / 2
        addConstraintsWithFormat("H:|-30-[v0]-30-|", views: username)
        addConstraintsWithFormat("H:|-30-[v0]-30-|", views: password)
        addConstraintsWithFormat("H:|-30-[v0]-30-|", views: login)
        addConstraintsWithFormat("V:|-\(sizeH)-[v0(40)]-10-[v1(40)]-20-[v2(50)]", views: username, password, login)
        
    }
}