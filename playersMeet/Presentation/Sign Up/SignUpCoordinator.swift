//
//  SignUpCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/5/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit

protocol SignUpFlow {
    func signIn()
    func signUp()
}

struct SignUpCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let signUpVC = SignUpViewController.instantiate(coordinator: self)
        navigationController.setViewControllers([signUpVC], animated: false)
    }
}

extension SignUpCoordinator: SignUpFlow {
    func signUp() {
        guard let user = FirebaseAuthClient.getUser() else { return }
        let editProfileCoordinator = EditProfileCoordinator(navigationController: navigationController, user: user, userState: .newUser, profileImage: nil)
        coordinate(to: editProfileCoordinator)
    }
    
    func signIn() {
        guard let user = FirebaseAuthClient.getUser() else { return }
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController, user: user)
        coordinate(to: tabBarCoordinator)
    }
}
