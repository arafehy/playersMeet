//
//  SignUpCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/5/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit

protocol SignUpFlow {
    func coordinatoToHome()
}

struct SignUpCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let signUpVC = SignUpViewController.instantiate(coordinator: self)
        navigationController.pushViewController(signUpVC, animated: true)
    }
}

extension SignUpCoordinator: SignUpFlow {
    func coordinatoToHome() {
        guard let user = FirebaseAuthClient.getUser() else { return }
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController, user: user)
        coordinate(to: tabBarCoordinator)
    }
}
