//
//  NetworkService.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import Moya

enum YelpService {
    enum BusinessesProvider: TargetType {
        case search(_ latitute: Double, _ longitude: Double)
        var baseURL: URL {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.yelp.com"
            components.path = "/v3/businesses"
            return components.url!
        }
        var path: String {
            switch self {
            case .search:
                return "/search"
            }
        }
        var method: Moya.Method {
            return .get
        }
        var sampleData: Data {
            return Data()
        }
        
        var task: Task {
            switch self {
            case let .search(latitude, longitude):
                return .requestParameters(parameters:
                                            ["term": "Basketball court",
                                             "latitude": latitude,
                                             "longitude": longitude,
                                             "limit": 30],
                                          encoding: URLEncoding.queryString)
            }
        }
        var headers: [String : String]? {
            return ["Authorization": "Bearer \(API_Keys.Yelp)"]
        }
    }
}
