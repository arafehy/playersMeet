//
//  EditProfileCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/5/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol EditProfileFlow {
    func updateProfile()
    func createProfile()
}

struct EditProfileCoordinator: Coordinator {
    let navigationController: UINavigationController
    let user: User
    let userState: UserState
    let profileImage: UIImage?
    
    init(navigationController: UINavigationController, user: User, userState: UserState, profileImage: UIImage?) {
        self.navigationController = navigationController
        self.user = user
        self.userState = userState
        self.profileImage = profileImage
    }
    
    func start() {
        let editProfileVC = EditProfileViewController.instantiate(user: user, userState: userState, originalPhoto: profileImage, coordinator: self)
        navigationController.show(UINavigationController(rootViewController: editProfileVC), sender: nil)
    }
}

extension EditProfileCoordinator: EditProfileFlow {
    func updateProfile() {
        guard let profileVC: ProfileViewController = navigationController.viewControllers.first(where: { viewController in
            viewController is ProfileViewController
        }) as? ProfileViewController else {
            navigationController.dismiss(animated: true)
            return
        }
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                print("Could not load updated profile")
                return
            }
            profileVC.loadUserProfile(userID: self.user.uid)
        }
    }
    
    func createProfile() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController, user: user, selectedTab: .profile)
        coordinate(to: tabBarCoordinator)
    }
}
