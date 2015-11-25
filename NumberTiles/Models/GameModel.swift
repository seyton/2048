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

    let dimension: Int
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
        
        dimension = d
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
        if gameQueue.count == 0 {  return }
        
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

//MARK: Game Tile Methods
extension GameModel {
    
    func insertTile(position: (Int, Int), value: Int) {
        
        let (x, y) = position
        
        if case .Empty = gameBoard[x,y] {
            
            gameBoard[x,y] = TileObject.Tile(value)
            delegate.insertTile(position, value: value)
        }
    }
    
    func insertRandomTileLocation(value: Int) {
        
        let slots = emptySlots()
        if slots.isEmpty { return }
        
        let index = Int(arc4random_uniform(UInt32(slots.count-1)))
        let (x, y) = slots[index]
        
        insertTile((x, y), value: value)
    }
    
    func emptySlots() -> [(Int, Int)] {
        var emptySlots = [(Int, Int)]()
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                if case .Empty = gameBoard[i, j] {
                    emptySlots += [(i, j)]
                }
            }
        }
        return emptySlots
    }
}

//MARK: Game Logic
extension GameModel {
    
    func tileBelowHasSameValue(location: (Int, Int), _ value: Int) -> Bool {
        
        let (x, y) = location
        
        guard y != dimension - 1 else { return false }
        
        if case let .Tile(v) = gameBoard[x, y+1] {
            return v == value
        }
        
        return false
    }
    
    func tileToRightHasSameValue(location: (Int, Int), _ value: Int) -> Bool {
        
        let (x, y) = location
        
        guard x != dimension - 1 else { return false }
        
        if case let .Tile(v) = gameBoard[x+1, y] {
            return v == value
        }
        
        return false
    }
    
    func gameWon() -> (Bool, (Int, Int)?) {
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                
                if case let .Tile(v) = gameBoard[i, j] where v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    func gameOver() -> Bool {
        
        guard emptySlots().isEmpty else { return false }
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameBoard[i, j] {
                case .Empty:
                    assert(false, "Gameboard reported itself as full, but there is still an empty tile.")
                case let .Tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
}

//MARK: - Game Movements
extension GameModel {
    
    func performMove(direction: MoveDirection) -> Bool {
        
        let cellGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) -> [(Int, Int)] in
            
            var cell = Array<(Int, Int)>(count: self.dimension, repeatedValue: (0,0))
            
            for i in 0..<self.dimension {
                switch direction {
                case .Up: cell[i]    = (i, iteration)
                case .Down: cell[i]  = (self.dimension - i - 1, iteration)
                case .Left: cell[i]  = (iteration, i)
                case .Right: cell[i] = (iteration, self.dimension - i - 1)
                }
            }
            return cell
        }
        
        var atLeastOneMoreMove = false
        
        for i in 0..<dimension {
            
            let cells = cellGenerator(i)
            
            let tiles = cells.map() { (c: (Int, Int)) -> TileObject in
                let (x, y) = c
                return self.gameBoard[x, y]
            }
            
            let orders = merge(tiles)
            atLeastOneMoreMove = orders.count > 0 ? true : false
            
            for object in orders {
                
                switch object {
                    
                case let MoveOrder.SingleMoveOrder(source , destination, value, wasMerged):
                    let (sourceX, sourceY)       = cells[source]
                    let (dimensionX, dimensionY) = cells[destination]
                    
                    if wasMerged {
                        score += value
                    }
                    
                    gameBoard[sourceX, sourceY]       = TileObject.Empty
                    gameBoard[dimensionX, dimensionY] = TileObject.Tile(value)
                    delegate.moveOneTile(cells[source], to: cells[destination], value: value)
                    
                case let MoveOrder.DoubleMoveOrder(firstSource: source1, secondSource: source2, destination: destination, value: value):
                    
                    let (source1X, source1Y)         = cells[source1]
                    let (source2X, source2Y)         = cells[source2]
                    let (destinationX, destinationY) = cells[destination]
                    
                    score += value
                    
                    gameBoard[source1X, source1Y]         = TileObject.Empty
                    gameBoard[source2X, source2Y]         = TileObject.Empty
                    gameBoard[destinationX, destinationY] = TileObject.Tile(value)
                    delegate.moreTwoTiles((cells[source1], cells[source2]), to: cells[destination], value: value)
                    
                }
            }
        }
        
        return atLeastOneMoreMove
    }
    
}

//MARK: - Game Utilities
extension GameModel {
    
    func merge(tileGroup: [TileObject]) -> [MoveOrder] {
        return convert(collapse(condense(tileGroup)))
    }
    
    func convert(group: [ActionToken]) -> [MoveOrder] {
        
        var moveBuffer = [MoveOrder]()
        
        for (index, tile) in group.enumerate() {
            
            switch tile {
            
            case let .Move(source, value):
                moveBuffer.append(MoveOrder.SingleMoveOrder(source: source, destination: index, value: value, wasMerged: false))
            
            case let .SingleCombine(source, value):
                moveBuffer.append(MoveOrder.SingleMoveOrder(source: source, destination: index, value: value, wasMerged: true))
                
            case let .DoubleCombine(source1, source2, value):
                moveBuffer.append(MoveOrder.DoubleMoveOrder(firstSource: source1, secondSource: source2, destination: index, value: value))
                
            default:
                break
            }
        }
        
        return moveBuffer
    }
    
    func collapse(group: [ActionToken]) -> [ActionToken] {
        
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        
        for (index, token) in group.enumerate() {
            if skipNext {
                skipNext = false
                continue
            }
            
            switch token {
                
            case .SingleCombine:
                assert(false, "Sorry you can not have single combine token for input.")
            
            case .DoubleCombine:
                assert(false, "Sorry you can not have double combine token for input.")
                
            case let .NoAction(source, value) where (index < group.count - 1
                && value == group[index+1].getValue()
                && GameModel.inActiveTileStillInActive(index, outputLength: tokenBuffer.count, originalPosition: source)):
                
                let next = group[index + 1]
                let newValue = value + group[index + 1].getValue()
                tokenBuffer.append(ActionToken.SingleCombine(source: next.getSource(), value: newValue))
                
            case let t where (index < group.count-1 && t.getValue() == group[index + 1].getValue()):
                let next = group[index + 1]
                let newValue = t.getValue() + group[index + 1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.DoubleCombine(firstSource: t.getSource(), secondSource: next.getSource(), value: newValue))
                
            case let .NoAction(source, value) where !GameModel.inActiveTileStillInActive(index, outputLength: tokenBuffer.count, originalPosition: source):
                tokenBuffer.append(ActionToken.Move(source: source, value: value))
                
            case let .NoAction(source, value):
                tokenBuffer.append(ActionToken.NoAction(source: source, value: value))
                
            case let .Move(source, value):
                // Propagate a move
                tokenBuffer.append(ActionToken.Move(source: source, value: value))
                
            default:
                // Don't do anything
                break
            }
        }
        
        return tokenBuffer
    }
    
    func condense(group: [TileObject]) -> [ActionToken] {
        
        var tokenBuffer = [ActionToken]()
        
        for (index, tile) in group.enumerate() {
            
            switch tile {
                
            case let .Tile(value) where tokenBuffer.count == index:
                tokenBuffer.append(ActionToken.NoAction(source: index, value: value))
                
            case let .Tile(value):
                tokenBuffer.append(ActionToken.Move(source: index, value: value))
                
            default:
                break
            }
        }
        
        return tokenBuffer
    }
    
    class func inActiveTileStillInActive(inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        // Return whether or not a 'NoAction' token still represents an unmoved tile
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
}
