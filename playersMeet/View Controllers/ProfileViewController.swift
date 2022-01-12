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
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var lottieView: UIView!
    static var assignedStringColor: String = UIColor.toHexString(UIColor.random)()
    let animationView = AnimationView()
    let user: User
    var userInfo = UserInfo(username: "", name: "", bio: "", age: "", photoURL: "",color: "")
    let teammateID: String?
    
    // MARK: - VC Life Cycle
    
    static func instantiate(user: User, teammateID: String? = nil) -> ProfileViewController {
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") { coder in
            ProfileViewController(coder: coder, user: user, teammateID: teammateID)
        }
        profileVC.navigationItem.title = "Profile"
        profileVC.tabBarItem = UITabBarItem(title: "Profile",
                                            image: UIImage(systemName: "person.crop.circle"),
                                            selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        return profileVC
    }
    
    init?(coder: NSCoder, user: User, teammateID: String?) {
        self.user = user
        self.teammateID = teammateID
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoopingAnimation(animation: .bouncingBall, animationView: animationView, lottieView: lottieView)
        
        if let teammateID = teammateID {
            loadUserProfile(userID: teammateID)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        }
        else {
            loadUserProfile(userID: user.uid)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseAuthClient.addLoginStateListener(currentUser: self.user) { [weak self] isSignedIn in
            if !isSignedIn { Navigation.goToSignUp(window: self?.view.window) }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseAuthClient.removeLoginStateListener()
    }
    
    // MARK: - Button Actions
    
    @objc func logOut() {
        FirebaseAuthClient.signOut()
    }
    
    @objc func editProfile() {
        let editProfileVC = EditProfileViewController.instantiate(user: user, userState: .existingUser(userInfo), originalPhoto: profilePicture.image)
        show(UINavigationController(rootViewController: editProfileVC), sender: nil)
    }
    
    @objc func doneTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Profile Loading
    
    func loadUserProfile(userID: String) {
        Task {
            do {
                userInfo = try await FirebaseManager.dbClient.retrieveUserProfile(userID: userID)
                userInfo.color = ProfileViewController.self.assignedStringColor
                if let _ = URL(string: self.userInfo.photoURL) {
                    loadProfilePicture(userID: userID)
                }
                else {
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
                setLabelTexts()
            } catch {
                showErrorAlert(with: error)
                print("Could not load profile: \(error)")
            }
        }
    }
    
    func loadProfilePicture(userID: String) {
        Task {
            do {
                let image = try await FirebaseManager.dbClient.retrieveProfilePicture(userID: userID)
                profilePicture.image = image
                profilePicture.configureProfilePicture()
                navigationItem.rightBarButtonItem?.isEnabled = true
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    func setLabelTexts() {
        self.nameLabel.text = self.userInfo.name.isEmpty ? "No name" : self.userInfo.name
        self.usernameLabel.text = self.userInfo.username.isEmpty ? "No username" : self.userInfo.username
        self.bioTextView.text = self.userInfo.bio.isEmpty ? "No bio" : self.userInfo.bio
        self.ageLabel.text = self.userInfo.age.isEmpty ? "No age" : "Age: \(self.userInfo.age)"
    }
}
