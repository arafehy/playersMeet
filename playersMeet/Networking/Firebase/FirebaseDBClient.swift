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
    
    // MARK: - User
    
    func retrieveUserProfile(userID: String) async throws -> UserInfo {
        let (snapshot, _) = await DBPaths.profileInfo.child(userID).observeSingleEventAndPreviousSiblingKey(of: .value)
        let userInfo = try FirebaseDecoder().decode(UserInfo.self, from: snapshot.value as Any)
        return userInfo
    }
    
    func updateUserProfile(userID: String, userInfo: UserInfo) async throws {
        try await DBPaths.profileInfo.child(userID).updateChildValues(userInfo.asDictionary())
    }
    
    func getCurrentLocationID(userID: String) async -> String? {
        let (snapshot, _) = await DBPaths.userInfo.child(userID).observeSingleEventAndPreviousSiblingKey(of: .value)
        let locationID = snapshot.value as? String
        return locationID
    }
    
    func joinLocationWith(ID locationID: String, for userID: String) async throws -> String? {
        let currentLocationID = await getCurrentLocationID(userID: userID)
        guard currentLocationID != locationID else {
            // User is already at this location
            return currentLocationID
        }
        let childUpdates: [String: Any] = [
            "\(DBPathNames.userInfo.rawValue)/\(userID)": locationID,
            "\(DBPathNames.businesses.rawValue)/\(locationID)": ServerValue.increment(1)
        ]
        try await DBPaths.root.updateChildValues(childUpdates)
        return locationID
    }
    
    func leaveLocationWith(ID locationID: String, for userID: String) async throws -> String? {
        let currentLocationID = await getCurrentLocationID(userID: userID)
        guard currentLocationID == locationID else {
            // User is not at this location
            return currentLocationID
        }
        let childUpdates: [String: Any?] = [
            "\(DBPathNames.userInfo.rawValue)/\(userID)": nil,
            "\(DBPathNames.businesses.rawValue)/\(locationID)": ServerValue.increment(-1)
        ]
        try await DBPaths.root.updateChildValues(childUpdates as [AnyHashable : Any])
        return nil
    }
    
    func switchLocation(for userID: String, from oldLocationID: String, to newLocationID: String) async throws -> String? {
        let childUpdates: [String: Any] = [
            "\(DBPathNames.userInfo.rawValue)/\(userID)": newLocationID,
            "\(DBPathNames.businesses.rawValue)/\(oldLocationID)": ServerValue.increment(-1),
            "\(DBPathNames.businesses.rawValue)/\(newLocationID)": ServerValue.increment(1)
        ]
        try await DBPaths.root.updateChildValues(childUpdates)
        return newLocationID
    }
    
    // MARK: Profile Picture
    
    func uploadProfilePicture(userID: String, imageData: Data, imageType: ImageType) async throws -> String {
        let userStorageRef = StoragePaths.images.child(userID)
        try await uploadPhoto(reference: userStorageRef, imageData: imageData, imageType: imageType)
        let photoURL = try await userStorageRef.downloadURL().absoluteString
        try await DBPaths.profileInfo.child("\(userID)/photoURL").setValue(photoURL)
        return photoURL
    }
    
    private func uploadPhoto(reference: StorageReference, imageData: Data, imageType: ImageType) async throws {
        let metadata = StorageMetadata()
        metadata.contentType = "image/\(imageType.rawValue)"
        return try await withCheckedThrowingContinuation { continuation in
            reference.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard metadata != nil else {
                    continuation.resume(throwing: ImageError.invalidMetadata)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    func retrieveProfilePicture(userID: String) async throws -> UIImage {
        let maxImageSize: Int64 = 5 * 1024 * 1024
        return try await withCheckedThrowingContinuation { continuation in
            StoragePaths.images.child(userID).getData(maxSize: maxImageSize) { (data, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    continuation.resume(throwing: ImageError.invalidData)
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - Locations
    
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
    
    func sendMessage(_ message: String, from userID: String, to locationID: String) async throws {
        let userProfile = try await retrieveUserProfile(userID: userID)
        let message = ChatMessage(userID: userID, username: userProfile.username, text: message, createdAt: Date().timeIntervalSince1970, color: userProfile.color)
        try await sendMessage(message, to: locationID)
    }
    
    private func sendMessage(_ message: ChatMessage, to locationID: String) async throws {
        return try await withCheckedThrowingContinuation({ continuation in
            DBPaths.teamChat.child(locationID).childByAutoId().setValue(message.asDictionary()) { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        })
    }
}
