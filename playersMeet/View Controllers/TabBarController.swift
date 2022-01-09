//
//  TabBarController.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/8/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    let coordinator: TabBarCoordinator?
    
    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
