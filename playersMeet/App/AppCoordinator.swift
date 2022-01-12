//
//  AppCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/2/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import Firebase

class AppCoordinator: Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        if let user = FirebaseAuthClient.getUser() {
            let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController, user: user, selectedTab: .locations)
            coordinate(to: tabBarCoordinator)
        }
        else {
            let signUpCoordinator = SignUpCoordinator(navigationController: navigationController)
            coordinate(to: signUpCoordinator)
        }
    }
}
