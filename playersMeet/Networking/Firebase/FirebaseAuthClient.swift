//
//  FirebaseAuthManager.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthClient {
    
    private static let authObject = Auth.auth()
    private static var handle: AuthStateDidChangeListenerHandle?
    
    static func createUser(email: String, password: String) async throws {
        try await authObject.createUser(withEmail: email, password: password)
    }
    
    static func signIn(email: String, password: String, completion: @escaping (Result<User?, Error>) -> Void) {
        authObject.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user else {
                completion(.failure(AuthError.userNotFound))
                return
            }
            completion(.success(user))
        }
    }
    
    static func signOut() -> Void {
        do {
            try authObject.signOut()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func getUser() -> User? {
        return authObject.currentUser
    }
    
    static func getUserID() -> String {
        return authObject.currentUser!.uid
    }
    
    static func addLoginStateListener(currentUser: User?, completion: @escaping (_ isSignedIn: Bool) -> Void) {
        let newHandle = authObject.addStateDidChangeListener { auth, user in
            if currentUser != user {
                completion(false)
            }
            completion(true)
        }
        if newHandle.isEqual(handle) { removeLoginStateListener() }
        handle = newHandle
    }
    
    static func removeLoginStateListener() {
        guard let handle = handle else { return }
        authObject.removeStateDidChangeListener(handle)
    }
}
