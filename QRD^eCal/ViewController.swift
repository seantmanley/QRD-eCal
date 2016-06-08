//
//  ViewController.swift
//  QRD^eCal
//
//  Created by Sean Manley on 6/7/16.
//  Copyright © 2016 Sean Manley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let panel = QRDStandardPanel.init(maxDesignWidth: 1200, maxDesignDepth: 150, designFinWidth: 3, designFrequency: 600)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

