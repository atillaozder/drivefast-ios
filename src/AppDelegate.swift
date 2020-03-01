//
//  AppDelegate.swift
//  Retro Car Racing
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var interstitialIdentifier: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/4411468910"
        #else
        return "ca-app-pub-3176546388613754/6987129300"
        #endif
    }
    
    static var rewardBasedVideoAdIdentifier: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/1712485313"
        #else
        return "ca-app-pub-3176546388613754/7634389777"
        #endif
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        GADRewardBasedVideoAd
            .sharedInstance()
            .load(.init(), withAdUnitID: AppDelegate.rewardBasedVideoAdIdentifier)
                
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
