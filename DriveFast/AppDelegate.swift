//
//  AppDelegate.swift
//  DriveFast
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import Firebase

enum RootViewControllerType {
    case splash, game
}

let applicationViewControllerState: RootViewControllerType = .splash

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var rootViewController: UIViewController {
        #if DEBUG
        switch applicationViewControllerState {
        case .splash:
            return SplashViewController()
        case .game:
            return GameViewController()
        }
        #else
        return SplashViewController()
        #endif
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = AppDelegate.rootViewController
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        window.backgroundColor = UIColor.roadColor
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: .shouldStayPausedNotification, object: nil)
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
