//
//  UserLocationError.swift
//  playersMeet
//
//  Created by Yazan Arafeh on 11/24/21.
//  Copyright © 2021 Yazan Arafeh. All rights reserved.
//

import Foundation

enum UserLocationError: Error {
    case cannotBeLocated
    case userDenied
}
