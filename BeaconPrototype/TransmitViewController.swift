//
//  TransmitViewController.swift
//  BeaconPrototype
//
//  Created by jimmy on 9/8/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import UIKit

class TransmitViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    private var advertising: Bool = false
    
    private let virtualUUID = "106d83fe-e45f-4142-93ac-d43d8d0780c6"//"368EC032-4117-4A35-A91A-FD1FB5B6892C"
    private var virtualBeacon1: BeaconRegion!
    private var virtualBeacon2: BeaconRegion!
    private var virtualBeacon3: BeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.infoLabel.text = "UUID: \(virtualUUID)\nMajor: 1\nMionr: 1"
        self.virtualBeacon1 = BeaconRegion(withUUID: self.virtualUUID, major: 1, minor: 1)
        // self.virtualBeacon2 = BeaconRegion(withUUID: self.virtualUUID, major: 1, minor: 3)
        // self.virtualBeacon3 = BeaconRegion(withUUID: self.virtualUUID, major: 1, minor: 4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapStartTransmit(sender: UIButton) {
        
        if self.advertising == true {
            BeaconTransmitter.sharedInstance.stopTransmitting()
            self.advertising = false
        }
        else {
            self.advertising = BeaconTransmitter.sharedInstance.startTransmitting(self.virtualBeacon1)
            // self.advertising = BeaconTransmitter.sharedInstance.startTransmitting(self.virtualBeacon2)
            // self.advertising = BeaconTransmitter.sharedInstance.startTransmitting(self.virtualBeacon3)
        }
        
        if self.advertising == true {
            sender.setTitle("Advertising... Stop?", forState: .Normal)
        }
        else {
            sender.setTitle("Start Advertising", forState: .Normal)
        }
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
