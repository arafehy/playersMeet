//
//  LocationDetailsCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/7/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol LocationDetailsFlow {
    func dismissDetail()
    func coordinateToChat(teamID: String)
}

class LocationDetailsCoordinator: Coordinator {
    let navigationController: UINavigationController
    let user: User
    let location: Location
    let delegate: DetailsViewControllerDelegate
    
    init(navigationController: UINavigationController, user: User, location: Location, delegate: DetailsViewControllerDelegate) {
        self.navigationController = navigationController
        self.user = user
        self.location = location
        self.delegate = delegate
    }
    
    func start() {
        let locationDetailsVC = DetailsViewController.instantiate(user: user, location: location, delegate: delegate, coordinator: self)
        navigationController.pushViewController(locationDetailsVC, animated: true)
    }
}

extension LocationDetailsCoordinator: LocationDetailsFlow {
    func dismissDetail() {
        navigationController.dismiss(animated: true)
    }
    
    func coordinateToChat(teamID: String) {
        let chatCoordinator = ChatCoordinator(navigationController: navigationController, user: user, teamID: teamID)
        coordinate(to: chatCoordinator)
    }
}
