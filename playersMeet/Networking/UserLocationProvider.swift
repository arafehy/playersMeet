//
//  UserLocationProvider.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/24/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserLocationProvider {
    func findUserLocation() async throws -> CLLocation
}

extension CLLocationManager {
    var authStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return self.authorizationStatus
        } else {
            // Fallback on earlier versions
            return CLLocationManager.authorizationStatus()
        }
    }
}
