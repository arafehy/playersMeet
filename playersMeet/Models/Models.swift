//
//  Models.swift
//  playersMeet
//
//  Created by Nada Zeini on 4/26/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation

struct Root: Codable{
    let businesses: [Business]
}
struct Business: Codable{
    let id: String
    let name: String
    let imageUrl: URL
    let distance: Double
}
//view model for the list of courts
struct CourtListViewModel {
    let name:String
    let imageUrl:URL
    let distance: Double
    let id:String
}
extension CourtListViewModel{
    init(business: Business) {
        self.name = business.name
        self.id = business.id
        self.imageUrl = business.imageUrl
        self.distance = business.distance
    }
}
