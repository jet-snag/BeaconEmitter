//
//  BeaconRegion.swift
//  BeaconPrototype
//
//  Created by jimmy on 9/8/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class ScannedBeacon: NSObject {
    
    var coreBeacon: CLBeacon
    var scannedTime: NSDate
    
    init(beacon: CLBeacon, scannedTime: NSDate) {
        
        self.coreBeacon = beacon
        self.scannedTime = scannedTime
    }
    
    func isEqualBeacon(beacon: CLBeacon) -> Bool {
        
        if self.coreBeacon.major.intValue == beacon.major.intValue && self.coreBeacon.minor.intValue == beacon.minor.intValue && self.coreBeacon.proximityUUID.UUIDString.lowercaseString == beacon.proximityUUID.UUIDString.lowercaseString {
            
            return true
        }
        
        return false
    }
}

class BeaconInfo: NSObject {
    
    let uuid: NSUUID
    let major: UInt16
    let minor: UInt16
    let desc: String
    
    init(uuid: NSUUID, major: UInt16, minor: UInt16, desc: String) {
        
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.desc = desc
        
        super.init()
    }
}

class BeaconRegion: NSObject {
    
    static let beaconIdentifer = "com.dolphi.virtualBeacon"
    let coreRegion: CLBeaconRegion
    
    init(withUUID uuid: String, major: UInt16?, minor: UInt16?) {
        
        let uuid = NSUUID(UUIDString: uuid)!
        
        if major != nil && minor != nil {
            self.coreRegion = CLBeaconRegion(proximityUUID: uuid, major: major!, minor: minor!, identifier: BeaconRegion.beaconIdentifer)
        }
        else if major != nil {
            self.coreRegion = CLBeaconRegion(proximityUUID: uuid, major: major!, identifier: BeaconRegion.beaconIdentifer)
        }
        else {
            self.coreRegion = CLBeaconRegion(proximityUUID: uuid, identifier: BeaconRegion.beaconIdentifer)
        }
        
        super.init()
    }
    
    func getBeaconPeripheralData() -> [String: AnyObject] {
        
        return NSDictionary(dictionary: self.coreRegion.peripheralDataWithMeasuredPower(nil)) as! [String: AnyObject]
    }
}