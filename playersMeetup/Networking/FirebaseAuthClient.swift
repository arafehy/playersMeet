//
//  FirebaseAuthManager.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 10/27/21.
//  Copyright © 2021 Nada Zeini. All rights reserved.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthClient {
    private static let authObject = Auth.auth()
    
    static func createUser(email: String, password: String, completion: @escaping (Result<User?, Error>) -> Void) {
        authObject.createUser(withEmail: email, password: password){ (result, error) in
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
}
