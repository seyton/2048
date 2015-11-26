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

    let appearanceProvider  = AppearanceProvider()

    let tilePopStartScale = CGFloat(0.1)
    let tilePopMaxScale   = CGFloat(1.1)
    let tilePopDelay      = NSTimeInterval(0.05)
    let tileExpandTime    = NSTimeInterval(0.2)
    let tileContractTime  = NSTimeInterval(0.1)
    
    let tileMergeStartScale   = CGFloat(1.0)
    let tileMergeExpandTime   = NSTimeInterval(0.08)
    let tileMergeContractTime = NSTimeInterval(0.08)

    let perSquareSlideDuration = NSTimeInterval(0.08)
    
    init(dimension d: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor ) {
        
        assert(d > 0)
        dimension = d
        tileWidth = width
        tilePadding = padding
        cornerRadius = radius
        tiles = Dictionary()
        let sideLength = padding + CGFloat(dimension) * (width + padding)
        super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
        layer.cornerRadius = radius
        setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground(backgroundColor bgColor: UIColor, tileColor: UIColor) {
        backgroundColor = bgColor
        
        var xCursor = tilePadding
        var yCursor: CGFloat
        
        let backgroundRadius = (cornerRadius >= 2) ? cornerRadius - 2: 0
        
        for _ in 0..<dimension {
            
            yCursor = tilePadding
            
            for _ in 0..<dimension {
                
                let background = UIView(frame: CGRectMake(xCursor, yCursor, tileWidth, tileWidth))
                background.layer.cornerRadius = backgroundRadius
                background.backgroundColor    = tileColor
                addSubview(background)
                
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func reset() {
        
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        
        tiles.removeAll(keepCapacity: true)
    }
}

//MARK: - Move Methods
extension GameBoardView {
    
    func positionIsValid(pos: (x: Int, y: Int)) -> Bool {

        return (pos.x >= 0 && pos.x < dimension && pos.y >= 0 && pos.y < dimension)
    }
    
    func insertTile(pos: (x: Int, y: Int), value: Int) {
        
        let x    = tilePadding + CGFloat(pos.y) * (tileWidth + tilePadding)
        let y    = tilePadding + CGFloat(pos.x) * (tileWidth + tilePadding)
        let r    = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        let tile = TileView(position: CGPointMake(x, y), width: tileWidth, value: value, radius: r, appearanceDelegate: appearanceProvider)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        
        addSubview(tile)
        bringSubviewToFront(tile)
        tiles[NSIndexPath(forRow: pos.x, inSection: pos.y)] = tile
        
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: .TransitionNone,
            animations: {
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            },
            completion: { finished in
                UIView.animateWithDuration(self.tileContractTime, animations: { () -> Void in
                    tile.layer.setAffineTransform(CGAffineTransformIdentity)
                })
        })
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        
        assert(positionIsValid(from) && positionIsValid(to))
        
        let (fromRow, fromCol) = from
        let (toRow, toCol)     = to
        let fromKey            = NSIndexPath(forRow: fromRow, inSection: fromCol)
        let toKey              = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tile = tiles[fromKey] else {
            assert(false, "Error for tiles in moveOneTile")
        }
        
        let endTile = tiles[toKey]
        
        var finalFrame = tile.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol) * (tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow) * (tileWidth + tilePadding)
        
        tiles.removeValueForKey(fromKey)
        tiles[toKey] = tile
        
        let shouldPop = endTile != nil
        UIView.animateWithDuration(perSquareSlideDuration, delay: 0.0, options: .BeginFromCurrentState,
            animations: {
                tile.frame = finalFrame
            },
            completion: { (finished: Bool) -> Void in
                tile.value = value
                endTile?.removeFromSuperview()
                if !shouldPop || !finished {
                    return
                }
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                // Pop tile
                UIView.animateWithDuration(self.tileMergeExpandTime,
                    animations: {
                        tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    },
                    completion: { finished in
                        // Contract tile to original size
                        UIView.animateWithDuration(self.tileMergeContractTime) {
                            tile.layer.setAffineTransform(CGAffineTransformIdentity)
                        }
                })
        })
    }
    
    func moveTwoTiles(from: (a: (Int, Int), b:(Int, Int)), to: (Int, Int), value: Int) {
        
        assert(positionIsValid(from.a) && positionIsValid(from.b) && positionIsValid(to))

        let (fromRowA, fromColA) = from.a
        let (fromRowB, fromColB) = from.b
        let (toRow, toCol)       = to
        
        let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
        let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
        let toKey    = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "Error for tiles in moveTwoTiles: tileA")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "Error for tiles in moveTwoTiles: TileB")
        }
        
        // Make the frame
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)
        
        // Update the state
        let oldTile = tiles[toKey]  // TODO: make sure this doesn't cause issues
        oldTile?.removeFromSuperview()
        tiles.removeValueForKey(fromKeyA)
        tiles.removeValueForKey(fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animateWithDuration(perSquareSlideDuration, delay: 0.0, options: .BeginFromCurrentState,
            animations: {
                tileA.frame = finalFrame
                tileB.frame = finalFrame
            },
            completion: { finished in
                tileA.value = value
                tileB.removeFromSuperview()
                if !finished {
                    return
                }
                tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                // Pop tile
                UIView.animateWithDuration(self.tileMergeExpandTime,
                    animations: {
                        tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    },
                    completion: { finished in
                        UIView.animateWithDuration(self.tileMergeContractTime) {
                            tileA.layer.setAffineTransform(CGAffineTransformIdentity)
                        }
                })
        })
    }
}