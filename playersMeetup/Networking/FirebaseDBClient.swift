//
//  FirebaseReferences.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/5/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import Foundation
import Firebase


struct FirebaseDBClient {
    enum DBPathNames: String {
        case userInfo, profileInfo, teamChat, businessesRef
    }
    
    enum StoragePathNames: String {
        case images
    }
    
    func getDBReference(pathName: DBPathNames) -> DatabaseReference {
        return Database.database().reference().ref.child(pathName.rawValue)
    }
    
    func getStorageRefence(pathName: StoragePathNames) -> StorageReference {
        return Storage.storage().reference(withPath: pathName.rawValue)
    }
    
    /// Adds the user to the list of players
    /// - Parameter user: dictionary of user ID to array of join status and location
    func addUserToDB(user: [String: [String]]) {
        guard let (uid, hasJoined) = user.first else {
            print("Could not add user to database: Invalid user info")
            return
        }
        getDBReference(pathName: DBPathNames.userInfo).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(uid) {
                print("User is in database")
            }
            else {
                print("Adding user to database")
                let newUser = FirebaseDBClient.userInfoRef.child(uid)
                
                newUser.setValue(hasJoined)
            }
        }
    }
    
    static let userInfoRef = Database.database().reference().ref.child("userInfo")
    static let usersRef = Database.database().reference().ref.child("profileInfo")
    static let imagesRef = Storage.storage().reference(withPath: "images")
    static let chatRef = Database.database().reference().ref.child("teamChat")
    static let businessesRef = Database.database().reference().ref.child("businesses")
}
