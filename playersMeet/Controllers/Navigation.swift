//
//  Navigation.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/1/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation
import UIKit

struct Navigation {
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    static func goToSignUp(window: UIWindow?) {
        let loginVC = storyboard.instantiateViewController(identifier: "SignUpViewController")
        window?.rootViewController = loginVC
    }
    
    static func goToHome(window: UIWindow?) {
        let profileVC = storyboard.instantiateInitialViewController()
        window?.rootViewController = profileVC
    }
}
