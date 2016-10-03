//
//  SearchViewController.swift
//  BeaconPrototype
//
//  Created by jimmy on 9/8/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    private let virtualUUID = "368EC032-4117-4A35-A91A-FD1FB5B6892C"
    
    private var observingUUID: NSUUID!
    private var observingBeacons = [BeaconInfo]()
    
    private var searching: Bool = false
    
    private var foundBeacons: [CLBeacon]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Load CSV file
        let formatter = NSNumberFormatter()
        
        do {
           
            let beaconFeed = try NSString(contentsOfURL: Configuration.feedURL, encoding: NSUTF8StringEncoding)
            let brokenByLines = beaconFeed.componentsSeparatedByString("\n")
            
            for (i, line) in brokenByLines.enumerate() {
                if line.characters.count < 1 {
                    continue
                }
                
                if i == 0 {
                    // UUID
                    self.observingUUID = NSUUID(UUIDString: line)!
                }
                else {
                    
                    let fields = line.componentsSeparatedByString(",")
                    
                    var majorNumber: UInt16? = nil
                    if let major = formatter.numberFromString(fields[0]) where major.intValue >= 0 {
                        majorNumber = major.unsignedShortValue
                    }
                    
                    var minorNumber: UInt16? = nil
                    if let minor = formatter.numberFromString(fields[1]) where minor.intValue >= 0 {
                        minorNumber = minor.unsignedShortValue
                    }
                    
                    let desc = fields[2]
                    
                    if majorNumber != nil && minorNumber != nil && desc.characters.count > 0 {
                        
                        let beaconInfo = BeaconInfo(uuid: self.observingUUID, major: majorNumber!, minor: minorNumber!, desc: desc)
                        self.observingBeacons.append(beaconInfo)
                    }
                }
            }
            
            BeaconManager.sharedInstance.setupRegionToMonitor(self.observingUUID)
        }
        catch {
            
            
        }
        
        // self.beaconRegion.append( BeaconRegion(withUUID: "368EC032-4117-4A35-A91A-FD1FB5B6892C", major: nil, minor: nil) )
        
        BeaconManager.sharedInstance.delegate = self
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        BeaconManager.sharedInstance.triggerBeaconService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapSearchBeacon(sender: UIButton) {
        
        searching = !searching
        if searching {
            sender.setTitle("Scanning... Stop?", forState: .Normal)
            
            BeaconManager.sharedInstance.startMonitoring()
            // BeaconManager.sharedInstance.startRanging()
        }
        else {
            sender.setTitle("Start Scanning", forState: .Normal)
            
            BeaconManager.sharedInstance.stop()
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let foundBeacons = self.foundBeacons {
            return foundBeacons.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell")!
        
        let beacon = self.foundBeacons![indexPath.row]
        cell.textLabel?.text = beacon.proximityUUID.UUIDString + " (\(beacon.rssi) dB)"
        
        return cell
    }
}

extension SearchViewController: BeaconManagerDelegate {
    
    func reloadTableView(beacons: [CLBeacon]) {
        
        self.foundBeacons = beacons
        
        if self.foundBeacons?.count > 0 {
            self.placeholderLabel.hidden = true
        }
        else {
            self.placeholderLabel.hidden = false
        }
        
        self.tableView.reloadData()
    }
    
    func didBeaconsFound(beacons: [CLBeacon]) {
        
        reloadTableView(beacons)
    }
    
    func didVicinityBeaconsFound(beacons: [CLBeacon], newBeacon: CLBeacon?) {
        
        // generate local notification
        if UIApplication.sharedApplication().applicationState == .Background && newBeacon != nil {
            
            for observingBeacon in self.observingBeacons {
                if observingBeacon.major == newBeacon?.major.unsignedShortValue && observingBeacon.minor == newBeacon?.minor.unsignedShortValue {
                    LocalRemoteNotificationManager.generateLocalNotificationWithContent("Found \(observingBeacon.desc)", userInfo: nil)
                    break
                }
            }
            
        }
        
        reloadTableView(beacons)
    }
    
    func didEnterRegion() {
        
        // generate local notification
        if UIApplication.sharedApplication().applicationState == .Background {
            LocalRemoteNotificationManager.generateLocalNotificationWithContent("Entered to beacon region", userInfo: nil)
        }
    }
    
    func didLeaveRegion() {
        
        // generate local notification
        if UIApplication.sharedApplication().applicationState == .Background {
            LocalRemoteNotificationManager.generateLocalNotificationWithContent("Leaved from beacon region", userInfo: nil)
        }
    }
}
