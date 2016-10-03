//
//  BeaconManager.swift
//  BeaconPrototype
//
//  Created by jimmy on 9/7/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import Foundation
import CoreLocation

protocol BeaconManagerDelegate: NSObjectProtocol {
    
    func didVicinityBeaconsFound(beacons: [CLBeacon], newBeacon: CLBeacon?)
    func didBeaconsFound(beacons: [CLBeacon])
    func didEnterRegion()
    func didLeaveRegion()
}

class BeaconManager: NSObject, CLLocationManagerDelegate {
    let locationManager: CLLocationManager
    
    weak var delegate: BeaconManagerDelegate?
    
    var regionToMonitor: CLBeaconRegion?
    
    var currentScannedBeacon = [ScannedBeacon]()
    var previousScannedBeacon = [ScannedBeacon]()
    
    private let kScanTimeout: Double = 13
    private var lastDelegateTime: NSDate
    
    class var sharedInstance: BeaconManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: BeaconManager? = nil
        }
        
        dispatch_once(&Static.onceToken) { 
            Static.instance = BeaconManager()
        }
        
        return Static.instance!
    }
    
    static func isLocationServiceEnable() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .Restricted || authStatus == .Denied {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    override init() {
        
        self.locationManager = CLLocationManager()
        self.lastDelegateTime = NSDate()
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.pausesLocationUpdatesAutomatically = true
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: - CoreLocation Service
    // --------------------------------------------------------------------------------------------------
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print(">>>> didEnterRegion")
        
        if region.isKindOfClass(CLBeaconRegion.self) {
            
            let beaconRegion = region as! CLBeaconRegion
            if beaconRegion.proximityUUID.UUIDString == self.regionToMonitor?.proximityUUID.UUIDString {
                self.delegate?.didEnterRegion()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print(">>>> didExitRegion")
        
        if region.isKindOfClass(CLBeaconRegion.self) {
            
            let beaconRegion = region as! CLBeaconRegion
            if beaconRegion.proximityUUID.UUIDString == self.regionToMonitor?.proximityUUID.UUIDString {
                self.delegate?.didLeaveRegion()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
     
        for foundBeacon in beacons {

            print("found beacon = \(foundBeacon.proximityUUID.UUIDString) - \(foundBeacon.major) - \(foundBeacon.minor)")
            print("rssi \(foundBeacon.rssi) prox \(foundBeacon.proximity.rawValue) accuracy \(foundBeacon.accuracy)")
            
            var exist: Bool = false
            var existingIndex: Int = 0
            
            for (i, beacon) in self.currentScannedBeacon.enumerate() {
                
                if beacon.isEqualBeacon(foundBeacon) == true {
                    beacon.scannedTime = NSDate()
                    exist = true
                    existingIndex = i
                    break
                }
            }
            
            if exist == false && self.isVicinity(foundBeacon) == true {
                
                let scannedBeacon = ScannedBeacon(beacon: foundBeacon, scannedTime: NSDate())
                self.currentScannedBeacon.append(scannedBeacon)
            }
            else if exist == true && self.isVicinity(foundBeacon) == false {
                
                // need to remove this one
                self.currentScannedBeacon.removeAtIndex(existingIndex)
            }
            
            // Remove outdated Beacons
            var removingBeacons = [Int]()
            let currentTime = NSDate().timeIntervalSince1970
            for (i, beacon) in self.currentScannedBeacon.enumerate() {
                
                if beacon.scannedTime.timeIntervalSince1970 - currentTime > kScanTimeout {
                    removingBeacons.append(i)
                }
            }
            
            var offset = 0
            for obj in removingBeacons {
                
                self.currentScannedBeacon.removeAtIndex(obj - offset)
                offset += 1
            }
            
            // Check two array
            var isEqual: Bool = true
            var newBeacon: CLBeacon?
            
            if self.previousScannedBeacon.count != self.currentScannedBeacon.count {
                
                isEqual = false
                
                for scannedBeacon in self.currentScannedBeacon {
                    
                    var isExist: Bool = false
                    for foundBeacon in self.previousScannedBeacon {
                        if scannedBeacon.isEqualBeacon(foundBeacon.coreBeacon) {
                            isExist = true
                            break
                        }
                    }
                    
                    if isExist == false {
                        newBeacon = scannedBeacon.coreBeacon
                        break
                    }
                }
            }
            else {
                
                for foundBeacon  in self.previousScannedBeacon {
                    
                    var isExist: Bool = false
                    for scannedBeacon in self.currentScannedBeacon {
                        if scannedBeacon.isEqualBeacon(foundBeacon.coreBeacon) {
                            isExist = true
                            break
                        }
                    }
                    
                    if isExist == false {
                        isEqual = false
                        newBeacon = foundBeacon.coreBeacon
                        
                        break
                    }
                }
            }
            
            // Inform to Delegate
            if isEqual == false {
                
                self.previousScannedBeacon.removeAll()
                self.previousScannedBeacon.appendContentsOf(self.currentScannedBeacon)
                
                var arrayBeacons = [CLBeacon]()
                for beacon in self.currentScannedBeacon {
                    arrayBeacons.append(beacon.coreBeacon)
                }
                
                self.delegate?.didVicinityBeaconsFound(arrayBeacons, newBeacon: newBeacon)
                self.lastDelegateTime = NSDate()
            }
            else {
                
                if currentTime - self.lastDelegateTime.timeIntervalSince1970 > 10 {
                
                    var arrayBeacons = [CLBeacon]()
                    for beacon in self.currentScannedBeacon {
                        arrayBeacons.append(beacon.coreBeacon)
                    }
                    
                    self.delegate?.didBeaconsFound(arrayBeacons)
                    self.lastDelegateTime = NSDate()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        print(">>>> didDetermineState with state = \(state.rawValue) region = \(region.identifier))")
        
        if region.isKindOfClass(CLBeaconRegion.self) == true {
            let beaconRegion = region as! CLBeaconRegion
            
            if state == .Inside {
                self.locationManager.startRangingBeaconsInRegion(beaconRegion)
                
//                if beaconRegion.proximityUUID.UUIDString == self.regionToMonitor?.proximityUUID.UUIDString {
//                    self.delegate?.didEnterRegion()
//                }
            }
            else {
                self.locationManager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
                
//                if beaconRegion.proximityUUID.UUIDString == self.regionToMonitor?.proximityUUID.UUIDString {
//                    self.delegate?.didLeaveRegion()
//                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        
        print(">>>> didStartMonitoringForRegion")
    }
    
    // --------------------------------------------------------------------------------------------------
    // MARK: - Visible beacon?
    // --------------------------------------------------------------------------------------------------
    func isVicinity(beacon: CLBeacon) -> Bool {
        
        if beacon.proximity == .Far || beacon.proximity == .Near || beacon.proximity == .Immediate {
            return true
        }
        
        return false
    }
    
    // --------------------------------------------------------------------------------------------------
    // MARK: - Beacon Monitoring Service
    // --------------------------------------------------------------------------------------------------
    func setupRegionToMonitor(regionUUID: NSUUID) {
        
        self.regionToMonitor = CLBeaconRegion(proximityUUID: regionUUID, identifier: "com.dolphi.virtualBeacon")
    }
    
    func stop() {
        
        if let regionToMonitor = self.regionToMonitor {
            self.locationManager.stopMonitoringForRegion(regionToMonitor)
            self.locationManager.stopRangingBeaconsInRegion(regionToMonitor)
        }
    }
    
    func startMonitoring() {
        
        if let regionToMonitor = self.regionToMonitor {
            
            self.regionToMonitor?.notifyEntryStateOnDisplay = true
            self.regionToMonitor?.notifyOnEntry = true
            self.regionToMonitor?.notifyOnExit = true
            self.locationManager.startMonitoringForRegion(regionToMonitor)
        }
    }
    
    func startRanging() {
        
        if let regionToMonitor = self.regionToMonitor {
            self.locationManager.startRangingBeaconsInRegion(regionToMonitor)
        }
    }
    
    // --------------------------------------------------------------------------------------------------
    // MARK: - Beacon Service & Location Manager Delegate
    // --------------------------------------------------------------------------------------------------
    func triggerBeaconService() {
        
        if CLLocationManager.locationServicesEnabled() {
            if self.locationManager.respondsToSelector(#selector( CLLocationManager.requestAlwaysAuthorization )) == true {
                if CLLocationManager.authorizationStatus() == .NotDetermined {
                    self.locationManager.requestAlwaysAuthorization()
                }
                else if CLLocationManager.authorizationStatus() == .Denied {
                    
                }
            }
            else {
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            
        }
        else {
            
        }
    }
}
