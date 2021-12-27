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
    
    private var playerCountHandles: [String: UInt] = [:]
    
    // MARK: - Database
    
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
    
    // MARK: - Storage
    
    enum StoragePaths {
        static let root = Storage.storage().reference()
        static let images = root.child(StoragePathNames.images.rawValue)
    }
    
    enum StoragePathNames: String {
        case images
    }
    
    enum ImageType: String {
        case png
    }
    
    // MARK: - Private Helpers
    
    private static func sendChildUpdates(_ childUpdates: [AnyHashable: Any?], to reference: DatabaseReference, _ completion: @escaping (Result<DatabaseReference, Error>) -> Void) {
        reference.updateChildValues(childUpdates as [AnyHashable: Any]) { error, reference in
            if let error = error {
                print("Data could not be saved: \(error)")
                completion(.failure(error))
            } else {
                completion(.success(reference))
            }
        }
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
        FirebaseDBClient.sendChildUpdates(profileAsDictionary, to: DBPaths.profileInfo.child(userID)) { result in
            switch result {
            case .success(_):
                completion(.success(userInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCurrentLocationID(userID: String, completion: @escaping (String?) -> Void) {
        DBPaths.userInfo.child(userID).observeSingleEvent(of: .value) { (snapshot) in
            let locationID = snapshot.value as? String
            completion(locationID)
        }
    }
    
    func joinLocationWith(ID locationID: String, for userID: String, completion: @escaping (Result<String?, Error>) -> Void) {
        getCurrentLocationID(userID: userID) { (currentLocationID) in
            guard currentLocationID != locationID else {
                // User is already at this location
                completion(.success(locationID))
                return
            }
            let childUpdates: [String: Any] = [
                "\(DBPathNames.userInfo.rawValue)/\(userID)": locationID,
                "\(DBPathNames.businesses.rawValue)/\(locationID)": ServerValue.increment(1)
            ]
            FirebaseDBClient.sendChildUpdates(childUpdates, to: DBPaths.root) { result in
                switch result {
                case .success(_):
                    completion(.success(locationID))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func leaveLocationWith(ID locationID: String, for userID: String, completion: @escaping (Result<String?, Error>) -> Void) {
        getCurrentLocationID(userID: userID) { (currentLocationID) in
            guard currentLocationID == locationID else {
                // User is not at this location
                completion(.success(currentLocationID))
                return
            }
            let childUpdates: [String: Any?] = [
                "\(DBPathNames.userInfo.rawValue)/\(userID)": nil,
                "\(DBPathNames.businesses.rawValue)/\(locationID)": ServerValue.increment(-1)
            ]
            FirebaseDBClient.sendChildUpdates(childUpdates, to: DBPaths.root) { result in
                switch result {
                case .success(_):
                    completion(.success(nil))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func switchLocation(for userID: String, from oldLocationID: String, to newLocationID: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let childUpdates: [String: Any] = [
            "\(DBPathNames.userInfo.rawValue)/\(userID)": newLocationID,
            "\(DBPathNames.businesses.rawValue)/\(oldLocationID)": ServerValue.increment(-1),
            "\(DBPathNames.businesses.rawValue)/\(newLocationID)": ServerValue.increment(1)
        ]
        FirebaseDBClient.sendChildUpdates(childUpdates, to: DBPaths.root) { result in
            switch result {
            case .success(_):
                completion(.success(newLocationID))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Profile Picture
    
    func uploadProfilePicture(userID: String, imageData: Data, imageType: ImageType, completion: @escaping (Result<String, Error>) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/\(imageType.rawValue)"
        
        StoragePaths.images.child(userID).putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard metadata != nil else {
                completion(.failure(ImageError.invalidMetadata))
                return
            }
            StoragePaths.images.child(userID).downloadURL { (url, error) in
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
        StoragePaths.images.child(userID).getData(maxSize: maxImageSize) { (data, error) in
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
    
    func observePlayerCount(at locationID: String, completion: @escaping (Int) -> Void)  {
        guard playerCountHandles[locationID] == nil else { return } // Return if already observing at that location
        let observerHandle = DBPaths.businesses.child(locationID).observe(.value) { snapshot in
            // Listen in realtime to whenever it updates
            let playerCount = (snapshot.value as? Int) ?? 0
            completion(playerCount)
        }
        playerCountHandles.updateValue(observerHandle, forKey: locationID)
    }
    
    func stopObservingPlayerCount(at locationID: String) {
        guard let handle: UInt = playerCountHandles.removeValue(forKey: locationID) else { return }
        DBPaths.businesses.child(locationID).removeObserver(withHandle: handle)
    }
    
    // MARK: Chat
    
    func retrieveMessages(at locationID: String, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        let messagesReference = FirebaseDBClient.DBPaths.teamChat.child(locationID)
        messagesReference.queryOrdered(byChild: "createdAt").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            do {
                let message = try FirebaseDecoder().decode(ChatMessage.self, from: value)
                completion(.success(message))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func sendMessage(_ message: String, from userID: String, to locationID: String, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        retrieveUserProfile(userID: userID) { [weak self] (result) in
            switch result {
            case .success(let userInfo):
                let message = ChatMessage(userID: userID, username: userInfo.username, text: message, createdAt: Date().timeIntervalSince1970, color: userInfo.color)
                self?.sendMessage(message, to: locationID, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func sendMessage(_ message: ChatMessage, to locationID: String, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        DBPaths.teamChat.child(locationID).childByAutoId().setValue(message.asDictionary()) { (error, reference) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(message))
            }
        }
    }
}
