//
//  ProfileCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/6/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ProfileFlow {
    func editProfile(userInfo: UserInfo, profileImage: UIImage?)
    func dismissProfile()
    func signOut()
}

struct ProfileCoordinator: Coordinator {
    let navigationController: UINavigationController
    let user: User
    let profileID: String
    
    init(navigationController: UINavigationController, user: User, profileID: String) {
        self.navigationController = navigationController
        self.user = user
        self.profileID = profileID
    }

    func start() {
        let profileVC = ProfileViewController.instantiate(user: user, profileID: profileID, coordinator: self)
        let isFromChat = navigationController.viewControllers.last is TeamChatViewController
        if isFromChat {
            navigationController.show(UINavigationController(rootViewController: profileVC), sender: nil)
        } else {
            navigationController.show(profileVC, sender: nil)
        }
    }
}

extension ProfileCoordinator: ProfileFlow {
    func editProfile(userInfo: UserInfo, profileImage: UIImage?) {
        guard user.uid == profileID else { return }
        let editProfileCoordinator = EditProfileCoordinator(navigationController: navigationController, user: user, userState: .existingUser(userInfo), profileImage: profileImage)
        coordinate(to: editProfileCoordinator)
    }
    
    func dismissProfile() {
        navigationController.dismiss(animated: true)
    }
    
    func signOut() {
        let signUpCoordinator = SignUpCoordinator(navigationController: navigationController)
        coordinate(to: signUpCoordinator)
    }
}
