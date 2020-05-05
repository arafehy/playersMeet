//
//  ProfileViewController.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 4/29/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let user: User? = Auth.auth().currentUser
    var userInfo = UserInfo(username: "", name: "", bio: "", photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userID = user?.uid {
            loadUserProfile(userID: userID)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            guard self.user == user else {
                print("Not logged in")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(identifier: "SignUpViewController")
                UIApplication.shared.keyWindow?.rootViewController = loginVC
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if handle != nil {
            Auth.auth().removeStateDidChangeListener(handle!)
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func loadUserProfile(userID: String) {
        FirebaseReferences.usersRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let name = value?["name"] as? String
            let username = value?["username"] as? String
            let bio = value?["bio"] as? String
            let photoURLString = value?["photoURL"] as? String
            
            if let _ = URL(string: photoURLString ?? "") {
                self.loadProfilePicture(userID: userID)
            }
            else {
                self.editButton.isEnabled = true
            }
            self.userInfo = UserInfo(username: username, name: name, bio: bio, photoURL: photoURLString)
            
            if self.userInfo.name.isEmpty {
                self.nameLabel.text = "No name"
            }
            else {
                self.nameLabel.text = self.userInfo.name
            }
            if self.userInfo.username.isEmpty {
                self.usernameLabel.text = "No username"
            }
            else {
                self.usernameLabel.text = self.userInfo.username
            }
            if self.userInfo.bio.isEmpty {
                self.bioTextView.text = "No bio"
            }
            else {
                self.bioTextView.text = self.userInfo.bio
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadProfilePicture(userID: String) {
        FirebaseReferences.imagesRef.child(userID).getData(maxSize: 5 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            self.profilePicture.image = UIImage(data: data)
            self.editButton.isEnabled = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.userInfo = self.userInfo
            editProfileVC.initialPhoto = self.profilePicture.image
        }
    }
}
