//
//  User.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/3/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import Foundation

struct UserProfile {
    var username: String
    var fullName: String
    var bio: String
    var profilePicture: String
    
    init(username: String, fullName: String, bio: String, photoURL: String) {
        self.username = username
        self.fullName = fullName
        self.bio = bio
        self.profilePicture = photoURL
    }
    
    func asDictionary() -> Dictionary<String, String> {
        return ["username": self.username,
                "fullname": self.fullName,
                "bio": self.bio,
                "profilePicture": self.profilePicture
        ]
    }
}
