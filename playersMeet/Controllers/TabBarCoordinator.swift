//
//  TabBarCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/5/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth

struct TabBarCoordinator: Coordinator {
    let navigationController: UINavigationController
    let user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        let locationsNavigationController = createLocationsController()
        let profileNavigationController = createProfileController()
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [locationsNavigationController,
                                            profileNavigationController]
        tabBarController.selectedIndex = 0
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    private func createLocationsController() -> UINavigationController {
        let locationsVC = LocationsViewController.instantiate(user: user)
        let locationsNavigationController = UINavigationController(rootViewController: locationsVC)
        locationsNavigationController.navigationItem.title = "Locations"
        locationsNavigationController.tabBarItem = UITabBarItem(title: "Locations",
                                                                image: UIImage(systemName: "location"),
                                                                selectedImage: UIImage(systemName: "location.fill"))
        return locationsNavigationController
    }
    
    private func createProfileController() -> UINavigationController {
        let profileVC = ProfileViewController.instantiate(user: user)
        let profileNavigationController = UINavigationController(rootViewController: profileVC)
        profileNavigationController.navigationItem.title = "Profile"
        profileNavigationController.tabBarItem = UITabBarItem(title: "Profile",
                                                              image: UIImage(systemName: "person.crop.circle"),
                                                              selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        return profileNavigationController
    }
}
