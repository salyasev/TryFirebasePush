//
//  ViewController.swift
//  TryFirebasePush
//
//  Created by Sergey Alyasev on 24/10/2017.
//  Copyright © 2017 Convergent Media Group. All rights reserved.
//

import UIKit
import Firebase

enum ButtonPrefix: String {
    case Subscribe
    case Unsubscribe
    
    mutating func next() {
        switch self {
        case .Subscribe:
           self = .Unsubscribe
        case .Unsubscribe:
            self = .Subscribe
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var subscribeNewsButton: UIButton!
    var buttonPrefix: ButtonPrefix = .Subscribe
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        subscribeNewsButton.setTitle("\(buttonPrefix)", for: .normal)
    }

    @IBAction func subscribeNewsButtonPressed(_ sender: UIButton) {

        switch buttonPrefix {
        case .Subscribe:
            Messaging.messaging().subscribe(toTopic: "news")
        case .Unsubscribe:
            Messaging.messaging().unsubscribe(fromTopic: "news")
        }
        
        buttonPrefix.next()
        sender.setTitle("\(buttonPrefix)", for: .normal)
    }
    
}

