//
//  YelpClient.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/21/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import Moya
import CoreLocation

struct YelpClient: LocationProvider {
    private let service = MoyaProvider<YelpService.BusinessesProvider>()
    private let decoder = JSONDecoder()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func retrieveLocations(near location: CLLocation, completion: @escaping (Result<[Location], Error>) -> Void) {
        service.request(.search(location.coordinate.latitude, location.coordinate.longitude)) { (result) in
            switch result {
            case .success(let response):
                guard let locations = try? decoder.decode(BusinessesResponse.self, from: response.data).businesses else {
                    print("Could not decode Yelp response")
                    return
                }
                completion(.success(locations))
                FirebaseManager.dbClient.addNewLocations(locations: locations)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
