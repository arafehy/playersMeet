//
//  LocationManager.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/15/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import CoreLocation

class UserLocationService: NSObject, UserLocationProvider {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    var completion: ((Result<CLLocation, UserLocationError>) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func findUserLocation(completion: @escaping (Result<CLLocation, UserLocationError>) -> Void) {
        self.completion = completion
        switch locationManager.authStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(.failure(.userDenied))
        @unknown default:
            print("Unknown location authorization status")
            completion(.failure(.cannotBeLocated))
        }
    }
}

// MARK: - Location Manager Delegate

extension UserLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authStatus == .authorizedWhenInUse || manager.authStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.last {
            completion?(.success(location))
        } else {
            completion?(.failure(.cannotBeLocated))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(.cannotBeLocated))
    }
}
