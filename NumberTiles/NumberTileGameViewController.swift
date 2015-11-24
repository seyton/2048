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

    let boardWidth         = CGFloat(230)
    let narrowPadding      = CGFloat(3)
    let thickPadding       = CGFloat(6)
    let viewPadding        = CGFloat(10)
    let verticleVIewOffset = CGFloat(0)

    init(dimension d: Int, threshold t: Int) {
        
        dimension = d > 2 ? d : 2
        threshold = t > 8 ? t : 8
        
        super.init(nibName: nil, bundle: nil)

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
