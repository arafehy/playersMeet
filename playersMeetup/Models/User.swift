//
//  User.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/3/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import Foundation

struct UserInfo: Codable {
    var username: String
    var name: String
    var bio: String
    var age: String
    var photoURL: String
    var color: String
    
    init(username: String?, name: String?, bio: String?, age: String?, photoURL: String?, color: String?) {
        self.username = username ?? ""
        self.name = name ?? ""
        self.bio = bio ?? ""
        self.age = age ?? ""
        self.photoURL = photoURL ?? ""
        self.color = color ?? ""
    }
    
    func asDictionary() -> Dictionary<String, String> {
        return ["username": self.username,
                "name": self.name,
                "bio": self.bio,
                "age": self.age,
                "photoURL": self.photoURL,
                "color": self.color
        ]
    }
}
