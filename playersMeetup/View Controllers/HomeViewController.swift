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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        self.view.window?.rootViewController = initial
    }
}
