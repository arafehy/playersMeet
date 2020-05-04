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
    
    var handle: AuthStateDidChangeListenerHandle?
    
    let user: User? = Auth.auth().currentUser
    var userInfo = UserInfo(username: "", name: "", bio: "", photoURL: "")
    var usersRef = Database.database().reference().ref.child("userInfo")
    let imagesRef = Storage.storage().reference(withPath: "images")
    
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
                let loginVC = storyboard.instantiateInitialViewController()
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
        usersRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let name = value?["name"] as? String
            let username = value?["username"] as? String
            let bio = value?["bio"] as? String
            let photoURLString = value?["photoURL"] as? String
            if let photoURL = URL(string: photoURLString ?? "") {
                self.profilePicture.af.setImage(withURL: photoURL)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.userInfo = self.userInfo
            if userInfo.profilePicture != "" {
                editProfileVC.profilePicture.image = self.profilePicture.image
            }
        }
    }
}
