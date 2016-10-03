//
//  CentralManager.swift
//  BeaconPrototype
//
//  Created by jimmy on 10/3/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class CentralManager: NSObject, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    
    class var sharedInstance: CentralManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: CentralManager? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = CentralManager()
        }
        
        return Static.instance!
    }
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "com.dolphi.centralManagerIdentifier"])
    }
    
    // ------------------------------------------------------------------------------------------------
    // MARK: - CBCentralManagerDelegate
    // ------------------------------------------------------------------------------------------------
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("centralManager willRestoreState = \(central.state.rawValue)")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("centralManager didUpdateState = \(central.state.rawValue)")
        
        // generate local notification in case of bluetooth off
        if central.state == .PoweredOff && UIApplication.sharedApplication().applicationState == .Background {
            LocalRemoteNotificationManager.generateLocalNotificationWithContent("Bluetooth turned off! Turn Bluetooth on to find nearby beacons!", userInfo: nil)
        }
    }
}
