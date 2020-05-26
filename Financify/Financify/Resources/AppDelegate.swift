//
//  AppDelegate.swift
//  Financify
//
//  Created by Chris Gonzales on 5/22/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications() // test if this will have an affect on the notifications
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let subscription = CKQuerySubscription(recordType: "", predicate: NSPredicate(format: "PREDICATE"), options: .firesOnRecordCreation)
        let info = CKSubscription.NotificationInfo()
        info.alertBody = "A new notification has been posted!"
        info.shouldBadge = true
        info.soundName = "default"
        
        subscription.notificationInfo = info
        
        CKContainer.default().publicCloudDatabase.save(subscription) { (subscription, error) in
            if error != nil {
                NSLog("Error: \(error)")
                return
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

