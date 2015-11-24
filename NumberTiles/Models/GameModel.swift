//
//  GameModel.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/24/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import UIKit

protocol GameModelDelegate: class {
    
    func scoreChanged(score: Int)
    func moveOneTile(from: (Int, Int), to:(Int, Int), value: Int)
    func moreTwoTiles(from: ((Int, Int), (Int, Int)), to:(Int, Int), value: Int)
    func insertTile(location: (Int, Int), value: Int)
}


class GameModel: NSObject {

    let diminsion: Int
    let threshold: Int
    
    var score: Int = 0 {
        didSet {
            delegate.scoreChanged(score)
        }
    }
    
    unowned let delegate: GameModelDelegate

    var gameBoard: SquareGameboard<TileObject>
    var gameQueue: [MoveCommand]
    var gameTimer: NSTimer
    
    let maxCommands = 100
    let queueDelay  = 0.3
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelDelegate) {
        
        diminsion = d
        threshold = t
        gameQueue = [MoveCommand]()
        gameTimer = NSTimer()
        gameBoard = SquareGameboard(dimension: d, initialValue: .Empty)
        
        self.delegate = delegate
        
        super.init()
    }
    
    func reset() {
        
        score = 0
        gameBoard.setAll(.Empty)
        gameQueue.removeAll(keepCapacity: true)
        gameTimer.invalidate()
    }
    
    func queueMove(direction: MoveDirection, completion: (Bool) -> ()) {
        
        guard gameQueue.count <= maxCommands else {
            return
        }
        
        gameQueue.append(MoveCommand(direction: direction, completion: completion))
        
        if !gameTimer.valid {
            fireTimer(gameTimer)
        }
    }
    
    func fireTimer(_: NSTimer) {
        if gameQueue.count == 0 {
            return
        }
        
        var changed = false
        
        while gameQueue.count > 0 {
            let command = gameQueue.removeFirst()
            changed = performMove(command.direction)
            command.completion(changed)
            
            if changed {
                break
            }
        }
        
        if changed {
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(queueDelay, target: self, selector: Selector("fireTimer"), userInfo: nil, repeats: false)
        }
        
    }
}

//MARK: - Game Movements
extension GameModel {
    
    func performMove(direction: MoveDirection) -> Bool {
        
        return true
    }
}


