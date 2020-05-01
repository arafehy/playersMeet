//
//  ProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 4/29/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import AlamofireImage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    let user: User? = Auth.auth().currentUser
    var userRef = Database.database().reference().ref.child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard (user != nil) else {
            // TODO: Navigate to login screen
            print("Not signed in")
            return
        }

        let displayName: String = user?.displayName ?? "Name"
        guard let photoURL = user?.photoURL else {
            return
        }
        
        self.usernameLabel.text = displayName
        self.profilePicture.af.setImage(withURL: photoURL)
    }
}
