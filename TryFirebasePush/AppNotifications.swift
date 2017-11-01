//
//  AppNotifications.swift
//  TryFirebasePush
//
//  Created by Sergey Alyasev on 27/10/2017.
//  Copyright © 2017 Convergent Media Group. All rights reserved.
//

/*
 The server's role in the badge count
 It’s not just iOS developers who responsible for badge counts. Badge counts come from the server. Apps typically have unread notification counts maintained on the server for each user. When the server sends a push notification to a particular device, it sends the badge count along with the payload.
 Once a device receives a push notification, iOS automatically sets the badge count on your app icon to the specified value. So this value should always be up-to-date on the server side. Remember to inform the server when a message has been read so that it can reduce the badge count. It’s a simple process:
 Locally update the badge counter
 Then notify the server that the information was read by sending a request
 
 */

import UIKit
import Foundation
import UserNotifications

final class AppNotifications : NSObject {
    
    private var application: UIApplication?
    
    func setup(for application: UIApplication) {
        self.application = application

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {(granted, error) in
                if granted {
                    print("Notification access was granted")
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        // MARK: NOTE 1
        // This call will enable remote notifications in two cases:
        // 1. user had granted access to notifications
        // 2. if the app background mode is enabled
        application.registerForRemoteNotifications()
        
    }
    
    func handleNotificationInfo(withUserInfo userInfo: [AnyHashable : Any]) {
        let apsKey = "aps"
        let gcmMessage = "alert"
        let gcmLabel = "google.c.a.c_l"
        let customInfoKey = "Description"
        
        if let aps = userInfo[apsKey] as? NSDictionary {
            if let message = aps[gcmMessage] as? NSDictionary {
                DispatchQueue.main.async {
                    // let's show alert for example
                    let alert = UIAlertController(title: userInfo[gcmLabel] as? String ?? "",
                                                  message: message["body"] as? String,
                                                  preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
                    alert.addAction(dismissAction)

                    if let topController = UIApplication.topViewController() {
                        topController.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                print("user info parce error")
            }
        }
        
        // at the same let's get some other data
        if let customInfo = userInfo[customInfoKey] {
            print("customInfo: \(customInfo)")
        }
    }
    
    // call reset badge when:
    // 1. open the app
    // 2. go foreground
    // 3. press on notification
    // so we can just call it in the applicationDidBecomeActive
    func resetBadgeIcon() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // but there is one moment:
        // in this case notification will dissapear from list of notifications..
        
        // badge number received from the server.
        // So to to hadle incrementing you need to send current badge number to server and server will see.
    }
}

// Receive displayed notifications for iOS 10+ devices.
@available(iOS 10, *)
extension AppNotifications : UNUserNotificationCenterDelegate {
    
    // Called when app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Here we can handle some other backgroung tasks if background mode "Remote Notifications" is enabled in app setting
        // 1. in the target of project settings
        // 2. on the device in settings called "Background App Refresh"
        // let userInfo = notification.request.content.userInfo
        // Example: prefecth some data (photos) or sync some data
        // So do not enable it if we need only push notifications.. not nessesary
        
        // Do not handle user info here for push notifications
        // Otherwise it will some kind of trick:
        // We can send push to the app and don't notify the user, at the same time change some app setting for example
        // handleNotificationInfo(withUserInfo: userInfo)
        
        // See "Configuring a Silent Notification"
        // https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html
        
        // by default if push will received when user is in the app, the notification won't be shown.
        // But let's use completionHandler for showing system notification if app is in foreground.
        // and only if user press on notification will handle the notification in didReceive..
        completionHandler([.alert, .sound])
    }
    
    // Called when user pressed on the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        handleNotificationInfo(withUserInfo: userInfo)
        
        completionHandler()
    }
}
