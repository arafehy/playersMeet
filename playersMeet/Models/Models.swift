//
//  Models.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation

struct BusinessesResponse: Codable {
    let businesses: [Location]
}

struct Location: Codable {
    let id: String
    let name: String
    let imageUrl: URL
    var distance: Measurement<UnitLength>
    let coordinates: Coordinate
    
    enum CodingKeys: String, CodingKey {
        case id, name, imageUrl, distance, coordinates
    }
    
    enum CoordinateCodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        coordinates = try container.decode(Coordinate.self, forKey: .coordinates)
        
        let distanceAsDouble = try container.decode(Double.self, forKey: .distance)
        distance = Measurement(value: distanceAsDouble, unit: UnitLength.meters)
    }
}

struct Coordinate: Codable {
    let latitude, longitude: Double
}

struct LocationViewModel {
    let name: String
    let imageUrl: URL
    let distance: String
    let id: String
}

extension LocationViewModel {
    init(location: Location) {
        self.name = location.name
        self.id = location.id
        self.imageUrl = location.imageUrl
        self.distance = Formatter.getReadableMeasurement(location.distance)
    }
}
