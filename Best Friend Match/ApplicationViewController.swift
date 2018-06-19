//
//  ApplicationViewController.swift
//  Best Friend Match
//
//  Created by Alexander K. White on 6/18/18.
//  Copyright © 2018 Alexander K. White. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthCore


class ApplicationViewController: UIViewController {
    // Basic info
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the AWSCredentialsProvider from the AWSMobileClient
        let credentialsProvider = AWSMobileClient.sharedInstance().getCredentialsProvider()
        // Get the identity Id from the AWSIdentityManager
        let identityId = AWSIdentityManager.default().identityId
        
    }
}

