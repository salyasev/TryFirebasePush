//
//  NotificationViewController.swift
//  TryFirebasePushExtention
//
//  Created by Sergey Alyasev on 30/10/2017.
//  Copyright © 2017 Convergent Media Group. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

/*
 Need set myNotificationCategory in Info.plist. The same category should be used for sending push on server side.
 This extension will run for only the myNotificationCategory notifications. If an extension has another category, it will not run.
 Remember to do this. If you forget this, the extension it will not work for you.
 */

/*
 There is a way to test extention via firebase.
 Firebase console doesn't have ability to set category, due to is's ios specific.
 But we can use HTTP requests to send push:
 POST https://fcm.googleapis.com/fcm/send
 - Headers:
 Authorization - key=AAAA9BysAS8:APA91bGcOAOlq2iOt5ETpwxBZMiDUYr-NWp8YCmbx-8zVJKoedyAqyN5WAjzY84tfN6ZGhqFL0pC_ob49nELpdL64VQeZ3-ilyRjDeoW9T71ZRDdp91rvFqiHugVKwYaZYvH-dHI8FKS
 Content-Type - application/json
 
 - Body:
 { "notification": {
     "title": "push title",
     "text": "text",
     "click_action":"myNotificationCategory"
 },
 "to" : "eJaQHcvyehE:APA91bHjphf8aCN1M8vgYTHRgnbheCqYx-20az9C-LhqlozFrD_uq185oteTjNUM0V5t5sQmAUulY-BrFz7O0ULtrg5udORIN8buPPEFGonOrN0Ir1vROz3iCp8_j3VV8CiKztWiNH-f",
 "data": {
     "data": "DATA"
 }
 }
 
 ,where
 Authorization - server key from Firebase console
 to - FCM token
 
 
 */


class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        self.actionButton.setTitle(content.title, for: .normal)
        
    }
    
    @IBAction func customActionButtonPressed(_ sender: Any) {
        //print("custom action")
    }
}
