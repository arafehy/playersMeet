//
//  HomeViewController.swift
//  playersMeetup
//
//  Created by Risha Ray on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
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
