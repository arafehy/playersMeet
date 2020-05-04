//
//  CreateProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/2/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    var userInfo: UserInfo?
    let user = Auth.auth().currentUser
    
    let usersRef = Database.database().reference(withPath: "profileInfo")
    let imagesRef = Storage.storage().reference(withPath: "images")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        
        guard let info = userInfo else {    // Creating profile after signup
            self.bioTextView.text = "Enter a bio..."
            self.userInfo = UserInfo(username: "", name: "", bio: "", photoURL: "")
            return
        }
        
        guard !info.bio.isEmpty else {
            self.bioTextView.text = "Enter a bio..."
            return
        }
        
        self.nameField.text = self.userInfo?.name
        self.usernameField.text = self.userInfo?.username
        self.bioTextView.text = self.userInfo?.bio
        
    }
    
    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        guard let userID = user?.uid else {
            return
        }
        self.userInfo?.name = self.nameField.text!
        self.userInfo?.username = self.usernameField.text!
        self.userInfo?.bio = self.bioTextView.text
        
        updateProfile(userID: userID)
    }
    
    func updateProfile(userID: String) {
        guard let profileAsDictionary = userInfo?.asDictionary() else {
            print("Failed to convert to dictionary")
            return
        }
        usersRef.child(userID).updateChildValues(profileAsDictionary) { (error, usersRef) in
            guard error == nil else {
                print("Failed to save profile")
                return
            }
            
            guard let tabBarController = self.presentingViewController as? UITabBarController,
                let navigationController = tabBarController.selectedViewController as? UINavigationController,
                let profileVC = navigationController.viewControllers[0] as? ProfileViewController else {
                    self.performSegue(withIdentifier: "createProfileToHome", sender: UIBarButtonItem.self)
                    return
            }
            self.dismiss(animated: true) {
                profileVC.loadUserProfile(userID: userID)
            }
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

}
