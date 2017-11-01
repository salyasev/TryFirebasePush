//
//  AppDelegate.swift
//  TryFirebasePush
//
//  Created by Sergey Alyasev on 24/10/2017.
//  Copyright © 2017 Convergent Media Group. All rights reserved.
//

/* Comparison – Apple Push Notification Service (APNS), Firebase Cloud Messaging (FCM)
 
 FCM has responces about status.
 
 FCM - stores 100 notifications per device ( of 28 days)
 APNs - stores 1 notifications per device ( of 28 days)
 
 FCM supports for multiple platforms
 
 FCM supports topics
 
 APNs supports advanced notifications
 
 */

/* First steps:
https://firebase.google.com/docs/cloud-messaging/ios/certs
 
*** Create the authentication key ***

To create an authentication key:

1. In your developer account, go to Certificates, Identifiers & Profiles, and under Keys, select All.
2. Click the Add button (+) in the upper-right corner.
3. Enter a description for the APNs Auth Key
4. Under Key Services, select the APNs checkbox, and click Continue.
5. Click Confirm and then Download. Save your key in a secure place. This is a one-time download, and the key cannot be retrieved later.

*** Create an App ID ***
1. Navigate to the Apple Developer Member Center and sign in.
2. Navigate to Certificates, Identifiers and Profiles.
3. In the drop down menu on the top left corner, select iOS, tvOS, watchOS if it's not already selected, then navigate to Identifiers > App IDs.
4. Click the + button to create a new App ID.
5. To create the new App ID:
     Input a Name for your App ID (e.g. Firebase Sample App)
     Choose an App ID Prefix (the default selection should be fine)
     In the App ID Suffix section, select Explicit App ID, then input your Bundle ID (e.g. com.google.samples.firebaseexample). The value of the Bundle ID should match the value that you are using in your app's Info.plist and the value that you are using to get a configuration for FCM.
     In the App Services section, make sure that Push Notifications is checked.
6. Click Continue and check that your input is correct:
7. The value of Identifier should match the concatenation of the values of the App ID Prefix and of the Bundle ID
8. Push Notifications should be Configurable
9. Click Register to create the App ID.
 
 
 *** Create the Provisioning Profile ***
To test your app while under development, you need a Provisioning Profile for development to authorize your devices to run an app that is not yet published on the App Store.

1. Navigate to the Apple Developer Member Center and sign in.
2. Navigate to Certificates, Identifiers and Profiles.
3. In the drop down menu on the top left corner, select iOS, tvOS, watchOS if it's not already selected, then navigate to Provisioning Profiles > All.
4. Click the + button to create a new Provisioning Profile.
5. Select iOS App Development as provisioning profile type, then click Continue.
6. In the drop down menu, select the App ID you want to use, then click Continue.
7. Select the iOS Development certificate of the App ID you have chosen in the previous step, then click Continue.
8. Select the iOS devices that you want to include in the Provisioning Profile, then click Continue. Make sure to select all the devices you want to use for your testing.
9. Input a name for this provisioning profile (e.g. Firebase Sample App Development Profile), then click Generate.
10. Click Download to save the Provisioning Profile to your Mac.
11. Double-click the Provisioning Profile file to install it.
 
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let appNotifications = AppNotifications()
    let appDependencies = AppDependencies()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        appDependencies.setup()
        appNotifications.setup(for: application)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        appNotifications.resetBadgeIcon()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Remote Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // device token can be used for APNs service to send pushes
        print("deviceTokenString: \(deviceToken.hexString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Fail register for remote notifications: \(error.localizedDescription)")
    }
    
    @available(iOS, deprecated: 10.0)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        appNotifications.handleNotificationInfo(withUserInfo: userInfo)
    }
    
    @available(iOS, deprecated: 10.0)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        appNotifications.handleNotificationInfo(withUserInfo: userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

