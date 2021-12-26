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
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func findUserLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            switch locationManager.authStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                continuation.resume(throwing: UserLocationError.userDenied)
                locationContinuation = nil
            @unknown default:
                print("Unknown location authorization status")
                continuation.resume(throwing: UserLocationError.cannotBeLocated)
                locationContinuation = nil
            }
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
            locationContinuation?.resume(returning: location)
        } else {
            locationContinuation?.resume(throwing: UserLocationError.cannotBeLocated)
        }
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
