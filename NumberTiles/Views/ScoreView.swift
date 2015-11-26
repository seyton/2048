//
//  ScoreView.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/25/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import UIKit

protocol ScoreViewDelegate {
    func scoreChanged(newScore: Int)
}

class ScoreView: UIView {

    var score: Int = 0 {
        didSet {
            label.text = "SCORE: \(score)"
        }
    }
    
    let defaultFrame = CGRectMake(0, 0, 140, 140)
    var label: UILabel
    
    init(background bgColor: UIColor, textColor: UIColor, font: UIFont, radius r: CGFloat) {
        
        label = UILabel(frame: defaultFrame)
        label.textAlignment = .Center
        super.init(frame: defaultFrame)
        backgroundColor = bgColor
        label.textColor = textColor
        label.font = font
        layer.cornerRadius = r
        self.addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ScoreView: ScoreViewDelegate {
    
    func scoreChanged(newScore: Int) {
        score = newScore
    }
}