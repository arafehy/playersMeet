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
    
    enum YelpError: Error {
        case decodingError
    }
    
    func retrieveLocations(near location: CLLocation) async throws -> [Location] {
        let locations: [Location] = try await withCheckedThrowingContinuation({ continuation in
            service.request(.search(location.coordinate.latitude, location.coordinate.longitude)) { result in
                switch result {
                case .success(let response):
                    guard let locations = try? decoder.decode(BusinessesResponse.self, from: response.data).businesses else {
                        continuation.resume(throwing: YelpError.decodingError)
                        print("Could not decode Yelp response")
                        return
                    }
                    continuation.resume(returning: locations)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
        return locations
    }
}
