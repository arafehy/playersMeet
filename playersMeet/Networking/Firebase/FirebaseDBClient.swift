//
//  FirebaseReferences.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 5/5/20.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase


class FirebaseDBClient {
    
    // MARK: - Properties
    
    private let storageObject: Storage = Storage.storage()
    
    private var playerCountHandles: [String: UInt] = [:]
    
    // MARK: - Enums
    
    enum DBPaths {
        static let root = Database.database().reference().root
        static let userInfo = root.child(DBPathNames.userInfo.rawValue)
        static let profileInfo = root.child(DBPathNames.profileInfo.rawValue)
        static let teamChat = root.child(DBPathNames.teamChat.rawValue)
        static let businesses = root.child(DBPathNames.businesses.rawValue)
    }
    
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
    
    private func getStorageReference(pathName: StoragePathNames) -> StorageReference {
        return storageObject.reference(withPath: pathName.rawValue)
    }
    
    // MARK: - User
    
    func retrieveUserProfile(userID: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        DBPaths.profileInfo.child(userID).observeSingleEvent(of: .value) { snapshot in
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
        DBPaths.profileInfo.child(userID).updateChildValues(profileAsDictionary) { error, dbRef in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(userInfo))
        }
    }
    
    func getCurrentLocationID(userID: String, completion: @escaping (String?) -> Void) {
        DBPaths.userInfo.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            let locationID = snapshot.value as? String
            completion(locationID)
        }
    }
    
    func joinLocationWith(ID locationID: String, for userID: String, completion: @escaping (Bool) -> Void) {
        getCurrentLocationID(userID: userID) { (currentLocationID) in
            guard currentLocationID != locationID else {
                // User is already at this location
                completion(true)
                return
            }
            let childUpdates: [String: Any] = [
                "\(DBPathNames.userInfo.rawValue)/\(userID)": locationID,
                "\(DBPathNames.businesses.rawValue)/\(locationID)": ServerValue.increment(1)
            ]
            DBPaths.root.updateChildValues(childUpdates) { error, reference in
                if let error = error {
                    print("Data could not be saved: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func leaveLocationWith(ID locationID: String, for userID: String, completion: @escaping (Bool) -> Void) {
        getCurrentLocationID(userID: userID) { (currentLocationID) in
            guard currentLocationID == locationID else {
                // User is not at this location
                completion(true)
                return
            }
            let childUpdates: [String: Any?] = [
                "\(DBPathNames.userInfo.rawValue)/\(userID)": nil,
                "\(DBPathNames.businesses.rawValue)/\(locationID)": ServerValue.increment(-1)
            ]
            DBPaths.root.updateChildValues(childUpdates as [AnyHashable : Any]) { error, reference in
                if let error = error {
                    print("Data could not be saved: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func switchLocation(for userID: String, from oldLocationID: String, to newLocationID: String, completion: @escaping (Bool) -> Void) {
        let childUpdates: [String: Any] = [
            "\(DBPathNames.userInfo.rawValue)/\(userID)": newLocationID,
            "\(DBPathNames.businesses.rawValue)/\(oldLocationID)": ServerValue.increment(-1),
            "\(DBPathNames.businesses.rawValue)/\(newLocationID)": ServerValue.increment(1)
        ]
        DBPaths.root.updateChildValues(childUpdates) { error, reference in
            if let error = error {
                print("Data could not be saved: \(error)")
                completion(false)
            } else {
                completion(true)
            }
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
                DBPaths.profileInfo.child("\(userID)/photoURL").setValue(downloadURL) { (error, userRef) in
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
    
    func addNewLocations(locations: [Location]) {
        for location in locations {
            DBPaths.businesses.observeSingleEvent(of: .value) { snapshot in
                if !snapshot.hasChild(location.id) {
                    // if doesnt exist add it as child to businesses
                    DBPaths.businesses.child(location.id).setValue(0)
                }
            }
        }
    }
    
    // MARK: Observers
    
    func observePlayerCount(at locationID: String, completion: @escaping (Int?) -> Void)  {
        guard playerCountHandles[locationID] == nil else { return } // Return if already observing at that location
        let observerHandle = DBPaths.businesses.child(locationID).observe(.value) { snapshot in
            // Listen in realtime to whenever it updates
            guard let playerCount = snapshot.value as? Int else {
                print("Player count for location with ID \(locationID) unavailable")
                completion(nil)
                return
            }
            completion(playerCount)
        }
        playerCountHandles.updateValue(observerHandle, forKey: locationID)
    }
    
    func stopObservingPlayerCount(at locationID: String) {
        guard let handle: UInt = playerCountHandles.removeValue(forKey: locationID) else { return }
        DBPaths.businesses.child(locationID).removeObserver(withHandle: handle)
    }
    
    // MARK: - Temporary Refs
    
    static let userInfoRef = Database.database().reference().ref.child("userInfo")
    static let usersRef = Database.database().reference().ref.child("profileInfo")
    static let imagesRef = Storage.storage().reference(withPath: "images")
    static let chatRef = Database.database().reference().ref.child("teamChat")
    static let businessesRef = Database.database().reference().ref.child("businesses")
}
