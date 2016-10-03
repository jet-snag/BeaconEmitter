//
//  LocalRemoteNotificationManager.swift
//  BeaconPrototype
//
//  Created by jimmy on 9/8/16.
//  Copyright © 2016 Dolphi Inc. All rights reserved.
//

import UIKit

class LocalRemoteNotificationManager: NSObject {
    
    class var sharedInstance: LocalRemoteNotificationManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocalRemoteNotificationManager? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = LocalRemoteNotificationManager()
        }
        
        return Static.instance!
    }
    
    static func generateLocalNotificationWithContent(content: String, userInfo: [String: AnyObject]?) {
        let localNotification = UILocalNotification()
        localNotification.alertBody = content
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.userInfo = userInfo
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Public
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func registerRemoteNotification() {
        let types: UIUserNotificationType = [.Badge, .Sound, .Alert]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func registerLocalNotification() {
        let types: UIUserNotificationType = [.Badge, .Sound, .Alert]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(token: NSData) {
        let rawTokenStr: NSString = token.description
        let tokenStr: String = rawTokenStr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        print("device token registered = \(tokenStr)")
        
        // todo: - in case the registration finishes after post session...
        
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        
    }
    
    func didReceiveLocalNotification(notification: UILocalNotification) {
        
    }
    
    func didReceiveRemoteNotification(userInfo: [NSObject : AnyObject]) {
        
    }
}