//
//  ChatMessage.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/30/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import Firebase

struct ChatMessage: Codable {
    let userID: String
    let username: String
    let text: String
    let createdAt: TimeInterval
    let color: String
    
    func asDictionary() -> [String: Any] {
        return ["userID": userID,
                "username": username,
                "text": text,
                "createdAt": createdAt,
                "color": color
        ]
    }
}
