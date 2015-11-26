//
//  NumberTileGameViewController.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/24/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import UIKit

class NumberTileGameViewController: UIViewController {

    var dimension: Int
    var threshold: Int
    var board: GameBoardView?
    var gameModel: GameModel?
    var scoreView: ScoreViewDelegate?
    
    let boardWidth         = CGFloat(230)
    let narrowPadding      = CGFloat(3)
    let thickPadding       = CGFloat(6)
    let viewPadding        = CGFloat(10)
    let verticalViewOffset = CGFloat(0)

    init(dimension d: Int, threshold t: Int) {
        
        dimension = d > 2 ? d : 2
        threshold = t > 8 ? t : 8
        
        super.init(nibName: nil, bundle: nil)
        
        gameModel = GameModel(dimension: dimension, threshold: threshold, delegate: self)
        view.backgroundColor = UIColor.whiteColor()
        setupSwipeControls()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupSwipeControls() {
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("swipeUp:"))
        swipeUp.numberOfTouchesRequired = 1
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        

        let swipeDown = UISwipeGestureRecognizer(target: self, action: Selector("swipeDown:"))
        swipeDown.numberOfTouchesRequired = 1
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeft:"))
        swipeLeft.numberOfTouchesRequired = 1
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("swipeRight:"))
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
    }
    
    func setupGame() {
        
        let scoreView = ScoreView(background: .blackColor(), textColor: .whiteColor(), font:  UIFont.systemFontOfSize(16.0), radius: 6)
        scoreView.score = 0
        
        let padding: CGFloat = dimension > 5 ? narrowPadding : thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        let gameboard = GameBoardView(dimension: dimension, tileWidth: width, tilePadding: padding, cornerRadius: 6, backgroundColor: .blackColor(), foregroundColor: .darkGrayColor())
        
        let views = [scoreView, gameboard]
        
        var scoreViewFrame = scoreView.frame
        scoreViewFrame.origin.x = xPositionToCenterView(scoreView)
        scoreViewFrame.origin.y = yPositionForViewAtPosition(0, views: views)
        scoreView.frame = scoreViewFrame
        
        var gameViewFrame = gameboard.frame
        gameViewFrame.origin.x = xPositionToCenterView(gameboard)
        gameViewFrame.origin.y = yPositionForViewAtPosition(1, views: views)
        gameboard.frame = gameViewFrame
        
        
        // Add to game state
        view.addSubview(gameboard)
        board = gameboard
        view.addSubview(scoreView)
        self.scoreView = scoreView
        
        assert(gameModel != nil)
        gameModel!.insertRandomTileLocation(2)
        gameModel!.insertRandomTileLocation(2)
    }
}

//MARK: - Utility Methods
extension NumberTileGameViewController {
    
    func xPositionToCenterView(aView: UIView) -> CGFloat {
        
        let width = aView.bounds.size.width
        let posX = 0.5 * ( view.bounds.size.width - width)
        
        return posX >= 0 ? posX : 0
    }
    
    func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
        
        assert(views.count > 0)
        assert(order >= 0 && order < views.count)
        
        let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, combine: { $0 + $1 })
        let viewsTop = 0.5 * (view.bounds.size.height - totalHeight) >= 0 ? 0.5 * (view.bounds.size.height - totalHeight) : 0
        
        var newHeight = CGFloat(0)
        for i in 0..<order {
            newHeight += viewPadding + views[i].bounds.size.height
        }
        return viewsTop + newHeight
    }
    
    func gameCheck() {
        assert(gameModel != nil)
        
        let (win, _) = gameModel!.gameWon()
        if win {
            //TODO: Replace and add restart
            let alertView = UIAlertView()
            alertView.title = "Champion"
            alertView.message = "Winner! Winner! Chicken Dinner!"
            alertView.addButtonWithTitle("Cancel")
            alertView.show()
            return
        }
        
        let randomVal = Int(arc4random_uniform(10))
        gameModel?.insertRandomTileLocation(randomVal == 1 ? 4 : 2)
        
        if gameModel!.gameOver() {
         
            //TODO: need to delegate the lose and update
            let alertView = UIAlertView()
            alertView.title = "LOSER!!"
            alertView.message = "Ouch that didn't work out well."
            alertView.addButtonWithTitle("Cancel")
            alertView.show()
        }
    }
}

//MARK: - Gesture Controls
extension NumberTileGameViewController {
    
    func swipeUp(recognizer: UIGestureRecognizer) {
        assert(gameModel != nil)
                
        gameModel!.queueMove(.Up) { (changed: Bool) -> () in
            if changed {
                self.gameCheck()
            }
        }
    }
    
    func swipeDown(recognizer: UIGestureRecognizer) {
        assert(gameModel != nil)
        
        gameModel!.queueMove(.Down) { (changed: Bool) -> () in
            if changed {
                self.gameCheck()
            }
        }
    }
    
    func swipeLeft(recognizer: UIGestureRecognizer) {
        assert(gameModel != nil)
        
        gameModel!.queueMove(.Left) { (changed: Bool) -> () in
            if changed {
                self.gameCheck()
            }
        }
    }
    
    func swipeRight(recognizer: UIGestureRecognizer) {
        assert(gameModel != nil)
        
        gameModel!.queueMove(.Right) { (changed: Bool) -> () in
            if changed {
                self.gameCheck()
            }
        }
    }
}

extension NumberTileGameViewController: GameModelDelegate {
    
    func scoreChanged(score: Int) {
    
        scoreView?.scoreChanged(score)
    }
    
    func moveOneTile(from: (Int, Int), to:(Int, Int), value: Int) {
     
        board?.moveOneTile(from, to: to, value: value)
    }
    
    func moreTwoTiles(from: ((Int, Int), (Int, Int)), to:(Int, Int), value: Int) {
        board?.moveTwoTiles(from, to: to, value: value)
    }
    
    func insertTile(location: (Int, Int), value: Int) {
        
        board?.insertTile(location, value: value)
    }
}