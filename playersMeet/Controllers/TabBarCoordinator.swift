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
        let locationsNavigationController = UINavigationController()
        locationsNavigationController.tabBarItem = UITabBarItem(title: "Locations",
                                                                image: UIImage(systemName: "location"),
                                                                selectedImage: UIImage(systemName: "location.fill"))
        let locationsCoordinator = LocationsCoordinator(navigationController: locationsNavigationController, user: user)
        
        let profileNavigationController = UINavigationController()
        profileNavigationController.tabBarItem = UITabBarItem(title: "Profile",
                                                              image: UIImage(systemName: "person.crop.circle"),
                                                              selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        let profileCoordinator = ProfileCoordinator(navigationController: profileNavigationController, user: user, profileID: user.uid)
        
        let tabBarController = TabBarController(coordinator: self)
        tabBarController.viewControllers = [locationsNavigationController,
                                            profileNavigationController]
        tabBarController.selectedIndex = initialTabIndex
        navigationController.setViewControllers([tabBarController], animated: true)
        navigationController.navigationBar.isHidden = true
        
        coordinate(to: locationsCoordinator)
        coordinate(to: profileCoordinator)
    }
}
