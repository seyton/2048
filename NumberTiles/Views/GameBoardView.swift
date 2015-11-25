//
//  GameBoardView.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/25/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import UIKit

class GameBoardView: UIView {

    var dimension: Int
    var tileWidth: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat
    var tiles: Dictionary<NSIndexPath, TileView>

}
