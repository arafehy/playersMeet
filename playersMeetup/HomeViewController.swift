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
overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
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
    
        
            
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


