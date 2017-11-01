//
//  AppDependencies.swift
//  TryFirebasePush
//
//  Created by Sergey Alyasev on 27/10/2017.
//  Copyright © 2017 Convergent Media Group. All rights reserved.
//

import Foundation
import Firebase

// We can use APNs for sending pushes but for demo let's use firebase.
// https://firebase.google.com/docs/cloud-messaging/ios/client

final class AppDependencies: NSObject, MessagingDelegate {
    
    lazy var firebaseToken = Messaging.messaging().fcmToken
    
    func setup() {
        FirebaseApp.configure()
        
        // fcmToken used for push via Firebase console to single device.
        // but Firebase inside uses device token for sending to APNs service the push info
        // Messaging.messaging().apnsToken == deviceToken in case FCM swizzling enabled.
        // See Firebase docs: https://firebase.google.com/docs/cloud-messaging/ios/client
        print("FCM token: \(firebaseToken ?? "empty")")
    }

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        self.firebaseToken = fcmToken
        print("Firebase registration token: \(fcmToken)")
    }
    
}
