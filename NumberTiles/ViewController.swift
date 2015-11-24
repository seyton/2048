//
//  ViewController.swift
//  NumberTiles
//
//  Created by Wesley Matlock on 11/24/15.
//  Copyright © 2015 insoc.net. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func startGameAction(sender: UIButton) {
        let gameVC = NumberTileGameViewController(dimension: 4, threshold: 2048)
        presentViewController(gameVC, animated: true, completion: nil)
    }
}

