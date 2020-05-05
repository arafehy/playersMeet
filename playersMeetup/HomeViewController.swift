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
        
        
             do {
                     try Auth.auth().signOut()
                 }
              catch let signOutError as NSError {
                     print ("Error signing out: %@", signOutError)
                 }
                 
                 let storyboard = UIStoryboard(name: "Main", bundle: nil)
                 let initial = storyboard.instantiateInitialViewController()
                 UIApplication.shared.keyWindow?.rootViewController = initial
    }
}
