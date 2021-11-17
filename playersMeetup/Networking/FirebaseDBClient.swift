//
//  FirebaseReferences.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/5/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase


struct FirebaseDBClient {
    
    // MARK: - Properties
    
    private let dbObject: Database = Database.database()
    private let storageObject: Storage = Storage.storage()
    
    // MARK: - Enums
    
    enum DBPathNames: String {
        case userInfo, profileInfo, teamChat, businesses
    }
    
    enum StoragePathNames: String {
        case images
    }
    
    enum ImageType: String {
        case png
    }
    
    // MARK: - Private Helpers
    
    private func getDBReference(pathName: DBPathNames) -> DatabaseReference {
        return dbObject.reference().ref.child(pathName.rawValue)
    }
    
    private func getStorageReference(pathName: StoragePathNames) -> StorageReference {
        return storageObject.reference(withPath: pathName.rawValue)
    }
    
    // MARK: - User
    
    /// Adds the user to the list of players
    /// - Parameter user: dictionary of user ID to array of join status and location
    func addUser(user: [String: [String]], completion: @escaping (Result<String, Error>) -> Void) {
        guard let (uid, hasJoined) = user.first else {
            completion(.failure(DatabaseError.invalidInput))
            return
        }
        let userInfoRef = getDBReference(pathName: .userInfo)
        userInfoRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(uid) {
                print("User is in database")
            }
            else {
                print("Adding user to database")
                let newUser = userInfoRef.child(uid)
                newUser.setValue(hasJoined)
            }
            completion(.success(uid))
        }
    }
    
    func retrieveUserProfile(userID: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        getDBReference(pathName: .profileInfo).child(userID).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else { return }
            do {
                let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: value)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateUserProfile(userID: String, userInfo: UserInfo, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        let profileAsDictionary = userInfo.asDictionary()
        getDBReference(pathName: .profileInfo).child(userID).updateChildValues(profileAsDictionary) { error, dbRef in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(userInfo))
        }
    }
    
    // MARK: Profile Picture
    
    func uploadProfilePicture(userID: String, imageData: Data, imageType: ImageType, completion: @escaping (Result<String, Error>) -> Void) {
        let profileRef = getStorageReference(pathName: .images)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/\(imageType.rawValue)"
        
        profileRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard metadata != nil else {
                completion(.failure(ImageError.invalidMetadata))
                return
            }
            profileRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(ImageError.invalidDownloadURL))
                    return
                }
                getDBReference(pathName: .profileInfo).child("\(userID)/photoURL").setValue(downloadURL) { (error, userRef) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(downloadURL))
                }
            }
        }
    }
    
    func retrieveProfilePicture(userID: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let maxImageSize: Int64 = 5 * 1024 * 1024
        getStorageReference(pathName: .images).child(userID).getData(maxSize: maxImageSize) { (data, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(ImageError.invalidData))
                return
            }
            completion(.success(image))
        }
    }
    
    // MARK: - Locations
    
    func addNewLocations(locations: [String: Int]) {
        // make counter var - update counter on click and set ref
        // FirebaseReferences.businessesRef.setValue(self.names)
        let locationsRef: DatabaseReference = getDBReference(pathName: .businesses)
        for (name, count) in locations {
            locationsRef.observeSingleEvent(of: .value) { snapshot in
                if !snapshot.hasChild(name) {
                    // if doesnt exist add it as child to businesses
                    locationsRef.child(name).setValue(count)
                }
            }
        }
    }
    
    // MARK: - Temporary Refs
    
    static let userInfoRef = Database.database().reference().ref.child("userInfo")
    static let usersRef = Database.database().reference().ref.child("profileInfo")
    static let imagesRef = Storage.storage().reference(withPath: "images")
    static let chatRef = Database.database().reference().ref.child("teamChat")
    static let businessesRef = Database.database().reference().ref.child("businesses")
}
