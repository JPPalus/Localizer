//
//  WindowController.swift
//  AXDAnalyzer
//
//  Created by Olivier on 14/06/2019.
//  Copyright © 2019 AudioXD. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    var mainVC: MainVC!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        mainVC = (contentViewController as! MainVC)
    }
    
    @IBAction func didClickLoadProfileButton(_ sender: Any) {
        mainVC.loadProfile()
    }
    
    @IBAction func didClickLoadMeasurementButton(_ sender: Any) {
        mainVC.loadMeasurement()
    }
    
    @IBAction func didClickExportMeasurementButton(_ sender: Any) {
        mainVC.exportMeasurement()
    }
}
