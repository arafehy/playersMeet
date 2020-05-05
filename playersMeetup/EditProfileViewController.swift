//
//  CreateProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/2/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var createProfileButton: UIBarButtonItem!
    
    var userInfo: UserInfo?
    let user = Auth.auth().currentUser
    var initialUserInfo: [String] = Array(repeating: "", count: 3)
    var isNameDifferent: Bool {
        nameField.text != initialUserInfo[0]
    }
    var isUsernameDifferent: Bool {
        usernameField.text != initialUserInfo[1]
    }
    var isBioDifferent: Bool {
        let bio = bioTextView.text
        return bio != initialUserInfo[2] && bio != "Enter a bio..."
    }
    var isAnythingDifferent: Bool {
        isNameDifferent || isUsernameDifferent || isBioDifferent
    }
    var areNameOrUsernameEmpty: Bool {
        nameField.text?.isEmpty ?? true || usernameField.text?.isEmpty ?? true
    }
    
    let usersRef = Database.database().reference(withPath: "profileInfo")
    let imagesRef = Storage.storage().reference(withPath: "images")
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        usernameField.delegate = self
        bioTextView.delegate = self
        
        guard let info = userInfo else {    // Creating profile after signup
            self.bioTextView.text = "Enter a bio..."
            self.userInfo = UserInfo(username: "", name: "", bio: "", photoURL: "")
            return
        }
        
        guard !info.bio.isEmpty else {
            self.bioTextView.text = "Enter a bio..."
            return
        }
        
        initialUserInfo[0] = info.name
        initialUserInfo[1] = info.username
        initialUserInfo[2] = info.bio
        
        self.nameField.text = info.name
        self.usernameField.text = info.username
        self.bioTextView.text = info.bio
        
    }
    
    // MARK: - Profile Updating
    
    @IBAction func saveProfile(_ sender: UIBarButtonItem) {
        guard let userID = user?.uid else {
            return
        }
        guard self.nameField.text! != initialUserInfo[0] || self.usernameField.text != initialUserInfo[1] || self.bioTextView.text != initialUserInfo[2] else {
            print("Nothing changed")
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
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileVC = storyboard.instantiateInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = profileVC
                    return
            }
            self.dismiss(animated: true) {
                profileVC.loadUserProfile(userID: userID)
            }
        }
    }
    
    // MARK: - Text Fields/View Helpers
    
    @IBAction func nameChanged(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    @IBAction func usernameChanged(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }        
    
    func textViewDidChange(_ textView: UITextView) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    @IBAction func nameEndedEdit(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    @IBAction func usernameEndedEdit(_ sender: UITextField) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard isAnythingDifferent, !areNameOrUsernameEmpty else {
            saveButton.isEnabled = false
            createProfileButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
        createProfileButton.isEnabled = true
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
