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
    
    static func createUser(email: String, password: String, completion: @escaping (Result<User?, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(result?.user))
        }
    }
    
    static func signInUser(email: String, password: String, completion: @escaping (Result<User?, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(result?.user))
        }
    }
    
    static func getUserID() -> String {
        return Auth.auth().currentUser!.uid
    }
}
