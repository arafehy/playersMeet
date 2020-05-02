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
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let user: User? = Auth.auth().currentUser
    var userRef = Database.database().reference().ref.child("userInfo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = loginVC
                self.dismiss(animated: true, completion: nil)
                return
            }
        }
        
        let displayName: String = user?.displayName ?? "Name"
        guard let photoURL = user?.photoURL else {
            return
        }
        
        self.usernameLabel.text = displayName
        self.profilePicture.af.setImage(withURL: photoURL)
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
