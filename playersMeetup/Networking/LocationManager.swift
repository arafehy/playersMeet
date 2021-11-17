//
//  LocationManager.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 11/15/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import CoreLocation

struct LocationManager {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private let defaultCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863)
    private var locationAuthStatus: CLAuthorizationStatus { CLLocationManager.authorizationStatus() }
    
    func getCoordinates() -> CLLocationCoordinate2D {
        switch locationAuthStatus {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            fallthrough
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            fallthrough
        case .authorized:
            return self.locationManager.location?.coordinate ?? defaultCoordinates
        
        case .restricted:
            fallthrough
        case .denied:
            fallthrough
        @unknown default:
            return defaultCoordinates
        }
    }
}
