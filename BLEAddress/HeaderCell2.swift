//
//  HeaderCell.swift
//  BLEAddress
//
//  Created by DatTran on 4/22/29 H.
//  Copyright © 29 Heisei ANSV. All rights reserved.
//

import Foundation
import UIKit

class HeaderCell: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("wtf?")
    }
    
    let name: UILabel = {

        let label = UILabel()
        label.textAlignment = .Left
        label.textColor = UIColor.darkGrayColor()
        label.text = ""
        label.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 14)
        
        return label
    }()
    
    let bottomBorderView: UIView = {
    
        let view = UIView()
        view.backgroundColor = UIColor.darkGrayColor()
        
        return view
    }()
    
    func setupViews() {
        
        addSubview(name)
        addSubview(bottomBorderView)
        
        addConstraintsWithFormat("H:|-8-[v0]-8-|", views: name)
        addConstraintsWithFormat("H:|[v0]|", views: bottomBorderView)
        addConstraintsWithFormat("V:|[v0][v1(0.5)]|", views: name, bottomBorderView)
        
    }
}
