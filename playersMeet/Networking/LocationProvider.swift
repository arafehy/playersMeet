//
//  LocationRetriever.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/25/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationProvider {
    func retrieveLocations(near location: CLLocation, completion: @escaping (Result<[Location], Error>) -> Void)
}
