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

struct YelpClient {
    static let shared = YelpClient()
    private let service = MoyaProvider<YelpService.BusinessesProvider>()
    private let decoder = JSONDecoder()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func retrieveLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
        let coordinates: CLLocationCoordinate2D = LocationManager.shared.getCoordinates()
        service.request(.search(coordinates.latitude, coordinates.longitude)) { (result) in
            switch result {
            case .success(let response):
                guard let locations = try? decoder.decode(BusinessesResponse.self, from: response.data).businesses else {
                    print("Could not decode Yelp response")
                    return
                }
                // let locations = self.decodeResponse(response)
                FirebaseManager.dbClient.addNewLocations(locations: locations)
                completion(.success(locations))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func decodeResponse(_ response: Response) -> [String: Int] {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase // letting it know camel case
        do {
            let dataDictionary = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
            var locations: [[String: Any]] = [[:]]
            locations = dataDictionary["businesses"] as? [[String: Any]] ?? [[:]]
            var names: [String: Int] = [:]
            for location in locations {
                guard let locationID = location["id"] as? String else { continue }
                if names[locationID] == nil {
                    names[locationID] = 0
                }
            }
            return names
        } catch {
            print(error)
        }
        return [:]
    }
}
