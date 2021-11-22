//
//  ProfileViewController.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 4/29/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage
import Foundation
import Lottie
class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var lottieView: UIView!
    static var assignedStringColor: String = UIColor.toHexString(UIColor.random)()
    var handle: AuthStateDidChangeListenerHandle?
    let animationView = AnimationView()
    let user: User? =  FirebaseAuthClient.getUser()
    var userInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "",color: "")
    var teammateID: String?
    
    // MARK: - VC Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoopingAnimation(animationName: .bouncingBall, animationView: animationView, lottieView: lottieView)
        
        if let teammateID = teammateID {
            loadUserProfile(userID: teammateID)
        }
        else if let userID = user?.uid {
            loadUserProfile(userID: userID)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = FirebaseAuthClient.addLoginStateListener(currentUser: self.user) { [unowned self] isSignedIn in
            if !isSignedIn {
                Navigation.goToSignUp(window: self.view.window)
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = handle {
            FirebaseAuthClient.removeLoginStateListener(handle: handle)
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        FirebaseAuthClient.signOut()
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Profile Loading
    
    func loadUserProfile(userID: String) {
        FirebaseManager.dbClient.retrieveUserProfile(userID: userID) { [unowned self] (result) in
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
                self.userInfo.color = ProfileViewController.self.assignedStringColor
                if let _ = URL(string: self.userInfo.photoURL) {
                    self.loadProfilePicture(userID: userID)
                }
                else {
                    self.editButton.isEnabled = true
                }
                self.setLabelTexts()
            case .failure(let error):
                print("Could not load profile: \(error)")
            }
        }
    }
    
    func loadProfilePicture(userID: String) {
        FirebaseManager.dbClient.retrieveProfilePicture(userID: userID) { [unowned self] result in
            switch result {
            case .success(let image):
                self.profilePicture.image = image
                self.profilePicture.configureProfilePicture()
                self.editButton.isEnabled = true
            case .failure(let error):
                // TODO: Set placeholder image
                // self.profilePicture.image = placeholderProfilePicture
                self.showErrorAlert(with: error)
                print("Error retrieving image: \(error)")
            }
        }
    }
    
    func setLabelTexts() {
        self.nameLabel.text = self.userInfo.name.isEmpty ? "No name" : self.userInfo.name
        self.usernameLabel.text = self.userInfo.username.isEmpty ? "No username" : self.userInfo.username
        self.bioTextView.text = self.userInfo.bio.isEmpty ? "No bio" : self.userInfo.bio
        self.ageLabel.text = self.userInfo.age.isEmpty ? "No age" : "Age: \(self.userInfo.age)"
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfile" {
            let editProfileVC = segue.destination as! EditProfileViewController
            editProfileVC.userInfo = self.userInfo
            editProfileVC.originalPhoto = self.profilePicture.image
        }
    }
}
