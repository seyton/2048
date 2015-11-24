//
//  Constants.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/24/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import Foundation

enum MoveDirection {
    case Up, Down, Left, Right
}

enum MoveOrder {
    case SingleMoveOrder(source: Int, destination: Int, value: Int, wasMerged: Bool)
    case DoubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}

enum TileObject {
    case Empty
    case Tile(Int)
}

enum ActionToken {
    case NoAction(source: Int, value: Int)
    case Move(source: Int, value: Int)
    case SingleCombine(source: Int, value: Int)
    case DoubleCombine(firstSource: Int, secondSource: Int, value: Int)
    
    func getValue() -> Int {
        
        switch self {
        case let .NoAction(_, v): return v
        case let .Move(_, v): return v
        case let .SingleCombine(_, v): return v
        case let .DoubleCombine(_, _, v): return v
        }
    }
    
    func getSource() -> Int {
        
        switch self {
        case let .NoAction(s, _): return s
        case let .Move(s, _): return s
        case let .SingleCombine(s, _): return s
        case let .DoubleCombine(s, _, _): return s
        }
    }
}

struct MoveCommand {
    let direction: MoveDirection
    let completion: (Bool) -> ()
}

struct SquareGameboard<T> {
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, initialValue: T) {
        
        dimension = d
        boardArray = [T](count: d*d, repeatedValue: initialValue)
    }
    
    subscript(row: Int, col: Int) -> T {
        get {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row * dimension + col]
        }
        
        set {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            boardArray[row * dimension + col] = newValue
        }
    }
    
    mutating func setAll(item: T) {
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                self[i, j] = item
            }
        }
    }
}