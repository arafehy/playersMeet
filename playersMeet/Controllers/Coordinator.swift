//
//  Coordinator.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 1/2/22.
//  Copyright © 2022 Yazan Arafeh. All rights reserved.
//

import Foundation

protocol Coordinator {
    func start()
    func coordinate(to coordinator: Coordinator)
}

extension Coordinator {
    func coordinate(to coordinator: Coordinator) {
        coordinator.start()
    }
}
