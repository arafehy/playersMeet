//
//  LocationsCoordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/6/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol LocationsFlow {
    func coordinateToDetail(location: Location, delegate: DetailsViewControllerDelegate)
}

class LocationsCoordinator: Coordinator {
    let navigationController: UINavigationController
    let user: User
    
    init(navigationController: UINavigationController, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        let locationsVC = LocationsViewController.instantiate(user: user, coordinator: self)
        navigationController.pushViewController(locationsVC, animated: true)
    }
}

extension LocationsCoordinator: LocationsFlow {
    func coordinateToDetail(location: Location, delegate: DetailsViewControllerDelegate) {
        let locationDetailsCoordinator = LocationDetailsCoordinator(navigationController: navigationController, user: user, location: location, delegate: delegate)
        coordinate(to: locationDetailsCoordinator)
    }
}
