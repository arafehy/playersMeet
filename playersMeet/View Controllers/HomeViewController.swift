//
//  HomeViewController.swift
//  playersMeet
//
//  Created by Risha Ray on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        overrideUserInterfaceStyle = .light
    }
    
    @IBAction func onLogout(_ sender: Any) {
        FirebaseAuthClient.signOut()
        Navigation.goToSignUp(window: self.view.window)
    }
}
