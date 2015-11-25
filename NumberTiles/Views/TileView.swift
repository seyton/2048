//
//  TileView.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/25/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import UIKit

class TileView: UIView {

    var value: Int = 0 {

        didSet {
            backgroundColor = appearanceDelegate.tileColor(value)

        }
    }

    unowned let appearanceDelegate: AppearanceProviderProtocol
    let numberLabel: UILabel
    
    init(position: CGPoint, width: CGFloat, value v: Int, radius: CGFloat, appearanceDelegate d: AppearanceProviderProtocol) {
        
        appearanceDelegate = d
        numberLabel = UILabel(frame: CGRectMake(0, 0, width, width))
        numberLabel.textAlignment = .Center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = appearanceDelegate.fontForNumbers()

        super.init(frame: CGRectMake(position.x, position.y, width, width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        
        value = v
        
        backgroundColor = appearanceDelegate.tileColor(value)
        numberLabel.textColor = appearanceDelegate.numberColor(value)
        numberLabel.text = "\(value)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
