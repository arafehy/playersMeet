//
//  NetworkService.swift
//  playersMeetup
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import Foundation
import Moya
private let apiKey = "c6U-Y7eT1kS2ksM6uU_OUE5jdbrYU5cPYwpDpzyz5x98MMwHjRNrwr12essjSoYTIqR2VQFzHULybt1AUeHOInWxPGr6CydkHzioRYScXvmte7aaR2Wrs4Z3wiakXnYx"
enum YelpService {
    enum BusinessesProvider: TargetType{
        case search(lat: Double, long: Double)
        var baseURL: URL{
            return URL(string: "https://api.yelp.com/v3/businesses")!
        }
        var path: String{
            switch self {
            case .search:
                return "/search"
            }
        }
        var method: Moya.Method{
            return .get
        }
        var sampleData: Data{
            return Data()
        }
    
        var task: Task{
            switch self{
            case let .search(lat,long):
                return .requestParameters(parameters: ["term":"Basketball court" ,"latitude": lat, "longitude": long, "limit": 50], encoding: URLEncoding.queryString )
            }
        }
        var headers: [String : String]?{
            return ["Authorization": "Bearer \(apiKey)"]
        }
    }
}
