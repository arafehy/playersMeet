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
    let profileID: String
    
    let coordinator: ProfileFlow?
    
    // MARK: - VC Life Cycle
    
    static func instantiate(user: User, profileID: String, coordinator: ProfileFlow?) -> ProfileViewController {
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") { coder in
            ProfileViewController(coder: coder, user: user, profileID: profileID, coordinator: coordinator)
        }
        profileVC.navigationItem.title = "Profile"
        return profileVC
    }
    
    init?(coder: NSCoder, user: User, profileID: String, coordinator: ProfileFlow?) {
        self.user = user
        self.profileID = profileID
        self.coordinator = coordinator
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
        
        if profileID == user.uid {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile))
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        }
        loadUserProfile()
    }
    
    // MARK: - Button Actions
    
    @objc func logOut() {
        FirebaseAuthClient.signOut()
    }
    
    @objc func editProfile() {
        coordinator?.editProfile(userInfo: userInfo, profileImage: profilePicture.image)
    }
    
    @objc func doneTapped() {
        coordinator?.dismissProfile()
    }
    
    // MARK: - Profile Loading
    
    func loadUserProfile() {
        Task {
            do {
                userInfo = try await FirebaseManager.dbClient.retrieveUserProfile(userID: profileID)
                userInfo.color = ProfileViewController.self.assignedStringColor
                if let _ = URL(string: self.userInfo.photoURL) {
                    loadProfilePicture()
                } else {
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
                setLabelTexts()
            } catch {
                showErrorAlert(with: error)
                print("Could not load profile: \(error)")
            }
        }
    }
    
    func loadProfilePicture() {
        Task {
            do {
                let image = try await FirebaseManager.dbClient.retrieveProfilePicture(userID: profileID)
                profilePicture.image = image
                profilePicture.configureProfilePicture()
                navigationItem.rightBarButtonItem?.isEnabled = true
            } catch {
                showErrorAlert(with: error)
            }
        }
    }
    
    func setLabelTexts() {
        nameLabel.text = userInfo.name.isEmpty ? "No name" : userInfo.name
        usernameLabel.text = userInfo.username.isEmpty ? "No username" : userInfo.username
        bioTextView.text = userInfo.bio.isEmpty ? "No bio" : userInfo.bio
        ageLabel.text = userInfo.age.isEmpty ? "No age" : "Age: \(userInfo.age)"
    }
}
