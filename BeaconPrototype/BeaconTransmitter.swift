//
//  BeaconTransmitter.swift
//  BeaconPrototype
//
//  Created by jimmy on 9/8/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class BeaconTransmitter: NSObject, CBPeripheralManagerDelegate {
    
    private let peripheralManager: CBPeripheralManager
    
    class var sharedInstance: BeaconTransmitter {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: BeaconTransmitter? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = BeaconTransmitter()
        }
        
        return Static.instance!
    }
    
    override init() {
        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        
        super.init()
        
        self.peripheralManager.delegate = self
    }
    
    func startTransmitting(region: BeaconRegion) -> Bool {
        
        let beaconData = region.getBeaconPeripheralData()
        
        if self.peripheralManager.state == .PoweredOn {
            self.peripheralManager.startAdvertising(beaconData)
            
            return true
        }

        return false
    }
    
    func stopTransmitting() {
        
        self.peripheralManager.stopAdvertising()
    }
    
    // MARK: - peripheral manager delegate
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        print("CBPeripheral state: - \(peripheral.state)")
    }
}
